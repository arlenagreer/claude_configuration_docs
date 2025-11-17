#!/usr/bin/env bash
#
# Preflight checks for task-start skill
# Validates git status, working directory, and branch state
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BASE_BRANCH="${BASE_BRANCH:-development}"
PROTECTED_BRANCHES="${PROTECTED_BRANCHES:-main master production}"

# Exit codes
EXIT_SUCCESS=0
EXIT_PROTECTED_BRANCH=1
EXIT_UNCOMMITTED_CHANGES=2
EXIT_STASHED_WORK=3
EXIT_NOT_GIT_REPO=4

echo "🔍 Running preflight checks..."
echo

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}❌ Not a git repository${NC}"
    exit $EXIT_NOT_GIT_REPO
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 Current branch: $CURRENT_BRANCH"

# Check if on protected branch
for protected in $PROTECTED_BRANCHES; do
    if [ "$CURRENT_BRANCH" = "$protected" ]; then
        echo -e "${RED}❌ Cannot start new task from protected branch: $protected${NC}"
        echo -e "   New tasks must be started from $BASE_BRANCH branch"
        exit $EXIT_PROTECTED_BRANCH
    fi
done
echo -e "${GREEN}✅ Not on protected branch${NC}"

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo -e "${YELLOW}⚠️  Uncommitted changes detected:${NC}"
    git status --short
    echo
    echo "Please commit or stash changes before starting new task"
    exit $EXIT_UNCOMMITTED_CHANGES
fi
echo -e "${GREEN}✅ No uncommitted changes${NC}"

# Check for stashed work
STASH_COUNT=$(git stash list | wc -l | tr -d ' ')
if [ "$STASH_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  $STASH_COUNT stashed change(s) detected:${NC}"
    git stash list | head -3
    echo
    echo "Consider applying or clearing stashes before starting new task"
    exit $EXIT_STASHED_WORK
fi
echo -e "${GREEN}✅ No stashed work${NC}"

# Check if on base branch
if [ "$CURRENT_BRANCH" != "$BASE_BRANCH" ]; then
    echo -e "${YELLOW}⚠️  Not on base branch ($BASE_BRANCH)${NC}"
    echo "   Will switch to $BASE_BRANCH before creating new branch"
else
    echo -e "${GREEN}✅ On base branch ($BASE_BRANCH)${NC}"
fi

echo
echo -e "${GREEN}✅ All preflight checks passed${NC}"
exit $EXIT_SUCCESS
