#!/usr/bin/env bash
# Global Claude Code hook - runs quality checks after file write
set -euo pipefail

# Get the file that was just written
FILE="${1:-}"
if [ -z "$FILE" ]; then
  echo "No file specified"
  exit 0
fi

# Skip if disabled
if [ "${CLAUDE_HOOKS_DISABLED:-}" = "1" ]; then
  exit 0
fi

# Use quality-simple for individual files (more reliable)
if command -v quality-simple >/dev/null 2>&1; then
  QUALITY_CMD="quality-simple check"
elif command -v quality >/dev/null 2>&1; then
  QUALITY_CMD="quality check"
else
  exit 0
fi

# Convert to absolute path if needed
if [[ ! "$FILE" = /* ]]; then
  FILE="$(pwd)/$FILE"
fi

# Detect if this is a code file we should check
case "$FILE" in
  *.rb|*.rake)
    echo "🔍 Running Ruby quality checks on $FILE..."
    $QUALITY_CMD "$FILE" || {
      echo "💡 Issues found. You can fix with: quality fix $FILE"
    }
    ;;
    
  *.js|*.jsx|*.ts|*.tsx|*.mjs)
    echo "🔍 Running JavaScript/TypeScript quality checks on $FILE..."
    $QUALITY_CMD "$FILE" || {
      echo "💡 Issues found. You can fix with: quality fix $FILE"
    }
    ;;
    
  *.py|*.pyw)
    echo "🔍 Running Python quality checks on $FILE..."
    $QUALITY_CMD "$FILE" || {
      echo "💡 Issues found. You can fix with: quality fix $FILE"
    }
    ;;
    
  *.go)
    echo "🔍 Running Go quality checks on $FILE..."
    $QUALITY_CMD "$FILE" || {
      echo "💡 Issues found. You can fix with: quality fix $FILE"
    }
    ;;
    
  *.yml|*.yaml)
    echo "🔍 Checking YAML syntax..."
    if command -v yamllint &> /dev/null; then
      yamllint "$FILE" || true
    fi
    ;;
    
  *Dockerfile*)
    echo "🔍 Checking Dockerfile..."
    if command -v hadolint &> /dev/null; then
      hadolint "$FILE" || true
    fi
    ;;
    
  *.md)
    # Skip markdown files - no checks needed
    ;;
    
  *)
    # Skip other file types
    ;;
esac