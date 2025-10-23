# Git Worktree Support Context

**Load when**: Current directory is a git worktree OR multiple concurrent debugging sessions detected

---

## Worktree Detection

```bash
# Check if current directory is a worktree
git rev-parse --git-dir | grep "\.git/worktrees"
```

---

## Worktree-Aware Behavior

```yaml
when_in_worktree:
  - Use worktree-specific session ID: "{worktree-name}-{timestamp}"
  - Isolate browser sessions per worktree
  - Separate state files per worktree
  - Coordinate with main worktree if needed (shared test database, etc.)

coordination_with_main:
  - Shared test credentials (from SoftTrak context)
  - Shared knowledge base updates
  - Separate browser instances (isolated)
  - Separate temp directories
```

---

## Multi-Session Management

```yaml
list_active_sessions:
  - Detect all .debug-session-*.json files
  - Show worktree, status, age
  - Allow user to inspect or terminate

conflict_resolution:
  - Each worktree gets its own browser instance
  - No shared state between concurrent sessions
  - Knowledge base updates queued and merged
```

---

## Session Isolation

**Critical**: When running in a worktree environment, maintain complete isolation:

1. **Browser Instances**: Each worktree uses a separate Chrome instance with unique user-data-dir
2. **Session Files**: Prefix all session files with worktree name
3. **Port Allocation**: Auto-increment port numbers to avoid conflicts
4. **State Management**: No shared state except knowledge base (queued updates)

**Example**:
```
Main Project: Chrome on port 9222, session ID "main-1234567890"
Worktree-1:   Chrome on port 9223, session ID "worktree-1-1234567891"
Worktree-2:   Chrome on port 9224, session ID "worktree-2-1234567892"
```
