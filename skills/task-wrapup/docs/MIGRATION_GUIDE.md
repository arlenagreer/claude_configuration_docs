# Migration Guide: Automated Pull Request Creation

**Version**: 2.0.0
**Audience**: Existing task-wrapup skill users
**Migration Time**: 5-10 minutes

---

## Table of Contents

1. [What's Changed](#whats-changed)
2. [Before vs After](#before-vs-after)
3. [Prerequisites](#prerequisites)
4. [Migration Steps](#migration-steps)
5. [Testing Your Migration](#testing-your-migration)
6. [Backward Compatibility](#backward-compatibility)
7. [Common Migration Issues](#common-migration-issues)
8. [Rollback Procedure](#rollback-procedure)
9. [Getting Help](#getting-help)

---

## What's Changed

### New in v2.0.0

**Automated Pull Request Creation**:
- ✅ **Automatic PR creation** from session state when task wraps up
- ✅ **Auto-checkout to parent branch** after PR creation (configurable)
- ✅ **Session state cleanup** removes `.task_session_state.json` automatically
- ✅ **Comprehensive error handling** with specific exit codes
- ✅ **Network timeout protection** prevents hanging on network issues

### What Stayed the Same

**Everything else works exactly as before**:
- ✅ Summary generation from git commits, todos, file changes
- ✅ Email notifications to team members
- ✅ SMS notifications for critical updates
- ✅ Worklog time tracking
- ✅ Documentation updates
- ✅ All existing configuration options

### Breaking Changes

**None** - This is a **backward-compatible** upgrade. You can:
- Keep using manual PR creation workflows
- Gradually adopt automated PR creation
- Mix both approaches (some projects auto, some manual)

---

## Before vs After

### Old Workflow (Manual PR Creation)

```bash
# 1. Start task
task-start "user authentication"

# 2. Do work...
# (coding, committing, testing)

# 3. Wrap up
task-wrapup
# → Generates summary
# → Sends notifications
# → Logs work time
# → Updates docs

# 4. MANUALLY create PR
gh pr create --base develop --title "User Authentication" --body "..."

# 5. MANUALLY switch back to develop
git checkout develop
```

**Pain Points**:
- ❌ Manual PR creation is repetitive
- ❌ Remembering correct parent branch
- ❌ Crafting PR title/body each time
- ❌ Switching branches manually
- ❌ Easy to forget steps

### New Workflow (Automated PR Creation)

```bash
# 1. Start task
task-start "user authentication"
# → Creates session state with parent branch info

# 2. Do work...
# (coding, committing, testing)

# 3. Wrap up
task-wrapup
# → Generates summary
# → Sends notifications
# → Logs work time
# → Updates docs
# → CREATES PR AUTOMATICALLY
# → SWITCHES TO PARENT BRANCH AUTOMATICALLY
# → CLEANS UP SESSION STATE

# Done! PR created and you're back on develop
```

**Benefits**:
- ✅ One command does everything
- ✅ Parent branch remembered from task-start
- ✅ PR title/body auto-generated or templated
- ✅ Automatic branch switching
- ✅ No forgotten steps

---

## Prerequisites

### Required

1. **GitHub CLI installed and authenticated**:
```bash
# Check if installed
gh --version

# If not installed
brew install gh

# Authenticate
gh auth login
```

2. **Git repository with GitHub remote**:
```bash
# Check remote
git remote -v
# Should show github.com remote
```

3. **Latest task-wrapup skill version**:
```bash
# Check version
grep "version:" ~/.claude/skills/task-wrapup/SKILL.md
# Should show 2.0.0 or higher
```

### Optional

**Using task-start skill** for best experience:
- Session state is created automatically by task-start
- Parent branch tracking works seamlessly
- GitHub issue integration works automatically

**Without task-start**, you can still use PR automation by manually creating `.task_session_state.json`.

---

## Migration Steps

### Step 1: Update Configuration (3 minutes)

**Option A: Interactive Update**
```bash
# Navigate to your project
cd /path/to/your/project

# Update configuration
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py show
```

**Option B: Manual Edit**

Edit `.task_wrapup_skill_data.json` in your project root:

```json
{
  "schema_version": "1.0",
  "project_name": "YourProject",

  "pull_request": {
    "enabled": true,
    "default_parent_branch": "develop",
    "auto_checkout_parent": true,
    "cleanup_session_state": true,
    "draft": false,
    "title_template": null,
    "body_template": null
  },

  "summary_generation": { ... },
  "communication": { ... },
  "worklog": { ... },
  "documentation": { ... }
}
```

**Configuration Options**:

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `enabled` | boolean | `true` | Enable/disable PR automation |
| `default_parent_branch` | string | `"develop"` | Default branch for PRs |
| `auto_checkout_parent` | boolean | `true` | Auto-switch after PR creation |
| `cleanup_session_state` | boolean | `true` | Auto-remove session state file |
| `draft` | boolean | `false` | Create draft PRs by default |
| `title_template` | string/null | `null` | Custom PR title template |
| `body_template` | string/null | `null` | Custom PR body template |

**Recommended Settings**:
```json
{
  "enabled": true,
  "default_parent_branch": "develop",
  "auto_checkout_parent": true,
  "cleanup_session_state": true,
  "draft": false,
  "title_template": null,
  "body_template": null
}
```

### Step 2: Validate Configuration (1 minute)

```bash
# Validate configuration
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py validate

# Expected output:
# {
#   "status": "success",
#   "valid": true,
#   "errors": []
# }
```

**If validation fails**, see [Common Migration Issues](#common-migration-issues).

### Step 3: Add to .gitignore (1 minute)

Add session state file to your project's `.gitignore`:

```bash
# Navigate to project root
cd /path/to/your/project

# Add to .gitignore
echo "" >> .gitignore
echo "# Task-wrapup session state (local only)" >> .gitignore
echo ".task_session_state.json" >> .gitignore

# Commit change
git add .gitignore
git commit -m "Add task-wrapup session state to gitignore"
```

**Why?** Session state is local-only and should not be committed to version control.

### Step 4: Test GitHub CLI (1 minute)

```bash
# Test authentication
gh auth status

# Expected output:
# ✓ Logged in to github.com as YOUR_USERNAME (oauth_token)
# ✓ Git operations for github.com configured to use https protocol.

# Test PR listing
gh pr list

# Should succeed (even if no PRs exist)
```

**If GitHub CLI fails**, see [Prerequisites](#prerequisites) or [Troubleshooting](TROUBLESHOOTING_PR.md).

---

## Testing Your Migration

### Test 1: Dry Run (2 minutes)

Test without creating actual PR:

1. **Create test branch**:
```bash
git checkout -b test-pr-automation
```

2. **Make test commit**:
```bash
echo "# Test PR Automation" > TEST_PR.md
git add TEST_PR.md
git commit -m "Test PR automation migration"
```

3. **Create session state manually**:
```bash
cat > .task_session_state.json <<EOF
{
  "schema_version": "1.0",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "feature_branch": "test-pr-automation",
  "parent_branch": "develop",
  "issue_number": null,
  "github_issue": null
}
EOF
```

4. **Test PR workflow script**:
```bash
~/.claude/skills/task-wrapup/scripts/pr-workflow.sh develop test-pr-automation "Test PR Automation" "Testing automated PR creation migration"
```

5. **Expected output**:
```
═══════════════════════════════════════════
  Pull Request Creation Workflow
═══════════════════════════════════════════

Configuration:
   Parent Branch:  develop
   Feature Branch: test-pr-automation
   Draft PR:       false
   PR Title:       Test PR Automation

Running prerequisite checks...

✅ GitHub CLI is installed
✅ Authenticated with GitHub
✅ No uncommitted changes
✅ 1 commit(s) ready to push (new branch)

ℹ️  Pushing test-pr-automation to origin...
✅ Pushed test-pr-automation to origin

ℹ️  Creating pull request...
✅ Pull request created successfully
ℹ️  PR URL: https://github.com/YOUR_ORG/YOUR_REPO/pull/XXX

═══════════════════════════════════════════
  Pull Request Workflow Complete
═══════════════════════════════════════════
```

6. **Cleanup**:
```bash
# Close test PR
gh pr close test-pr-automation

# Delete test branch
git checkout develop
git branch -D test-pr-automation
git push origin --delete test-pr-automation

# Remove test file
rm -f .task_session_state.json TEST_PR.md
```

### Test 2: Full Workflow (5 minutes)

Test complete task-start → work → task-wrapup flow:

1. **Start test task**:
```bash
# If you have task-start skill
@~/.claude/skills/task-start/SKILL.md "test pr migration"

# Or manually create branch and session state
git checkout -b feature/test-pr-migration
cat > .task_session_state.json <<EOF
{
  "schema_version": "1.0",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "feature_branch": "feature/test-pr-migration",
  "parent_branch": "develop",
  "issue_number": null,
  "github_issue": null
}
EOF
```

2. **Make meaningful changes**:
```bash
# Create test file
echo "# PR Migration Test" > MIGRATION_TEST.md
git add MIGRATION_TEST.md
git commit -m "Test migration workflow"
```

3. **Wrap up task**:
```bash
@~/.claude/skills/task-wrapup/SKILL.md
```

4. **Verify results**:
```bash
# Check current branch (should be develop if auto_checkout_parent: true)
git branch --show-current

# Check session state (should be deleted if cleanup_session_state: true)
ls -la .task_session_state.json

# Check PR created
gh pr list --head feature/test-pr-migration
```

5. **Expected outcomes**:
- ✅ PR created successfully
- ✅ Switched back to develop (if auto_checkout_parent: true)
- ✅ Session state cleaned up (if cleanup_session_state: true)
- ✅ Summary generated and sent
- ✅ Notifications delivered

6. **Cleanup**:
```bash
# Close test PR
gh pr close feature/test-pr-migration

# Delete feature branch
git branch -D feature/test-pr-migration
git push origin --delete feature/test-pr-migration

# Remove test file
git checkout develop
git pull
rm -f MIGRATION_TEST.md
git add MIGRATION_TEST.md
git commit -m "Clean up migration test"
```

---

## Backward Compatibility

### Using Both Workflows

You can **mix automated and manual PR creation** in the same project:

**Automated (default)**:
```json
{
  "pull_request": {
    "enabled": true
  }
}
```

**Manual (disable for specific task)**:
```json
{
  "pull_request": {
    "enabled": false
  }
}
```

**Or toggle temporarily**:
```bash
# Disable PR automation for this task only
export SKIP_PR_CREATION=true
task-wrapup
```

### Gradual Migration Strategy

**Strategy**: Adopt automation project-by-project

1. **Week 1**: Test on non-critical project
2. **Week 2**: Adopt on personal projects
3. **Week 3**: Expand to team projects
4. **Week 4**: Full migration complete

**Per-project configuration**:
- Each project has its own `.task_wrapup_skill_data.json`
- Configure automation independently per project
- No global setting required

### Manual PR Creation Still Works

If you prefer manual PR creation, you can:

**Option 1**: Disable automation globally
```json
{
  "pull_request": {
    "enabled": false
  }
}
```

**Option 2**: Don't use task-start skill
- Without session state, PR automation is skipped
- Manual PR creation workflow unchanged

**Option 3**: Ignore PR automation
- Let automation fail gracefully
- Create PR manually afterward
- No harm done

---

## Common Migration Issues

### Issue 1: Configuration Validation Fails

**Symptom**:
```
{
  "status": "error",
  "valid": false,
  "errors": ["pull_request.enabled must be a boolean"]
}
```

**Cause**: Invalid configuration field types

**Fix**:
1. **Check field types**:
```bash
cat .task_wrapup_skill_data.json | python3 -m json.tool | grep -A 10 '"pull_request"'
```

2. **Fix field types**:
- `enabled`: Must be `true` or `false` (not `"true"` or `"false"`)
- `draft`: Must be `true` or `false`
- `auto_checkout_parent`: Must be `true` or `false`
- `cleanup_session_state`: Must be `true` or `false`
- `default_parent_branch`: Must be string with content (not empty `""`)
- `title_template`: Must be string or `null`
- `body_template`: Must be string or `null`

3. **Validate again**:
```bash
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py validate
```

### Issue 2: GitHub CLI Not Authenticated

**Symptom**:
```
❌ Error: Not authenticated with GitHub. Run: gh auth login
Exit code: 11
```

**Cause**: GitHub CLI not authenticated

**Fix**:
```bash
# Authenticate with GitHub
gh auth login

# Follow prompts:
# 1. Choose GitHub.com
# 2. Choose HTTPS or SSH
# 3. Authenticate via web browser
# 4. Complete authentication

# Verify
gh auth status
```

### Issue 3: Old Configuration Schema

**Symptom**:
```
{
  "schema_version": "0.9",
  "pull_request": {}  # Missing
}
```

**Cause**: Configuration created before v2.0.0

**Fix**:
```bash
# Migration automatically adds pull_request section
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py show
# Configuration will be migrated automatically

# Verify migration
cat .task_wrapup_skill_data.json | python3 -m json.tool | grep -A 10 '"pull_request"'
```

### Issue 4: Session State Not Created

**Symptom**:
```
⚠️  Warning: No session state found at .task_session_state.json
Skipping PR creation - use manual workflow
```

**Cause**: Using task-wrapup without task-start

**Fix Option 1**: Use task-start skill
```bash
@~/.claude/skills/task-start/SKILL.md "feature description"
```

**Fix Option 2**: Manually create session state
```bash
cat > .task_session_state.json <<EOF
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

**Fix Option 3**: Disable PR automation
```json
{
  "pull_request": {
    "enabled": false
  }
}
```

### Issue 5: PR Already Exists

**Symptom**:
```
⚠️  Warning: Pull request already exists for this branch
ℹ️  Existing PR: https://github.com/org/repo/pull/123
```

**Cause**: PR already created (manually or automatically)

**Fix**: This is **not an error** - automation detects existing PR and skips creation

**No action needed** - continue with workflow

### Issue 6: Wrong Parent Branch

**Symptom**:
```
✅ Pull request created successfully
ℹ️  PR URL: https://github.com/org/repo/pull/123
# But PR targets wrong branch (e.g., main instead of develop)
```

**Cause**: Incorrect `default_parent_branch` in configuration

**Fix**:
1. **Update configuration**:
```json
{
  "pull_request": {
    "default_parent_branch": "develop"  // Correct branch
  }
}
```

2. **Update existing PR**:
```bash
gh pr edit 123 --base develop
```

### Issue 7: Network Timeout

**Symptom**:
```
❌ Error: Push timed out after 60s. Check your network connection.
Exit code: 20
```

**Cause**: Slow network or large push

**Fix**:
1. **Retry push**:
```bash
git push -u origin $(git branch --show-current)
```

2. **If still fails, increase timeout**:
```bash
# Edit pr-workflow.sh temporarily
# Change: readonly TIMEOUT=60
# To: readonly TIMEOUT=120

# Or push manually first
git push -u origin $(git branch --show-current)

# Then run task-wrapup again
```

---

## Rollback Procedure

If you need to revert to manual PR creation:

### Option 1: Disable Automation (Recommended)

**Keep skill, disable automation**:
```json
{
  "pull_request": {
    "enabled": false
  }
}
```

**Benefits**:
- ✅ All other task-wrapup features still work
- ✅ Easy to re-enable later
- ✅ No skill uninstallation needed

### Option 2: Complete Rollback

**Remove all automation components**:

1. **Remove configuration**:
```bash
# Edit .task_wrapup_skill_data.json
# Remove entire "pull_request" section
```

2. **Remove session state**:
```bash
rm -f .task_session_state.json
```

3. **Resume manual workflow**:
```bash
# Manual PR creation
gh pr create --base develop --title "..." --body "..."
```

**Rollback complete** - you're back to v1.x workflow

---

## Getting Help

### Documentation Resources

- **PR Automation Guide**: [PR_AUTOMATION_GUIDE.md](PR_AUTOMATION_GUIDE.md)
- **Troubleshooting Guide**: [TROUBLESHOOTING_PR.md](TROUBLESHOOTING_PR.md)
- **Configuration Reference**: See DEFAULT_CONFIG in `config_manager.py`

### Diagnostic Commands

```bash
# Full system diagnostic
~/.claude/skills/task-wrapup/scripts/diagnostic-full.sh

# Configuration validation
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py validate

# Session state validation
cat .task_session_state.json | python3 -m json.tool

# GitHub CLI check
gh auth status
gh pr list
```

### Gathering Information for Support

If you encounter issues, gather this information:

```bash
# 1. Configuration
cat .task_wrapup_skill_data.json | python3 -m json.tool

# 2. Session state
cat .task_session_state.json 2>/dev/null | python3 -m json.tool || echo "No session state"

# 3. Git status
git status
git branch --show-current
git log --oneline -5

# 4. GitHub CLI
gh --version
gh auth status

# 5. PR workflow logs (if available)
cat ~/.task-wrapup/pr-workflow.log 2>/dev/null || echo "No logs"
```

### Common Questions

**Q: Do I have to use automated PR creation?**
A: No - it's completely optional. Set `"enabled": false` to keep manual workflow.

**Q: Can I customize PR titles and bodies?**
A: Yes - use `title_template` and `body_template` in configuration.

**Q: What if I want to review PR before creation?**
A: Set `"draft": true` to create draft PRs, then convert to ready when satisfied.

**Q: Can I use this without task-start skill?**
A: Yes - manually create `.task_session_state.json` with required fields.

**Q: What happens if automation fails?**
A: Graceful fallback - you can create PR manually. No data loss, no broken workflow.

**Q: Can I mix automated and manual PR creation?**
A: Yes - configure per-project or toggle temporarily with `SKIP_PR_CREATION` env var.

---

## Migration Checklist

Use this checklist to track your migration progress:

- [ ] **Prerequisites verified**
  - [ ] GitHub CLI installed (`gh --version`)
  - [ ] GitHub CLI authenticated (`gh auth status`)
  - [ ] Git repository with GitHub remote (`git remote -v`)
  - [ ] Latest task-wrapup skill version (2.0.0+)

- [ ] **Configuration updated**
  - [ ] Added `pull_request` section to `.task_wrapup_skill_data.json`
  - [ ] Set `enabled: true`
  - [ ] Set `default_parent_branch` correctly
  - [ ] Configured `auto_checkout_parent` and `cleanup_session_state`
  - [ ] Validation passes (`config_manager.py validate`)

- [ ] **Repository prepared**
  - [ ] Added `.task_session_state.json` to `.gitignore`
  - [ ] Committed `.gitignore` changes

- [ ] **Testing completed**
  - [ ] Dry run test passed (Test 1)
  - [ ] Full workflow test passed (Test 2)
  - [ ] PR created successfully
  - [ ] Auto-checkout worked (if enabled)
  - [ ] Session state cleaned up (if enabled)

- [ ] **Migration complete**
  - [ ] Ready to use automated PR creation in real workflows
  - [ ] Team members notified (if team project)
  - [ ] Documentation bookmarked for reference

---

## Conclusion

**Congratulations!** You've successfully migrated to automated PR creation.

**What you've gained**:
- ✅ Faster task completion
- ✅ Fewer manual steps
- ✅ Consistent PR creation
- ✅ Reduced cognitive load
- ✅ Better workflow integration

**Next steps**:
1. Use new workflow in daily work
2. Customize templates if needed
3. Share feedback for improvements
4. Help teammates migrate

**Remember**:
- Automation is **optional** - use what works for you
- Manual workflow still works perfectly
- Mix and match based on project needs
- Help available in troubleshooting guide

---

**Happy automating!** 🚀
