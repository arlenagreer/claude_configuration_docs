# Pull Request Automation Troubleshooting Guide

Comprehensive troubleshooting guide for diagnosing and resolving PR automation issues in the task-wrapup skill.

## Table of Contents

1. [Quick Diagnostics](#quick-diagnostics)
2. [Common Issues](#common-issues)
3. [Error Code Reference](#error-code-reference)
4. [Diagnostic Procedures](#diagnostic-procedures)
5. [Manual Recovery](#manual-recovery)
6. [Debug Mode](#debug-mode)
7. [FAQ](#faq)
8. [Advanced Troubleshooting](#advanced-troubleshooting)

---

## Quick Diagnostics

### Step 1: Check Configuration
```bash
# Verify configuration exists and is valid
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py validate

# Check specific pull_request settings
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py show | grep -A 10 '"pull_request"'
```

### Step 2: Check Session State
```bash
# Verify session state file exists
ls -la .task_session_state.json

# View session state contents
cat .task_session_state.json | python3 -m json.tool
```

### Step 3: Check Git Status
```bash
# Verify git repository status
git status

# Check current branch
git branch --show-current

# Check for uncommitted changes
git diff-index --quiet HEAD -- || echo "Uncommitted changes detected"
```

### Step 4: Check GitHub CLI
```bash
# Verify gh CLI is installed
gh --version

# Check authentication status
gh auth status

# Test GitHub connection
gh repo view
```

---

## Common Issues

### Issue 1: "No session state file found"

**Symptom**: PR creation fails with error about missing `.task_session_state.json`

**Causes**:
1. Task not started with task-start skill
2. Session state file manually deleted
3. Wrong working directory

**Resolution**:

**Diagnostic Steps**:
```bash
# 1. Check if file exists anywhere in git repository
find $(git rev-parse --show-toplevel 2>/dev/null || pwd) -name ".task_session_state.json"

# 2. Verify current directory is git repository root
git rev-parse --show-toplevel

# 3. Check git history for session state creation
git log --all --full-history -- .task_session_state.json
```

**Fix Option 1 - Manual Creation** (if you know parent branch):
```bash
# Create session state manually
cat > .task_session_state.json <<'EOF'
{
  "schema_version": "1.0",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "feature_branch": "$(git branch --show-current)",
  "parent_branch": "develop",
  "issue_number": null,
  "github_issue": null
}
EOF
```

**Fix Option 2 - Use Configuration Default**:
If you don't have session state, the skill will fall back to `default_parent_branch` from configuration. Verify this is set correctly:
```bash
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py show | grep default_parent_branch
```

**Prevention**:
- Always use task-start skill to begin work
- Add `.task_session_state.json` to `.gitignore` to prevent accidental commits
- Don't manually delete session state until PR is created

---

### Issue 2: "GitHub CLI not installed or not authenticated"

**Symptom**: PR creation fails with exit code 10 or 11

**Exit Codes**:
- Exit 10: `gh` CLI not installed
- Exit 11: `gh` CLI installed but not authenticated

**Resolution**:

**For Exit Code 10 (Not Installed)**:
```bash
# Install GitHub CLI
# macOS
brew install gh

# Linux
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Verify installation
gh --version
```

**For Exit Code 11 (Not Authenticated)**:
```bash
# Authenticate with GitHub
gh auth login

# Follow interactive prompts:
# 1. Choose GitHub.com
# 2. Choose HTTPS
# 3. Authenticate with web browser (recommended)

# Verify authentication
gh auth status

# Expected output:
# github.com
#   ✓ Logged in to github.com as YOUR_USERNAME (oauth_token)
#   ✓ Git operations for github.com configured to use https protocol.
```

**Verify GitHub Connection**:
```bash
# Test GitHub API access
gh api user

# Test repository access
gh repo view

# List your repositories
gh repo list
```

**Common Authentication Issues**:
1. **Token expired**: Re-run `gh auth login`
2. **Wrong account**: Check `gh auth status`, switch with `gh auth switch`
3. **Insufficient permissions**: Token needs `repo` scope - regenerate with `gh auth login --scopes repo`

---

### Issue 3: "Uncommitted changes detected"

**Symptom**: PR creation fails with exit code 12

**Cause**: Working directory has uncommitted changes

**Resolution**:

**Diagnostic**:
```bash
# Check for uncommitted changes
git status

# See what files are modified
git diff --name-only

# See staged changes
git diff --cached --name-only
```

**Fix Option 1 - Commit Changes**:
```bash
# Stage all changes
git add .

# Commit with descriptive message
git commit -m "Your commit message here"

# Retry PR creation
@~/.claude/skills/task-wrapup/SKILL.md
```

**Fix Option 2 - Stash Changes** (if you want to save but not commit):
```bash
# Stash uncommitted changes
git stash push -m "Work in progress - $(date)"

# Retry PR creation
@~/.claude/skills/task-wrapup/SKILL.md

# After PR created, restore changes
git stash pop
```

**Fix Option 3 - Discard Changes** (if changes are not needed):
```bash
# WARNING: This permanently deletes uncommitted changes!
# Review changes first
git diff

# Discard all changes
git reset --hard HEAD

# Retry PR creation
@~/.claude/skills/task-wrapup/SKILL.md
```

**Prevention**:
- Commit frequently during development
- Use meaningful commit messages
- Review changes before attempting PR creation

---

### Issue 4: "No commits to push"

**Symptom**: PR creation fails with exit code 13

**Cause**: Feature branch has no commits compared to parent branch

**Resolution**:

**Diagnostic**:
```bash
# Check commits ahead of parent branch
git log origin/develop..HEAD --oneline

# If empty, no new commits exist

# Check if remote branch exists
git ls-remote --heads origin $(git branch --show-current)

# Compare local and remote
git rev-list --count origin/develop..HEAD
```

**Understanding the Issue**:
This usually happens when:
1. You created a branch but made no commits
2. All your commits were already merged to parent
3. You're on the wrong branch

**Fix Option 1 - Make Commits**:
```bash
# Make sure you're on the feature branch
git branch --show-current

# Make changes and commit
# (do your development work)
git add .
git commit -m "Implement feature"

# Retry PR creation
@~/.claude/skills/task-wrapup/SKILL.md
```

**Fix Option 2 - Verify Correct Branch**:
```bash
# Check all branches
git branch -a

# Switch to correct feature branch
git checkout feature/your-branch-name

# Retry PR creation
@~/.claude/skills/task-wrapup/SKILL.md
```

**Prevention**:
- Make at least one commit before attempting PR creation
- Verify you're on the correct branch before starting work
- Use `git log` to verify commits exist

---

### Issue 5: "Push to remote failed"

**Symptom**: PR creation fails with exit code 20

**Causes**:
1. Network connectivity issues
2. Push timeout (>60 seconds)
3. Authentication problems
4. Branch protection rules
5. Insufficient permissions

**Resolution**:

**Diagnostic Steps**:
```bash
# 1. Test network connectivity
ping github.com

# 2. Test GitHub authentication
gh auth status

# 3. Test push manually
git push -u origin $(git branch --show-current)

# 4. Check remote configuration
git remote -v

# 5. Check branch protection
gh api repos/:owner/:repo/branches/$(git branch --show-current)/protection
```

**Fix Option 1 - Network Issues**:
```bash
# Wait for network to stabilize
# Retry push manually
git push -u origin $(git branch --show-current)

# If successful, retry PR creation
@~/.claude/skills/task-wrapup/SKILL.md
```

**Fix Option 2 - Authentication Issues**:
```bash
# Re-authenticate
gh auth login

# Retry push
git push -u origin $(git branch --show-current)

# Retry PR creation
@~/.claude/skills/task-wrapup/SKILL.md
```

**Fix Option 3 - Timeout Issues**:
If push is timing out due to large commits:
```bash
# Increase git timeout
git config --global http.postBuffer 524288000  # 500MB

# Retry push
git push -u origin $(git branch --show-current)

# Retry PR creation
@~/.claude/skills/task-wrapup/SKILL.md
```

**Fix Option 4 - Permission Issues**:
```bash
# Check repository permissions
gh api repos/:owner/:repo | grep -E '"permissions":|"push":'

# If you don't have push access, contact repository admin
```

**Prevention**:
- Ensure stable network before starting PR creation
- Keep commits reasonably sized
- Verify repository permissions before starting work

---

### Issue 6: "Pull request creation failed"

**Symptom**: PR creation fails with exit code 30

**Causes**:
1. PR already exists for this branch
2. Invalid PR title or body
3. Base branch doesn't exist
4. GitHub API timeout
5. Repository settings prevent PR creation

**Resolution**:

**Diagnostic Steps**:
```bash
# 1. Check if PR already exists
gh pr list --head $(git branch --show-current)

# 2. Check if base branch exists
gh api repos/:owner/:repo/branches | grep -E '"name":|"develop"'

# 3. Test PR creation manually
gh pr create --base develop --title "Test PR" --body "Test"

# 4. Check repository settings
gh repo view --json hasIssuesEnabled,hasWikiEnabled,hasProjectsEnabled
```

**Fix Option 1 - PR Already Exists**:
```bash
# List existing PRs for this branch
gh pr list --head $(git branch --show-current)

# View the existing PR
gh pr view

# If you want to update the PR description
gh pr edit --body "New description"
```

**Fix Option 2 - Invalid Base Branch**:
```bash
# Check available branches
gh api repos/:owner/:repo/branches | grep '"name":'

# Update configuration to use correct base branch
# Edit .task_wrapup_skill_data.json:
{
  "pull_request": {
    "default_parent_branch": "main"  # Change to correct branch
  }
}

# Retry PR creation
@~/.claude/skills/task-wrapup/SKILL.md
```

**Fix Option 3 - GitHub API Issues**:
```bash
# Check GitHub status
curl https://www.githubstatus.com/api/v2/status.json

# Wait for GitHub to stabilize, then retry
# Alternatively, create PR manually
gh pr create --base develop --title "Your Title" --body "Your Description"
```

**Prevention**:
- Check for existing PRs before creation
- Verify base branch name in configuration
- Monitor GitHub status for API issues

---

## Error Code Reference

Complete reference of exit codes from `pr-workflow.sh`:

| Exit Code | Meaning | Quick Fix |
|-----------|---------|-----------|
| 0 | Success | N/A - PR created successfully |
| 10 | `gh` CLI not installed | Install: `brew install gh` |
| 11 | Not authenticated with GitHub | Run: `gh auth login` |
| 12 | Uncommitted changes detected | Commit or stash changes |
| 13 | No commits to push | Make commits or check branch |
| 20 | Push to remote failed | Check network/auth, retry push |
| 30 | PR creation failed | Check if PR exists, verify base branch |

**Error Code Diagnostic Flow**:
```
Exit Code 10 → Install gh CLI → Retry
Exit Code 11 → Run gh auth login → Verify → Retry
Exit Code 12 → git status → Commit/Stash → Retry
Exit Code 13 → git log → Make commits → Retry
Exit Code 20 → Test network → Test auth → Manual push → Retry
Exit Code 30 → Check existing PR → Verify base → Manual create → Retry
```

---

## Diagnostic Procedures

### Full System Diagnostic

Run this comprehensive diagnostic to check all PR automation components:

```bash
#!/bin/bash
# PR Automation Full Diagnostic

echo "=== PR Automation Diagnostic ==="
echo

echo "1. Configuration Check"
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py validate
echo

echo "2. Session State Check"
if [ -f .task_session_state.json ]; then
    echo "✓ Session state exists"
    cat .task_session_state.json | python3 -m json.tool
else
    echo "✗ Session state missing"
fi
echo

echo "3. Git Status"
git status --short
echo

echo "4. Git Branch"
echo "Current: $(git branch --show-current)"
echo "Parent: $(cat .task_session_state.json 2>/dev/null | python3 -c 'import sys, json; print(json.load(sys.stdin).get("parent_branch", "N/A"))' 2>/dev/null || echo "N/A")"
echo

echo "5. Commits to Push"
PARENT=$(cat .task_session_state.json 2>/dev/null | python3 -c 'import sys, json; print(json.load(sys.stdin).get("parent_branch", "develop"))' 2>/dev/null || echo "develop")
git log origin/$PARENT..HEAD --oneline | wc -l | xargs echo "Commits ahead:"
echo

echo "6. GitHub CLI"
gh --version 2>&1 | head -1
gh auth status 2>&1 | grep "Logged in"
echo

echo "7. Existing PRs"
gh pr list --head $(git branch --show-current) 2>/dev/null || echo "No existing PRs"
echo

echo "=== End Diagnostic ==="
```

Save this as `diagnose-pr.sh` and run:
```bash
chmod +x diagnose-pr.sh
./diagnose-pr.sh
```

### Configuration Validation Diagnostic

```bash
#!/bin/bash
# Validate PR Configuration

CONFIG_FILE=".task_wrapup_skill_data.json"

echo "=== Configuration Validation ==="
echo

if [ ! -f "$CONFIG_FILE" ]; then
    echo "✗ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

echo "1. Schema Version"
cat "$CONFIG_FILE" | python3 -c 'import sys, json; print(json.load(sys.stdin).get("schema_version", "N/A"))'
echo

echo "2. Pull Request Configuration"
cat "$CONFIG_FILE" | python3 -c '
import sys, json

config = json.load(sys.stdin)
pr_config = config.get("pull_request", {})

print(f"  enabled: {pr_config.get(\"enabled\", \"N/A\")}")
print(f"  default_parent_branch: {pr_config.get(\"default_parent_branch\", \"N/A\")}")
print(f"  auto_checkout_parent: {pr_config.get(\"auto_checkout_parent\", \"N/A\")}")
print(f"  cleanup_session_state: {pr_config.get(\"cleanup_session_state\", \"N/A\")}")
print(f"  draft: {pr_config.get(\"draft\", \"N/A\")}")
print(f"  title_template: {pr_config.get(\"title_template\", \"N/A\")}")
print(f"  body_template: {pr_config.get(\"body_template\", \"N/A\")}")
'
echo

echo "3. Validation Test"
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py validate
echo

echo "=== End Validation ==="
```

### Session State Validation Diagnostic

```bash
#!/bin/bash
# Validate Session State

STATE_FILE=".task_session_state.json"

echo "=== Session State Validation ==="
echo

if [ ! -f "$STATE_FILE" ]; then
    echo "✗ Session state file not found: $STATE_FILE"
    exit 1
fi

echo "1. File Permissions"
ls -l "$STATE_FILE"
echo

echo "2. JSON Validity"
if cat "$STATE_FILE" | python3 -m json.tool > /dev/null 2>&1; then
    echo "✓ Valid JSON"
else
    echo "✗ Invalid JSON"
    exit 1
fi
echo

echo "3. Schema Fields"
cat "$STATE_FILE" | python3 -c '
import sys, json

state = json.load(sys.stdin)

required = ["schema_version", "created_at", "feature_branch", "parent_branch"]
optional = ["issue_number", "github_issue"]

print("Required fields:")
for field in required:
    value = state.get(field)
    status = "✓" if field in state else "✗"
    print(f"  {status} {field}: {value}")

print("\nOptional fields:")
for field in optional:
    value = state.get(field)
    print(f"  {field}: {value}")
'
echo

echo "4. Branch Verification"
FEATURE=$(cat "$STATE_FILE" | python3 -c 'import sys, json; print(json.load(sys.stdin)["feature_branch"])')
PARENT=$(cat "$STATE_FILE" | python3 -c 'import sys, json; print(json.load(sys.stdin)["parent_branch"])')
CURRENT=$(git branch --show-current)

echo "  Feature branch (from state): $FEATURE"
echo "  Parent branch (from state): $PARENT"
echo "  Current branch (from git): $CURRENT"

if [ "$FEATURE" == "$CURRENT" ]; then
    echo "  ✓ On correct feature branch"
else
    echo "  ✗ Not on feature branch from state"
fi
echo

echo "=== End Validation ==="
```

---

## Manual Recovery

### Recovering from Failed PR Creation

If automated PR creation fails, you can create PR manually and clean up:

**Step 1: Create PR Manually**
```bash
# Get parent branch from session state
PARENT=$(cat .task_session_state.json | python3 -c 'import sys, json; print(json.load(sys.stdin)["parent_branch"])')

# Push branch if not already pushed
git push -u origin $(git branch --show-current)

# Create PR manually
gh pr create --base "$PARENT" --title "Your PR Title" --body "Your PR Description"
```

**Step 2: Clean Up Session State** (if `cleanup_session_state: true`):
```bash
# Remove session state file
rm .task_session_state.json
```

**Step 3: Checkout Parent Branch** (if `auto_checkout_parent: true`):
```bash
# Checkout parent branch
git checkout "$PARENT"
```

### Recovering from Partial Completion

If PR creation partially completed (e.g., push succeeded but PR creation failed):

**Scenario 1: Branch Pushed, PR Not Created**
```bash
# Branch is on remote, just create PR
gh pr create --base develop --title "Your Title" --body "Your Description"

# Clean up session state
rm .task_session_state.json

# Checkout parent if desired
git checkout develop
```

**Scenario 2: PR Created, Cleanup Failed**
```bash
# PR exists, just clean up session state
rm .task_session_state.json

# Checkout parent if desired
git checkout develop
```

**Scenario 3: Everything Failed**
```bash
# Start over with manual process
# 1. Ensure commits are made
git log --oneline -n 5

# 2. Push branch
git push -u origin $(git branch --show-current)

# 3. Create PR
gh pr create --base develop --title "Your Title" --body "Your Description"

# 4. Clean up
rm .task_session_state.json
git checkout develop
```

### Recovering from Configuration Issues

If configuration is invalid or corrupted:

**Option 1: Fix Existing Configuration**
```bash
# Validate configuration
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py validate

# Edit configuration manually
nano .task_wrapup_skill_data.json

# Add or fix pull_request section:
{
  "pull_request": {
    "enabled": true,
    "default_parent_branch": "develop",
    "auto_checkout_parent": true,
    "cleanup_session_state": true,
    "draft": false,
    "title_template": null,
    "body_template": null
  }
}

# Validate again
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py validate
```

**Option 2: Reset to Default Configuration**
```bash
# Backup existing config
cp .task_wrapup_skill_data.json .task_wrapup_skill_data.json.backup

# Create new config with defaults
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py create --project-name "Your Project"

# Manually restore any custom settings from backup
```

---

## Debug Mode

### Enabling Debug Output

Add debug output to PR workflow script:

```bash
# Run pr-workflow.sh with bash debug mode
bash -x ~/.claude/skills/task-wrapup/scripts/pr-workflow.sh develop
```

### Verbose Git Operations

```bash
# Enable git verbose output
export GIT_TRACE=1
export GIT_CURL_VERBOSE=1

# Run PR creation
@~/.claude/skills/task-wrapup/SKILL.md

# Disable after debugging
unset GIT_TRACE
unset GIT_CURL_VERBOSE
```

### GitHub CLI Debug Mode

```bash
# Enable gh CLI debug output
export GH_DEBUG=1

# Run PR creation
@~/.claude/skills/task-wrapup/SKILL.md

# Disable after debugging
unset GH_DEBUG
```

### Python Script Debug Mode

```bash
# Run config manager with verbose output
python3 -u ~/.claude/skills/task-wrapup/scripts/config_manager.py validate
```

---

## FAQ

### Q1: Can I create PR without session state?

**A**: Yes. If session state doesn't exist, the system falls back to `default_parent_branch` from configuration. However, this is not recommended as it may target the wrong branch.

**Best Practice**: Always use task-start skill to create session state.

### Q2: Can I manually edit session state?

**A**: Yes, but not recommended. Session state is automatically managed. Manual edits can cause issues.

**When Manual Edit Is Acceptable**:
- Correcting wrong parent branch before PR creation
- Adding GitHub issue metadata

**How to Edit Safely**:
```bash
# 1. Validate JSON before editing
cat .task_session_state.json | python3 -m json.tool

# 2. Edit file
nano .task_session_state.json

# 3. Validate JSON after editing
cat .task_session_state.json | python3 -m json.tool

# 4. Verify schema fields are correct
```

### Q3: What happens if PR already exists?

**A**: The script detects existing PRs and gracefully handles it:
- Displays warning message
- Shows existing PR URL
- Exits with code 0 (success)
- Does NOT create duplicate PR

### Q4: Can I create multiple PRs from same branch?

**A**: No. GitHub allows only one PR per branch. If you need multiple PRs:
1. Create new branch for each PR
2. Each branch gets its own PR

### Q5: How do I change parent branch after task started?

**A**: Edit session state file:
```bash
# Option 1: Edit session state
nano .task_session_state.json
# Change "parent_branch" value

# Option 2: Delete session state and rely on config default
rm .task_session_state.json
```

### Q6: Can I disable PR automation temporarily?

**A**: Yes, set `enabled: false` in configuration:
```json
{
  "pull_request": {
    "enabled": false
  }
}
```

Then create PRs manually with `gh pr create`.

### Q7: What if I want to keep session state after PR creation?

**A**: Set `cleanup_session_state: false` in configuration:
```json
{
  "pull_request": {
    "cleanup_session_state": false
  }
}
```

**Use Case**: Multiple PRs from same branch (not recommended) or preserving state for reference.

### Q8: Can I customize PR title and body?

**A**: Not yet in v2.0.0. Custom templates are planned for future release.

**Current Workaround**:
1. Let automation create PR with default title/body
2. Edit PR manually: `gh pr edit --title "New Title" --body "New Body"`

**Future Feature**: `title_template` and `body_template` configuration fields.

### Q9: What if checkout fails after PR creation?

**A**: Checkout failure doesn't affect PR creation. PR is already created successfully.

**Fix**:
```bash
# Manually checkout parent branch
git checkout develop

# Or stay on feature branch if you prefer
```

### Q10: How do I disable auto-checkout after PR?

**A**: Set `auto_checkout_parent: false` in configuration:
```json
{
  "pull_request": {
    "auto_checkout_parent": false
  }
}
```

---

## Advanced Troubleshooting

### Issue: Session State JSON Parse Error

**Symptom**: Python error when reading `.task_session_state.json`

**Diagnostic**:
```bash
# Test JSON validity
cat .task_session_state.json | python3 -m json.tool
```

**Common Causes**:
1. **Trailing comma**: JSON doesn't allow trailing commas
```json
{
  "feature_branch": "test",
  "parent_branch": "develop",  ← Remove this comma
}
```

2. **Missing quotes**: All keys and string values must be quoted
```json
{
  feature_branch: "test"  ← Wrong
  "feature_branch": "test"  ← Correct
}
```

3. **Invalid escaping**: Escape special characters properly
```json
{
  "title": "Fix \"bug\""  ← Correct
}
```

**Fix**:
```bash
# Recreate session state with correct format
cat > .task_session_state.json <<'EOF'
{
  "schema_version": "1.0",
  "created_at": "2025-11-15T10:30:00Z",
  "feature_branch": "feature/current-branch",
  "parent_branch": "develop",
  "issue_number": null,
  "github_issue": null
}
EOF

# Validate
cat .task_session_state.json | python3 -m json.tool
```

### Issue: Permission Denied on Session State File

**Symptom**: Cannot read or write `.task_session_state.json`

**Diagnostic**:
```bash
# Check file permissions
ls -l .task_session_state.json

# Check ownership
stat .task_session_state.json
```

**Fix**:
```bash
# Fix permissions
chmod 644 .task_session_state.json

# Fix ownership (if needed)
sudo chown $USER:$USER .task_session_state.json
```

### Issue: Wrong Branch in Session State

**Symptom**: Session state shows wrong feature or parent branch

**Diagnostic**:
```bash
# Compare session state to actual git state
echo "Session state:"
cat .task_session_state.json | python3 -c 'import sys, json; s=json.load(sys.stdin); print(f"Feature: {s[\"feature_branch\"]}\nParent: {s[\"parent_branch\"]}")'

echo "\nActual git state:"
echo "Current: $(git branch --show-current)"
echo "Parent: (check git history or remote)"
```

**Fix**:
```bash
# Edit session state to correct values
nano .task_session_state.json

# Or delete and recreate
rm .task_session_state.json
# Use task-start skill to create new session state
```

### Issue: Network Timeout During PR Creation

**Symptom**: PR creation times out after 60 seconds

**Diagnostic**:
```bash
# Test GitHub API response time
time gh api user

# Test repository access time
time gh repo view
```

**Fix Option 1 - Increase Timeout**:
Edit `~/.claude/skills/task-wrapup/scripts/pr-workflow.sh`:
```bash
# Change line 45
readonly TIMEOUT=120  # Increase from 60 to 120 seconds
```

**Fix Option 2 - Retry**:
```bash
# Wait for network to stabilize
# Manually create PR
gh pr create --base develop --title "Your Title" --body "Your Body"
```

### Issue: Branch Protection Prevents Push

**Symptom**: Push fails with "protected branch" error

**Diagnostic**:
```bash
# Check branch protection settings
gh api repos/:owner/:repo/branches/$(git branch --show-current)/protection
```

**Understanding**:
Feature branches typically shouldn't be protected. If they are, contact repository admin.

**Workaround**:
```bash
# Push to differently named branch
git checkout -b feature/alternative-name
git push -u origin feature/alternative-name

# Update session state
cat > .task_session_state.json <<EOF
{
  "schema_version": "1.0",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "feature_branch": "feature/alternative-name",
  "parent_branch": "develop",
  "issue_number": null,
  "github_issue": null
}
EOF

# Retry PR creation
@~/.claude/skills/task-wrapup/SKILL.md
```

### Issue: Stale Session State from Old Task

**Symptom**: Session state references branches or commits that no longer exist

**Diagnostic**:
```bash
# Check if branches in session state exist
STATE_FEATURE=$(cat .task_session_state.json | python3 -c 'import sys, json; print(json.load(sys.stdin)["feature_branch"])')
STATE_PARENT=$(cat .task_session_state.json | python3 -c 'import sys, json; print(json.load(sys.stdin)["parent_branch"])')

echo "Checking feature branch: $STATE_FEATURE"
git branch --list "$STATE_FEATURE"

echo "Checking parent branch: $STATE_PARENT"
git branch --list "$STATE_PARENT"
```

**Fix**:
```bash
# Delete stale session state
rm .task_session_state.json

# Create new session state with current branch
# Use task-start skill to properly initialize
```

---

## Getting Help

If you encounter issues not covered in this guide:

1. **Check Logs**:
   - pr-workflow.sh output
   - GitHub CLI debug output (`GH_DEBUG=1`)
   - Git trace output (`GIT_TRACE=1`)

2. **Run Full Diagnostic**:
   ```bash
   ./diagnose-pr.sh > diagnostic-output.txt
   ```

3. **Gather Information**:
   - Configuration: `cat .task_wrapup_skill_data.json`
   - Session state: `cat .task_session_state.json`
   - Git status: `git status`
   - GitHub CLI status: `gh auth status`

4. **Consult Documentation**:
   - PR_AUTOMATION_GUIDE.md - Feature overview
   - SESSION_STATE_SCHEMA.md - State file specification
   - task-start/SKILL.md - Task initialization

5. **Report Issues**:
   Include diagnostic output, configuration, session state, and error messages when reporting issues.

---

**Version**: 2.0.0
**Last Updated**: 2025-11-15
**Related Documentation**:
- [PR_AUTOMATION_GUIDE.md](PR_AUTOMATION_GUIDE.md) - Feature overview and usage
- [SESSION_STATE_SCHEMA.md](SESSION_STATE_SCHEMA.md) - Session state specification
- [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) - Upgrading from manual PR creation
