# GitHub Issue Processing Workflow

## Overview

This reference describes the detailed workflow for processing GitHub bug reports automatically using subagents and the frontend-debug skill.

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- Git repository with GitHub remote
- Frontend-debug skill available in `~/.claude/skills/frontend-debug/`
- Repository must have bug reports labeled with "bug"

## Workflow Steps

### 1. Issue Discovery

Use `scripts/get_github_issues.sh` to fetch all open bug reports. The script:
- Verifies GitHub CLI is installed and authenticated
- Confirms current directory is a git repository
- Queries GitHub API for open issues with "bug" label
- Returns issues in format: `issue_number|title`
- Sorts by issue number (oldest first)

### 2. Issue Processing Loop

For each issue returned:

#### 2.1 Generate Branch Name
- Use `scripts/generate_branch_name.sh <issue_number> <title>`
- Format: `bug-{number}-{sanitized-title}`
- Example: `bug-42-fix-login-button-styling`

#### 2.2 Create Git Branch
- Ensure working directory is clean
- Create and checkout new branch: `git checkout -b <branch_name>`

#### 2.3 Spawn Subagent
Launch a Task agent to handle the issue in isolation:
```
Use Task tool with:
- description: "Fix GitHub Issue #{number}: {title}"
- prompt: Detailed prompt including:
  * Issue number and title
  * Instruction to use frontend-debug skill
  * Branch name for context
  * Requirement to commit changes when complete
  * Full issue description/details from GitHub
```

#### 2.4 Subagent Responsibilities
The spawned subagent should:
1. Read the full issue details from GitHub using `gh issue view <number>`
2. Invoke the frontend-debug skill to diagnose and fix the issue
3. Make necessary code changes
4. Test the fix (if applicable)
5. Stage all changes: `git add .`
6. Commit with descriptive message: `git commit -m "Fix #<number>: <title>"`
7. Report completion status

#### 2.5 Post-Processing
After subagent completes:
- Verify commit was made: `git log -1 --oneline`
- Return to main branch: `git checkout main` (or `master`)
- Log issue completion

### 3. Completion

When all issues are processed:
- Report summary: total issues processed, branches created
- Remind user to review branches and push/create PRs as needed

## Error Handling

### Issue Fetching Errors
- GitHub CLI not installed: Report error and exit
- Not a git repository: Report error and exit
- Authentication failure: Report error and exit
- No open bug reports: Report success (nothing to do)

### Branch Creation Errors
- Dirty working directory: Stash changes or abort
- Branch already exists: Skip to next issue or delete and recreate

### Subagent Errors
- Frontend-debug skill not available: Report error and skip issue
- Subagent fails to fix issue: Log failure, move to next issue
- No commit made: Log warning, move to next issue

## Best Practices

1. **Context Preservation**: Keep main session context clean by delegating all debugging work to subagents
2. **Branch Naming**: Use consistent, descriptive branch names for easy tracking
3. **Commit Messages**: Include issue number in commit message for GitHub linking
4. **Sequential Processing**: Process one issue at a time to avoid conflicts
5. **Status Reporting**: Provide clear progress updates after each issue

## GitHub CLI Commands Reference

```bash
# List open bug issues
gh issue list --label "bug" --state open

# View issue details
gh issue view <number>

# Close issue (optional, post-fix)
gh issue close <number> --comment "Fixed in branch <branch_name>"

# Create PR (optional, post-fix)
gh pr create --title "Fix #<number>: <title>" --body "Closes #<number>"
```

## Example Session Flow

```
1. Fetch issues: Found 3 open bug reports
2. Processing issue #42: "Login button styling broken"
   - Created branch: bug-42-login-button-styling-broken
   - Spawned subagent with frontend-debug skill
   - Subagent completed: 1 commit made
   - Returned to main branch
3. Processing issue #43: "Dashboard layout issue"
   - Created branch: bug-43-dashboard-layout-issue
   - Spawned subagent with frontend-debug skill
   - Subagent completed: 1 commit made
   - Returned to main branch
4. Processing issue #44: "Form validation not working"
   - Created branch: bug-44-form-validation-not-working
   - Spawned subagent with frontend-debug skill
   - Subagent completed: 2 commits made
   - Returned to main branch
5. Summary: Processed 3 issues successfully
   - Branches created: bug-42-*, bug-43-*, bug-44-*
   - Next steps: Review branches and create pull requests
```
