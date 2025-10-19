#!/usr/bin/env bash
# Global quality check hook for Claude Code
# Triggers quality checks on file modifications across all projects

set -euo pipefail

# Log for debugging
LOG_FILE="$HOME/.claude/hooks/hook-execution.log"
mkdir -p "$(dirname "$LOG_FILE")"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Global quality check hook triggered" >> "$LOG_FILE"

# Read JSON input from stdin
JSON_INPUT=$(cat)
echo "Received input: $JSON_INPUT" >> "$LOG_FILE"

# Extract file path from JSON using multiple patterns
# First try direct file_path field
FILE_PATH=$(echo "$JSON_INPUT" | grep -o '"file_path":"[^"]*' | sed 's/"file_path":"//' | head -1 || true)

# Try Write tool format
if [ -z "$FILE_PATH" ]; then
    FILE_PATH=$(echo "$JSON_INPUT" | grep -o 'File created successfully at: [^"\\]*' | sed 's/File created successfully at: //' | head -1 || true)
fi

# Try Edit tool format: "The file /path/to/file has been updated"
if [ -z "$FILE_PATH" ]; then
    FILE_PATH=$(echo "$JSON_INPUT" | grep -o 'The file [^ ]* has been updated' | sed 's/The file //;s/ has been updated//' | head -1 || true)
fi

# Try MultiEdit tool format
if [ -z "$FILE_PATH" ]; then
    FILE_PATH=$(echo "$JSON_INPUT" | grep -o 'successfully updated [^"\\]*' | sed 's/successfully updated //' | head -1 || true)
fi

# Try to extract any absolute path from the result
if [ -z "$FILE_PATH" ]; then
    FILE_PATH=$(echo "$JSON_INPUT" | grep -o '/[^"\\]*\.\(rb\|js\|jsx\|ts\|tsx\|py\|go\|java\|php\|rs\|cpp\|c\|h\|hpp\)' | head -1 || true)
fi

echo "Extracted file path: '$FILE_PATH'" >> "$LOG_FILE"

# Skip if no file path found
if [ -z "$FILE_PATH" ]; then
    echo "No file path found in input" >> "$LOG_FILE"
    exit 0
fi

# Skip if disabled
if [ "${CLAUDE_HOOKS_DISABLED:-}" = "1" ]; then
    echo "Hooks disabled via environment variable" >> "$LOG_FILE"
    exit 0
fi

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "File does not exist: $FILE_PATH" >> "$LOG_FILE"
    exit 0
fi

# Determine project root (look for common project markers)
PROJECT_ROOT="$FILE_PATH"
while [ "$PROJECT_ROOT" != "/" ]; do
    PROJECT_ROOT=$(dirname "$PROJECT_ROOT")
    if [ -f "$PROJECT_ROOT/package.json" ] || [ -f "$PROJECT_ROOT/Gemfile" ] || [ -f "$PROJECT_ROOT/.git/config" ] || [ -f "$PROJECT_ROOT/go.mod" ] || [ -f "$PROJECT_ROOT/Cargo.toml" ]; then
        break
    fi
done

echo "Project root: $PROJECT_ROOT" >> "$LOG_FILE"

# Run quality checks based on file type
case "$FILE_PATH" in
    *.rb|*.rake)
        echo "🔍 Running Ruby quality checks on $FILE_PATH..." | tee -a "$LOG_FILE"
        
        # Check syntax first
        if ! ruby -c "$FILE_PATH" 2>&1 | tee -a "$LOG_FILE"; then
            echo "❌ Ruby syntax errors found!" | tee -a "$LOG_FILE"
            echo "💡 Fix syntax errors before continuing" | tee -a "$LOG_FILE"
            exit 1
        fi
        
        # Run Rubocop if available
        if command -v rubocop >/dev/null 2>&1; then
            echo "Running Rubocop..." | tee -a "$LOG_FILE"
            rubocop --format simple "$FILE_PATH" 2>&1 | tee -a "$LOG_FILE" || {
                echo "💡 Rubocop issues found. You can auto-fix with: rubocop -A $FILE_PATH" | tee -a "$LOG_FILE"
            }
        fi
        
        # Run Brakeman for security if it's a Rails project
        if [ -f "$PROJECT_ROOT/Gemfile" ] && grep -q "rails" "$PROJECT_ROOT/Gemfile" 2>/dev/null; then
            if command -v brakeman >/dev/null 2>&1; then
                echo "Running Brakeman security scan..." | tee -a "$LOG_FILE"
                cd "$PROJECT_ROOT" && brakeman --no-pager --file "$FILE_PATH" 2>&1 | tee -a "$LOG_FILE" || true
            fi
        fi
        ;;
        
    *.js|*.jsx|*.ts|*.tsx)
        echo "🔍 Running JavaScript/TypeScript quality checks on $FILE_PATH..." | tee -a "$LOG_FILE"
        
        # Run ESLint if available
        if command -v eslint >/dev/null 2>&1; then
            echo "Running ESLint..." | tee -a "$LOG_FILE"
            eslint "$FILE_PATH" 2>&1 | tee -a "$LOG_FILE" || {
                echo "💡 ESLint issues found. You can auto-fix with: eslint --fix $FILE_PATH" | tee -a "$LOG_FILE"
            }
        elif [ -f "$PROJECT_ROOT/node_modules/.bin/eslint" ]; then
            echo "Running project ESLint..." | tee -a "$LOG_FILE"
            "$PROJECT_ROOT/node_modules/.bin/eslint" "$FILE_PATH" 2>&1 | tee -a "$LOG_FILE" || {
                echo "💡 ESLint issues found. You can auto-fix with: npx eslint --fix $FILE_PATH" | tee -a "$LOG_FILE"
            }
        fi
        
        # Run TypeScript compiler check for .ts/.tsx files
        if [[ "$FILE_PATH" =~ \.(ts|tsx)$ ]]; then
            if command -v tsc >/dev/null 2>&1; then
                echo "Running TypeScript check..." | tee -a "$LOG_FILE"
                tsc --noEmit --skipLibCheck "$FILE_PATH" 2>&1 | tee -a "$LOG_FILE" || true
            elif [ -f "$PROJECT_ROOT/node_modules/.bin/tsc" ]; then
                echo "Running project TypeScript check..." | tee -a "$LOG_FILE"
                "$PROJECT_ROOT/node_modules/.bin/tsc" --noEmit --skipLibCheck "$FILE_PATH" 2>&1 | tee -a "$LOG_FILE" || true
            fi
        fi
        ;;
        
    *.py)
        echo "🔍 Running Python quality checks on $FILE_PATH..." | tee -a "$LOG_FILE"
        
        # Check syntax
        if ! python3 -m py_compile "$FILE_PATH" 2>&1 | tee -a "$LOG_FILE"; then
            echo "❌ Python syntax errors found!" | tee -a "$LOG_FILE"
            exit 1
        fi
        
        # Run flake8 if available
        if command -v flake8 >/dev/null 2>&1; then
            echo "Running flake8..." | tee -a "$LOG_FILE"
            flake8 "$FILE_PATH" 2>&1 | tee -a "$LOG_FILE" || {
                echo "💡 Flake8 issues found" | tee -a "$LOG_FILE"
            }
        fi
        
        # Run black if available
        if command -v black >/dev/null 2>&1; then
            echo "Running black formatter check..." | tee -a "$LOG_FILE"
            black --check "$FILE_PATH" 2>&1 | tee -a "$LOG_FILE" || {
                echo "💡 Formatting issues found. You can auto-fix with: black $FILE_PATH" | tee -a "$LOG_FILE"
            }
        fi
        ;;
        
    *.go)
        echo "🔍 Running Go quality checks on $FILE_PATH..." | tee -a "$LOG_FILE"
        
        # Run gofmt
        if command -v gofmt >/dev/null 2>&1; then
            echo "Running gofmt..." | tee -a "$LOG_FILE"
            gofmt -l "$FILE_PATH" 2>&1 | tee -a "$LOG_FILE" | grep . && {
                echo "💡 Formatting issues found. You can auto-fix with: gofmt -w $FILE_PATH" | tee -a "$LOG_FILE"
            }
        fi
        
        # Run go vet
        if command -v go >/dev/null 2>&1; then
            echo "Running go vet..." | tee -a "$LOG_FILE"
            cd "$(dirname "$FILE_PATH")" && go vet "$FILE_PATH" 2>&1 | tee -a "$LOG_FILE" || true
        fi
        ;;
        
    *)
        echo "File type not configured for quality checks: $FILE_PATH" >> "$LOG_FILE"
        ;;
esac

# Check for common security issues in any file type
echo "🔐 Checking for security issues..." | tee -a "$LOG_FILE"

# Check for hardcoded secrets
if grep -E '(password|secret|token|api_key|apikey|access_key|private_key)\s*=\s*["\x27][^"\x27]+["\x27]' "$FILE_PATH" 2>/dev/null; then
    echo "⚠️  WARNING: Possible hardcoded secrets detected in $FILE_PATH" | tee -a "$LOG_FILE"
fi

# Check for SQL injection vulnerabilities in common patterns
if grep -E '(SELECT|INSERT|UPDATE|DELETE|DROP).*\$\{|"+.*\+.*"' "$FILE_PATH" 2>/dev/null; then
    echo "⚠️  WARNING: Possible SQL injection vulnerability detected in $FILE_PATH" | tee -a "$LOG_FILE"
fi

echo "Hook execution completed for $FILE_PATH" >> "$LOG_FILE"
echo "---" >> "$LOG_FILE"
