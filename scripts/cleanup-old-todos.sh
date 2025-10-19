#!/bin/bash
# Claude Code Todo Cleanup Script
# Removes session todo files older than 30 days
# Run monthly via cron or manually

CLAUDE_DIR="$HOME/.claude"
TODO_DIR="$CLAUDE_DIR/todos"
LOG_DIR="$CLAUDE_DIR/logs"
LOG_FILE="$LOG_DIR/cleanup-$(date +%Y%m).log"

# Create logs directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== Starting monthly todo cleanup ==="

# Count files before cleanup
BEFORE_COUNT=$(find "$TODO_DIR" -name "*.json" -type f | wc -l | tr -d ' ')
BEFORE_SIZE=$(du -sh "$TODO_DIR" | awk '{print $1}')

log "Before cleanup: $BEFORE_COUNT files, $BEFORE_SIZE disk usage"

# Remove old todo files (>30 days)
REMOVED_COUNT=$(find "$TODO_DIR" -name "*.json" -type f -mtime +30 | wc -l | tr -d ' ')

if [ "$REMOVED_COUNT" -gt 0 ]; then
    find "$TODO_DIR" -name "*.json" -type f -mtime +30 -delete
    log "Removed $REMOVED_COUNT old todo files"
else
    log "No old todo files to remove"
fi

# Count files after cleanup
AFTER_COUNT=$(find "$TODO_DIR" -name "*.json" -type f | wc -l | tr -d ' ')
AFTER_SIZE=$(du -sh "$TODO_DIR" | awk '{print $1}')

log "After cleanup: $AFTER_COUNT files, $AFTER_SIZE disk usage"
log "=== Cleanup complete ==="

# Send notification if significant cleanup occurred
if [ "$REMOVED_COUNT" -gt 100 ]; then
    log "NOTICE: Removed $REMOVED_COUNT files - consider more frequent cleanup"
fi
