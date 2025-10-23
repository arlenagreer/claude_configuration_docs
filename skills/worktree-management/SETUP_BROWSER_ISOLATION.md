# Browser Isolation Setup Guide

## Overview

This guide walks you through setting up complete browser isolation for worktree-management skill, enabling multiple Claude Code sessions to use browser automation (Playwright, Chrome DevTools, Puppeteer) simultaneously without interference.

## Problem Solved

**Before**: Multiple worktrees sharing browser resources → interference, conflicts, shared state
**After**: Each worktree gets isolated browser profiles → completely independent browsing

---

## 🚀 Quick Setup (5 minutes)

### Step 1: Run the Setup Script

```bash
~/.claude/skills/worktree-management/scripts/setup-mcp-isolation.sh
```

**What it does**:
- Creates shared Docker volume `browser-profiles`
- Restarts MCP containers with volume mounts
- Validates configuration

**Expected output**:
```
✅ MCP Browser Isolation Setup Complete!
   • Shared volume 'browser-profiles' created
   • playwright-mcp: Running with /browser-data mount
   • chrome-devtools-mcp: Running with /browser-data mount
   • puppeteer-mcp: Running with /browser-data mount
```

### Step 2: Verify Setup

```bash
~/.claude/skills/worktree-management/scripts/test-isolation.sh
```

**Expected output**:
```
✅ All tests passed! Browser isolation is properly configured.
```

### Step 3: Test with Real Worktrees

```bash
# Create two test worktrees
@worktree create test-iso-1
@worktree create test-iso-2

# In Terminal 1
cd ../SoftTrak-test-iso-1
claude

# In Terminal 2 (simultaneously)
cd ../SoftTrak-test-iso-2
claude

# In both Claude sessions, try browser automation
# Example: "Use Playwright to navigate to localhost:4001"
# Both should work without interference
```

---

## 🔧 Manual Setup (If Script Fails)

### Step 1: Create Shared Volume

```bash
docker volume create browser-profiles
```

### Step 2: Restart MCP Containers

**Playwright MCP**:
```bash
docker stop playwright-mcp
docker rm playwright-mcp
docker run -d \
  --name playwright-mcp \
  -v browser-profiles:/browser-data \
  --restart unless-stopped \
  mcr.microsoft.com/playwright:v1.48.0-jammy \
  tail -f /dev/null
```

**Chrome DevTools MCP**:
```bash
docker stop chrome-devtools-mcp
docker rm chrome-devtools-mcp
docker run -d \
  --name chrome-devtools-mcp \
  -v browser-profiles:/browser-data \
  --restart unless-stopped \
  zenika/alpine-chrome:latest \
  tail -f /dev/null
```

**Puppeteer MCP**:
```bash
docker stop puppeteer-mcp
docker rm puppeteer-mcp
docker run -d \
  --name puppeteer-mcp \
  -v browser-profiles:/browser-data \
  --restart unless-stopped \
  ghcr.io/puppeteer/puppeteer:latest \
  tail -f /dev/null
```

### Step 3: Verify Volume Mounts

```bash
docker inspect playwright-mcp | grep browser-profiles
docker inspect chrome-devtools-mcp | grep browser-profiles
docker inspect puppeteer-mcp | grep browser-profiles

# Should show volume mounts
```

---

## 🔍 How It Works

### Architecture

```
Claude Code Session 1 (worktree-1)
  ↓
.mcp.json: PLAYWRIGHT_USER_DATA_DIR=/browser-data/SoftTrak-worktree-1/playwright
  ↓
docker exec playwright-mcp (with env vars)
  ↓
Browser launches with:
  --remote-debugging-port=9224
  --user-data-dir=/browser-data/SoftTrak-worktree-1/playwright
  ↓
Creates isolated profile in Docker volume

Claude Code Session 2 (worktree-2)
  ↓
.mcp.json: PLAYWRIGHT_USER_DATA_DIR=/browser-data/SoftTrak-worktree-2/playwright
  ↓
docker exec playwright-mcp (with env vars)
  ↓
Browser launches with:
  --remote-debugging-port=9225
  --user-data-dir=/browser-data/SoftTrak-worktree-2/playwright
  ↓
Creates isolated profile in Docker volume

Result: Two completely separate browsers
```

### Key Components

1. **Shared Docker Volume**: `browser-profiles` mounted at `/browser-data/` in all MCP containers
2. **Unique Paths**: Each worktree uses `/browser-data/{worktree-name}/` namespace
3. **Unique Ports**: Auto-incremented debugging ports (9224, 9225, 9226, ...)
4. **Environment Variables**: Passed via `docker exec -e` from `.mcp.json`

---

## 🧪 Testing & Validation

### Test 1: Volume Existence

```bash
docker volume ls | grep browser-profiles
# Expected: browser-profiles
```

### Test 2: Container Mounts

```bash
docker inspect playwright-mcp --format='{{range .Mounts}}{{.Source}} → {{.Destination}}{{"\n"}}{{end}}'
# Expected: browser-profiles → /browser-data
```

### Test 3: Path Accessibility

```bash
docker exec playwright-mcp ls -la /browser-data/
# Expected: Directory listing (may be empty before first worktree use)
```

### Test 4: Worktree Profile Creation

```bash
# After creating and using a worktree
docker exec playwright-mcp ls -la /browser-data/
# Expected: SoftTrak-{worktree-name} directories
```

### Test 5: Parallel Browser Sessions

```bash
# Terminal 1 & 2: Create worktrees and launch Claude
# In both sessions: "Use Playwright to open localhost:3001"
# Expected: Two separate browser windows
# Verify: Different user-data-dir paths, different debugging ports
```

---

## 🐛 Troubleshooting

### Issue: "Volume not found"

**Symptom**: Docker commands fail with "volume browser-profiles not found"

**Solution**:
```bash
docker volume create browser-profiles
```

### Issue: "Container already running"

**Symptom**: Setup script fails because containers are running

**Solution**:
```bash
docker stop playwright-mcp chrome-devtools-mcp puppeteer-mcp
docker rm playwright-mcp chrome-devtools-mcp puppeteer-mcp
# Re-run setup script
```

### Issue: "Permission denied in /browser-data"

**Symptom**: Browser fails to create profiles

**Solution**:
```bash
docker exec playwright-mcp chmod 777 /browser-data
```

### Issue: "Browser still shares state between worktrees"

**Symptom**: Cookies/storage shared between sessions

**Diagnosis**:
```bash
# Check if worktrees use correct paths
cat ../SoftTrak-worktree-1/.mcp.json | grep PLAYWRIGHT_USER_DATA_DIR
# Should show: /browser-data/SoftTrak-worktree-1/playwright

# Check if profiles are actually separate
docker exec playwright-mcp ls -la /browser-data/
# Should show separate directories per worktree
```

**Solution**: Recreate worktrees after setup:
```bash
@worktree remove worktree-1
@worktree create worktree-1
```

### Issue: "Port conflicts despite allocation"

**Symptom**: Second worktree fails to start browser

**Diagnosis**:
```bash
@worktree ports
# Verify unique ports allocated

lsof -i :9224  # Check if port actually in use
```

**Solution**: Port locking should prevent this. If it occurs:
```bash
# Stop all worktree browsers
# Restart MCP containers
docker restart playwright-mcp chrome-devtools-mcp puppeteer-mcp
```

---

## 📊 Before & After Comparison

### Before (Shared Container, Host Paths)

```json
{
  "env": {
    "PLAYWRIGHT_USER_DATA_DIR": "/Users/arlenagreer/Github_Projects/SoftTrak-worktree-1/.browser-data/playwright"
  }
}
```

**Problems**:
- ❌ Host path not accessible in container
- ❌ Fallback to default profile (shared)
- ❌ All worktrees use same browser instance
- ❌ Port conflicts (all try 9222)

### After (Shared Volume, Container Paths)

```json
{
  "env": {
    "PLAYWRIGHT_USER_DATA_DIR": "/browser-data/SoftTrak-worktree-1/playwright",
    "PLAYWRIGHT_CHROMIUM_DEBUG_PORT": "9224",
    "PLAYWRIGHT_LAUNCH_OPTIONS": "{\"args\":[\"--remote-debugging-port=9224\",\"--user-data-dir=/browser-data/SoftTrak-worktree-1/playwright\"]}"
  }
}
```

**Benefits**:
- ✅ Container can access path (volume mounted)
- ✅ Unique profile per worktree
- ✅ Separate browser instances
- ✅ Unique debugging ports
- ✅ Complete isolation

---

## 🎯 Success Criteria

After setup, you should be able to:

1. ✅ Create multiple worktrees simultaneously without port conflicts
2. ✅ Launch Claude in multiple worktrees at the same time
3. ✅ Use browser automation in all sessions without interference
4. ✅ See separate browser windows/profiles for each worktree
5. ✅ Different cookies/storage/cache per worktree
6. ✅ Independent navigation and state management

---

## 📚 Related Documentation

- [Browser Isolation Reference](references/browser-isolation.md) - Detailed architecture
- [Port Allocation Reference](references/port-allocation.md) - Port management details
- [Troubleshooting Guide](references/troubleshooting.md) - Common issues

---

## 🔄 Maintenance

### Cleaning Old Profiles

Browser profiles accumulate over time. Clean them periodically:

```bash
# View all profiles
docker exec playwright-mcp ls -la /browser-data/

# Remove profiles for deleted worktrees
docker exec playwright-mcp rm -rf /browser-data/SoftTrak-old-worktree
```

### Backup/Restore

To backup browser profiles:

```bash
# Create backup
docker run --rm -v browser-profiles:/source -v $(pwd):/backup alpine tar czf /backup/browser-profiles-backup.tar.gz -C /source .

# Restore backup
docker run --rm -v browser-profiles:/target -v $(pwd):/backup alpine tar xzf /backup/browser-profiles-backup.tar.gz -C /target
```

---

**Version**: 1.0.0
**Last Updated**: 2025-01-23
**Compatibility**: Docker 20.10+, macOS/Linux
