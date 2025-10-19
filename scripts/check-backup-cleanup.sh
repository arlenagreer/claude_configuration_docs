#!/bin/bash
# Backup Cleanup Reminder
# Checks for old cleanup backups and reminds user to delete them

BACKUP_DIR="$HOME"
LOG_DIR="$HOME/.claude/logs"
REMINDER_LOG="$LOG_DIR/backup-reminders.log"

mkdir -p "$LOG_DIR"

# Find cleanup backups older than 7 days
OLD_BACKUPS=$(find "$BACKUP_DIR" -maxdepth 1 -name "claude-backup-*.tar.gz" -mtime +7 2>/dev/null)

if [ -n "$OLD_BACKUPS" ]; then
    {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] REMINDER: Old cleanup backups found"
        echo ""
        echo "The following backup files are older than 7 days:"
        echo "$OLD_BACKUPS" | while read -r file; do
            SIZE=$(ls -lh "$file" | awk '{print $5}')
            DATE=$(ls -l "$file" | awk '{print $6, $7, $8}')
            echo "  - $(basename "$file") ($SIZE, created $DATE)"
        done
        echo ""
        echo "If Claude Code is working normally, you can safely delete these:"
        echo "  rm ~/claude-backup-*.tar.gz"
        echo ""
    } | tee -a "$REMINDER_LOG"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] No old backups to clean up" >> "$REMINDER_LOG"
fi
