# Claude Code Handler for Task-Wrapup Documentation Updates

## Quick Reference

When the task-wrapup skill completes, Claude Code should automatically detect and process documentation update requests.

## Detection

After task-wrapup skill execution, check for:

```
.task_wrapup_doc_update_request.md
```

## Processing Steps

### 1. Detect Request File

```python
import os

request_file = ".task_wrapup_doc_update_request.md"
if os.path.exists(request_file):
    # Process documentation update
    ...
```

### 2. Read Request Content

```python
with open(request_file, 'r') as f:
    request_content = f.read()
```

The file contains:
- Project name
- Session timestamp
- Full session summary (git commits, file changes, completed tasks)
- Target documentation paths
- Update strategy (smart_merge)

### 3. Invoke /sc:document

Use the SlashCommand tool to invoke `/sc:document`:

```python
# Extract session summary from request file
# Parse target paths (CHANGELOG.md, README.md, etc.)
# Invoke /sc:document with appropriate arguments
```

**Example invocation:**
```
/sc:document --target CHANGELOG.md README.md --strategy smart_merge
```

**What to pass to /sc:document:**
- Session summary (what was accomplished)
- Key changes and features
- Files modified/created
- Tests added
- Documentation that needs updating

### 4. Let /sc:document Do Its Work

The `/sc:document` command will:

✅ **CHANGELOG.md**:
- Add dated entry for today
- List features, fixes, improvements
- Format according to existing style
- Group changes by category

✅ **README.md**:
- Update Installation if dependencies changed
- Update Usage if API/interface changed
- Add new sections for new features
- Refresh examples if needed

✅ **Other Docs**:
- API documentation if endpoints changed
- Configuration docs if settings changed
- Architecture docs if structure changed

### 5. Cleanup Request File

After `/sc:document` completes successfully:

```python
os.remove(request_file)
```

### 6. Report Results

Include in the final wrap-up summary:

```
📝 Documentation Updates:
  ✅ CHANGELOG.md: Added session entry (2025-01-15)
  ✅ README.md: Updated installation section with new dependencies
  ✅ docs/API.md: Refreshed authentication endpoint documentation
```

## Error Handling

### Request File Not Found
```
ℹ️  No documentation update request detected
   (Documentation updates disabled or not configured)
```

### /sc:document Execution Failed
```
❌ Documentation update failed
   Error: [error details]
   Request file preserved: .task_wrapup_doc_update_request.md
   Please manually review and update documentation
```

### Partial Success
```
⚠️  Partial documentation update
   ✅ CHANGELOG.md: Updated successfully
   ❌ README.md: Failed to update (file locked)
   Request file preserved for retry
```

## Integration Pattern

### Skill Invocation Flow

```
User: "Wrap up this session"
  │
  ▼
┌─────────────────────────────────────┐
│ Task-Wrapup Skill Loads             │
│ (via Skill tool)                    │
└─────────────────────────────────────┘
  │
  ▼
┌─────────────────────────────────────┐
│ Phase 1: Summary Generation         │
│ - Analyze git commits               │
│ - Check file changes                │
│ - Review completed todos            │
└─────────────────────────────────────┘
  │
  ▼
┌─────────────────────────────────────┐
│ Phase 2: Preview & Confirmation     │
│ - Show summary                      │
│ - Ask 3 mandatory questions         │
│ - Get user approval                 │
└─────────────────────────────────────┘
  │
  ▼
┌─────────────────────────────────────┐
│ Phase 3: Parallel Dispatch          │
│ - Email (via email skill)           │
│ - SMS (via text-message skill)      │
│ - Worklog (via worklog skill)       │
│ - Documentation (create request)    │
│   └─> .task_wrapup_doc_update_...   │
└─────────────────────────────────────┘
  │
  ▼
┌─────────────────────────────────────┐
│ Phase 4: Final Summary              │
│ - Report all results                │
│ - Include success/failure stats     │
└─────────────────────────────────────┘
  │
  ▼
┌─────────────────────────────────────┐
│ Claude Code Post-Processing         │
│                                     │
│ 1. Detect request file              │
│ 2. Read session summary             │
│ 3. Invoke /sc:document              │
│ 4. Update CHANGELOG, README, etc.   │
│ 5. Cleanup request file             │
│ 6. Report documentation updates     │
└─────────────────────────────────────┘
```

## Example Request File

```markdown
# Documentation Update Request

Project: SuperClaude Framework
Date: 2025-01-15 14:30:45
Strategy: smart_merge

## Session Summary

### Completed Work
- Implemented proper `/sc:document` integration in task-wrapup skill
- Created two-phase documentation update workflow
- Added comprehensive documentation guides
- Updated notification_dispatcher.py with actual implementation
- Clarified distinction between `/sc:document` and `/sc:save`

### Files Modified
- skills/task-wrapup/scripts/notification_dispatcher.py
- skills/task-wrapup/SKILL.md
- skills/task-wrapup/DOCUMENTATION_INTEGRATION.md (new)
- skills/task-wrapup/CLAUDE_CODE_HANDLER.md (new)

### Key Features
- Request file creation (.task_wrapup_doc_update_request.md)
- Smart merge strategy for documentation
- Automatic CHANGELOG and README updates
- Post-processing hook for Claude Code

## Target Documentation Files

- CHANGELOG.md
- README.md
- skills/task-wrapup/SKILL.md

## Instructions

Please update the following documentation based on this session:

1. **CHANGELOG.md**: Add entry for v1.1.0 release with documentation integration
2. **README.md**: Update task-wrapup skill description with new capabilities
3. **skills/task-wrapup/SKILL.md**: Already updated, verify completeness

Use the smart_merge strategy to intelligently merge this information.
```

## Commands Used

### Correct Command: `/sc:document`
**Purpose**: Update project documentation
**Usage**: Documentation updates for CHANGELOG, README, API docs
**Example**: `/sc:document "Add CHANGELOG entry for authentication feature"`

### Wrong Command: `/sc:save`
**Purpose**: Session context persistence (NOT documentation)
**Usage**: Save work context to Serena MCP
**Example**: `/sc:save "Session context for future reference"`

## Pro Tips

1. **Always Check**: Look for `.task_wrapup_doc_update_request.md` after skill completes
2. **Read First**: Parse the session summary before invoking `/sc:document`
3. **Context Matters**: Pass rich context to `/sc:document` for better updates
4. **Cleanup**: Always remove request file after successful processing
5. **Report**: Include documentation updates in final wrap-up summary
6. **Error Handling**: Preserve request file if `/sc:document` fails

---

**Handler Version**: 1.0.0
**Last Updated**: 2025-01-15
**Compatible With**: task-wrapup skill v1.1.0+
