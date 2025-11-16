# Documentation Integration Guide

## Overview

The task-wrapup skill uses a **two-phase approach** to update project documentation:

1. **Python Script Phase**: Creates a documentation update request
2. **Claude Code Phase**: Processes the request using `/sc:document`

This separation allows the Python scripts to run independently while enabling Claude Code to perform the actual documentation updates using its superior context and intelligence.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Task-Wrapup Skill Execution                                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. User invokes skill                                      │
│  2. Generate session summary (git, files, todos)            │
│  3. Dispatch notifications (email, SMS, worklog, etc.)      │
│  4. Create documentation request file                       │
│     └─> .task_wrapup_doc_update_request.md                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ Claude Code Post-Processing                                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Detect request file in current directory               │
│  2. Read session summary and target paths                  │
│  3. Invoke /sc:document with context                       │
│  4. Update CHANGELOG.md, README.md, other docs             │
│  5. Remove request file (cleanup)                          │
│  6. Report what was updated                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Request File Format

The `.task_wrapup_doc_update_request.md` file contains:

```markdown
# Documentation Update Request

Project: MyProject
Date: 2025-01-15 14:30:00
Strategy: smart_merge

## Session Summary

[Full session summary from git commits, file changes, completed tasks]

## Target Documentation Files

- README.md
- CHANGELOG.md
- docs/API.md

## Instructions

Please update the following documentation based on this session:

1. **CHANGELOG.md**: Add entry for today's changes
2. **README.md**: Update any sections affected by changes (if applicable)
3. Other specified paths: Update as needed based on context

Use the smart_merge strategy to intelligently merge this information.
```

## Claude Code Detection Logic

After the task-wrapup skill completes, Claude Code should:

```python
import os

# 1. Check for documentation request
request_file = ".task_wrapup_doc_update_request.md"

if os.path.exists(request_file):
    print("📝 Documentation update request detected")

    # 2. Read the request
    with open(request_file, 'r') as f:
        request_content = f.read()

    print(f"Request file:\n{request_content}\n")

    # 3. Invoke /sc:document using SlashCommand tool
    # This will analyze the session summary and intelligently update docs

    # Example invocation:
    # /sc:document "Update CHANGELOG and README based on session:
    #              [session summary here]"

    # 4. /sc:document will:
    #    - Parse the session summary
    #    - Identify key changes and features
    #    - Update CHANGELOG.md with dated entry
    #    - Update README.md sections if affected
    #    - Update any other specified documentation paths

    # 5. Cleanup
    os.remove(request_file)
    print("✅ Documentation updated, request file removed")

    # 6. Report
    print("Documentation updates:")
    print("  - CHANGELOG.md: Added session entry")
    print("  - README.md: Updated installation section")
```

## Why Two Phases?

### Python Script Limitations
- Cannot directly invoke Claude Code commands
- No access to `/sc:document` intelligence
- Limited context about project structure
- Cannot make intelligent documentation decisions

### Claude Code Advantages
- Access to full project context via Serena MCP
- Intelligent analysis of what needs updating
- `/sc:document` command with smart merge strategies
- Better understanding of documentation structure
- Can make context-aware decisions about what to document

## Integration with /sc:document

The `/sc:document` command will:

1. **Analyze Session Summary**: Extract key changes, features, fixes
2. **Determine Scope**: Identify which documentation files need updates
3. **CHANGELOG Updates**:
   - Add dated entry with session changes
   - Format according to existing CHANGELOG style
   - Group changes by type (Features, Fixes, Improvements)

4. **README Updates**:
   - Update Installation section if dependencies changed
   - Update Usage section if API/interface changed
   - Add new sections if new features introduced
   - Refresh examples if behavior changed

5. **Other Documentation**:
   - Update API docs if endpoints changed
   - Refresh configuration docs if settings changed
   - Update architecture docs if structure changed

6. **Smart Merge Strategy**:
   - Preserve existing documentation structure
   - Avoid duplicating information
   - Maintain consistent voice and style
   - Intelligently place new content

## Command Clarification

### `/sc:document` - Documentation Generation
**Purpose**: Update project documentation files
**Use Case**: CHANGELOG, README, API docs, guides
**Used By**: task-wrapup skill (this implementation)
**Example**: `/sc:document "Add CHANGELOG entry for authentication feature"`

### `/sc:save` - Session Context Persistence
**Purpose**: Save work context to Serena MCP
**Use Case**: Cross-session continuity, project memory
**NOT Used By**: task-wrapup skill
**Example**: `/sc:save "Session context for future reference"`

### Key Difference
- **`/sc:document`**: Updates **project documentation** (visible files)
- **`/sc:save`**: Saves **session memory** (internal context)

## Error Handling

### Request File Not Found
```python
# Not an error - documentation disabled or auto_update=false
print("ℹ️  No documentation update request found")
```

### /sc:document Fails
```python
# Log error, preserve request file for manual processing
print("❌ Documentation update failed")
print("Request file preserved: .task_wrapup_doc_update_request.md")
print("Please manually review and update documentation")
```

### Partial Updates
```python
# Some files updated, others failed
print("⚠️  Partial documentation update")
print("✅ Updated: CHANGELOG.md")
print("❌ Failed: README.md (file locked)")
```

## Testing

### Manual Test
```bash
# 1. Create test request file
cat > .task_wrapup_doc_update_request.md << 'EOF'
# Documentation Update Request

Project: TestProject
Date: 2025-01-15 14:30:00
Strategy: smart_merge

## Session Summary

- Implemented user authentication system
- Added JWT token support
- Created login/logout endpoints
- Added password hashing with bcrypt

## Target Documentation Files

- CHANGELOG.md
- README.md

## Instructions

Please update the following documentation based on this session:

1. **CHANGELOG.md**: Add entry for today's changes
2. **README.md**: Update any sections affected by changes
EOF

# 2. Invoke Claude Code detection logic
# (Claude Code should detect and process this file)

# 3. Verify updates
cat CHANGELOG.md
cat README.md

# 4. Verify cleanup
ls -la .task_wrapup_doc_update_request.md  # Should not exist
```

## Future Enhancements

### Possible Improvements
1. **Structured Format**: Use JSON instead of Markdown for request file
2. **Diff Inclusion**: Include git diffs in request for better context
3. **Automated PR**: Create pull request with documentation updates
4. **Review Mode**: Preview changes before applying
5. **Rollback Support**: Keep backup of documentation before updates

---

**Implementation Status**: ✅ Complete
**Last Updated**: 2025-01-15
**Version**: 1.0.0
