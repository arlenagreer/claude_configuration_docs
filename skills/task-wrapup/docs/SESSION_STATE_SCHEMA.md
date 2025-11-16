# Session State Schema Documentation

## Overview

The `.task_session_state.json` file tracks the relationship between feature branches and their parent branches, enabling automated pull request creation with correct target branches.

## File Location

- **Project Root**: `.task_session_state.json`
- **Created By**: `task-start` skill during branch creation
- **Consumed By**: `task-wrapup` skill during PR creation
- **Lifecycle**: Created at task start, removed after successful PR creation

## Schema Version 1.0

### Complete Schema

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

### Field Specifications

#### `schema_version` (required)
- **Type**: String
- **Format**: Semantic version (e.g., "1.0")
- **Purpose**: Enable future schema evolution and compatibility checks
- **Validation**: Must match pattern `^\d+\.\d+$`

#### `created_at` (required)
- **Type**: String
- **Format**: ISO 8601 UTC timestamp (e.g., "2025-01-15T10:30:00Z")
- **Purpose**: Track session state creation time for debugging
- **Validation**: Must be valid ISO 8601 format with 'Z' timezone

#### `feature_branch` (required)
- **Type**: String
- **Format**: Git branch name
- **Purpose**: Name of the feature branch being worked on
- **Validation**:
  - Non-empty string
  - Valid git branch name (no spaces, special chars limited)
  - Should match current git branch when created
- **Example**: `"feature/456-user-authentication"`

#### `parent_branch` (required)
- **Type**: String
- **Format**: Git branch name
- **Purpose**: Name of the branch to target for pull request
- **Validation**:
  - Non-empty string
  - Valid git branch name
  - Should exist in repository
- **Example**: `"develop"`, `"main"`, `"release/v2.0"`
- **Default Fallback**: `"develop"` if session state unavailable

#### `issue_number` (optional)
- **Type**: Integer or null
- **Purpose**: GitHub issue number associated with this feature
- **Validation**: Positive integer or null
- **Example**: `456`, `null`
- **Usage**: Auto-link PR to issue, include in PR description

#### `github_issue` (optional)
- **Type**: Object or null
- **Purpose**: Complete GitHub issue metadata for rich PR descriptions
- **Validation**: Must contain required subfields if present
- **Subfields**:
  - `number` (integer): GitHub issue number
  - `title` (string): Issue title
  - `labels` (array of strings): Issue labels for PR categorization

## Validation Rules

### Required Fields
All implementations must validate:
1. `schema_version` is present and matches supported versions
2. `created_at` is valid ISO 8601 timestamp
3. `feature_branch` is non-empty valid git branch name
4. `parent_branch` is non-empty valid git branch name

### Optional Fields
Implementations should handle gracefully:
1. `issue_number` may be null or absent
2. `github_issue` may be null or absent
3. Unknown fields should be ignored for forward compatibility

### File Integrity
1. File must be valid JSON
2. File permissions should be readable by skill scripts
3. Malformed files should trigger graceful degradation

## Error Handling

### Missing File
**Scenario**: `.task_session_state.json` does not exist

**Behavior**:
- Graceful degradation to default parent branch
- Log warning about missing session state
- Prompt user for parent branch if interactive mode

**Exit Code**: Continue with warning (not fatal error)

### Invalid JSON
**Scenario**: File exists but contains invalid JSON

**Behavior**:
- Log error with file location
- Graceful degradation to default parent branch
- Suggest file deletion and recreation

**Exit Code**: Continue with warning

### Missing Required Fields
**Scenario**: JSON valid but missing required fields

**Behavior**:
- Log specific missing fields
- Attempt to infer missing values from git context
- Graceful degradation where possible

**Exit Code**: Continue with partial data

### Schema Version Mismatch
**Scenario**: `schema_version` not "1.0"

**Behavior**:
- Log version mismatch warning
- Attempt best-effort parsing
- Suggest skill update if version newer

**Exit Code**: Continue with warning

## Usage Examples

### Example 1: Standard Feature Branch
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

### Example 2: Hotfix Branch
```json
{
  "schema_version": "1.0",
  "created_at": "2025-01-15T14:20:00Z",
  "feature_branch": "hotfix/critical-security-patch",
  "parent_branch": "main",
  "issue_number": 789,
  "github_issue": {
    "number": 789,
    "title": "Critical security vulnerability in auth",
    "labels": ["bug", "security", "critical"]
  }
}
```

### Example 3: Release Branch
```json
{
  "schema_version": "1.0",
  "created_at": "2025-01-15T16:00:00Z",
  "feature_branch": "release/v2.1.0",
  "parent_branch": "main",
  "issue_number": null,
  "github_issue": null
}
```

### Example 4: Minimal Valid State
```json
{
  "schema_version": "1.0",
  "created_at": "2025-01-15T09:00:00Z",
  "feature_branch": "feature/quick-fix",
  "parent_branch": "develop"
}
```

## Integration Points

### task-start Skill
**Responsibility**: Create `.task_session_state.json`

**When**: After creating feature branch, before switching to it

**Required Actions**:
1. Capture current branch as `parent_branch`
2. Record new branch name as `feature_branch`
3. Generate ISO 8601 timestamp for `created_at`
4. Set `schema_version` to "1.0"
5. Include GitHub issue data if available
6. Write JSON file to project root

**Script**: `~/.claude/skills/task-start/scripts/branch-create.sh`

### task-wrapup Skill
**Responsibility**: Read and consume `.task_session_state.json`

**When**: During PR creation workflow

**Required Actions**:
1. Attempt to read `.task_session_state.json`
2. Validate schema version and required fields
3. Use `parent_branch` as PR target
4. Include issue reference in PR description if available
5. Delete file after successful PR creation (if configured)

**Script**: `~/.claude/skills/task-wrapup/scripts/notification_dispatcher.py`

### pr-workflow.sh
**Responsibility**: Use session state data for PR creation

**When**: Creating pull request via GitHub CLI

**Required Actions**:
1. Receive parent branch from dispatcher
2. Create PR targeting parent branch
3. Include issue reference in PR if provided
4. Return success/failure exit code

**Script**: `~/.claude/skills/task-wrapup/scripts/pr-workflow.sh`

## Backward Compatibility

### Legacy Workflows
Workflows without session state tracking will:
- Fall back to `default_parent_branch` from config
- Continue to function normally
- Not benefit from automatic parent branch detection

### Migration Path
1. Install updated `task-start` skill
2. New tasks automatically create session state
3. Existing feature branches continue with default parent
4. No manual intervention required

## Security Considerations

### File Permissions
- File should be readable by user only (644 or 600)
- No sensitive credentials should be stored
- GitHub issue data is public information

### Git Ignore
**CRITICAL**: `.task_session_state.json` MUST be in `.gitignore`

**Rationale**:
- Session state is local to developer's environment
- Should not be committed to repository
- Different developers may have different parent branches
- Prevents merge conflicts

**Implementation**: Add to project `.gitignore` files

### Data Sanitization
- All JSON values should be sanitized before shell execution
- Branch names validated against git naming rules
- Issue numbers validated as integers
- No arbitrary code execution from JSON values

## Future Schema Evolution

### Version 1.1 (Planned)
Potential additions:
- `repository_url`: Full GitHub repository URL
- `pr_template_id`: Custom PR template identifier
- `assignees`: Default PR assignees
- `reviewers`: Default PR reviewers
- `milestone`: Associated milestone number

### Version 2.0 (Conceptual)
Breaking changes might include:
- Nested branch hierarchy for multi-level branching strategies
- Multiple parent branch options
- Workflow metadata for complex approval processes

## Testing Checklist

### Schema Validation Tests
- [ ] Valid schema with all fields parses correctly
- [ ] Minimal schema (only required fields) parses correctly
- [ ] Invalid JSON triggers graceful error handling
- [ ] Missing required fields handled appropriately
- [ ] Unknown fields ignored (forward compatibility)
- [ ] Unsupported schema version handled gracefully

### Integration Tests
- [ ] task-start creates valid session state
- [ ] task-wrapup reads session state correctly
- [ ] PR targets correct parent branch
- [ ] Issue reference included in PR description
- [ ] Session state deleted after successful PR
- [ ] Legacy workflows continue without session state

### Error Handling Tests
- [ ] Missing file triggers default parent branch
- [ ] Corrupted JSON triggers warning and fallback
- [ ] Invalid branch names rejected
- [ ] File permission errors handled gracefully

## Troubleshooting

### Problem: Session state not created
**Symptoms**: `.task_session_state.json` missing after task-start

**Diagnosis**:
1. Check task-start script execution
2. Verify write permissions in project root
3. Check for script errors in logs

**Resolution**: Manually create file or use default parent branch

### Problem: PR targets wrong branch
**Symptoms**: PR created against incorrect parent branch

**Diagnosis**:
1. Verify session state `parent_branch` field
2. Check if file was manually edited
3. Verify git branch state when task-start ran

**Resolution**:
1. Close incorrect PR
2. Update session state or delete file
3. Re-run PR creation

### Problem: Session state persists after PR creation
**Symptoms**: Old `.task_session_state.json` remains in project

**Diagnosis**:
1. Check `cleanup_session_state` configuration
2. Verify PR creation succeeded
3. Check for file permission issues

**Resolution**:
1. Manually delete `.task_session_state.json`
2. Enable cleanup in configuration
3. Verify file permissions

## References

- **ISO 8601**: https://en.wikipedia.org/wiki/ISO_8601
- **Git Branch Naming**: https://git-scm.com/docs/git-check-ref-format
- **GitHub CLI**: https://cli.github.com/manual/gh_pr_create
- **JSON Schema**: https://json-schema.org/

## Changelog

### Version 1.0 (2025-01-15)
- Initial schema definition
- Required fields: schema_version, created_at, feature_branch, parent_branch
- Optional fields: issue_number, github_issue
- Basic validation rules
- Error handling specifications
