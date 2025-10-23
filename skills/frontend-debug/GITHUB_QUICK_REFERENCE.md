# Frontend-Debug Skill: GitHub Integration Quick Reference

## How to Use

### Method 1: Issue Number (Recommended)
```bash
@~/.claude/skills/frontend-debug.md "#123"
```

### Method 2: Explicit Flag
```bash
@~/.claude/skills/frontend-debug.md --github-issue 123
```

### Method 3: GitHub URL
```bash
@~/.claude/skills/frontend-debug.md "https://github.com/yourorg/repo/issues/123"
```

### Method 4: Inline Description (No GitHub Tracking)
```bash
@~/.claude/skills/frontend-debug.md "Login button not working"
```

---

## What Happens with GitHub Integration

### 1. Session Start
- ✅ Fetches issue details (title, body, labels, comments)
- ✅ Posts comment: "🤖 **Debugging session started**"
- ✅ Adds labels: `automated-debug`, `in-progress`

### 2. During Investigation
- 📊 Posts "Investigation Phase" update
- 🔍 Posts "Root Cause Analysis" update
- 🔄 Posts iteration updates for each fix attempt
- ❓ Posts clarification questions if needed (with @mention)

### 3. On Success
- ✅ Posts resolution summary with root cause and fix
- ✅ Adds label: `resolved-by-claude`
- ✅ Removes labels: `automated-debug`, `in-progress`
- ✅ Closes issue with verification note

### 4. On Escalation
- ⚠️ Posts detailed investigation report
- ⚠️ Includes findings, questions, recommendations
- ⚠️ Adds label: `needs-human-review`
- ⚠️ Keeps issue open for human intervention

---

## Setup Requirements

### Install GitHub CLI
```bash
# macOS
brew install gh

# Login
gh auth login

# Verify
gh auth status
```

### Create Recommended Labels
```bash
gh label create "automated-debug" --color "0E8A16" --description "Automated debugging in progress"
gh label create "in-progress" --color "FBCA04" --description "Currently being worked on"
gh label create "resolved-by-claude" --color "5319E7" --description "Resolved by automated debugging"
gh label create "needs-human-review" --color "D93F0B" --description "Automated debugging escalated"
```

---

## Example Session Flow

```bash
# You invoke the skill
@~/.claude/skills/frontend-debug.md "#42"

# Issue #42 gets comment:
🤖 **Debugging session started**
Automated investigation initiated by Claude Agent.
I'll post progress updates here as I work through the issue.

# Labels added: automated-debug, in-progress

# Phase 1 comment:
📊 **Investigation Phase**
Reproducing issue in isolated browser environment...

# Phase 2 comment:
🔍 **Root Cause Analysis**
Analyzing findings and forming hypothesis...

# If clarification needed:
@submitter I need more information to proceed:

1. What browser version are you using?
2. Can you provide steps to reproduce from a fresh login?

Please provide these details when possible.

# On resolution:
✅ **Issue Resolved**

**Root Cause**: Event handler not attached due to missing dependency

**Fix Applied**: Added missing import in `LoginButton.tsx` (line 15)

**Verification**: All criteria passed
- ✅ UI State: Login button clickable and styled correctly
- ✅ Console: No errors
- ✅ Network: Login API call succeeds
- ✅ Interaction: Login flow completes end-to-end
- ✅ Regression: Related features still work

Full investigation report attached below.

# Issue closed with label: resolved-by-claude
```

---

## Common Scenarios

### Scenario 1: Quick Fix
```bash
@~/.claude/skills/frontend-debug.md "#101"
# Session runs 5-10 minutes
# Issue closed automatically with resolution
```

### Scenario 2: Needs Clarification
```bash
@~/.claude/skills/frontend-debug.md "#102"
# Session posts questions to issue
# You respond in GitHub issue comments
# Can re-invoke skill to continue: @~/.claude/skills/frontend-debug.md "#102"
```

### Scenario 3: Escalation Required
```bash
@~/.claude/skills/frontend-debug.md "#103"
# Session posts detailed report
# Adds label: needs-human-review
# Keeps issue open for team review
```

---

## Tips & Best Practices

### For Issue Submitters
1. **Provide reproduction steps** in issue body
2. **Include browser/environment details**
3. **Respond to @mentions promptly** for faster resolution
4. **Review automated comments** for transparency

### For Maintainers
1. **Use GitHub issue tracking** for automated debugging sessions
2. **Review `needs-human-review` labels** regularly
3. **Monitor `resolved-by-claude` issues** for quality
4. **Create regression tests** from investigation reports

### For Developers
1. **Reference issues when invoking**: Better tracking and history
2. **Check session state file** for crash recovery
3. **Review full investigation reports** in issue comments
4. **Update skill knowledge base** with learnings

---

## Troubleshooting

### "gh: command not found"
```bash
# Install GitHub CLI
brew install gh

# Or download from: https://cli.github.com
```

### "Issue #123 not found"
```bash
# Verify issue exists
gh issue view 123

# Check you're in the right repository
gh repo view
```

### "Must have push access"
```bash
# You need write permissions to edit issues
# Request access from repository maintainer
# Skill will continue investigation but skip issue updates
```

### "API rate limit exceeded"
```bash
# Check your rate limit
gh api rate_limit

# Wait for reset or use with caution
# Skill will cache data and retry
```

---

## Advanced Features

### Resume Crashed Session
```bash
# If session crashed, state is preserved
@~/.claude/skills/frontend-debug.md "#42"

# Skill will ask:
"Found incomplete debugging session from 10 minutes ago. Resume? (yes/no)"

# Answer "yes" to continue from last checkpoint
```

### Multiple Concurrent Sessions
```bash
# Terminal 1
cd ~/project-main
@~/.claude/skills/frontend-debug.md "#42"

# Terminal 2 (git worktree)
cd ~/project-feature-x
@~/.claude/skills/frontend-debug.md "#43"

# Each gets isolated browser and session state
```

### Manual Session Cleanup
```bash
# List active sessions
ls -la .debug-session-*.json

# Remove old sessions (>24h)
find . -name ".debug-session-*.json" -mtime +1 -delete
```

---

## Getting Help

**Skill Documentation**: `~/.claude/skills/frontend-debug/SKILL.md`

**GitHub Integration Details**: `~/.claude/skills/frontend-debug/GITHUB_INTEGRATION_UPDATE.md`

**GitHub CLI Docs**: https://cli.github.com/manual/

**Chrome DevTools MCP**: https://github.com/anthropics/chrome-devtools-mcp

---

## Quick Commands Cheat Sheet

```bash
# View issue
gh issue view 123

# List all automated-debug issues
gh issue list --label "automated-debug"

# List needs-human-review issues
gh issue list --label "needs-human-review"

# Close issue manually
gh issue close 123 --comment "Fixed manually"

# Reopen closed issue
gh issue reopen 123

# Add comment to issue
gh issue comment 123 --body "Additional context..."

# View issue in browser
gh issue view 123 --web
```
