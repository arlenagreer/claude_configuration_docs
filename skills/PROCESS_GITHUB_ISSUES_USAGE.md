# Process GitHub Issues Skill - Usage Guide

## Overview

The `process-github-issues` skill has been successfully created and is ready to use! This skill automates the processing of GitHub bug reports by:

1. Fetching all open issues labeled "bug"
2. Creating a git branch for each issue
3. Spawning a subagent that uses the frontend-debug skill to fix it
4. Committing the changes
5. Moving to the next issue

## How to Use

### Basic Usage

Simply invoke the skill in Claude Code:

```
Use the process-github-issues skill
```

or

```
@~/.claude/skills/process-github-issues/SKILL.md
```

### Prerequisites Checklist

Before using the skill, ensure:

- [ ] GitHub CLI (`gh`) is installed and authenticated
  ```bash
  gh auth status
  ```

- [ ] You're in a git repository with a GitHub remote
  ```bash
  git remote -v
  ```

- [ ] Working directory is clean
  ```bash
  git status
  ```

- [ ] Frontend-debug skill is available
  ```bash
  ls ~/.claude/skills/frontend-debug/
  ```

- [ ] Repository has issues labeled "bug"
  ```bash
  gh issue list --label bug
  ```

## What Happens When You Use It

1. **Fetches Issues**: Runs `scripts/get_github_issues.sh` to get all open bug reports
2. **For Each Issue**:
   - Generates branch name: `bug-{number}-{sanitized-title}`
   - Creates and checks out the branch
   - Fetches full issue details from GitHub
   - Spawns a Task subagent with the frontend-debug skill
   - Subagent fixes the issue and commits
   - Returns to main branch
3. **Reports Summary**: Lists all processed issues and created branches

## Example Session

```
User: Use the process-github-issues skill

Claude: I'll process all open bug reports from GitHub Issues.

Fetching open bug reports...
Found 3 open bugs:
- #42: Login button styling broken
- #43: Dashboard layout issue
- #44: Form validation not working

Processing issue #42...
✓ Created branch: bug-42-login-button-styling-broken
✓ Spawning subagent with frontend-debug skill
✓ Subagent completed with 1 commit
✓ Returned to main branch

Processing issue #43...
✓ Created branch: bug-43-dashboard-layout-issue
✓ Spawning subagent with frontend-debug skill
✓ Subagent completed with 1 commit
✓ Returned to main branch

Processing issue #44...
✓ Created branch: bug-44-form-validation-not-working
✓ Spawning subagent with frontend-debug skill
✓ Subagent completed with 2 commits
✓ Returned to main branch

Summary:
- Total issues processed: 3
- Branches created: bug-42-*, bug-43-*, bug-44-*

Next steps:
- Review branches: git branch --list 'bug-*'
- Push branches: git push origin <branch_name>
- Create PRs: gh pr create --head <branch_name>
```

## Skill Structure

```
process-github-issues/
├── SKILL.md                           # Main skill instructions
├── scripts/
│   ├── get_github_issues.sh          # Fetches open bug reports
│   └── generate_branch_name.sh       # Creates standardized branch names
└── references/
    └── workflow_guide.md             # Detailed workflow documentation
```

## Key Features

✅ **Context Preservation**: Keeps main session clean by delegating work to subagents
✅ **Automated Branch Management**: Creates properly named branches automatically
✅ **Sequential Processing**: Handles one issue at a time to avoid conflicts
✅ **Error Handling**: Continues processing even if individual issues fail
✅ **Comprehensive Logging**: Provides detailed status updates throughout

## Limitations

- Only processes issues labeled as "bug"
- Assumes frontend-debug skill is appropriate for all bugs
- Requires clean working directory to start
- Processes sequentially (not parallel)
- Requires manual PR creation after processing
- Does not automatically close issues

## Troubleshooting

### "gh not found"
Install GitHub CLI: https://cli.github.com/

### "Not authenticated"
Run: `gh auth login`

### "Working directory dirty"
Commit or stash changes: `git stash` or `git commit -am "WIP"`

### "No bug reports found"
Verify issues are labeled "bug": `gh issue list --label bug`

### Subagent fails
Check frontend-debug skill is available: `ls ~/.claude/skills/frontend-debug/`

## Advanced Usage

### Custom Label
To process issues with a different label, modify `scripts/get_github_issues.sh`:
```bash
# Change this line:
--label "bug" \
# To:
--label "your-custom-label" \
```

### Parallel Processing
For parallel processing, consider using the worktree-management skill (not yet integrated).

## Integration

This skill works best with:
- **frontend-debug**: Primary debugging skill (required)
- **commit**: Enhanced commit messages (optional)
- **worktree-management**: Future parallel processing (planned)

## Next Steps

1. Make sure all prerequisites are met
2. Navigate to your project directory
3. Invoke the skill
4. Review the created branches
5. Push branches and create PRs
6. Close issues once fixes are verified

Enjoy automated bug fixing! 🐛→✅
