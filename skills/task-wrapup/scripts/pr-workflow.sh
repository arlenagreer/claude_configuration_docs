#!/usr/bin/env bash
#
# Pull Request Creation Workflow Script
# Creates pull requests via GitHub CLI with comprehensive error handling
#
# Exit Codes:
#   0  - Success: PR created or already exists
#  10  - gh CLI not installed
#  11  - Not authenticated with GitHub
#  12  - Uncommitted changes detected
#  13  - No commits to push
#  20  - Push to remote failed
#  30  - PR creation failed
#
# Usage:
#   pr-workflow.sh PARENT_BRANCH [FEATURE_BRANCH] [PR_TITLE] [PR_BODY] [DRAFT]
#

set -e

# Colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

# Script arguments with defaults
readonly PARENT_BRANCH="${1:-develop}"
readonly FEATURE_BRANCH="${2:-$(git branch --show-current 2>/dev/null || echo "")}"
readonly PR_TITLE="${3:-}"
readonly PR_BODY="${4:-}"
readonly DRAFT="${5:-false}"

# Exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_GH_NOT_INSTALLED=10
readonly EXIT_NOT_AUTHENTICATED=11
readonly EXIT_UNCOMMITTED_CHANGES=12
readonly EXIT_NO_COMMITS=13
readonly EXIT_PUSH_FAILED=20
readonly EXIT_PR_FAILED=30

# Timeout for push/PR operations (60 seconds)
readonly TIMEOUT=60

#
# Helper Functions
#

# Print colored message
print_message() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

# Print error and exit with code
error_exit() {
    local message="$1"
    local exit_code="$2"
    print_message "$RED" "❌ Error: $message"
    exit "$exit_code"
}

# Print warning
warn() {
    local message="$1"
    print_message "$YELLOW" "⚠️  Warning: $message"
}

# Print info
info() {
    local message="$1"
    print_message "$BLUE" "ℹ️  $message"
}

# Print success
success() {
    local message="$1"
    print_message "$GREEN" "✅ $message"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

#
# Prerequisite Checks
#

check_gh_cli_installed() {
    info "Checking for GitHub CLI (gh)..."

    if ! command_exists gh; then
        error_exit "GitHub CLI (gh) is not installed. Install with: brew install gh" "$EXIT_GH_NOT_INSTALLED"
    fi

    success "GitHub CLI is installed"
}

check_gh_authentication() {
    info "Checking GitHub authentication..."

    if ! gh auth status >/dev/null 2>&1; then
        error_exit "Not authenticated with GitHub. Run: gh auth login" "$EXIT_NOT_AUTHENTICATED"
    fi

    success "Authenticated with GitHub"
}

check_uncommitted_changes() {
    info "Checking for uncommitted changes..."

    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        error_exit "Uncommitted changes detected. Please commit all changes before creating PR." "$EXIT_UNCOMMITTED_CHANGES"
    fi

    success "No uncommitted changes"
}

check_commits_to_push() {
    info "Checking for commits to push..."

    # Get current branch
    local current_branch="$FEATURE_BRANCH"

    # Check if remote branch exists
    if git ls-remote --heads origin "$current_branch" | grep -q "$current_branch"; then
        # Remote branch exists, check for new commits
        local commits_ahead=$(git rev-list --count "origin/${current_branch}..HEAD" 2>/dev/null || echo "0")

        if [ "$commits_ahead" -eq 0 ]; then
            warn "No new commits to push (branch is up to date with remote)"
            # Not an error - PR may already exist, continue
        else
            success "$commits_ahead commit(s) ready to push"
        fi
    else
        # Remote branch doesn't exist yet, check for any commits
        local total_commits=$(git rev-list --count "$PARENT_BRANCH..HEAD" 2>/dev/null || echo "0")

        if [ "$total_commits" -eq 0 ]; then
            error_exit "No commits to push. The feature branch has no commits compared to $PARENT_BRANCH." "$EXIT_NO_COMMITS"
        fi

        success "$total_commits commit(s) ready to push (new branch)"
    fi
}

#
# Core Workflow Functions
#

push_to_remote() {
    info "Pushing $FEATURE_BRANCH to origin..."

    # Use timeout to prevent hanging on network issues
    if timeout "$TIMEOUT" git push -u origin "$FEATURE_BRANCH" 2>&1; then
        success "Pushed $FEATURE_BRANCH to origin"
        return 0
    else
        local exit_code=$?

        # Check if timeout occurred (exit code 124)
        if [ "$exit_code" -eq 124 ]; then
            error_exit "Push timed out after ${TIMEOUT}s. Check your network connection." "$EXIT_PUSH_FAILED"
        else
            error_exit "Failed to push branch to remote. Check your network connection and permissions." "$EXIT_PUSH_FAILED"
        fi
    fi
}

create_pull_request() {
    info "Creating pull request..."

    # Build gh pr create command
    local gh_cmd="gh pr create --base \"$PARENT_BRANCH\""

    # Add title if provided
    if [ -n "$PR_TITLE" ]; then
        gh_cmd="$gh_cmd --title \"$PR_TITLE\""
    fi

    # Add body if provided
    if [ -n "$PR_BODY" ]; then
        gh_cmd="$gh_cmd --body \"$PR_BODY\""
    fi

    # Add draft flag if requested
    if [ "$DRAFT" = "true" ]; then
        gh_cmd="$gh_cmd --draft"
    fi

    # Execute PR creation with timeout
    local pr_output
    local pr_exit_code

    if pr_output=$(timeout "$TIMEOUT" eval "$gh_cmd" 2>&1); then
        pr_exit_code=0
    else
        pr_exit_code=$?
    fi

    # Check for timeout
    if [ "$pr_exit_code" -eq 124 ]; then
        error_exit "PR creation timed out after ${TIMEOUT}s. Check your network connection." "$EXIT_PR_FAILED"
    fi

    # Check for "already exists" message (not an error)
    if echo "$pr_output" | grep -q "already exists"; then
        warn "Pull request already exists for this branch"

        # Extract PR URL from output or find it manually
        local pr_url=$(gh pr list --head "$FEATURE_BRANCH" --json url --jq '.[0].url' 2>/dev/null || echo "")

        if [ -n "$pr_url" ]; then
            info "Existing PR: $pr_url"
        fi

        return 0
    fi

    # Check for other errors
    if [ "$pr_exit_code" -ne 0 ]; then
        error_exit "Failed to create PR: $pr_output" "$EXIT_PR_FAILED"
    fi

    # Success
    success "Pull request created successfully"

    # Extract and display PR URL
    local pr_url=$(echo "$pr_output" | grep -o 'https://github.com[^ ]*' | head -1)
    if [ -n "$pr_url" ]; then
        info "PR URL: $pr_url"
    fi

    return 0
}

#
# Main Workflow
#

main() {
    print_message "$BLUE" "═══════════════════════════════════════════"
    print_message "$BLUE" "  Pull Request Creation Workflow"
    print_message "$BLUE" "═══════════════════════════════════════════"
    echo

    # Display configuration
    info "Configuration:"
    echo "   Parent Branch:  $PARENT_BRANCH"
    echo "   Feature Branch: $FEATURE_BRANCH"
    echo "   Draft PR:       $DRAFT"
    if [ -n "$PR_TITLE" ]; then
        echo "   PR Title:       $PR_TITLE"
    fi
    echo

    # Run prerequisite checks
    print_message "$BLUE" "Running prerequisite checks..."
    echo

    check_gh_cli_installed
    check_gh_authentication
    check_uncommitted_changes
    check_commits_to_push

    echo

    # Push to remote
    push_to_remote

    echo

    # Create pull request
    create_pull_request

    echo
    print_message "$GREEN" "═══════════════════════════════════════════"
    print_message "$GREEN" "  Pull Request Workflow Complete"
    print_message "$GREEN" "═══════════════════════════════════════════"

    exit "$EXIT_SUCCESS"
}

# Validate required arguments
if [ -z "$FEATURE_BRANCH" ]; then
    error_exit "Could not determine feature branch. Please provide as second argument." 1
fi

# Run main workflow
main
