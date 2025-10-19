#!/bin/bash
# Claude Code Database Monitor
# Tracks database growth and reports anomalies
# Run monthly or on-demand

CLAUDE_DIR="$HOME/.claude"
DATA_DIR="$CLAUDE_DIR/data"
LOG_DIR="$CLAUDE_DIR/logs"
MONITOR_LOG="$LOG_DIR/database-monitor.log"
HISTORY_FILE="$LOG_DIR/database-history.csv"

# Create directories if needed
mkdir -p "$LOG_DIR"

# Initialize history file if it doesn't exist
if [ ! -f "$HISTORY_FILE" ]; then
    echo "date,size_bytes,size_human,file_count" > "$HISTORY_FILE"
fi

# Get current database stats
DB_SIZE_BYTES=$(du -sk "$DATA_DIR" | awk '{print $1}')
DB_SIZE_HUMAN=$(du -sh "$DATA_DIR" | awk '{print $1}')
FILE_COUNT=$(find "$DATA_DIR" -type f | wc -l | tr -d ' ')
CURRENT_DATE=$(date '+%Y-%m-%d')

# Append to history
echo "$CURRENT_DATE,$DB_SIZE_BYTES,$DB_SIZE_HUMAN,$FILE_COUNT" >> "$HISTORY_FILE"

# Log current status
{
    echo "=== Database Monitor Report: $CURRENT_DATE ==="
    echo "Database directory: $DATA_DIR"
    echo "Total size: $DB_SIZE_HUMAN ($DB_SIZE_BYTES KB)"
    echo "File count: $FILE_COUNT"
    echo ""

    # Show database files
    echo "Database files:"
    ls -lh "$DATA_DIR"
    echo ""

    # Check for WAL/SHM file sizes
    if [ -f "$DATA_DIR/astrotask.db-wal" ]; then
        WAL_SIZE=$(ls -lh "$DATA_DIR/astrotask.db-wal" | awk '{print $5}')
        echo "WAL file size: $WAL_SIZE"

        # Warn if WAL is unusually large
        WAL_BYTES=$(stat -f%z "$DATA_DIR/astrotask.db-wal" 2>/dev/null || stat -c%s "$DATA_DIR/astrotask.db-wal" 2>/dev/null)
        if [ "$WAL_BYTES" -gt 1048576 ]; then  # >1MB
            echo "WARNING: WAL file is large ($WAL_SIZE) - consider checkpoint"
        fi
    fi

    # Growth analysis (if we have history)
    if [ $(wc -l < "$HISTORY_FILE") -gt 2 ]; then
        echo ""
        echo "Recent growth trend (last 5 entries):"
        tail -6 "$HISTORY_FILE" | column -t -s,

        # Calculate growth rate
        PREV_SIZE=$(tail -2 "$HISTORY_FILE" | head -1 | cut -d, -f2)
        if [ -n "$PREV_SIZE" ] && [ "$PREV_SIZE" != "size_bytes" ]; then
            GROWTH=$((DB_SIZE_BYTES - PREV_SIZE))
            if [ $GROWTH -gt 0 ]; then
                echo ""
                echo "Growth since last check: +${GROWTH}KB"
            fi
        fi
    fi

    echo "=== End of report ==="
} | tee -a "$MONITOR_LOG"
