#!/usr/bin/env bash
#
# Branch creation script for task-startup skill
# Creates properly named feature branches from task names
#

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
BRANCH_PREFIX="${BRANCH_PREFIX:-feature}"
MAX_LENGTH="${MAX_LENGTH:-50}"
BASE_BRANCH="${BASE_BRANCH:-development}"

# Function to sanitize branch name
sanitize_name() {
    local name="$1"

    # Convert to lowercase
    name=$(echo "$name" | tr '[:upper:]' '[:lower:]')

    # Replace spaces and special chars with hyphens
    name=$(echo "$name" | sed 's/[^a-z0-9-]/-/g')

    # Remove multiple consecutive hyphens
    name=$(echo "$name" | sed 's/-\+/-/g')

    # Remove leading/trailing hyphens
    name=$(echo "$name" | sed 's/^-//;s/-$//')

    # Truncate to max length
    if [ ${#name} -gt $MAX_LENGTH ]; then
        name="${name:0:$MAX_LENGTH}"
        # Remove trailing hyphen if truncation created one
        name=$(echo "$name" | sed 's/-$//')
    fi

    echo "$name"
}

# Function to create branch name
create_branch_name() {
    local task_name="$1"

    local sanitized_name=$(sanitize_name "$task_name")
    echo "${BRANCH_PREFIX}/${sanitized_name}"
}

# Function to switch to base branch
switch_to_base() {
    local current_branch=$(git branch --show-current)

    if [ "$current_branch" != "$BASE_BRANCH" ]; then
        echo -e "${BLUE}🔄 Switching to base branch: $BASE_BRANCH${NC}"
        git checkout "$BASE_BRANCH"
    fi
}

# Function to create and checkout new branch
create_and_checkout() {
    local branch_name="$1"

    echo -e "${BLUE}🌿 Creating branch: $branch_name${NC}"

    # Create and checkout new branch
    git checkout -b "$branch_name"

    echo -e "${GREEN}✅ Branch created and checked out: $branch_name${NC}"
    echo
    echo "Current branch: $(git branch --show-current)"
}

# Function to create session state file
create_session_state() {
    local feature_branch="$1"
    local parent_branch="$2"
    local task_name="$3"
    local project_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    local state_file="${project_root}/.task_session_state.json"

    echo -e "${BLUE}📝 Creating session state...${NC}"

    # Generate ISO 8601 UTC timestamp
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Build JSON
    cat > "$state_file" <<EOF
{
  "schema_version": "1.0",
  "created_at": "$timestamp",
  "feature_branch": "$feature_branch",
  "parent_branch": "$parent_branch",
  "task_name": "$task_name"
}
EOF

    if [ -f "$state_file" ]; then
        echo -e "${GREEN}✅ Session state created: $state_file${NC}"
    else
        echo -e "${YELLOW}⚠️  Warning: Failed to create session state${NC}"
    fi
}

# Main script
if [ $# -lt 1 ]; then
    echo "Usage: $0 <task-name>"
    echo
    echo "Examples:"
    echo "  $0 'user-auth'"
    echo "  $0 'payment-api'"
    echo "  $0 'fix-login'"
    exit 1
fi

TASK_NAME="$1"

# Generate branch name
BRANCH_NAME=$(create_branch_name "$TASK_NAME")

echo "📋 Branch Configuration:"
echo "   Task Name: $TASK_NAME"
echo "   Branch Name: $BRANCH_NAME"
echo

# Capture parent branch before switching
PARENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "$BASE_BRANCH")

# Switch to base branch if needed
switch_to_base

# Create and checkout new branch
create_and_checkout "$BRANCH_NAME"

# Create session state file for PR automation
create_session_state "$BRANCH_NAME" "$PARENT_BRANCH" "$TASK_NAME"
