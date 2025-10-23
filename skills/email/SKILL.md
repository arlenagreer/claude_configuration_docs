---
name: email
description: Send and draft professional emails with seasonal HTML formatting, authentic writing style, contact lookup via Google Contacts, security-first approach, and Gmail MCP integration with Himalaya CLI fallback. This skill should be used for ALL email operations (mandatory per RULES.md).
category: communication
version: 2.0.0
---

# Email Agent Skill

## Purpose

Send and draft professional emails on behalf of Arlen Greer with:
- Automatic contact lookup via Google Contacts
- Seasonal HTML formatting based on current date
- Authentic professional writing style
- Security-first approach with credential redaction
- Gmail MCP primary, Himalaya CLI fallback

## When to Use This Skill

**🔴 CRITICAL: This skill is MANDATORY for ALL email operations per RULES.md**

Use this skill when:
- User requests to send or draft an email
- Email-related keywords detected: "email", "send", "compose", "draft", "message", "write to"
- User mentions contacting someone by email
- NO EXCEPTIONS - Even "simple" emails require this skill

**Why Mandatory**:
- Provides Arlen's authentic writing style
- Ensures seasonal HTML formatting
- Handles contact lookup automatically
- Enforces security-first approach
- Maintains professional communication standards

## Core Workflow

### 1. Recipient Resolution

**Known Recipients (Skip Lookup)**:
- Ed Korkuch → `ekorkuch@versacomputing.com`
- Mark Whitney → `mark@dreamanager.com`
- Julie Whitney → `julie@dreamanager.com`
- Rose Fletcher → `rose@dreamanager.com`

**Contact Lookup** (for all other recipients):
```bash
scripts/lookup_contact_email.rb --name "First Last"
```

**⚠️ CRITICAL**: Require BOTH first AND last name:
- ❌ WRONG: `--name "John"` or `--name "Smith"`
- ✅ RIGHT: `--name "John Smith"`

**Error Handling**:
- If lookup fails (status = "error"): **STOP immediately** and prompt user for email
- If multiple matches (note field present): Inform user, proceed with first match
- Never proceed without valid email address

**User Shorthands**:
- "bcc me" → Add `arlenagreer@gmail.com` to BCC field
- "send to [Name]" → Look up contact email
- "send to [email]" → Use email directly

### 2. Security Review (MANDATORY)

**🔒 BEFORE composing email, scan for sensitive information:**

**Never Include**:
- ❌ Passwords (current, temporary, default)
- ❌ API keys, access tokens, auth credentials
- ❌ Private keys (SSH, PGP, certificates)
- ❌ Database credentials, connection strings
- ❌ Credit card information (use last 4 digits only)
- ❌ Social Security Numbers, government IDs
- ❌ Secret environment variables

**When Sensitive Info Must Be Referenced**:
```
✅ Good: "I've configured the API key (redacted for security)"
✅ Good: "API key: sk-proj-...XXXX (last 4 chars for verification)"
❌ Bad: "Here's your password: MyP@ssw0rd123"
```

**Remember**: Email is NOT ENCRYPTED. When in doubt, redact it out.

### 3. Date & Theme Selection

**Determine Current Date**:
- Check system clock from `<env>` context
- Never assume dates from knowledge cutoff

**Apply Theme**:
- Check for matching national holiday (takes priority)
- Otherwise use seasonal theme based on date
- See `references/seasonal_themes.md` for detailed styling

**Season Ranges**:
- Spring: March 20 - June 20
- Summer: June 21 - September 22
- Fall: September 23 - December 20
- Winter: December 21 - March 19

### 4. Compose Content

**Apply Arlen's Writing Style**:
- Professional but approachable tone
- Direct and solution-oriented
- Lead with status/accomplishment
- Use bullets for multiple items
- Offer proactive support

See `references/writing_style_guide.md` for:
- Greeting patterns
- Email structure templates
- Communication scenarios
- Language patterns
- Closing conventions

**Signature**:
- Standard: `-Arlen`
- Formal: `-Arlen A. Greer` (for senior executives, legal, contracts)
- ❌ NO AI attribution or footers

### 5. Create HTML Email

**Use Template**: `assets/email_template.html`

**Replace Placeholders**:
- `{{SUBJECT}}` - Email subject line
- `{{RECIPIENT_NAME}}` - Recipient's first name
- `{{CONTENT}}` - Email body content

**Apply Seasonal Styling**:
- Replace seasonal-header background
- Update h1 color
- Set link colors
- See `references/seasonal_themes.md` for color palettes

**Mobile Responsive**:
- Template includes responsive styles
- Max-width: 600px
- Adjusts for mobile viewports

### 6. Send or Draft

**Primary Method: Gmail MCP**

Available tools:
- `mcp__gmail__send_email` - Send immediately
- `mcp__gmail__draft_email` - Create draft for review

Example:
```javascript
mcp__gmail__send_email({
  to: ["recipient@example.com"],
  subject: "Project Update",
  htmlBody: "<html>...</html>",
  mimeType: "text/html",
  bcc: ["arlenagreer@gmail.com"] // if "bcc me" requested
})
```

**Fallback Method: Himalaya CLI**

If Gmail MCP unavailable, use Himalaya CLI.

See `references/himalaya_cli.md` for:
- Configuration details
- Send commands (plain text and HTML)
- Troubleshooting

Basic HTML send:
```bash
himalaya message send << 'EOF'
From: arlenagreer@gmail.com
To: recipient@example.com
Subject: Subject Here
MIME-Version: 1.0
Content-Type: text/html; charset=utf-8

<!DOCTYPE html>
<html>...</html>
EOF
```

## Bundled Resources

### Scripts

**`scripts/lookup_contact_email.rb`**
- Query Google Contacts by name
- Returns email address via JSON output
- Requires: `~/.claude/.google/client_secret.json` and `~/.claude/.google/token.json`

**Usage**:
```bash
scripts/lookup_contact_email.rb --name "John Smith"
```

**Output**:
- Success: `{"status": "success", "email": "john@example.com", "name": "John Smith"}`
- Error: `{"status": "error", "code": "NO_MATCH_FOUND", "message": "..."}`

**Exit Codes**:
- 0: Success
- 1: No match found
- 2: Authentication error
- 3: API error
- 4: Invalid arguments

### References

**`references/seasonal_themes.md`**
- Detailed seasonal color palettes and CSS
- National holiday themes with styling
- Season determination logic
- HTML examples for each theme

**`references/writing_style_guide.md`**
- Comprehensive Arlen writing style examples
- Email structure templates
- Communication scenarios
- Language patterns and conventions

**`references/himalaya_cli.md`**
- Himalaya CLI configuration and usage
- Send commands for plain text and HTML
- Troubleshooting and error handling

### Assets

**`assets/email_template.html`**
- Base HTML email template
- Mobile-responsive structure
- Placeholder system for content
- Ready for seasonal theme injection

## Error Handling

**Contact Lookup Fails**:
1. **STOP** email workflow immediately
2. Display error: "❌ Contact lookup failed: No contact found for '[Name]'"
3. **PROMPT** user: "Please provide an email address for [Name] to continue."
4. **WAIT** for user response - do not assume or guess
5. Only proceed once valid email provided

**Authentication Issues**:
- Check credentials: `~/.claude/.google/client_secret.json`
- Verify token: `~/.claude/.google/token.json`
- Re-authenticate if needed or request manual email

**Gmail MCP Unavailable**:
- Automatically offer Himalaya CLI fallback
- Provide clear instructions for CLI method
- Confirm user wants to proceed

## Pre-Send Checklist

**🔒 Security (Check FIRST)**:
- ✅ No passwords or credentials visible
- ✅ API keys and tokens redacted
- ✅ URLs checked for embedded auth
- ✅ Log outputs sanitized

**Content & Style**:
- ✅ Recipient email resolved
- ✅ Current date verified from system clock
- ✅ Appropriate seasonal/holiday theme applied
- ✅ Writing style matches Arlen's voice
- ✅ Proper greeting and closing (no AI attribution)
- ✅ Mobile responsive HTML

## Quick Reference

**Contact Lookup**:
```bash
scripts/lookup_contact_email.rb --name "First Last"
```

**Season Determination**: Check date in `<env>` → Apply corresponding theme from `references/seasonal_themes.md`

**Writing Style**: Follow patterns in `references/writing_style_guide.md`

**HTML Template**: Use `assets/email_template.html` with seasonal styling

**Signature**: `-Arlen` (standard) or `-Arlen A. Greer` (formal) - NO AI attribution

---

## Version History

- **2.0.0** (2025-10-23) - Restructured with skill-creator best practices: extracted references/ (seasonal_themes.md, writing_style_guide.md, himalaya_cli.md), moved script to scripts/, created assets/ with email_template.html, streamlined SKILL.md for progressive disclosure
- **1.7.0** (2025-10-20) - Added three new known recipient shortcuts: Mark Whitney, Julie Whitney, Rose Fletcher
- **1.6.0** (2025-10-19) - Added known recipient shortcut: Ed Korkuch
- **1.5.0** (2025-10-19) - Enhanced documentation with robustness improvements
- **1.4.0** (2025-10-19) - Added "bcc me" shorthand
- **1.3.0** (2025-10-19) - Removed AI attribution from emails
- **1.2.0** (2025-10-19) - Enhanced contact lookup error handling
- **1.1.0** (2025-10-19) - Added comprehensive security requirements
- **1.0.0** (2025-10-19) - Initial email skill creation
