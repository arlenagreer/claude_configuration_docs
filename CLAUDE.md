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

# Communication Skills - MANDATORY USAGE

## Email Communication - MANDATORY SKILL USAGE

**🔴 CRITICAL: ALL email operations MUST use the Email Agent Skill**

**Command**: `@~/.claude/skills/email/SKILL.md [request]`

**NO exceptions for "simple" emails** - ALL emails require the skill

### Why This Matters

The email skill provides essential features that direct MCP calls bypass:
- ✅ **Arlen's authentic writing style** - Maintains consistent voice and tone
- ✅ **Seasonal HTML formatting** - Professional themed templates based on current date
- ✅ **Automatic contact lookup** - Google Contacts integration by name
- ✅ **Mobile-responsive templates** - Proper formatting on all devices
- ✅ **Date-aware theming** - Spring, summer, fall, winter, holiday styles
- ✅ **Himalaya CLI fallback** - Works as alternative when Gmail API unavailable

### Technical Stack

**Primary Method**: Gmail API direct integration via Ruby scripts
**Fallback Method**: Himalaya CLI (when API unavailable)
**Contact Resolution**: `~/.claude/skills/email/lookup_contact_email.rb --name "First Last"`

### Usage Examples

```bash
# Send email to contact by name
@~/.claude/skills/email/SKILL.md "Send Rob a summary of the frontend-debug skill"

# Email with specific formatting
@~/.claude/skills/email/SKILL.md "Draft professional email to team about Q4 planning"

# Quick message
@~/.claude/skills/email/SKILL.md "Email Sarah about tomorrow's meeting"
```

### Enforcement

This rule is enforced in RULES.md as 🔴 CRITICAL priority.

## Text Message Communication - AGENT SKILL

**Command**: `@~/.claude/skills/text-message/SKILL.md [request]`

**🔴 CRITICAL BEHAVIOR: Messages are ALWAYS sent individually to each recipient, NEVER as group messages**

Send text messages (SMS/iMessage) via Apple Messages app with intelligent features:
- ✅ **Individual message delivery** - Multiple recipients = multiple separate 1-on-1 messages (NEVER group chats)
- ✅ **Automatic contact lookup** - Resolves names to mobile numbers via Google Contacts
- ✅ **Interactive prompts** - Asks for missing recipient or message information
- ✅ **Flexible phone formats** - Accepts any phone number format, normalizes automatically
- ✅ **iMessage & SMS support** - Messages app handles delivery method automatically

**Key Difference from Email**:
- 📧 Email skill: CAN send to multiple recipients simultaneously
- 💬 Text-message skill: MUST send individually to each recipient (no group messages)

### When to Use

Use the text-message skill when:
- User requests to send a text message or SMS
- Keywords: "text", "message", "SMS", "iMessage", "send to", "tell"
- Mobile communication needed

### Technical Stack

**Platform**: macOS only (requires Apple Messages app)
**Contact Resolution**: Google Contacts API via contacts skill
**Delivery**: AppleScript automation of Messages app

### Usage Examples

```bash
# Send to named contact (single recipient)
@~/.claude/skills/text-message/SKILL.md "Send Rob a text saying I'm running 10 minutes late"

# Natural "tell" pattern (NEW)
@~/.claude/skills/text-message/SKILL.md "Tell Sheila Anderson I'll be there in 10 minutes"

# Multiple recipients (sends individually, NOT as group)
@~/.claude/skills/text-message/SKILL.md "Text Rob, Julie, and Mark that the meeting is postponed"
# Result: Three separate 1-on-1 messages sent

# Direct phone number
@~/.claude/skills/text-message/SKILL.md "Text 555-123-4567 to confirm the appointment"

# Interactive (will prompt for recipient and message)
@~/.claude/skills/text-message/SKILL.md "Send a text message"
```

### Requirements

- **macOS**: Apple Messages app required
- **Permissions**: System Settings → Privacy & Security → Automation → Enable Messages
- **Contact Integration**: Google Contacts via contacts skill for name lookups

### Script Reference

Direct script usage:
```bash
~/.claude/skills/text-message/scripts/send_message.sh "PHONE_NUMBER" "MESSAGE_TEXT"
```


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

- Remember to offer to use the Himalaya CLI to send emails in the event that the Gmail API is not available
