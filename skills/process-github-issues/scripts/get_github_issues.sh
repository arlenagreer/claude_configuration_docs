#!/bin/bash
# Get open bug reports from GitHub Issues for the current repository
# Requires: gh CLI tool installed and authenticated
# Usage: ./get_github_issues.sh

set -e

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed. Install it from https://cli.github.com/" >&2
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository" >&2
    exit 1
fi

# Get repository information
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
if [ -z "$REPO" ]; then
    echo "Error: Could not determine repository. Make sure you're in a GitHub repository." >&2
    exit 1
fi

# Fetch open bug issues, sorted by creation date (oldest first)
# Output format: issue_number|title
gh issue list \
    --repo "$REPO" \
    --label "bug" \
    --state open \
    --json number,title \
    --jq '.[] | "\(.number)|\(.title)"' \
    | sort -t'|' -k1 -n

exit 0
