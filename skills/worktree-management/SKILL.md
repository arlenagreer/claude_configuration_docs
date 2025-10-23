---
name: worktree-management
description: Automate Git worktree creation with isolated Docker services and browser automation for parallel Claude Code development sessions. This skill should be used when creating, managing, or removing Git worktrees for isolated development environments with automatic port allocation, environment file copying, and browser MCP isolation.
---

# Worktree Management Skill

## Purpose

This skill automates Git worktree creation and management for parallel development workflows. It provides isolated development environments with:

- Automatic Git worktree and branch creation
- Auto-incrementing port allocation for Docker services
- Isolated browser MCP servers (Playwright, Chrome DevTools, Puppeteer)
- Automatic `.env` file copying from main project
- Docker Compose configuration extension
- Worktree state tracking and lifecycle management
- Port conflict detection and resolution

## When to Use This Skill

Use this skill when:

- Creating isolated development environments for feature branches
- Running parallel development sessions without port conflicts
- Testing features independently with isolated Docker services
- Managing multiple worktrees across a project
- Cleaning up and removing worktrees safely

## Core Commands

### Create Worktree

```bash
@worktree create <name> [--branch=<branch-name>] [--start-services]
```

Creates a new Git worktree with isolated services. The process:

1. Validates worktree name and checks for conflicts
2. Allocates unique ports (auto-incremented from existing worktrees)
3. Creates Git worktree and branch
4. Copies `.env` files from main project (backend/.env, frontend/.env, .env)
5. Creates isolated browser data directory (`.browser-data/`)
6. Generates `.mcp.json` with browser isolation configuration
7. Generates `docker-compose.worktree.yml` extending main config
8. Creates `start-worktree.sh` startup script
9. Updates worktree tracking registry
10. Optionally starts Docker services
11. Provides next-step instructions for Claude Code launch

**Examples:**
```bash
@worktree create feature-user-export
@worktree create bugfix-email --branch=bugfix/email-preview-fix
@worktree create docs-api --branch=docs/api-documentation --start-services
```

### List Worktrees

```bash
@worktree list [--status]
```

Shows all active worktrees with name, path, branch, allocated ports, Docker service status, and created timestamp.

### Switch to Worktree

```bash
@worktree switch <name>
```

Provides instructions to change directory, check service status, and launch Claude Code instance.

### Start/Stop Services

```bash
@worktree start <name>
@worktree stop <name>
```

Starts or stops Docker services for specified worktree.

### Remove Worktree

```bash
@worktree remove <name> [--delete-branch] [--force]
```

Safely removes worktree with cleanup:
1. Stops Docker services if running
2. Removes worktree directory
3. Optionally deletes Git branch
4. Frees allocated ports
5. Updates tracking registry

**Flags:**
- `--delete-branch`: Delete the Git branch after removal
- `--force`: Skip confirmation prompts

### Check Status

```bash
@worktree status <name>
```

Shows detailed status including Git branch/commit info, Docker service status, port allocations, and uncommitted changes warnings.

### Show Port Allocations

```bash
@worktree ports [<name>]
```

Shows port allocations for specific worktree or all worktrees.

### Sync from Main Branch

```bash
@worktree sync <name>
```

Updates worktree branch from development/main by fetching latest and rebasing.

## Implementation Details

### Port Allocation Strategy

**Auto-increment approach:**
- Scans existing worktrees for highest port numbers
- Increments by 1 for each new worktree
- Maintains port registry to prevent conflicts
- Intelligently scans up to 50 sequential ports to find available ones

**Port ranges:**
- Backend: 3000 (main), 3001+ (worktrees)
- Frontend: 4000 (main), 4001+ (worktrees)
- Database: 5433 (main), 5434+ (worktrees)
- Playwright: 9223 (main), 9224+ (worktrees)
- Chrome DevTools: 9222 (main), 9226+ (worktrees)
- Puppeteer: 9224 (main), 9228+ (worktrees)

**Port conflict prevention:**
- Pre-flight validation checks all ports before Docker startup
- Detects conflicts from main project, other worktrees, or system processes
- Provides detailed conflict report with resolution options
- Graceful degradation: worktree creation succeeds even with port conflicts (services startup deferred)

For detailed port allocation documentation, see `references/port-allocation.md`.

### Browser Isolation

Each worktree creates a `.browser-data/` directory with subdirectories for each browser MCP:
```
.browser-data/
├── playwright/       # Playwright browser profiles
├── chrome-devtools/  # Chrome DevTools user data
└── puppeteer/        # Puppeteer browser profiles
```

**Environment variables set per worktree:**
- `PLAYWRIGHT_USER_DATA_DIR`: Points to worktree's `.browser-data/playwright/`
- `CHROME_USER_DATA_DIR`: Points to worktree's `.browser-data/chrome-devtools/`
- `PUPPETEER_USER_DATA_DIR`: Points to worktree's `.browser-data/puppeteer/`
- `CHROME_ARGS`: Includes `--user-data-dir` and `--remote-debugging-port`
- `PUPPETEER_LAUNCH_OPTIONS`: JSON with args array for user data and debugging port

**Benefits:**
- Run Playwright tests in multiple worktrees simultaneously
- Separate browser state per worktree
- No cookie/session conflicts
- Independent debugging ports

For detailed browser isolation information, see `references/browser-isolation.md`.

### Docker Compose Strategy

Uses Docker Compose extension pattern. Each worktree generates a `docker-compose.worktree.yml` that extends the main `docker-compose.yml` with custom port mappings.

**Usage:**
```bash
docker-compose -f docker-compose.yml -f docker-compose.worktree.yml up
```

For detailed Docker strategy documentation, see `references/docker-strategy.md`.

### Environment File Management

Automatically copies environment files from main project to each worktree:
- `backend/.env` → Copied to worktree's backend directory
- `frontend/.env` → Copied to worktree's frontend directory
- `.env` (root) → Copied to worktree root

This prevents Docker service startup failures due to missing gitignored files.

### State Tracking

**Worktree Registry** (`worktrees.json`):
Tracks all worktrees with name, path, branch, creation timestamp, port allocations, status, and Docker service state.

**Port Registry** (`port-registry.json`):
Maintains allocated ports to prevent conflicts.

## Using the Skill

### Typical Development Workflow

```bash
# 1. Create worktree with services
@worktree create feature-auth --start-services

# 2. Switch to worktree (in new terminal)
cd /path/to/worktree
claude

# 3. Develop in isolated environment
# - Separate conversation history
# - Independent browser automation
# - No port conflicts

# 4. When done, merge back
cd /path/to/main/project
git checkout development
git merge feature/auth

# 5. Keep worktree for reuse or remove
@worktree remove feature-auth
```

### Accessing Bundled Resources

**Scripts** (`scripts/`):
- `worktree-manager.sh` - Main worktree management script with all commands

**Templates** (`assets/`):
- `docker-compose.worktree.template.yml` - Docker Compose extension template
- `mcp.template.json` - MCP configuration template with browser isolation
- `start-worktree.template.sh` - Service startup script template

**References** (`references/`):
- `port-allocation.md` - Detailed port allocation documentation
- `browser-isolation.md` - Browser MCP isolation details
- `docker-strategy.md` - Docker Compose extension pattern
- `troubleshooting.md` - Common issues and solutions

**State Files** (skill root):
- `worktrees.json` - Worktree registry (auto-managed)
- `port-registry.json` - Port allocations (auto-managed)

To execute worktree commands, invoke the main script:
```bash
~/.claude/skills/worktree-management/scripts/worktree-manager.sh <command> [args]
```

## Best Practices

1. **Name worktrees descriptively**: Use clear names like `feature-auth`, `bugfix-email`, `docs-api`
2. **Use branch naming conventions**: Auto-converts `feature-auth` → `feature/auth`
3. **Verify `.env` files exist**: Ensure main project has `.env` files before creating worktrees
4. **Start services explicitly**: Use `--start-services` flag or run manually after resolving conflicts
5. **Stop services when done**: Free resources with `@worktree stop <name>`
6. **Sync regularly**: Stay updated with `@worktree sync <name>`
7. **Keep worktrees for reuse**: Don't remove unless completely done with feature
8. **Check status before merge**: View uncommitted changes with `@worktree status <name>`
9. **Browser isolation works automatically**: No manual configuration needed for parallel testing

## Safety Features

- Pre-creation validation (name conflicts, port availability)
- Pre-removal validation (uncommitted changes, running services)
- Rollback on failed operations
- Port registry prevents conflicts
- State tracking enables recovery
- Confirmation prompts for destructive operations
- Automatic `.env` file copying prevents Docker failures
- Browser isolation prevents session conflicts

## Limitations

- **Claude Code launch**: Instruction-based only (can't auto-launch new instance)
- **Manual cleanup**: Worktrees kept indefinitely (manual removal required)
- **No automatic sync**: Must manually sync from development branch
- **Port exhaustion**: No automatic cleanup of unused port allocations
- **`.env` file changes**: Updates to main project `.env` not auto-synced to worktrees

## Troubleshooting

For detailed troubleshooting guidance, see `references/troubleshooting.md`.

### Quick Solutions

**Port conflicts:**
```bash
@worktree ports                    # Check allocations
@worktree stop <name>             # Free ports
```

**Docker services won't start:**
```bash
# Stop main project services
cd /path/to/main/project
docker-compose down
```

**Missing `.env` files:**
```bash
# Copy manually if automatic copying failed
cp /path/to/main/backend/.env ./backend/.env
cp /path/to/main/frontend/.env ./frontend/.env
```

## Recent Bug Fixes

### Critical: Worktree Removal Bug (FIXED - 2025-10-22)

**Issue**: Removing a worktree accidentally removed ALL Docker containers, including main project containers.

**Root Cause**: Removal script used `docker-compose down` with both main and worktree compose files.

**Fix**: Removed `docker-compose down` command. Now uses only targeted container removal by name, which is safe and isolated.

**Impact**: No longer affects main project containers when removing worktrees.
