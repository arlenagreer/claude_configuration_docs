# Changelog

All notable changes to the task-wrapup skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-01-15

### Added

#### Automated Pull Request Creation
- **Automatic PR Creation**: Task-wrapup now automatically creates GitHub pull requests when configured
- **Session State Integration**: Seamless integration with task-start skill via `.task_session_state.json`
- **Parent Branch Detection**: Automatically targets correct parent branch from session state
- **Branch Switching**: Auto-checkout parent branch after successful PR creation
- **Session Cleanup**: Removes session state file after successful PR creation

#### Configuration Enhancements
- **New `pull_request` Configuration Section**: Comprehensive PR automation settings
  - `enabled`: Toggle PR automation on/off (default: true)
  - `default_parent_branch`: Fallback parent branch (default: "develop")
  - `auto_checkout_parent`: Auto-switch to parent branch (default: true)
  - `cleanup_session_state`: Auto-remove session state (default: true)
  - `draft`: Create draft PRs (default: false)
  - `title_template`: Optional PR title template (default: null)
  - `body_template`: Optional PR body template (default: null)

#### PR Workflow Script (`pr-workflow.sh`)
- **Comprehensive Error Handling**: 7 exit codes for different failure scenarios
- **Prerequisite Checks**: GitHub CLI installation, authentication, uncommitted changes, commits
- **Network Resilience**: 60-second timeout with automatic retry
- **Exit Codes**:
  - `0`: Success
  - `10`: GitHub CLI not installed
  - `11`: Not authenticated with GitHub
  - `12`: Uncommitted changes detected
  - `13`: No commits to push
  - `20`: Push to remote failed
  - `30`: PR creation failed

#### Enhanced Configuration Validation
- **Pull Request Field Validation**: Type checking for all PR configuration fields
- **Default Parent Branch Validation**: Non-empty string requirement
- **Boolean Field Validation**: `enabled`, `auto_checkout_parent`, `cleanup_session_state`, `draft`
- **Nullable Field Validation**: `title_template` and `body_template` (string or null)
- **Automatic Schema Migration**: Old configurations auto-upgrade to v2.0.0 schema

#### Documentation
- **PR_AUTOMATION_GUIDE.md**: Complete user guide for automated PR creation
  - Feature overview and benefits
  - Configuration reference
  - Usage examples and workflows
  - Troubleshooting guide
  - Integration patterns
- **TROUBLESHOOTING_PR.md**: Comprehensive troubleshooting guide
  - Common issues and solutions
  - Diagnostic commands
  - Error code reference
  - Network troubleshooting
  - Recovery procedures
- **MIGRATION_GUIDE.md**: Step-by-step migration guide for existing users
  - What's changed in v2.0.0
  - Before/after workflow comparison
  - Prerequisites and setup
  - Migration steps with validation
  - Testing procedures (dry run and full workflow)
  - Backward compatibility strategy
  - Common migration issues
  - Rollback procedures

### Changed

#### Notification Dispatcher
- **Enhanced PR Creation Logic**: New `create_pull_request()` function
- **Session State Loading**: Reads `.task_session_state.json` for PR context
- **Graceful Fallback**: Continues with other operations if PR creation fails
- **Improved Error Messages**: Clear, actionable error messages for PR failures

#### Configuration Schema
- **Schema Version**: Updated to "1.0" with automatic migration
- **Deep Merge Migration**: Preserves user data during schema upgrades
- **Timestamp Management**: Automatic `last_updated` tracking

#### Task-Wrapup Workflow
- **Phase 3 Enhancement**: Added PR creation question
  - Only shown when PR automation enabled
  - Skipped if session state missing
  - Provides manual PR creation guidance if automation disabled
- **Session State Awareness**: Detects and uses session state when available
- **Backward Compatible**: Works with and without session state

### Fixed
- **Configuration Migration**: Automatic upgrade from pre-v2.0.0 configurations
- **Empty Parent Branch**: Validation prevents empty `default_parent_branch`
- **Type Errors**: Strict type validation for all configuration fields
- **Session State Cleanup**: Proper cleanup after successful PR creation
- **Network Timeouts**: 60-second timeout prevents hanging on network issues

### Security
- **No Breaking Changes**: Fully backward compatible with v1.x
- **No New Permissions**: Uses existing GitHub CLI authentication
- **Session State Privacy**: `.task_session_state.json` should be gitignored
- **No Credential Storage**: Relies on GitHub CLI credential management

## Migration Guide

**Upgrading from v1.x to v2.0.0 is fully backward compatible.** Automated PR creation is opt-in and can be enabled gradually.

### Quick Migration Steps

1. **Update Configuration**:
```bash
# Configuration auto-migrates on next skill invocation
# Or manually add to .task_wrapup_skill_data.json:
{
  "pull_request": {
    "enabled": true,
    "default_parent_branch": "develop",
    "auto_checkout_parent": true,
    "cleanup_session_state": true,
    "draft": false
  }
}
```

2. **Validate Configuration**:
```bash
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py validate
```

3. **Add to .gitignore** (recommended):
```bash
echo ".task_session_state.json" >> .gitignore
```

4. **Verify GitHub CLI Authentication**:
```bash
gh auth status
```

5. **Test with Dry Run** (optional but recommended):
```bash
# See MIGRATION_GUIDE.md for complete dry run test procedure
```

### Detailed Migration Information

For comprehensive migration instructions, see:
- **Complete Guide**: [docs/MIGRATION_GUIDE.md](docs/MIGRATION_GUIDE.md)
- **Troubleshooting**: [docs/TROUBLESHOOTING_PR.md](docs/TROUBLESHOOTING_PR.md)
- **User Guide**: [docs/PR_AUTOMATION_GUIDE.md](docs/PR_AUTOMATION_GUIDE.md)

## Breaking Changes

**None.** Version 2.0.0 is fully backward compatible with v1.x.

- ✅ Manual PR creation still works
- ✅ Old configurations auto-migrate
- ✅ Can disable PR automation anytime
- ✅ Can mix automated and manual workflows
- ✅ No new required fields
- ✅ No changes to existing workflows

## Known Issues

None at this time.

## Upgrade Instructions

### From v1.x to v2.0.0

**Automatic Upgrade** (recommended):
```bash
# Next time you invoke task-wrapup, configuration will auto-migrate
# No manual intervention required
```

**Manual Upgrade** (optional):
```bash
# 1. Update configuration file
# Add pull_request section to .task_wrapup_skill_data.json

# 2. Validate configuration
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py validate

# 3. Test configuration
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py show
```

## Contributors

- **Claude Code SuperClaude Framework**: Primary development and testing
- **Task-Start Skill**: Session state integration
- **GitHub CLI**: PR automation foundation

## Support

### Getting Help

**Documentation**:
- [PR_AUTOMATION_GUIDE.md](docs/PR_AUTOMATION_GUIDE.md) - Complete user guide
- [TROUBLESHOOTING_PR.md](docs/TROUBLESHOOTING_PR.md) - Troubleshooting guide
- [MIGRATION_GUIDE.md](docs/MIGRATION_GUIDE.md) - Migration instructions

**Diagnostic Commands**:
```bash
# Check configuration
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py show

# Validate configuration
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py validate

# Check GitHub CLI authentication
gh auth status

# Check git repository status
git status
git branch --show-current
```

**Common Issues**:
- GitHub CLI not installed → `brew install gh`
- Not authenticated → `gh auth login`
- Configuration errors → See TROUBLESHOOTING_PR.md
- PR creation fails → Check network, permissions, branch status

## Previous Versions

### [1.0.0] - 2024-12-01

Initial release of task-wrapup skill.

**Features**:
- Summary generation (git commits, todo tasks, file changes)
- Multi-channel notifications (email, SMS, Slack)
- Worklog time tracking
- Documentation updates
- Session state management

---

**For detailed release notes and migration guides, see the [docs/](docs/) directory.**
