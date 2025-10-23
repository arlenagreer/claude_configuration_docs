# SuperClaude Entry Point - Optimized

@COMMANDS.md
@FLAGS.md
@PRINCIPLES.md
@RULES.md
@MCP.md
@PERSONAS.md
@ORCHESTRATOR.md
@MODES.md
@WORKFLOW.md

# System References

- CRITICAL: When referring to dates, you MUST reference the system clock.  Do not use your cut-off date as a reference when applying a timestamp or referencing any date relative to 'now'

# Email Communication - MANDATORY SKILL USAGE

**🔴 CRITICAL: ALL email operations MUST use the Email Agent Skill**

**Command**: `@~/.claude/skills/email/SKILL.md [request]`

**NEVER use direct Gmail MCP calls** (`mcp__gmail__send_email`, `mcp__gmail__draft_email`)
**NO exceptions for "simple" emails** - ALL emails require the skill

## Why This Matters

The email skill provides essential features that direct MCP calls bypass:
- ✅ **Arlen's authentic writing style** - Maintains consistent voice and tone
- ✅ **Seasonal HTML formatting** - Professional themed templates based on current date
- ✅ **Automatic contact lookup** - Google Contacts integration by name
- ✅ **Mobile-responsive templates** - Proper formatting on all devices
- ✅ **Date-aware theming** - Spring, summer, fall, winter, holiday styles
- ✅ **Himalaya CLI fallback** - Works even when Gmail MCP unavailable

## Technical Stack

**Primary Method**: Gmail MCP integration (through skill)
**Fallback Method**: Himalaya CLI (when MCP unavailable)
**Contact Resolution**: `~/.claude/skills/email/lookup_contact_email.rb --name "First Last"`

## Usage Examples

```bash
# Send email to contact by name
@~/.claude/skills/email/SKILL.md "Send Rob a summary of the frontend-debug skill"

# Email with specific formatting
@~/.claude/skills/email/SKILL.md "Draft professional email to team about Q4 planning"

# Quick message
@~/.claude/skills/email/SKILL.md "Email Sarah about tomorrow's meeting"
```

## Enforcement

This rule is enforced in RULES.md as 🔴 CRITICAL priority. Any direct Gmail MCP usage is a behavioral violation.


# ===================================================
# SuperClaude Framework Components
# ===================================================

# Additional Behavioral Modes (not in MODES.md)
@MODE_Brainstorming.md
@MODE_Business_Panel.md
@MODE_DeepResearch.md
@MODE_Orchestration.md

# Core Business Framework
@BUSINESS_PANEL_EXAMPLES.md
@BUSINESS_SYMBOLS.md
@RESEARCH_CONFIG.md

- Remember to offer to use the Himalaya CLI to send emails in the event that the Gmail MCP is not available
