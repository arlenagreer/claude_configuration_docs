# Pull Request Automation - Implementation Roadmap

**Feature**: Automated Pull Request Creation in task-wrapup Skill
**Version**: 1.0
**Created**: 2025-01-15
**Status**: Ready for Implementation

---

## Executive Summary

This roadmap outlines the implementation of automated pull request creation in the task-wrapup skill. After committing changes, the skill will push to GitHub, create a pull request targeting the parent branch, and checkout the parent branch locally.

**Key Benefits**:
- Seamless workflow from task start to PR creation
- Automatic parent branch detection and tracking
- Comprehensive error handling and recovery
- Zero manual git operations required

**Estimated Timeline**: 2-3 days
**Complexity**: Moderate
**Risk Level**: Low

---

## Phase 1: Foundation & Session State Tracking

**Duration**: 4-6 hours
**Dependencies**: None
**Risk**: Low

### 1.1 Create Session State File Schema

**File**: `.task_session_state.json`
**Location**: Project root (created by task-start, read by task-wrapup)

**Implementation**:

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

**Tasks**:
- [ ] Define schema structure and required fields
- [ ] Document schema in task-start SKILL.md
- [ ] Add schema validation logic
- [ ] Add to .gitignore for project-specific state

**Success Criteria**:
- Schema documented with all required and optional fields
- Clear specification of data types and constraints
- Gitignore entry prevents accidental commits

---

### 1.2 Update task-start Branch Creation Script

**File**: `~/.claude/skills/task-start/scripts/branch-create.sh`

**Changes Required**:

```bash
# Add at end of script (after successful branch creation)

# Capture the branch we switched FROM (parent branch)
PARENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "develop")

# Create session state file
cat > .task_session_state.json <<EOF
{
  "schema_version": "1.0",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "feature_branch": "${FEATURE_BRANCH}",
  "parent_branch": "${PARENT_BRANCH}",
  "issue_number": ${ISSUE_NUMBER:-null},
  "github_issue": ${GITHUB_ISSUE_JSON:-null}
}
EOF

echo "📝 Session state saved to .task_session_state.json"
echo "   Parent branch: ${PARENT_BRANCH}"
echo "   Feature branch: ${FEATURE_BRANCH}"
```

**Tasks**:
- [ ] Add parent branch detection logic
- [ ] Add session state file creation
- [ ] Add error handling for file write failures
- [ ] Add success confirmation output
- [ ] Test with various branch scenarios (main, develop, custom)

**Success Criteria**:
- Session state file created after every successful branch creation
- Parent branch correctly captured from current branch
- Graceful failure if file cannot be written
- Clear user feedback about session state

**Testing Scenarios**:
1. Create branch from `develop` → parent should be `develop`
2. Create branch from `main` → parent should be `main`
3. Create branch from `feature/other` → parent should be `feature/other`
4. File write permission denied → graceful error message

---

### 1.3 Update task-start Configuration Schema

**File**: `~/.claude/skills/task-start/SKILL.md`

**Configuration Addition**:

```json
{
  "task_start": {
    "session_state": {
      "enabled": true,
      "file_path": ".task_session_state.json",
      "track_parent_branch": true,
      "track_github_issue": true
    }
  }
}
```

**Tasks**:
- [ ] Add session_state section to configuration schema
- [ ] Document configuration options
- [ ] Add examples of session state usage
- [ ] Update SKILL.md with session state explanation

**Success Criteria**:
- Configuration schema complete and documented
- Clear explanation of session state purpose
- Examples showing integration with task-wrapup

---

## Phase 2: Pull Request Workflow Script

**Duration**: 6-8 hours
**Dependencies**: Phase 1 (session state)
**Risk**: Moderate (external dependency on gh CLI)

### 2.1 Create PR Workflow Bash Script

**File**: `~/.claude/skills/task-wrapup/scripts/pr-workflow.sh`

**Full Implementation**:

```bash
#!/bin/bash
# Pull Request Workflow Script
# Pushes changes to GitHub and creates pull request
#
# Usage: pr-workflow.sh [parent_branch] [feature_branch] [pr_title] [pr_body] [draft]
# Returns: 0 on success, non-zero on failure with specific error codes
#
# Exit Codes:
#   0  - Success
#   10 - gh CLI not installed
#   11 - Not authenticated with GitHub
#   12 - Uncommitted changes detected
#   13 - No commits to push
#   20 - Push failed
#   30 - PR creation failed

set -e

# Script arguments
PARENT_BRANCH="${1:-develop}"
FEATURE_BRANCH="${2:-$(git branch --show-current)}"
PR_TITLE="${3:-}"
PR_BODY="${4:-}"
DRAFT="${5:-false}"

echo "🚀 Pull Request Workflow Starting..."
echo "   Feature Branch: ${FEATURE_BRANCH}"
echo "   Parent Branch: ${PARENT_BRANCH}"
echo ""

# Prerequisite checks
echo "🔍 Checking prerequisites..."

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ Error: GitHub CLI (gh) not installed"
    echo ""
    echo "Installation instructions:"
    echo "  macOS: brew install gh"
    echo "  Linux: https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
    echo ""
    exit 10
fi
echo "✅ GitHub CLI installed"

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Error: Not authenticated with GitHub"
    echo ""
    echo "Please authenticate:"
    echo "  gh auth login"
    echo ""
    exit 11
fi
echo "✅ GitHub authentication verified"

# Check for uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
    echo "❌ Error: Uncommitted changes detected"
    echo ""
    echo "Please commit your changes first:"
    echo "  git status"
    echo "  git add <files>"
    echo "  git commit -m 'message'"
    echo ""
    exit 12
fi
echo "✅ No uncommitted changes"

# Check if current branch has commits ahead of parent
COMMIT_COUNT=$(git rev-list --count HEAD ^origin/${PARENT_BRANCH} 2>/dev/null || echo "0")
if [[ "${COMMIT_COUNT}" == "0" ]]; then
    echo "⚠️  Warning: No new commits to push"
    echo "   Branch is up to date with ${PARENT_BRANCH}"
    echo ""
    exit 13
fi
echo "✅ ${COMMIT_COUNT} commit(s) ready to push"
echo ""

# Push changes
echo "📤 Pushing ${FEATURE_BRANCH} to origin..."

if git push -u origin "${FEATURE_BRANCH}" 2>&1; then
    echo "✅ Successfully pushed to origin/${FEATURE_BRANCH}"
else
    PUSH_EXIT=$?
    echo "❌ Push failed (exit code: ${PUSH_EXIT})"
    echo ""
    echo "Common causes:"
    echo "  - Network connectivity issues"
    echo "  - Remote repository permissions"
    echo "  - Force push required (branch diverged)"
    echo ""
    exit 20
fi
echo ""

# Create pull request
echo "🔗 Creating pull request..."

# Build gh pr create command
PR_CMD="gh pr create --base ${PARENT_BRANCH} --head ${FEATURE_BRANCH}"

if [[ -n "${PR_TITLE}" ]]; then
    PR_CMD="${PR_CMD} --title \"${PR_TITLE}\""
else
    # Use --fill to auto-generate from commits
    PR_CMD="${PR_CMD} --fill"
fi

if [[ -n "${PR_BODY}" ]]; then
    PR_CMD="${PR_CMD} --body \"${PR_BODY}\""
fi

if [[ "${DRAFT}" == "true" ]]; then
    PR_CMD="${PR_CMD} --draft"
fi

# Execute PR creation
if eval "${PR_CMD}" 2>&1; then
    # Try to get PR URL
    PR_URL=$(gh pr view --json url -q .url 2>/dev/null || echo "")
    echo "✅ Pull request created successfully!"
    if [[ -n "${PR_URL}" ]]; then
        echo "   URL: ${PR_URL}"
    fi
else
    PR_EXIT=$?

    # Check if PR already exists
    if gh pr list --head "${FEATURE_BRANCH}" --json number --jq '.[0].number' &> /dev/null; then
        PR_NUMBER=$(gh pr list --head "${FEATURE_BRANCH}" --json number --jq '.[0].number')
        PR_URL=$(gh pr view ${PR_NUMBER} --json url -q .url)
        echo "ℹ️  Pull request already exists: #${PR_NUMBER}"
        echo "   URL: ${PR_URL}"
        exit 0
    fi

    echo "❌ Pull request creation failed (exit code: ${PR_EXIT})"
    echo ""
    echo "Common causes:"
    echo "  - Base branch does not exist"
    echo "  - No commits between branches"
    echo "  - Repository settings prevent PR creation"
    echo ""
    exit 30
fi

echo ""
echo "🎉 Pull request workflow completed successfully!"
exit 0
```

**Tasks**:
- [ ] Create pr-workflow.sh with full implementation
- [ ] Make executable: `chmod +x pr-workflow.sh`
- [ ] Add comprehensive comments and documentation
- [ ] Implement all prerequisite checks
- [ ] Add error handling with specific exit codes
- [ ] Add helpful error messages with solutions
- [ ] Test with various scenarios

**Success Criteria**:
- Script executes successfully with valid inputs
- All prerequisite checks function correctly
- Clear error messages for all failure scenarios
- Exit codes match specification
- PR URL returned on success

**Testing Scenarios**:
1. **Happy Path**: Valid branch, commits, authentication → PR created
2. **No gh CLI**: Script exits with code 10 and installation instructions
3. **Not authenticated**: Script exits with code 11 and auth instructions
4. **Uncommitted changes**: Script exits with code 12 and commit instructions
5. **No commits**: Script exits with code 13 (branch up to date)
6. **Push failure**: Script exits with code 20 and troubleshooting help
7. **PR exists**: Script detects existing PR and returns URL
8. **Network failure**: Graceful failure with helpful error message

---

### 2.2 Create Error Handling Helper Function

**File**: `~/.claude/skills/task-wrapup/scripts/pr-workflow.sh` (add to script)

**Implementation**:

```bash
# Add at beginning of script, after shebang and comments

get_pr_error_help() {
    local exit_code=$1

    case $exit_code in
        10)
            echo "Install GitHub CLI: brew install gh (macOS) or see https://cli.github.com"
            ;;
        11)
            echo "Authenticate with GitHub: gh auth login"
            ;;
        12)
            echo "Commit changes before creating PR: git add . && git commit -m 'message'"
            ;;
        13)
            echo "Branch has no new commits - nothing to create PR for"
            ;;
        20)
            echo "Push failed - check network connection and repository permissions"
            ;;
        30)
            echo "PR creation failed - verify base branch exists and repository settings"
            ;;
        *)
            echo "Unexpected error - check GitHub CLI status: gh auth status"
            ;;
    esac
}
```

**Tasks**:
- [ ] Implement error help function
- [ ] Add to script before main logic
- [ ] Update error messages to use helper
- [ ] Test all error scenarios

**Success Criteria**:
- Helpful error messages for all exit codes
- Clear actionable instructions for users
- Consistent error message formatting

---

## Phase 3: Python Integration & Orchestration

**Duration**: 4-6 hours
**Dependencies**: Phase 2 (PR workflow script)
**Risk**: Low

### 3.1 Update notification_dispatcher.py

**File**: `~/.claude/skills/task-wrapup/scripts/notification_dispatcher.py`

**New Functions to Add**:

```python
import subprocess
import json
import os
from typing import Dict, Any, Optional

def load_session_state() -> Optional[Dict[str, Any]]:
    """Load session state from .task_session_state.json"""
    session_file = ".task_session_state.json"

    if not os.path.exists(session_file):
        return None

    try:
        with open(session_file, 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"⚠️  Warning: Failed to load session state: {str(e)}")
        return None

def create_pull_request(summary: Dict[str, Any], config: Dict[str, Any]) -> Dict[str, Any]:
    """
    Push changes and create pull request if user confirmed.

    Args:
        summary: Dictionary containing 'full' and 'concise' summary text
        config: Configuration dictionary with pull_request settings

    Returns:
        Dictionary with status, message, and optional pr_url
    """
    pr_config = config.get("pull_request", {})

    # Check if PR creation is enabled
    if not pr_config.get("enabled", False):
        return {
            "status": "skipped",
            "message": "Pull request creation disabled in config"
        }

    # Load session state to get parent branch
    session = load_session_state()

    if session is None:
        return {
            "status": "error",
            "message": "No session state found - was task-start skill used?",
            "help": "Session state is created by task-start skill. Run task-start before task-wrapup."
        }

    # Extract branch information
    parent_branch = session.get("parent_branch", pr_config.get("default_parent_branch", "develop"))
    feature_branch = session.get("feature_branch")

    if not feature_branch:
        return {
            "status": "error",
            "message": "No feature branch found in session state"
        }

    # Generate PR title and body from summary
    pr_title = summary.get("concise", "")[:72]  # GitHub PR title max length
    pr_body = summary.get("full", "")

    # Add issue reference if available
    if session.get("issue_number"):
        pr_body += f"\n\nCloses #{session['issue_number']}"

    # Check if creating as draft
    draft = pr_config.get("create_as_draft", False)

    # Get path to PR workflow script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    script_path = os.path.join(script_dir, "pr-workflow.sh")

    # Verify script exists and is executable
    if not os.path.exists(script_path):
        return {
            "status": "error",
            "message": f"PR workflow script not found: {script_path}"
        }

    if not os.access(script_path, os.X_OK):
        return {
            "status": "error",
            "message": f"PR workflow script not executable: {script_path}",
            "help": f"Run: chmod +x {script_path}"
        }

    # Execute PR workflow script
    try:
        result = subprocess.run(
            [script_path, parent_branch, feature_branch, pr_title, pr_body, str(draft).lower()],
            capture_output=True,
            text=True,
            timeout=60
        )

        if result.returncode == 0:
            # Extract PR URL from output
            pr_url = None
            for line in result.stdout.split('\n'):
                if 'github.com' in line and '/pull/' in line:
                    pr_url = line.strip().replace('URL: ', '')
                    break

            return {
                "status": "success",
                "pr_url": pr_url,
                "message": "Pull request created successfully",
                "output": result.stdout
            }
        else:
            # Get error help based on exit code
            error_help = get_pr_error_help(result.returncode)

            return {
                "status": "error",
                "code": result.returncode,
                "message": result.stderr or result.stdout,
                "troubleshooting": error_help
            }

    except subprocess.TimeoutExpired:
        return {
            "status": "error",
            "message": "PR creation timed out after 60 seconds",
            "help": "Check network connection and GitHub API status"
        }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Unexpected error during PR creation: {str(e)}"
        }

def get_pr_error_help(exit_code: int) -> str:
    """Get helpful error message for PR workflow exit code"""
    error_messages = {
        10: "Install GitHub CLI: brew install gh (macOS) or see https://cli.github.com",
        11: "Authenticate with GitHub: gh auth login",
        12: "Commit changes before creating PR: git add . && git commit -m 'message'",
        13: "Branch has no new commits - nothing to create PR for",
        20: "Push failed - check network connection and repository permissions",
        30: "PR creation failed - verify base branch exists and repository settings"
    }

    return error_messages.get(exit_code, "Unexpected error - check GitHub CLI status: gh auth status")

def checkout_parent_branch(session_state: Dict[str, Any], config: Dict[str, Any]) -> Dict[str, Any]:
    """
    Checkout parent branch locally after successful PR creation.

    Args:
        session_state: Session state dictionary with parent_branch
        config: Configuration dictionary with pull_request settings

    Returns:
        Dictionary with status and message
    """
    pr_config = config.get("pull_request", {})

    # Check if auto-checkout is enabled
    if not pr_config.get("auto_checkout_parent", True):
        return {
            "status": "skipped",
            "message": "Auto-checkout parent branch disabled in config"
        }

    # Get parent branch from session or config default
    parent_branch = session_state.get("parent_branch", pr_config.get("default_parent_branch", "develop"))

    try:
        # Checkout parent branch
        result = subprocess.run(
            ["git", "checkout", parent_branch],
            capture_output=True,
            text=True,
            timeout=10
        )

        if result.returncode == 0:
            return {
                "status": "success",
                "branch": parent_branch,
                "message": f"Checked out {parent_branch}"
            }
        else:
            return {
                "status": "error",
                "message": f"Failed to checkout {parent_branch}: {result.stderr}",
                "help": "You may need to manually checkout the parent branch"
            }

    except subprocess.TimeoutExpired:
        return {
            "status": "error",
            "message": "Checkout timed out after 10 seconds"
        }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Error checking out branch: {str(e)}"
        }

def cleanup_session_state(config: Dict[str, Any]) -> None:
    """
    Remove session state file after successful PR creation.

    Args:
        config: Configuration dictionary with pull_request settings
    """
    pr_config = config.get("pull_request", {})

    if not pr_config.get("cleanup_session_state", True):
        return

    session_file = ".task_session_state.json"

    try:
        if os.path.exists(session_file):
            os.remove(session_file)
            print(f"🧹 Cleaned up session state file")
    except Exception as e:
        print(f"⚠️  Warning: Failed to remove session state: {str(e)}")
```

**Integration into main() function**:

```python
def main():
    # ... existing code ...

    # After commit changes (if user confirmed)
    if user_confirmed_commit:
        commit_result = commit_changes(...)

        # NEW: Ask about PR creation
        if user_confirmed_pr:
            session_state = load_session_state()
            pr_result = create_pull_request(summary, config)

            if pr_result["status"] == "success":
                print(f"✅ Pull request created: {pr_result.get('pr_url', 'N/A')}")

                # Checkout parent branch
                checkout_result = checkout_parent_branch(session_state, config)
                if checkout_result["status"] == "success":
                    print(f"✅ Checked out {checkout_result['branch']}")

                # Cleanup session state
                cleanup_session_state(config)
            else:
                print(f"❌ PR creation failed: {pr_result['message']}")
                if "troubleshooting" in pr_result:
                    print(f"   {pr_result['troubleshooting']}")
```

**Tasks**:
- [ ] Implement load_session_state() function
- [ ] Implement create_pull_request() function
- [ ] Implement checkout_parent_branch() function
- [ ] Implement cleanup_session_state() function
- [ ] Implement get_pr_error_help() function
- [ ] Integrate into main() orchestration flow
- [ ] Add comprehensive error handling
- [ ] Add logging and status output
- [ ] Test all execution paths

**Success Criteria**:
- Session state loaded successfully
- PR created with correct title and body
- Parent branch checked out after PR creation
- Session state cleaned up after success
- Clear error messages for all failure scenarios

---

### 3.2 Update Phase 3 Questions in SKILL.md

**File**: `~/.claude/skills/task-wrapup/SKILL.md`

**Current Phase 3** (lines 59-108):
```markdown
**Question 1 - Git Commit:**
Would you like to commit changes to git before sending notifications? (y/n)

**Question 2 - Calendar:**
Would you like to create a calendar event or reminder? (y/n)

**Question 3 - GitHub:**
Would you like to create a GitHub issue, PR, or release notes? (y/n)
```

**Updated Phase 3**:
```markdown
**Question 1 - Git Commit:**
Would you like to commit changes to git before sending notifications? (y/n)

This will create a commit with:
- All uncommitted changes in working directory
- Commit message based on session summary
- Timestamp and completion marker

**Question 2 - Pull Request:**
Would you like to push changes and create a pull request? (y/n)

This will:
- Push committed changes to origin
- Create pull request to parent branch (or develop by default)
- Checkout parent branch locally after PR creation
- Include session summary in PR description

**Question 3 - Calendar:**
Would you like to create a calendar event or reminder? (y/n)

Options:
- Create event for deliverable/milestone
- Set reminder for follow-up tasks
- Schedule next work session

**Question 4 - GitHub:**
Would you like to create a GitHub issue or release notes? (y/n)

Options:
- Create issue for follow-up work
- Draft release notes for version
- Add labels and assignments
```

**Tasks**:
- [ ] Update SKILL.md with new Phase 3 questions
- [ ] Reorder questions: Commit → PR → Calendar → GitHub
- [ ] Add detailed descriptions for each question
- [ ] Update enforcement rules to reflect 4 questions
- [ ] Update examples showing new workflow

**Success Criteria**:
- Documentation clearly explains new PR question
- Question order matches logical workflow
- Enforcement rules updated correctly
- Examples demonstrate complete workflow

---

## Phase 4: Configuration Updates

**Duration**: 2-3 hours
**Dependencies**: Phase 3 (Python integration)
**Risk**: Low

### 4.1 Add pull_request Configuration Section

**File**: `.task_wrapup_skill_data.json` (project-level config)

**Configuration Addition**:

```json
{
  "schema_version": "1.0",
  "project_name": "MyProject",

  "pull_request": {
    "enabled": true,
    "create_as_draft": false,
    "auto_checkout_parent": true,
    "default_parent_branch": "develop",
    "cleanup_session_state": true,
    "pr_template": {
      "include_summary": true,
      "include_issue_reference": true,
      "include_generated_badge": true,
      "custom_footer": ""
    }
  },

  "summary_generation": {
    // existing configuration
  },

  "communication": {
    // existing configuration
  }
}
```

**Configuration Options**:
- **enabled**: Enable/disable PR creation (default: true)
- **create_as_draft**: Create PRs as drafts (default: false)
- **auto_checkout_parent**: Automatically checkout parent branch after PR (default: true)
- **default_parent_branch**: Fallback branch if parent unknown (default: "develop")
- **cleanup_session_state**: Remove session state file after success (default: true)
- **pr_template.include_summary**: Add work summary to PR body (default: true)
- **pr_template.include_issue_reference**: Add "Closes #N" if issue exists (default: true)
- **pr_template.include_generated_badge**: Add Claude Code badge (default: true)
- **pr_template.custom_footer**: Additional text for PR body (default: "")

**Tasks**:
- [ ] Add pull_request section to configuration schema
- [ ] Document all configuration options
- [ ] Add validation for configuration values
- [ ] Provide sensible defaults
- [ ] Update config_manager.py to handle new section

**Success Criteria**:
- Configuration schema complete and valid
- All options documented with examples
- Validation prevents invalid values
- Default configuration works for most use cases

---

### 4.2 Update Configuration Manager

**File**: `~/.claude/skills/task-wrapup/scripts/config_manager.py`

**Updates Required**:

```python
def get_default_config():
    """Return default configuration with PR settings"""
    config = {
        # ... existing defaults ...

        "pull_request": {
            "enabled": True,
            "create_as_draft": False,
            "auto_checkout_parent": True,
            "default_parent_branch": "develop",
            "cleanup_session_state": True,
            "pr_template": {
                "include_summary": True,
                "include_issue_reference": True,
                "include_generated_badge": True,
                "custom_footer": ""
            }
        }
    }
    return config

def validate_pr_config(config: dict) -> list:
    """Validate pull_request configuration section"""
    errors = []

    pr_config = config.get("pull_request", {})

    # Validate boolean fields
    bool_fields = ["enabled", "create_as_draft", "auto_checkout_parent", "cleanup_session_state"]
    for field in bool_fields:
        if field in pr_config and not isinstance(pr_config[field], bool):
            errors.append(f"pull_request.{field} must be boolean")

    # Validate default_parent_branch
    if "default_parent_branch" in pr_config:
        branch = pr_config["default_parent_branch"]
        if not isinstance(branch, str) or not branch.strip():
            errors.append("pull_request.default_parent_branch must be non-empty string")

    # Validate pr_template
    if "pr_template" in pr_config:
        template = pr_config["pr_template"]
        if not isinstance(template, dict):
            errors.append("pull_request.pr_template must be object")
        else:
            template_bools = ["include_summary", "include_issue_reference", "include_generated_badge"]
            for field in template_bools:
                if field in template and not isinstance(template[field], bool):
                    errors.append(f"pull_request.pr_template.{field} must be boolean")

            if "custom_footer" in template and not isinstance(template["custom_footer"], str):
                errors.append("pull_request.pr_template.custom_footer must be string")

    return errors
```

**Tasks**:
- [ ] Add pull_request to default configuration
- [ ] Implement validation for PR configuration
- [ ] Add CLI commands to view/edit PR settings
- [ ] Update configuration migration for existing configs

**Success Criteria**:
- Default configuration includes PR settings
- Validation catches invalid configuration
- Existing configurations migrate smoothly
- CLI tools support PR configuration

---

## Phase 5: Testing & Validation

**Duration**: 4-6 hours
**Dependencies**: Phases 1-4 (all implementation complete)
**Risk**: Low

### 5.1 Create Test Suite

**Test Scenarios**:

#### Test 1: Happy Path - Complete Workflow
```bash
# Setup
cd test-project
git checkout develop

# Execute task-start
task-start "test PR automation"

# Verify session state created
cat .task_session_state.json
# Expected: parent_branch = "develop"

# Make changes
echo "test" > test.txt
git add test.txt
git commit -m "Test change"

# Execute task-wrapup
task-wrapup
# Confirm all questions: commit=yes, PR=yes, calendar=no, github=no

# Verify
# - PR created on GitHub
# - Currently on develop branch
# - Session state removed
```

**Expected Results**:
- ✅ Session state created with correct parent branch
- ✅ PR created targeting develop
- ✅ Local branch is develop
- ✅ Session state file removed

---

#### Test 2: No Session State (Graceful Fallback)
```bash
# Setup: task-wrapup without task-start

# Execute
cd test-project
rm -f .task_session_state.json  # Ensure no session state
task-wrapup

# Confirm PR creation

# Expected behavior
# - Warning about no session state
# - Uses default parent branch (develop)
# - PR created successfully
```

**Expected Results**:
- ⚠️ Warning displayed about missing session state
- ✅ PR created using default parent branch
- ✅ Workflow completes successfully

---

#### Test 3: gh CLI Not Installed
```bash
# Setup
# Temporarily rename gh command to simulate not installed
sudo mv /usr/local/bin/gh /usr/local/bin/gh.backup

# Execute
task-wrapup
# Confirm PR creation

# Expected behavior
# - Exit code 10
# - Clear error message with installation instructions
```

**Expected Results**:
- ❌ PR creation fails with code 10
- 📋 Installation instructions displayed
- ✅ Other operations complete successfully

**Cleanup**:
```bash
sudo mv /usr/local/bin/gh.backup /usr/local/bin/gh
```

---

#### Test 4: Not Authenticated with GitHub
```bash
# Setup
gh auth logout

# Execute
task-wrapup
# Confirm PR creation

# Expected behavior
# - Exit code 11
# - Authentication instructions displayed
```

**Expected Results**:
- ❌ PR creation fails with code 11
- 📋 Authentication instructions displayed

**Cleanup**:
```bash
gh auth login
```

---

#### Test 5: No Commits to Push
```bash
# Setup
git checkout develop
task-start "no commits test"

# Don't make any changes

# Execute
task-wrapup
# Confirm PR creation

# Expected behavior
# - Exit code 13
# - Message about no commits
```

**Expected Results**:
- ℹ️ Exit code 13 (no commits)
- 📋 Clear message about branch being up to date
- ✅ Graceful handling without errors

---

#### Test 6: PR Already Exists
```bash
# Setup - create PR manually first
git checkout develop
task-start "duplicate PR test"
echo "test" > test.txt
git add test.txt
git commit -m "Test"
git push -u origin feature/123-duplicate-pr-test
gh pr create --base develop --head feature/123-duplicate-pr-test --fill

# Execute
task-wrapup
# Confirm PR creation

# Expected behavior
# - Detects existing PR
# - Returns existing PR URL
# - No error, exit code 0
```

**Expected Results**:
- ℹ️ Existing PR detected
- 📋 PR URL displayed
- ✅ No duplicate PR created

---

#### Test 7: Custom Parent Branch
```bash
# Setup
git checkout main
task-start "custom parent test"

# Verify session state
cat .task_session_state.json
# Expected: parent_branch = "main"

# Make changes
echo "test" > test.txt
git add test.txt
git commit -m "Test"

# Execute
task-wrapup
# Confirm PR creation

# Verify
# - PR targets main (not develop)
# - Checked out to main
```

**Expected Results**:
- ✅ PR targets main branch
- ✅ Session state correctly tracked main as parent
- ✅ Local checkout returns to main

---

### 5.2 Integration Testing

**Test Integration Points**:

1. **task-start → session state**
   - Verify session state file created
   - Verify parent branch captured correctly
   - Verify file permissions correct

2. **session state → task-wrapup**
   - Verify task-wrapup can read session state
   - Verify graceful handling if missing
   - Verify cleanup after success

3. **task-wrapup → git operations**
   - Verify commit message formatting
   - Verify push to correct remote branch
   - Verify PR creation with correct parameters

4. **task-wrapup → local state**
   - Verify checkout to parent branch
   - Verify session state cleanup
   - Verify no leftover files

**Tasks**:
- [ ] Execute all 7 test scenarios
- [ ] Document results for each test
- [ ] Fix any bugs discovered
- [ ] Add automated tests if possible
- [ ] Create troubleshooting guide

**Success Criteria**:
- All test scenarios pass
- Edge cases handled gracefully
- Error messages are helpful
- No data loss or corruption

---

### 5.3 Documentation Testing

**Documentation Review**:
- [ ] SKILL.md accurately describes workflow
- [ ] Configuration schema complete
- [ ] Error messages match documentation
- [ ] Examples work as documented
- [ ] Troubleshooting guide comprehensive

**User Experience Testing**:
- [ ] Questions are clear and unambiguous
- [ ] Error messages are actionable
- [ ] Success feedback is informative
- [ ] Workflow feels natural and intuitive

---

## Phase 6: Documentation & Rollout

**Duration**: 2-3 hours
**Dependencies**: Phase 5 (testing complete)
**Risk**: Low

### 6.1 Update Documentation

**Files to Update**:

1. **`~/.claude/skills/task-wrapup/SKILL.md`**
   - [ ] Update Phase 3 questions (4 questions now)
   - [ ] Add PR workflow section
   - [ ] Update configuration schema
   - [ ] Add troubleshooting section for PR creation
   - [ ] Update usage examples

2. **`~/.claude/skills/task-start/SKILL.md`**
   - [ ] Document session state file creation
   - [ ] Explain parent branch tracking
   - [ ] Add examples showing integration with task-wrapup

3. **New: `PR_AUTOMATION_GUIDE.md`**
   - [ ] Complete feature documentation
   - [ ] Setup and prerequisites
   - [ ] Workflow walkthrough
   - [ ] Configuration reference
   - [ ] Troubleshooting guide
   - [ ] FAQ section

**Tasks**:
- [ ] Update all documentation files
- [ ] Add diagrams showing workflow
- [ ] Create quick start guide
- [ ] Add troubleshooting section
- [ ] Update changelog

---

### 6.2 Create Troubleshooting Guide

**File**: `~/.claude/skills/task-wrapup/TROUBLESHOOTING_PR.md`

**Contents**:

```markdown
# Pull Request Automation - Troubleshooting Guide

## Prerequisites

**Required**:
- GitHub CLI (gh) installed and authenticated
- Git repository with remote configured
- Valid session state from task-start skill

**Check Prerequisites**:
```bash
# Check gh CLI installed
which gh

# Check authentication
gh auth status

# Check git remote
git remote -v

# Check session state
cat .task_session_state.json
```

## Common Issues

### PR Creation Fails - Exit Code 10

**Symptom**: "GitHub CLI (gh) not installed"

**Solution**:
```bash
# macOS
brew install gh

# Linux - Ubuntu/Debian
sudo apt install gh

# Linux - Other
# See https://github.com/cli/cli/blob/trunk/docs/install_linux.md
```

**Verify**:
```bash
gh --version
```

---

### PR Creation Fails - Exit Code 11

**Symptom**: "Not authenticated with GitHub"

**Solution**:
```bash
gh auth login
```

Follow the prompts to authenticate.

**Verify**:
```bash
gh auth status
```

---

### PR Creation Fails - Exit Code 12

**Symptom**: "Uncommitted changes detected"

**Solution**:
Commit your changes before creating PR:
```bash
git status
git add <files>
git commit -m "Your commit message"
```

---

### PR Creation Fails - Exit Code 13

**Symptom**: "No new commits to push"

**Cause**: Your branch has no commits ahead of the parent branch.

**Solution**: Make and commit changes before creating PR, or this is expected if no work was done.

---

### PR Creation Fails - Exit Code 20

**Symptom**: "Push failed"

**Possible Causes**:
- Network connectivity issues
- Remote repository permissions
- Branch protection rules
- Force push required (branch diverged)

**Solution**:
```bash
# Check network
ping github.com

# Check permissions
gh repo view

# Check branch status
git status
git log origin/develop..HEAD
```

---

### PR Creation Fails - Exit Code 30

**Symptom**: "Pull request creation failed"

**Possible Causes**:
- Base branch doesn't exist
- No commits between branches
- Repository settings prevent PR creation
- PR already exists

**Solution**:
```bash
# Check if PR exists
gh pr list --head $(git branch --show-current)

# Check base branch exists
git ls-remote --heads origin develop

# Verify commits
git log origin/develop..HEAD
```

---

### No Session State Found

**Symptom**: "No session state found - was task-start skill used?"

**Cause**: Session state file missing or not created by task-start.

**Solution**:
1. Always run task-start before task-wrapup
2. Or manually create session state:
```bash
cat > .task_session_state.json <<EOF
{
  "schema_version": "1.0",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "feature_branch": "$(git branch --show-current)",
  "parent_branch": "develop",
  "issue_number": null,
  "github_issue": null
}
EOF
```

---

### PR Created but Wrong Base Branch

**Symptom**: PR targets wrong branch (e.g., main instead of develop)

**Cause**: Session state has incorrect parent branch.

**Solution**:
1. Close incorrect PR: `gh pr close <number>`
2. Fix session state or config default_parent_branch
3. Re-run task-wrapup

---

### Can't Checkout Parent Branch

**Symptom**: "Failed to checkout parent_branch"

**Possible Causes**:
- Uncommitted changes prevent checkout
- Parent branch doesn't exist locally
- Merge conflicts

**Solution**:
```bash
# Stash changes if needed
git stash

# Fetch latest branches
git fetch

# Checkout manually
git checkout develop
```

## Advanced Troubleshooting

### Enable Debug Output

Add debug output to scripts:
```bash
# In pr-workflow.sh, add at top:
set -x  # Print commands as executed
```

### Check Script Permissions

```bash
# Verify pr-workflow.sh is executable
ls -la ~/.claude/skills/task-wrapup/scripts/pr-workflow.sh

# Fix permissions if needed
chmod +x ~/.claude/skills/task-wrapup/scripts/pr-workflow.sh
```

### Manual PR Creation

If automation fails, create PR manually:
```bash
# Push changes
git push -u origin $(git branch --show-current)

# Create PR
gh pr create --base develop --head $(git branch --show-current) --fill
```

## Getting Help

If issues persist:
1. Check script logs and error messages
2. Verify all prerequisites
3. Try manual git/gh commands
4. Check GitHub status: https://www.githubstatus.com
```

**Tasks**:
- [ ] Create comprehensive troubleshooting guide
- [ ] Document all error codes and solutions
- [ ] Add verification steps for each solution
- [ ] Include advanced troubleshooting techniques

---

### 6.3 Create Migration Guide

**File**: `~/.claude/skills/task-wrapup/MIGRATION_GUIDE.md`

**For Existing Users**:

```markdown
# Migration Guide - PR Automation Feature

## Overview

This guide helps existing task-wrapup users migrate to the new PR automation feature.

## What's New

1. **Session State Tracking**: task-start now creates `.task_session_state.json`
2. **PR Automation**: task-wrapup can now create pull requests automatically
3. **Auto-Checkout**: Returns to parent branch after PR creation
4. **Enhanced Questions**: Phase 3 now has 4 questions (added PR creation)

## Migration Steps

### Step 1: Update Configuration

Add PR configuration to `.task_wrapup_skill_data.json`:

```json
{
  "pull_request": {
    "enabled": true,
    "create_as_draft": false,
    "auto_checkout_parent": true,
    "default_parent_branch": "develop",
    "cleanup_session_state": true
  }
}
```

Or use the configuration manager:
```bash
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py add-pr-config
```

### Step 2: Install Prerequisites

```bash
# macOS
brew install gh
gh auth login

# Verify
gh auth status
```

### Step 3: Update .gitignore

Add session state to your project `.gitignore`:
```
.task_session_state.json
```

### Step 4: Test Workflow

```bash
# Start a test task
cd your-project
task-start "test PR automation"

# Make a change
echo "test" > test.txt
git add test.txt
git commit -m "Test PR automation"

# Wrap up (confirm PR creation)
task-wrapup

# Verify PR created
gh pr list
```

## Breaking Changes

**None** - PR automation is opt-in and backward compatible.

## FAQ

**Q: Do I need to use task-start?**
A: No, but recommended. Without task-start, PR will use default parent branch from config.

**Q: Can I disable PR automation?**
A: Yes, set `pull_request.enabled: false` in config.

**Q: What if gh CLI isn't installed?**
A: The skill will detect this and provide installation instructions. Other features continue to work.

**Q: Will existing workflows break?**
A: No, PR automation only activates if you answer "yes" to the PR question.
```

---

### 6.4 Update Changelog

**File**: `~/.claude/skills/task-wrapup/CHANGELOG.md`

**Add Entry**:

```markdown
## [v2.0.0] - 2025-01-15

### Added
- **Pull Request Automation**: Automatically create PRs after committing changes
- **Session State Tracking**: Track parent branch and feature context between skills
- **Auto-Checkout**: Return to parent branch after successful PR creation
- **Enhanced Phase 3**: Added dedicated PR creation question (now 4 questions)
- **Comprehensive Error Handling**: Detailed error codes and troubleshooting help
- **Configuration Options**: Full control over PR automation behavior

### Changed
- **Phase 3 Questions**: Now 4 questions (Commit → PR → Calendar → GitHub)
- **Workflow Flow**: Added PR creation and parent branch checkout steps
- **Configuration Schema**: Added pull_request section with 6 options

### Fixed
- None (new feature)

### Documentation
- Added PR_AUTOMATION_GUIDE.md
- Added TROUBLESHOOTING_PR.md
- Added MIGRATION_GUIDE.md
- Updated SKILL.md with PR automation documentation
- Updated configuration examples

### Breaking Changes
- None (backward compatible, opt-in feature)

### Migration
See MIGRATION_GUIDE.md for upgrade instructions.
```

---

## Complete Workflow Example

### Scenario: Implement User Authentication Feature

**Step 1: Start Task (task-start skill)**
```bash
cd my-project
task-start "user authentication system"

# Output:
# ✅ Preflight checks passed
# ✅ Environment health validated
# ✅ Branch created: feature/user-authentication
# 📝 Session state saved to .task_session_state.json
#    Parent branch: develop
#    Feature branch: feature/user-authentication
```

**Verify Session State**:
```bash
cat .task_session_state.json
```
```json
{
  "schema_version": "1.0",
  "created_at": "2025-01-15T14:30:00Z",
  "feature_branch": "feature/user-authentication",
  "parent_branch": "develop",
  "issue_number": null,
  "github_issue": null
}
```

---

**Step 2: Implement Feature**
```bash
# Create authentication files
touch backend/app/controllers/auth_controller.rb
touch backend/app/models/user.rb
touch frontend/src/components/LoginForm.tsx

# Implement authentication logic
# ... development work ...

# Commit changes incrementally
git add backend/app/controllers/auth_controller.rb
git commit -m "Add authentication controller"

git add backend/app/models/user.rb
git commit -m "Add user model with password hashing"

git add frontend/src/components/LoginForm.tsx
git commit -m "Add login form component"
```

---

**Step 3: Wrap Up (task-wrapup skill)**
```bash
task-wrapup
```

**Skill Execution**:

1. **Generate Summary** (automatic):
```
Full Summary:
Implemented user authentication system with secure password hashing,
JWT token generation, and login form component. Backend includes
authentication controller and user model. Frontend includes responsive
login form with validation.

Concise Summary:
Implemented user authentication with JWT tokens and login UI
```

2. **Preview** (automatic):
```
📋 Preview:
   Email: jane@example.com (Full summary)
   SMS: john@example.com (Concise summary)
   Worklog: 4 hours (Concise summary)
```

3. **Mandatory Questions** (user interaction):
```
Question 1 - Git Commit:
Would you like to commit changes to git before sending notifications? (y/n)
> y

Question 2 - Pull Request:
Would you like to push changes and create a pull request? (y/n)
> y

Question 3 - Calendar:
Would you like to create a calendar event or reminder? (y/n)
> n

Question 4 - GitHub:
Would you like to create a GitHub issue or release notes? (y/n)
> n
```

4. **Parallel Dispatch** (automatic):
```
📤 Sending Notifications...
   ✅ Email sent to jane@example.com
   ✅ SMS sent to john@example.com
   ✅ Worklog entry created (4 hours)
```

5. **Pull Request Workflow** (automatic):
```
🚀 Pull Request Workflow Starting...
   Feature Branch: feature/user-authentication
   Parent Branch: develop

🔍 Checking prerequisites...
   ✅ GitHub CLI installed
   ✅ GitHub authentication verified
   ✅ No uncommitted changes
   ✅ 3 commit(s) ready to push

📤 Pushing feature/user-authentication to origin...
   ✅ Successfully pushed to origin/feature/user-authentication

🔗 Creating pull request...
   ✅ Pull request created successfully!
   URL: https://github.com/user/repo/pull/123

🎉 Pull request workflow completed successfully!
```

6. **Checkout Parent Branch** (automatic):
```
🔄 Checking out parent branch...
   ✅ Checked out develop
```

7. **Cleanup** (automatic):
```
🧹 Cleaned up session state file
```

8. **Final Summary**:
```
📊 Task Wrap-Up Summary:
   ✅ Email: Sent (1)
   ✅ SMS: Sent (1)
   ✅ Worklog: Logged (4 hours)
   ✅ Pull Request: Created (#123)
   ✅ Branch: Checked out develop
   ⏭️  Calendar: Skipped
   ⏭️  GitHub: Skipped

🎉 All tasks completed successfully!
```

---

**Step 4: Verify Results**
```bash
# Check current branch
git branch
# * develop

# View PR on GitHub
gh pr view 123

# Check worklog
cat ~/.claude/skills/worklog/worklog.json | grep "user authentication"
```

**PR Created on GitHub**:
- **Title**: "Implemented user authentication with JWT tokens and login UI"
- **Body**: Full summary with implementation details
- **Base**: develop
- **Head**: feature/user-authentication
- **Status**: Open
- **Commits**: 3 commits included

---

## Timeline & Milestones

### Week 1
- **Day 1-2**: Phase 1 (Foundation & Session State)
  - Milestone: Session state file created by task-start
- **Day 3-4**: Phase 2 (PR Workflow Script)
  - Milestone: pr-workflow.sh working with all error handling
- **Day 5**: Phase 3 (Python Integration)
  - Milestone: notification_dispatcher.py integrated

### Week 2
- **Day 1**: Phase 4 (Configuration)
  - Milestone: Configuration complete and validated
- **Day 2-3**: Phase 5 (Testing)
  - Milestone: All test scenarios passing
- **Day 4**: Phase 6 (Documentation)
  - Milestone: All documentation complete
- **Day 5**: Final Review & Rollout
  - Milestone: Feature ready for production use

---

## Risk Mitigation

### High-Risk Areas
1. **External Dependency (gh CLI)**: Comprehensive prerequisite checking
2. **Network Failures**: Timeout handling and clear error messages
3. **Session State Loss**: Graceful fallback to defaults

### Mitigation Strategies
1. **Comprehensive Testing**: 7 test scenarios covering all paths
2. **Error Handling**: Specific exit codes for each failure type
3. **Documentation**: Detailed troubleshooting guide
4. **Backward Compatibility**: Feature is opt-in, existing workflows unaffected

---

## Success Metrics

### Technical Metrics
- [ ] All 7 test scenarios pass
- [ ] Zero data loss scenarios
- [ ] 100% error code coverage in documentation
- [ ] < 60 seconds for PR creation workflow

### User Experience Metrics
- [ ] Clear error messages with actionable solutions
- [ ] Intuitive question flow in Phase 3
- [ ] Successful migration for existing users
- [ ] Positive user feedback on workflow

---

## Rollout Plan

### Phase 1: Internal Testing (1 week)
- Test with personal projects
- Gather feedback on workflow
- Fix any discovered issues

### Phase 2: Documentation Review (2-3 days)
- Review all documentation for accuracy
- Test all examples
- Ensure troubleshooting guide is complete

### Phase 3: Soft Launch (1 week)
- Announce feature availability
- Provide migration guide
- Monitor for issues

### Phase 4: General Availability
- Feature fully available
- Documentation finalized
- Support channels ready

---

## Appendix

### A. Exit Code Reference

| Code | Meaning | Action Required |
|------|---------|----------------|
| 0 | Success | None |
| 10 | gh CLI not installed | Install gh CLI |
| 11 | Not authenticated | Run gh auth login |
| 12 | Uncommitted changes | Commit changes |
| 13 | No commits to push | Make changes first |
| 20 | Push failed | Check network/permissions |
| 30 | PR creation failed | Check base branch exists |

### B. File Locations

- **Session State**: `.task_session_state.json` (project root)
- **PR Workflow Script**: `~/.claude/skills/task-wrapup/scripts/pr-workflow.sh`
- **Python Orchestrator**: `~/.claude/skills/task-wrapup/scripts/notification_dispatcher.py`
- **Configuration**: `.task_wrapup_skill_data.json` (project root)
- **Branch Creation**: `~/.claude/skills/task-start/scripts/branch-create.sh`

### C. Configuration Reference

See Phase 4.1 for complete configuration schema and options.

### D. Dependencies

**Required**:
- Git (any modern version)
- GitHub CLI (gh) - latest version recommended
- Python 3.7+ (for notification_dispatcher.py)
- Bash 4.0+ (for scripts)

**Optional**:
- jq (for JSON parsing in bash)

---

## Conclusion

This implementation roadmap provides a complete, phased approach to adding pull request automation to the task-wrapup skill. The feature is designed to be:

- **Seamless**: Integrates naturally into existing workflow
- **Robust**: Comprehensive error handling for all scenarios
- **User-Friendly**: Clear questions and helpful error messages
- **Backward Compatible**: Opt-in feature, existing workflows unaffected
- **Well-Documented**: Complete guides for setup, usage, and troubleshooting

**Next Steps**: Review this roadmap, provide feedback, and approve for implementation.
