#!/bin/bash
# Setup Cron Jobs for Claude Code Maintenance
# Run this script to install monthly maintenance tasks

CLAUDE_DIR="$HOME/.claude"
SCRIPTS_DIR="$CLAUDE_DIR/scripts"

echo "Setting up Claude Code maintenance cron jobs..."
echo ""

# Check if scripts exist
if [ ! -f "$SCRIPTS_DIR/cleanup-old-todos.sh" ]; then
    echo "ERROR: cleanup-old-todos.sh not found"
    exit 1
fi

if [ ! -f "$SCRIPTS_DIR/monitor-database.sh" ]; then
    echo "ERROR: monitor-database.sh not found"
    exit 1
fi

# Create temporary cron file
TEMP_CRON=$(mktemp)

# Get existing crontab (if any)
crontab -l 2>/dev/null > "$TEMP_CRON" || true

# Check if our jobs are already installed
if grep -q "cleanup-old-todos.sh" "$TEMP_CRON"; then
    echo "Cron jobs already installed. Updating..."
    # Remove old entries
    grep -v "cleanup-old-todos.sh\|monitor-database.sh\|Claude Code Maintenance" "$TEMP_CRON" > "${TEMP_CRON}.new"
    mv "${TEMP_CRON}.new" "$TEMP_CRON"
fi

# Add new cron jobs
cat >> "$TEMP_CRON" << EOF

# Claude Code Maintenance (auto-generated)
# Run todo cleanup on the 1st of each month at 2am
0 2 1 * * $SCRIPTS_DIR/cleanup-old-todos.sh

# Run database monitor on the 1st of each month at 2:05am
5 2 1 * * $SCRIPTS_DIR/monitor-database.sh
EOF

# Install the new crontab
crontab "$TEMP_CRON"
rm "$TEMP_CRON"

echo "✅ Cron jobs installed successfully!"
echo ""
echo "Scheduled tasks:"
echo "  - Todo cleanup: 1st of each month at 2:00 AM"
echo "  - Database monitor: 1st of each month at 2:05 AM"
echo ""
echo "To view installed cron jobs:"
echo "  crontab -l | grep -A2 'Claude Code Maintenance'"
echo ""
echo "To remove these cron jobs:"
echo "  crontab -l | grep -v 'Claude Code Maintenance\\|cleanup-old-todos\\|monitor-database' | crontab -"
