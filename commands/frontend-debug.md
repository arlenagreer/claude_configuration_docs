# Debug Frontend Issue

Invoke the Frontend Debug Skill to investigate and resolve a frontend issue through empirical browser observation.

## Arguments
- `$ARGUMENTS`: Description of the frontend issue to debug

## Instructions

1. Load the Frontend Debug Skill:
   ```
   @~/.claude/skills/frontend-debug/SKILL.md $ARGUMENTS
   ```

2. If no issue description provided in `$ARGUMENTS`, ask the user:
   - What is the issue? (symptoms, reproduction steps)
   - Which page/feature is affected?
   - Any error messages observed?

3. Follow the skill's workflow phases:
   - Phase 0: Initialize isolated browser session
   - Phase 1: Investigate using Chrome DevTools
   - Phase 2: Analyze root cause (with /sc:troubleshoot)
   - Phase 3: Implement fix
   - Phase 4: Verify empirically (all 5 criteria must pass)
   - Phase 5: Document and update knowledge base

4. Iterate until issue is empirically verified as resolved or escalation is required.

## Notes
- Uses Chrome DevTools MCP for browser interaction
- Requires empirical verification - no shortcuts
- Auto-corrects SoftTrak credentials if detected
- Supports concurrent sessions via git worktrees
