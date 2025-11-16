# Pull Request Automation Guide

## Overview

The task-wrapup skill includes comprehensive pull request (PR) automation that seamlessly integrates with the task-start skill to create GitHub pull requests with correct target branches, professional descriptions, and optional draft mode.

**Key Features**:
- **Automatic Parent Branch Detection**: Tracks the branch you started from and targets PRs correctly
- **Session State Persistence**: Maintains context across task-start and task-wrapup workflows
- **GitHub Issue Integration**: Automatically links PRs to GitHub Issues when available
- **Configurable Behavior**: Control PR creation through `.task_wrapup_skill_data.json`
- **Professional PR Templates**: Generate well-formatted PR descriptions with summaries and test plans
- **Draft Mode Support**: Create draft PRs for work-in-progress features
- **Error Recovery**: Comprehensive error handling with clear exit codes and messages

## Architecture

### Two-Skill Integration

The PR automation system spans two skills:

**task-start skill** (`~/.claude/skills/task-start/`):
- Creates feature branches from base branch (typically `develop`)
- Captures parent branch before creating feature branch
- Generates `.task_session_state.json` with branch relationship metadata
- Stores GitHub Issue information if available

**task-wrapup skill** (`~/.claude/skills/task-wrapup/`):
- Reads session state to determine PR target branch
- Creates PR via GitHub CLI (`gh pr create`)
- Handles PR description generation and formatting
- Cleans up session state after successful PR creation

### Session State Tracking

**File**: `.task_session_state.json` (project root)

**Purpose**: Maintains the relationship between feature branch and parent branch to enable correct PR targeting.

**Schema**: See [SESSION_STATE_SCHEMA.md](SESSION_STATE_SCHEMA.md) for complete specification.

**Example**:
```json
{
  "schema_version": "1.0",
  "created_at": "2025-01-15T10:30:00Z",
  "feature_branch": "feature/456-user-authentication",
  "parent_branch": "develop",
  "issue_number": 456,
  "github_issue": {
    "number": 456,
    "title": "Implement user authentication",
    "labels": ["enhancement", "high-priority"]
  }
}
```

**Lifecycle**:
1. **Created**: By task-start skill during branch creation
2. **Read**: By task-wrapup skill during PR creation
3. **Deleted**: By task-wrapup skill after successful PR (if `cleanup_session_state: true`)

**Important**: `.task_session_state.json` should be in `.gitignore` (local session state only).

## Configuration

### Pull Request Configuration Section

**File**: `.task_wrapup_skill_data.json` (project root)

**Schema**:
```json
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
```

### Configuration Fields

#### `enabled` (boolean, required)
- **Purpose**: Enable or disable PR creation during task-wrapup
- **Default**: `true`
- **When to disable**: If you don't want task-wrapup to create PRs automatically
- **Example**: `"enabled": false`

#### `default_parent_branch` (string, required)
- **Purpose**: Fallback parent branch when session state is unavailable
- **Default**: `"develop"`
- **Validation**: Must be non-empty string
- **Common values**: `"develop"`, `"main"`, `"master"`, `"release/v2.0"`
- **Usage**: When `.task_session_state.json` is missing or corrupted, PRs target this branch
- **Example**: `"default_parent_branch": "main"`

#### `auto_checkout_parent` (boolean, required)
- **Purpose**: Automatically checkout parent branch after PR creation
- **Default**: `true`
- **Workflow**: After creating PR, switches back to parent branch (typically `develop`)
- **When to disable**: If you want to stay on feature branch after PR creation
- **Example**: `"auto_checkout_parent": false`

#### `cleanup_session_state` (boolean, required)
- **Purpose**: Delete `.task_session_state.json` after successful PR creation
- **Default**: `true`
- **Rationale**: Session state is no longer needed once PR is created
- **When to disable**: For debugging or if you want to preserve session metadata
- **Example**: `"cleanup_session_state": false`

#### `draft` (boolean, required)
- **Purpose**: Create PRs in draft mode by default
- **Default**: `false`
- **Draft PRs**: Marked as work-in-progress, cannot be merged until marked as ready
- **Use case**: When feature is incomplete but you want to share progress
- **Example**: `"draft": true`

#### `title_template` (string or null, optional)
- **Purpose**: Custom template for PR titles
- **Default**: `null` (auto-generated from commits and GitHub Issue)
- **Template variables**: Not yet implemented (reserved for future enhancement)
- **Example**: `"title_template": "[FEATURE] {issue_number} - {issue_title}"`

#### `body_template` (string or null, optional)
- **Purpose**: Custom template for PR descriptions
- **Default**: `null` (auto-generated with summary and test plan)
- **Template variables**: Not yet implemented (reserved for future enhancement)
- **Example**: `"body_template": "## Changes\n{summary}\n\n## Testing\n{test_plan}"`

### Configuration Management

**View current configuration**:
```bash
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py show
```

**Validate configuration**:
```bash
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py validate
```

**Update configuration manually**:
Edit `.task_wrapup_skill_data.json` directly and validate:
```bash
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py validate
```

**Configuration migration**:
- Old configurations without `pull_request` section are automatically migrated
- Migration adds all required fields with defaults
- No manual intervention required

## Workflow

### Complete Workflow: Task Start → Work → Task Wrapup → PR

```bash
# 1. Start new task (task-start skill)
@~/.claude/skills/task-start/SKILL.md "Implement user authentication"

# This creates:
# - Feature branch: feature/123-implement-user-authentication
# - Session state: .task_session_state.json with parent branch captured

# 2. Do your development work
# (make commits, implement features)

# 3. Wrap up task (task-wrapup skill)
@~/.claude/skills/task-wrapup/SKILL.md

# This will:
# - Generate summary of work completed
# - Read .task_session_state.json to determine parent branch
# - Create PR targeting the correct parent branch
# - Clean up session state (if cleanup_session_state: true)
# - Checkout parent branch (if auto_checkout_parent: true)
```

### Session State Workflow

**Step 1: Branch Creation (task-start)**
```bash
# User on develop branch
$ git branch
* develop

# task-start creates feature branch
$ @~/.claude/skills/task-start/SKILL.md "user authentication"

# Session state created:
$ cat .task_session_state.json
{
  "schema_version": "1.0",
  "created_at": "2025-01-15T10:30:00Z",
  "feature_branch": "feature/user-authentication",
  "parent_branch": "develop",
  "issue_number": null,
  "github_issue": null
}

# Now on feature branch
$ git branch
  develop
* feature/user-authentication
```

**Step 2: Development Work**
```bash
# Make commits
$ git commit -m "Add authentication models"
$ git commit -m "Implement JWT token generation"
$ git commit -m "Add login/logout endpoints"
```

**Step 3: PR Creation (task-wrapup)**
```bash
# Wrap up task
$ @~/.claude/skills/task-wrapup/SKILL.md

# task-wrapup skill:
# 1. Reads .task_session_state.json
# 2. Determines parent_branch = "develop"
# 3. Creates PR: feature/user-authentication → develop
# 4. Deletes .task_session_state.json (if cleanup_session_state: true)
# 5. Checks out develop (if auto_checkout_parent: true)

# Back on parent branch
$ git branch
* develop
  feature/user-authentication
```

### PR Creation Script

**Script**: `~/.claude/skills/task-wrapup/scripts/pr-workflow.sh`

**Usage**:
```bash
# With all arguments
pr-workflow.sh PARENT_BRANCH [FEATURE_BRANCH] [PR_TITLE] [PR_BODY] [DRAFT]

# Minimal (uses current branch)
pr-workflow.sh develop

# With custom PR details
pr-workflow.sh develop feature/123-auth "Add authentication" "Implements JWT auth" false

# Draft PR
pr-workflow.sh develop feature/wip-feature "WIP: New feature" "Work in progress" true
```

**Exit Codes**:
- `0`: Success - PR created or already exists
- `10`: GitHub CLI not installed
- `11`: Not authenticated with GitHub
- `12`: Uncommitted changes detected
- `13`: No commits to push
- `20`: Push to remote failed
- `30`: PR creation failed

**Prerequisite Checks**:
1. **GitHub CLI (gh)**: Checks if `gh` is installed
2. **Authentication**: Verifies GitHub authentication via `gh auth status`
3. **Uncommitted Changes**: Ensures all changes are committed
4. **Commits to Push**: Verifies there are commits to include in PR

**Error Handling**:
- **Timeouts**: 60-second timeout for push/PR operations
- **Network Issues**: Graceful handling with clear error messages
- **Already Exists**: Detects existing PRs and reports URL
- **Validation Failures**: Clear error messages with exit codes

## Usage Examples

### Example 1: Standard Feature Development

```bash
# 1. Start task with GitHub Issue
@~/.claude/skills/task-start/SKILL.md "Start task for issue #123"

# Creates:
# - Branch: feature/123-add-user-dashboard
# - Session state with issue_number: 123

# 2. Development work
# (make commits)

# 3. Create PR
@~/.claude/skills/task-wrapup/SKILL.md

# Result: PR created targeting develop with issue #123 linked
```

### Example 2: Hotfix Workflow

```bash
# Starting from main branch for hotfix
$ git checkout main
$ git branch
* main
  develop

# 1. Start hotfix
@~/.claude/skills/task-start/SKILL.md "Fix critical security issue"

# Session state captures parent_branch: "main"

# 2. Fix and commit

# 3. Create PR
@~/.claude/skills/task-wrapup/SKILL.md

# Result: PR targets main (not develop) because session state preserved parent
```

### Example 3: Draft PR for WIP

**Configuration**: Set `"draft": true` in `.task_wrapup_skill_data.json`

```json
{
  "pull_request": {
    "enabled": true,
    "draft": true
  }
}
```

```bash
# 1. Start task
@~/.claude/skills/task-start/SKILL.md "New experimental feature"

# 2. Partial implementation
# (commit work in progress)

# 3. Create draft PR
@~/.claude/skills/task-wrapup/SKILL.md

# Result: Draft PR created, cannot be merged until marked ready
```

### Example 4: Multiple Release Branches

```bash
# Working on release branch
$ git checkout release/v2.0
$ git branch
  main
  develop
* release/v2.0

# 1. Start task
@~/.claude/skills/task-start/SKILL.md "Release v2.0 bug fix"

# Session state captures parent_branch: "release/v2.0"

# 2. Fix and commit

# 3. Create PR
@~/.claude/skills/task-wrapup/SKILL.md

# Result: PR targets release/v2.0 (not develop or main)
```

### Example 5: Manual Parent Branch Override

**When session state is missing or incorrect**:

```bash
# Manually specify parent branch
pr-workflow.sh main feature/my-feature "Fix critical bug" "Emergency fix" false
```

**Result**: PR targets `main` regardless of session state.

## GitHub Issue Integration

### Automatic Issue Linking

When task-start is invoked with a GitHub Issue number:

```bash
@~/.claude/skills/task-start/SKILL.md "Start task for issue #456"
```

**Session state includes**:
```json
{
  "issue_number": 456,
  "github_issue": {
    "number": 456,
    "title": "Implement user authentication",
    "labels": ["enhancement", "high-priority"]
  }
}
```

**PR creation benefits**:
- **PR Title**: Auto-generated from issue title
- **PR Body**: Includes issue reference and links
- **GitHub Linking**: PR automatically linked to issue
- **Label Inheritance**: PR inherits relevant labels from issue

### Issue Reference Format

**PR Description includes**:
```markdown
## Summary
Implementation of user authentication system

## Related Issue
Closes #456

## Test Plan
- [ ] Test login functionality
- [ ] Test logout functionality
- [ ] Test token refresh
```

## Troubleshooting

### Common Issues

#### Issue: "No session state found"

**Symptoms**:
```
⚠️  Warning: No session state found, using default parent branch: develop
```

**Causes**:
1. `.task_session_state.json` was deleted
2. Task started outside task-start skill
3. Working in different directory than project root

**Solutions**:
1. **Use default**: PR will target `default_parent_branch` from config
2. **Manual specification**: Call `pr-workflow.sh` with explicit parent branch
3. **Recreate session state**: Manually create `.task_session_state.json`

**Prevention**: Always use task-start skill to create feature branches

#### Issue: "Uncommitted changes detected"

**Symptoms**:
```
❌ Error: Uncommitted changes detected. Please commit all changes before creating PR.
Exit Code: 12
```

**Causes**:
- Uncommitted files in working directory
- Staged but uncommitted changes

**Solutions**:
```bash
# Check status
git status

# Commit changes
git add .
git commit -m "Your commit message"

# Or stash if not ready to commit
git stash
```

#### Issue: "No commits to push"

**Symptoms**:
```
❌ Error: No commits to push. The feature branch has no commits compared to develop.
Exit Code: 13
```

**Causes**:
- Feature branch has no new commits
- All commits already pushed and merged

**Solutions**:
1. Make commits before creating PR
2. If work is complete, no PR needed
3. Check if PR already exists: `gh pr list`

#### Issue: "GitHub CLI not installed"

**Symptoms**:
```
❌ Error: GitHub CLI (gh) is not installed. Install with: brew install gh
Exit Code: 10
```

**Solution**:
```bash
# macOS
brew install gh

# Linux
# See https://cli.github.com/manual/installation

# Authenticate
gh auth login
```

#### Issue: "Push failed"

**Symptoms**:
```
❌ Error: Failed to push branch to remote. Check your network connection and permissions.
Exit Code: 20
```

**Causes**:
- Network connectivity issues
- Insufficient repository permissions
- Remote branch protection rules

**Solutions**:
1. Check network connection
2. Verify repository access: `gh repo view`
3. Check branch permissions in GitHub settings
4. Retry push: `git push -u origin feature/branch-name`

#### Issue: "PR creation failed"

**Symptoms**:
```
❌ Error: Failed to create PR: [error details]
Exit Code: 30
```

**Common Causes and Solutions**:

**Empty PR body**:
```bash
# Provide PR body explicitly
pr-workflow.sh develop feature/branch "Title" "Description of changes"
```

**Invalid parent branch**:
```bash
# Verify branch exists
git branch -a | grep develop

# Use correct parent branch name
pr-workflow.sh main feature/branch "Title" "Body"
```

**Network timeout**:
```bash
# Check GitHub status
curl -I https://api.github.com

# Retry PR creation
pr-workflow.sh develop
```

### Debug Mode

**Enable verbose output**:
```bash
# Add debug flag to pr-workflow.sh
bash -x ~/.claude/skills/task-wrapup/scripts/pr-workflow.sh develop
```

**Check session state**:
```bash
# View session state
cat .task_session_state.json | python3 -m json.tool

# Validate JSON syntax
python3 -c "import json; json.load(open('.task_session_state.json'))"
```

**Verify GitHub CLI**:
```bash
# Check authentication
gh auth status

# Test PR creation capability
gh pr list

# View repository info
gh repo view
```

### Manual Recovery

**If automation fails, create PR manually**:

```bash
# 1. Ensure changes are committed
git add .
git commit -m "Your changes"

# 2. Push to remote
git push -u origin feature/your-branch

# 3. Create PR via gh CLI
gh pr create --base develop --title "Your PR Title" --body "Your PR Description"

# Or create via GitHub web interface
# https://github.com/your-org/your-repo/compare/develop...feature/your-branch
```

## Best Practices

### 1. Always Use task-start Skill

**Why**: Ensures session state is created with correct parent branch tracking.

```bash
# ✅ Good
@~/.claude/skills/task-start/SKILL.md "New feature"

# ❌ Bad - Session state not created
git checkout -b feature/manual-branch
```

### 2. Keep Session State Clean

**Add to `.gitignore`**:
```bash
echo ".task_session_state.json" >> .gitignore
```

**Why**: Session state is local to your development environment, not for version control.

### 3. Configure Default Parent Branch

**Set appropriate default for your workflow**:

```json
{
  "pull_request": {
    "default_parent_branch": "develop"  // or "main" for your workflow
  }
}
```

**Why**: Provides fallback when session state is unavailable.

### 4. Use Draft Mode for WIP

**For incomplete work**:

```json
{
  "pull_request": {
    "draft": true
  }
}
```

**Why**: Prevents accidental merging of incomplete features.

### 5. Clean Up Session State

**Enable automatic cleanup**:

```json
{
  "pull_request": {
    "cleanup_session_state": true
  }
}
```

**Why**: Prevents stale session state from interfering with future tasks.

### 6. Commit Before Creating PR

**Always commit all changes**:

```bash
git status
git add .
git commit -m "Meaningful commit message"
```

**Why**: PR creation requires clean working directory.

### 7. Verify GitHub Authentication

**Before starting work**:

```bash
gh auth status
```

**Why**: Prevents PR creation failures due to authentication issues.

## Advanced Features

### Custom PR Templates

**Future Enhancement** (not yet implemented):

```json
{
  "pull_request": {
    "title_template": "[{labels}] #{issue_number} - {issue_title}",
    "body_template": "## Summary\n{summary}\n\n## Issue\nCloses #{issue_number}\n\n## Testing\n{test_plan}"
  }
}
```

**Template Variables** (planned):
- `{issue_number}`: GitHub Issue number
- `{issue_title}`: GitHub Issue title
- `{labels}`: Comma-separated issue labels
- `{summary}`: Auto-generated work summary
- `{test_plan}`: Auto-generated test checklist
- `{branch_name}`: Feature branch name
- `{parent_branch}`: Parent branch name

### Multiple PR Creation

**For multi-repository projects**:

```bash
# Create PRs in multiple repositories
for repo in frontend backend infrastructure; do
  cd $repo
  @~/.claude/skills/task-wrapup/SKILL.md
  cd ..
done
```

### PR Creation Hooks

**Future Enhancement** (not yet implemented):

**Pre-PR Hook**: Execute script before PR creation
```json
{
  "pull_request": {
    "pre_create_hook": "./scripts/pre-pr-checks.sh"
  }
}
```

**Post-PR Hook**: Execute script after PR creation
```json
{
  "pull_request": {
    "post_create_hook": "./scripts/notify-team.sh"
  }
}
```

## Migration Guide

### Upgrading from Manual PR Creation

**Before** (manual workflow):
```bash
git checkout -b feature/new-feature
# ... development work ...
git push -u origin feature/new-feature
gh pr create --base develop --title "New feature" --body "Description"
```

**After** (automated workflow):
```bash
@~/.claude/skills/task-start/SKILL.md "New feature"
# ... development work ...
@~/.claude/skills/task-wrapup/SKILL.md
# PR automatically created with correct parent branch
```

**Migration Steps**:
1. Install task-start and task-wrapup skills
2. Configure `.task_wrapup_skill_data.json` with `pull_request` section
3. Add `.task_session_state.json` to `.gitignore`
4. Start using task-start skill for new branches
5. Existing branches: Manually create `.task_session_state.json` if needed

### Upgrading Configuration

**Old configuration** (pre-v2.0):
```json
{
  "schema_version": "1.0",
  "project_name": "MyProject"
}
```

**Auto-migration**: Configuration automatically updated to include `pull_request` section:
```json
{
  "schema_version": "1.0",
  "project_name": "MyProject",
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
```

**No manual intervention required** - migration happens automatically on first use.

## Security Considerations

### GitHub Token Security

**PR creation requires GitHub authentication**:
- Uses GitHub CLI (`gh`) authentication
- Token stored securely by GitHub CLI
- Never stored in session state or configuration files

**Best Practices**:
- Use `gh auth login` to authenticate
- Use token with minimal required permissions
- Regularly rotate GitHub tokens
- Never commit tokens to version control

### Session State Security

**Session state contains project metadata**:
- Branch names (not sensitive)
- GitHub Issue numbers (public information)
- Timestamps (not sensitive)

**Best Practices**:
- Add to `.gitignore` to prevent accidental commits
- No sensitive data (credentials, tokens) stored in session state
- Safe to share within team for debugging

### Branch Protection

**Configure branch protection rules**:
- Require PR reviews before merge
- Require status checks to pass
- Prevent direct pushes to protected branches

**PR automation respects**:
- Branch protection rules
- Required reviews
- Status check requirements

## Performance Considerations

### Session State File Size

**Typical size**: 200-500 bytes (negligible)

**No performance impact**:
- Small JSON file (< 1KB)
- Read once during PR creation
- Written once during branch creation
- Deleted after PR creation

### Network Operations

**PR creation network calls**:
1. Push branch to remote (~1-5 seconds depending on commit size)
2. Create PR via GitHub API (~500ms - 2 seconds)

**Timeout handling**:
- 60-second timeout for push operations
- 60-second timeout for PR creation
- Automatic retry not implemented (manual retry required)

### Concurrent PR Creation

**Not recommended**: Creating multiple PRs simultaneously

**Why**: GitHub API rate limiting may cause failures

**Solution**: Create PRs sequentially with delays:
```bash
@~/.claude/skills/task-wrapup/SKILL.md
sleep 5
cd ../other-repo
@~/.claude/skills/task-wrapup/SKILL.md
```

## Changelog

### v2.0.0 (2025-01-15)

**Features**:
- ✅ Pull request automation with session state tracking
- ✅ Automatic parent branch detection
- ✅ GitHub Issue integration
- ✅ Configurable PR behavior
- ✅ Draft PR support
- ✅ Automatic session state cleanup
- ✅ Comprehensive error handling
- ✅ Prerequisite validation checks

**Configuration**:
- ✅ New `pull_request` configuration section
- ✅ Automatic migration from v1.0 configurations
- ✅ Validation for all PR configuration fields

**Scripts**:
- ✅ `pr-workflow.sh` - PR creation script
- ✅ `config_manager.py` - Configuration validation
- ✅ `branch-create.sh` - Session state generation

**Documentation**:
- ✅ PR_AUTOMATION_GUIDE.md (this document)
- ✅ SESSION_STATE_SCHEMA.md
- ✅ TROUBLESHOOTING_PR.md
- ✅ MIGRATION_GUIDE.md

### v1.0.0 (2025-01-10)

**Initial release**:
- Basic task-wrapup functionality
- Manual PR creation
- No session state tracking

## Support and Resources

### Documentation
- **Session State Schema**: [SESSION_STATE_SCHEMA.md](SESSION_STATE_SCHEMA.md)
- **Troubleshooting**: [TROUBLESHOOTING_PR.md](TROUBLESHOOTING_PR.md)
- **Migration Guide**: [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)

### Scripts
- **PR Workflow**: `~/.claude/skills/task-wrapup/scripts/pr-workflow.sh`
- **Config Manager**: `~/.claude/skills/task-wrapup/scripts/config_manager.py`
- **Branch Creation**: `~/.claude/skills/task-start/scripts/branch-create.sh`

### GitHub CLI Resources
- **Documentation**: https://cli.github.com/manual/
- **PR Creation**: https://cli.github.com/manual/gh_pr_create
- **Authentication**: https://cli.github.com/manual/gh_auth_login

### Contact
- **Issues**: Report bugs and feature requests via GitHub Issues
- **Questions**: Ask in project discussions or team Slack channel

---

**Last Updated**: 2025-01-15
**Version**: 2.0.0
**Author**: Claude Code SuperClaude Framework
