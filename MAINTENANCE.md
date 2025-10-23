# Claude Code Maintenance Guide

## Overview

This directory contains automated maintenance scripts to keep your `.claude` directory optimized and prevent accumulation of temporary files.

**Last Cleanup**: October 19, 2025
**Cleanup Backup**: `~/claude-backup-20251019-153615.tar.gz`

---

## Automated Maintenance

### Scheduled Tasks

Two cron jobs run automatically on the **1st of each month at 2:00 AM**:

1. **Todo Cleanup** (`cleanup-old-todos.sh`)
   - Removes session todo files older than 30 days
   - Logs results to `logs/cleanup-YYYYMM.log`
   - Typical savings: 50-100 files per month

2. **Database Monitor** (`monitor-database.sh`)
   - Tracks database size and growth
   - Logs to `logs/database-monitor.log`
   - Maintains history in `logs/database-history.csv`

### Viewing Scheduled Jobs

```bash
crontab -l | grep -A2 'Claude Code Maintenance'
```

### Disabling Automatic Maintenance

```bash
crontab -l | grep -v 'Claude Code Maintenance\|cleanup-old-todos\|monitor-database' | crontab -
```

---

## Manual Maintenance

### Run Cleanup Manually

```bash
# Clean old todo files
~/.claude/scripts/cleanup-old-todos.sh

# Check database status
~/.claude/scripts/monitor-database.sh

# Run both
~/.claude/scripts/cleanup-old-todos.sh && ~/.claude/scripts/monitor-database.sh
```

### One-Time Cleanup Tasks

**Clear all statsig cache:**
```bash
rm -f ~/.claude/statsig/statsig.cached.evaluations.*
```

**Remove very old todo files (>60 days):**
```bash
find ~/.claude/todos/ -name "*.json" -type f -mtime +60 -delete
```

**Check disk usage:**
```bash
du -sh ~/.claude/{todos,statsig,data,commands,agents}
```

---

## Backup Management

### Current Cleanup Backup

A backup was created during the October 2025 cleanup:
- **Location**: `~/claude-backup-20251019-153615.tar.gz`
- **Size**: 340KB
- **Contents**: Pre-cleanup state of todos, statsig, data, and commands

### Backup Retention

**Recommendation**: Delete cleanup backup after 1 week if everything works correctly.

```bash
# Verify Claude Code is working normally, then:
rm ~/claude-backup-20251019-153615.tar.gz
```

### Restore from Backup

If you need to rollback the cleanup:

```bash
cd ~/.claude
tar -xzf ~/claude-backup-20251019-153615.tar.gz
```

### Create Manual Backup

Before making manual changes:

```bash
tar -czf ~/claude-backup-$(date +%Y%m%d-%H%M%S).tar.gz -C ~/.claude todos/ statsig/ data/ commands/
```

---

## Monitoring

### Check Maintenance Logs

```bash
# View recent cleanup logs
tail -50 ~/.claude/logs/cleanup-$(date +%Y%m).log

# View database monitoring
tail -50 ~/.claude/logs/database-monitor.log

# Check database growth trend
cat ~/.claude/logs/database-history.csv
```

### Warning Signs

**Too many todo files accumulating:**
- Check: `find ~/.claude/todos -name "*.json" | wc -l`
- If >500: Run cleanup manually
- If >1000: Consider more frequent cleanup (bi-weekly)

**Database growing rapidly:**
- Check: `du -sh ~/.claude/data/`
- WAL file >1MB: May need checkpoint (monitor script will warn)
- Total >10MB: Review astrotask.db usage

**Statsig cache growing:**
- Check: `du -sh ~/.claude/statsig/`
- If >500KB: Clear cache manually

---

## Troubleshooting

### Cron Jobs Not Running

**Check if cron is installed:**
```bash
which crontab
```

**Check cron logs (macOS):**
```bash
log show --predicate 'process == "cron"' --last 1h
```

**Test script manually:**
```bash
~/.claude/scripts/cleanup-old-todos.sh
```

### Script Permissions

If scripts won't run:
```bash
chmod +x ~/.claude/scripts/*.sh
```

### Logs Not Being Created

Check if logs directory exists:
```bash
mkdir -p ~/.claude/logs
```

---

## Directory Structure

```
~/.claude/
├── agents/               # SuperClaude agents
├── commands/            # Slash commands
├── data/               # Active databases (astrotask.db)
├── logs/               # Maintenance logs (auto-created)
├── scripts/            # Maintenance scripts
│   ├── cleanup-old-todos.sh
│   ├── monitor-database.sh
│   └── setup-cron.sh
├── statsig/            # Feature flag cache
├── todos/              # Session todo files (cleaned monthly)
└── MAINTENANCE.md      # This file
```

---

## Best Practices

### Monthly Review

On the 2nd of each month, review maintenance logs:
```bash
tail -100 ~/.claude/logs/cleanup-$(date +%Y%m).log
tail -100 ~/.claude/logs/database-monitor.log
```

### Before Major Updates

Create a backup before updating Claude Code:
```bash
tar -czf ~/claude-backup-pre-update-$(date +%Y%m%d).tar.gz ~/.claude/
```

### Disk Space Alerts

Set up a disk space monitor if your system supports it:
```bash
# Add to ~/.zshrc or ~/.bashrc
alias claude-size='du -sh ~/.claude && echo "Todo files:" && find ~/.claude/todos -name "*.json" | wc -l'
```

---

## Reinstalling Maintenance

If you need to reinstall the cron jobs:

```bash
~/.claude/scripts/setup-cron.sh
```

---

## Questions?

- **Scripts not working?** Check script permissions and cron logs
- **Want different schedule?** Edit crontab: `crontab -e`
- **Need help?** Review logs in `~/.claude/logs/`

**Last updated**: October 19, 2025
