#!/bin/bash
# Generate a git branch name from a GitHub issue
# Usage: ./generate_branch_name.sh <issue_number> <issue_title>

set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 <issue_number> <issue_title>" >&2
    exit 1
fi

ISSUE_NUMBER="$1"
shift
ISSUE_TITLE="$*"

# Convert title to lowercase, replace spaces/special chars with hyphens, limit length
BRANCH_NAME=$(echo "bug-${ISSUE_NUMBER}-${ISSUE_TITLE}" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[^a-z0-9-]/-/g' \
    | sed 's/--*/-/g' \
    | sed 's/^-//' \
    | sed 's/-$//' \
    | cut -c1-80)

echo "$BRANCH_NAME"
