#!/usr/bin/env bash
#
# Environment health checks for task-start skill
# Validates Docker, database, dependencies, and environment variables
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration from environment or defaults
DOCKER_ENABLED="${DOCKER_ENABLED:-true}"
DOCKER_AUTO_START="${DOCKER_AUTO_START:-true}"
DOCKER_HEALTH_URL="${DOCKER_HEALTH_URL:-http://localhost:3000/health}"
CHECK_MIGRATIONS="${CHECK_MIGRATIONS:-true}"
AUTO_MIGRATE="${AUTO_MIGRATE:-true}"
CHECK_DEPS="${CHECK_DEPS:-true}"

# Exit codes
EXIT_SUCCESS=0
EXIT_DOCKER_NOT_RUNNING=10
EXIT_DB_NOT_READY=11
EXIT_MIGRATIONS_PENDING=12
EXIT_DEPS_OUTDATED=13
EXIT_ENV_MISSING=14

echo "🏥 Running environment health checks..."
echo

# Function to check Docker status
check_docker() {
    if [ "$DOCKER_ENABLED" != "true" ]; then
        echo "⏭️  Docker checks skipped (not enabled)"
        return 0
    fi

    echo "🐳 Checking Docker status..."

    if ! command -v docker-compose &> /dev/null && ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}⚠️  Docker not found (skipping Docker checks)${NC}"
        return 0
    fi

    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Docker daemon not running${NC}"
        return $EXIT_DOCKER_NOT_RUNNING
    fi

    # Check if containers are running
    if command -v docker-compose &> /dev/null; then
        RUNNING_CONTAINERS=$(docker-compose ps --services --filter "status=running" 2>/dev/null | wc -l | tr -d ' ')
    else
        RUNNING_CONTAINERS=$(docker ps --format '{{.Names}}' | wc -l | tr -d ' ')
    fi

    if [ "$RUNNING_CONTAINERS" -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No Docker containers running${NC}"

        if [ "$DOCKER_AUTO_START" = "true" ]; then
            echo -e "${BLUE}🔄 Attempting to start Docker services...${NC}"
            if command -v docker-compose &> /dev/null; then
                docker-compose up -d
            else
                echo -e "${YELLOW}⚠️  docker-compose not found, cannot auto-start${NC}"
                return $EXIT_DOCKER_NOT_RUNNING
            fi

            # Wait a bit for services to start
            echo "⏳ Waiting for services to start..."
            sleep 5

            # Re-check
            if command -v docker-compose &> /dev/null; then
                RUNNING_CONTAINERS=$(docker-compose ps --services --filter "status=running" 2>/dev/null | wc -l | tr -d ' ')
            fi

            if [ "$RUNNING_CONTAINERS" -eq 0 ]; then
                echo -e "${RED}❌ Failed to start Docker services${NC}"
                return $EXIT_DOCKER_NOT_RUNNING
            fi
            echo -e "${GREEN}✅ Docker services started${NC}"
        else
            echo "   Auto-start disabled. Please start Docker manually:"
            echo "   docker-compose up -d"
            return $EXIT_DOCKER_NOT_RUNNING
        fi
    else
        echo -e "${GREEN}✅ Docker containers running: $RUNNING_CONTAINERS${NC}"
    fi

    # Check health endpoint if specified
    if [ -n "$DOCKER_HEALTH_URL" ]; then
        echo "🔍 Checking health endpoint: $DOCKER_HEALTH_URL"
        if curl -sf "$DOCKER_HEALTH_URL" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Health check passed${NC}"
        else
            echo -e "${YELLOW}⚠️  Health check failed (services may still be starting)${NC}"
        fi
    fi

    return 0
}

# Function to check database migrations
check_database() {
    if [ "$CHECK_MIGRATIONS" != "true" ]; then
        echo "⏭️  Database checks skipped"
        return 0
    fi

    echo
    echo "🗄️  Checking database migrations..."

    # Try Rails migrations check
    if [ -f "bin/rails" ] || [ -f "Gemfile" ]; then
        echo "📋 Checking Rails migrations..."

        # Check for pending migrations
        if command -v docker-compose &> /dev/null; then
            PENDING=$(docker-compose exec -T backend rails db:migrate:status 2>/dev/null | grep -c "^\s*down" || true)
        else
            PENDING=$(rails db:migrate:status 2>/dev/null | grep -c "^\s*down" || true)
        fi

        if [ "$PENDING" -gt 0 ]; then
            echo -e "${YELLOW}⚠️  $PENDING pending migration(s) detected${NC}"

            if [ "$AUTO_MIGRATE" = "true" ]; then
                echo -e "${BLUE}🔄 Running migrations...${NC}"
                if command -v docker-compose &> /dev/null; then
                    docker-compose exec -T backend rails db:migrate
                else
                    rails db:migrate
                fi
                echo -e "${GREEN}✅ Migrations complete${NC}"
            else
                echo "   Auto-migrate disabled. Please run:"
                echo "   docker-compose exec backend rails db:migrate"
                return $EXIT_MIGRATIONS_PENDING
            fi
        else
            echo -e "${GREEN}✅ No pending migrations${NC}"
        fi
    else
        echo "⏭️  No Rails detected, skipping migration check"
    fi

    return 0
}

# Function to check dependencies
check_dependencies() {
    if [ "$CHECK_DEPS" != "true" ]; then
        echo "⏭️  Dependency checks skipped"
        return 0
    fi

    echo
    echo "📦 Checking dependencies..."

    # Check npm/yarn
    if [ -f "package.json" ]; then
        echo "🔍 Checking npm/yarn packages..."
        if command -v npm &> /dev/null; then
            OUTDATED=$(npm outdated 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
            if [ "$OUTDATED" -gt 0 ]; then
                echo -e "${YELLOW}⚠️  $OUTDATED outdated npm package(s)${NC}"
                echo "   Run 'npm outdated' to see details"
            else
                echo -e "${GREEN}✅ npm packages up to date${NC}"
            fi
        fi
    fi

    # Check bundler
    if [ -f "Gemfile" ]; then
        echo "🔍 Checking Ruby gems..."
        if command -v bundle &> /dev/null; then
            if bundle check &> /dev/null; then
                echo -e "${GREEN}✅ Ruby gems satisfied${NC}"
            else
                echo -e "${YELLOW}⚠️  Missing or outdated gems${NC}"
                echo "   Run 'bundle install' or 'docker-compose exec backend bundle install'"
            fi
        fi
    fi

    return 0
}

# Function to check environment variables
check_environment() {
    echo
    echo "🔐 Checking environment variables..."

    # Check for .env files
    if [ -f ".env" ]; then
        echo -e "${GREEN}✅ .env file found${NC}"
    else
        echo -e "${YELLOW}⚠️  .env file not found${NC}"
    fi

    if [ -f ".env.development" ]; then
        echo -e "${GREEN}✅ .env.development file found${NC}"
    else
        echo -e "${YELLOW}⚠️  .env.development file not found (may be optional)${NC}"
    fi

    # Check critical environment variables (if .env exists)
    if [ -f ".env" ]; then
        CRITICAL_VARS="${CRITICAL_VARS:-DATABASE_URL SECRET_KEY_BASE}"
        MISSING_VARS=()

        for var in $CRITICAL_VARS; do
            if ! grep -q "^${var}=" .env 2>/dev/null; then
                MISSING_VARS+=("$var")
            fi
        done

        if [ ${#MISSING_VARS[@]} -gt 0 ]; then
            echo -e "${YELLOW}⚠️  Missing critical environment variables:${NC}"
            for var in "${MISSING_VARS[@]}"; do
                echo "   - $var"
            done
        else
            echo -e "${GREEN}✅ Critical environment variables present${NC}"
        fi
    fi

    return 0
}

# Run all checks
FAILED=0

check_docker || FAILED=$?
check_database || FAILED=$?
check_dependencies || FAILED=$?
check_environment || FAILED=$?

echo
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All environment health checks passed${NC}"
else
    echo -e "${YELLOW}⚠️  Some health checks failed (code: $FAILED)${NC}"
    echo "   Fix issues above or continue with caution"
fi

exit $FAILED
