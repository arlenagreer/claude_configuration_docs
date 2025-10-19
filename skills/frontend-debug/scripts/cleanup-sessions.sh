#!/bin/bash

# Frontend Debug Session Cleanup Script
# Cleans up old debugging session files and temporary browser data

set -e

SKILL_DIR="$HOME/.claude/skills/frontend-debug"
TEMP_DIR="/tmp"
SESSION_RETENTION_HOURS=24
ARCHIVE_RETENTION_DAYS=7

echo "🧹 Frontend Debug Session Cleanup"
echo "=================================="
echo ""

# Function to calculate file age in hours
file_age_hours() {
    local file=$1
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        local current_time=$(date +%s)
        local file_time=$(stat -f %m "$file")
    else
        # Linux
        local current_time=$(date +%s)
        local file_time=$(stat -c %Y "$file")
    fi
    echo $(( ($current_time - $file_time) / 3600 ))
}

# Function to calculate file age in days
file_age_days() {
    local hours=$(file_age_hours "$1")
    echo $(( $hours / 24 ))
}

# Clean up session state files
echo "1. Cleaning up session state files..."
STATE_FILES=$(find "$SKILL_DIR" -name ".debug-session-*.json" 2>/dev/null || true)
STATE_COUNT=0
CLEANED_STATE=0

for file in $STATE_FILES; do
    STATE_COUNT=$((STATE_COUNT + 1))
    age_hours=$(file_age_hours "$file")

    # Check if session is completed or crashed and older than retention period
    status=$(jq -r '.status' "$file" 2>/dev/null || echo "unknown")

    if [[ "$status" == "completed" || "$status" == "crashed" ]] && [ $age_hours -gt $SESSION_RETENTION_HOURS ]; then
        echo "   ✓ Removing session file (${age_hours}h old, status: $status): $(basename $file)"
        rm "$file"
        CLEANED_STATE=$((CLEANED_STATE + 1))
    elif [[ "$status" == "active" ]]; then
        echo "   ⚠ Active session found (${age_hours}h old): $(basename $file)"
        echo "     Consider resuming or manually cleaning up if abandoned"
    fi
done

echo "   Found $STATE_COUNT session files, cleaned up $CLEANED_STATE"
echo ""

# Clean up temporary browser data directories
echo "2. Cleaning up temporary browser data..."
BROWSER_DIRS=$(find "$TEMP_DIR" -maxdepth 1 -name "claude-debug-*" -type d 2>/dev/null || true)
BROWSER_COUNT=0
CLEANED_BROWSER=0

for dir in $BROWSER_DIRS; do
    BROWSER_COUNT=$((BROWSER_COUNT + 1))
    age_hours=$(file_age_hours "$dir")

    if [ $age_hours -gt $SESSION_RETENTION_HOURS ]; then
        echo "   ✓ Removing browser data (${age_hours}h old): $(basename $dir)"
        rm -rf "$dir"
        CLEANED_BROWSER=$((CLEANED_BROWSER + 1))
    fi
done

echo "   Found $BROWSER_COUNT browser data directories, cleaned up $CLEANED_BROWSER"
echo ""

# Clean up old investigation reports
echo "3. Cleaning up old investigation reports..."
REPORT_DIR="$SKILL_DIR/investigation-reports"
if [ -d "$REPORT_DIR" ]; then
    REPORT_FILES=$(find "$REPORT_DIR" -name "*.md" -type f 2>/dev/null || true)
    REPORT_COUNT=0
    CLEANED_REPORTS=0

    for file in $REPORT_FILES; do
        REPORT_COUNT=$((REPORT_COUNT + 1))
        age_days=$(file_age_days "$file")

        if [ $age_days -gt $ARCHIVE_RETENTION_DAYS ]; then
            echo "   ✓ Archiving report (${age_days}d old): $(basename $file)"
            # Could move to archive directory instead of deleting
            # For now, we'll keep all reports
            # rm "$file"
            # CLEANED_REPORTS=$((CLEANED_REPORTS + 1))
        fi
    done

    echo "   Found $REPORT_COUNT investigation reports, archived $CLEANED_REPORTS"
else
    echo "   No investigation reports directory found"
fi
echo ""

# Show active sessions
echo "4. Active debugging sessions:"
ACTIVE_SESSIONS=$(find "$SKILL_DIR" -name ".debug-session-*.json" -exec sh -c 'jq -r "select(.status == \"active\") | .session_id" "$1" 2>/dev/null' _ {} \; 2>/dev/null || true)

if [ -z "$ACTIVE_SESSIONS" ]; then
    echo "   No active sessions"
else
    echo "$ACTIVE_SESSIONS" | while read session_id; do
        echo "   • $session_id"
    done
fi
echo ""

# Summary
echo "=================================="
echo "✅ Cleanup Summary"
echo "   Session files cleaned: $CLEANED_STATE"
echo "   Browser data cleaned: $CLEANED_BROWSER"
echo "   Reports archived: $CLEANED_REPORTS"
echo ""
echo "Done!"
