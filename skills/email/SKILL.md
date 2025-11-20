---
name: email
description: Send and draft professional emails with seasonal HTML formatting, authentic writing style, contact lookup via Google Contacts, security-first approach, and Google Gmail API via Ruby CLI. This skill should be used for ALL email operations (mandatory per RULES.md).
category: communication
version: 3.0.0
---

# Email Agent Skill

## ✅ PRE-FLIGHT VERIFICATION

**CRITICAL: Before proceeding with ANY email operation, verify this skill loaded correctly:**

1. ✅ This SKILL.md file loaded successfully
2. ✅ You can see version 2.5.0 at the bottom of this file
3. ✅ You can see the preferred email addresses section (Mark, Julie, Rose)
4. ✅ You can see the Core Workflow section with recipient resolution

**If ANY of these are missing:**
- 🛑 STOP immediately - do NOT proceed with email
- Report to user: "❌ Email skill did not load correctly"
- Show the error you encountered
- Ask user for guidance on how to proceed
- NEVER use alternative approaches (email search, manual Gmail API calls)

## Purpose

Send and draft professional emails on behalf of Arlen Greer with:
- Automatic contact lookup via Google Contacts
- Seasonal HTML formatting based on current date
- Authentic professional writing style
- Security-first approach with credential redaction
- Gmail API via Ruby script primary, Himalaya CLI fallback

**🔴 CRITICAL NAME RULE**: User's name is **"Arlen Greer"** or **"Arlen A. Greer"**
- ✅ CORRECT: Arlen, Arlen Greer, Arlen A. Greer
- ❌ NEVER: Arlena (this is WRONG - system username confusion)
- The system username is "arlenagreer" but the actual name is "Arlen"

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

**Preferred Email Addresses (Skip Lookup)**:

These contacts have preferred email addresses that ALWAYS take precedence over Google Contacts lookup:

- **Mark Whitney** → `mark@dreamanager.com`
- **Julie Whitney** → `julie@dreamanager.com`
- **Rose Fletcher** → `rose@dreamanager.com`
- **Jayson Bernstein** → `jayson@alt.bio`
- **Susan Butch** → `sbutch@alt.bio`
- **Kevin Blair** → `kblair@alt.bio`
- **Ryan Walsh** → `rwalsh@alt.bio`

**Team Aliases**:

- **ALT Team** (when in american_laboratory_trading project) → Send to all four:
  - `jayson@alt.bio`
  - `sbutch@alt.bio`
  - `kblair@alt.bio`
  - `rwalsh@alt.bio`

- **Dreamanager Team** or **Five Star Team** → Send to all four:
  - `mark@dreamanager.com`
  - `julie@dreamanager.com`
  - `rose@dreamanager.com`
  - `ed@dreamanager.com` (Dreamanager context)

**Context-Sensitive Routing**:

- **Ed Korkuch** → Context-based email selection:
  - `ed@dreamanager.com` - For Dreamanager project-related communications
  - `ekorkuch@versacomputing.com` - For all other topics

  **How to determine context**:
  - Dreamanager context indicators: project work, database, Rails app, deployments, features, bugs, investor/resident functionality
  - Non-Dreamanager context: general consulting, other projects, non-project discussions

  **When in doubt**: Default to `ekorkuch@versacomputing.com` for professional safety

**Contact Lookup** (for all other recipients):
```bash
~/.claude/skills/email/scripts/lookup_contact_email.rb --name "First Last"
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

**🔴 CRITICAL: BCC Default Behavior**:
- **Multiple Recipients (2+)**: MANDATORY - ALWAYS include `arlenagreer@gmail.com` in BCC field automatically
  - This is NON-NEGOTIABLE - do NOT ask user permission
  - Do NOT mention in conversation - just include it
  - User wants copy of ALL group emails for record-keeping
- **Single Recipient**: BCC only if user explicitly requests "bcc me"
- **Verification**: Before sending ANY multi-recipient email, confirm BCC field includes arlenagreer@gmail.com

### 2. Security Review (🔴 CRITICAL - MANDATORY)

**🔴 CRITICAL: BEFORE composing ANY email, MUST scan ALL content for sensitive information:**

**NEVER Include These in Emails (Zero Tolerance)**:
- ❌ **API Tokens** - Including app-specific tokens, bearer tokens, service tokens
- ❌ **API Keys** - AWS keys, Google API keys, service API keys, authentication keys
- ❌ **Access Tokens** - OAuth tokens, JWT tokens, session tokens, refresh tokens
- ❌ **Passwords** - Current, temporary, default, or any password variations
- ❌ **Auth Credentials** - Username/password pairs, login credentials, auth strings
- ❌ **Private Keys** - SSH keys, PGP keys, certificates, signing keys
- ❌ **Database Credentials** - Connection strings, database passwords, DB URLs with credentials
- ❌ **Credit Card Information** - Full numbers (use last 4 digits only if absolutely necessary)
- ❌ **Social Security Numbers** - Or any government-issued ID numbers
- ❌ **Secret Environment Variables** - AWS credentials, secret keys, config secrets

**🔴 CRITICAL API Token Examples (MUST REDACT)**:
```
❌ WRONG: "The API token is: j22pamuqie56upqinzeeNj"
❌ WRONG: "Use api_token=abc123xyz456 for authentication"
❌ WRONG: "Bearer token: eyJhbGciOiJIUzI1NiIsInR5cCI6..."

✅ CORRECT: "I've configured the API token (redacted for security)"
✅ CORRECT: "API token: ...XXXX (last 4 chars: Nj)"
✅ CORRECT: "The authentication token has been set up in the system"
✅ CORRECT: "Token configured (see secure documentation for access)"
```

**When Sensitive Info Must Be Referenced**:
- Reference it exists but NEVER include actual value
- Use "...XXXX" notation with last 4 characters only if verification needed
- Direct recipient to secure channel (secure docs, password manager, encrypted communication)
- Provide system location where they can find it securely

**Scanning Procedure (MANDATORY)**:
1. 🔍 **Scan user's original request** for any sensitive data
2. 🔍 **Scan email body** you're about to compose for any secrets
3. 🔍 **Scan code snippets** or technical examples for credentials
4. 🔍 **Scan URLs** for embedded tokens (e.g., `?token=...` or `?api_key=...`)
5. 🔍 **Scan configuration examples** for default/example credentials
6. 🔒 **REDACT immediately** if ANY sensitive data found

**Remember**: Email is NOT ENCRYPTED. When in doubt, redact it out. NEVER compromise security for convenience.

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

**Signature & Footer Requirements**:
- Standard: `-Arlen`
- Formal: `-Arlen A. Greer` (for senior executives, legal, contracts)
- ❌ **ABSOLUTELY NO AI ATTRIBUTION OR AUTOMATION NOTES**
- ❌ **NO FOOTERS** beyond signature - emails must end with signature only
- ❌ **FORBIDDEN PHRASES**: "generated by", "automation", "Claude Code", "AI-generated", "Co-Authored-By"
- Emails MUST appear to come directly from Arlen with no indication of automation

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

**Primary Method: Google Gmail API via CLI**

Use the `gmail_manager.rb` script for all email operations:

**Send Email**:
```bash
echo '{
  "to": ["recipient@example.com"],
  "subject": "Subject Line",
  "body_html": "<html>...</html>",
  "cc": [],
  "bcc": []
}' | ~/.claude/skills/email/scripts/gmail_manager.rb send
```

**Create Draft**:
```bash
echo '{
  "to": ["recipient@example.com"],
  "subject": "Draft Subject",
  "body_html": "<html>...</html>",
  "cc": [],
  "bcc": []
}' | ~/.claude/skills/email/scripts/gmail_manager.rb draft
```

**Important Notes**:
- BCC to `arlenagreer@gmail.com` is **automatically added** by the script
- No need to manually include in BCC field - script handles it
- For multiple recipients, just list all addresses in the `to` array
- JSON input via STDIN, JSON output via STDOUT

**First-Time OAuth Setup**:
```bash
# Script will prompt with authorization URL if not authenticated
~/.claude/skills/email/scripts/gmail_manager.rb send

# Follow the instructions:
# 1. Visit the provided authorization URL
# 2. Grant access to Gmail, Calendar, and Contacts
# 3. Copy the authorization code
# 4. Complete authorization:
~/.claude/skills/email/scripts/gmail_manager.rb auth <YOUR_CODE>
```

**OAuth Scopes**:
- `https://www.googleapis.com/auth/gmail.modify` - Send, draft, and read emails
- `https://www.googleapis.com/auth/calendar` - Calendar operations (shared token)
- `https://www.googleapis.com/auth/contacts` - Contact lookups (shared token)

**Shared Token**: Uses the same OAuth token as calendar and contacts skills at `~/.claude/.google/token.json`

## Bundled Resources

### Scripts

**`scripts/gmail_manager.rb`**
- Send and draft emails via Google Gmail API
- Automatic BCC to arlenagreer@gmail.com
- Shared OAuth token with calendar and contacts skills
- Requires: `~/.claude/.google/client_secret.json` and `~/.claude/.google/token.json`

**Commands**:
```bash
# Complete OAuth authorization
gmail_manager.rb auth <code>

# Send email (JSON input via STDIN)
echo '{"to":["test@example.com"],"subject":"Test","body_html":"<p>Hello</p>"}' | gmail_manager.rb send

# Create draft (JSON input via STDIN)
echo '{"to":["test@example.com"],"subject":"Draft","body_html":"<p>Draft</p>"}' | gmail_manager.rb draft

# List messages (optional query parameter)
echo '{"query":"is:unread","max_results":10}' | gmail_manager.rb list
```

**Output Format**:
- Success: `{"status": "success", "operation": "send", "message_id": "...", "thread_id": "...", "recipients": {...}}`
- Error: `{"status": "error", "error_code": "...", "message": "..."}`

**Exit Codes**:
- 0: Success
- 1: Operation failed
- 2: Authentication error
- 3: API error
- 4: Invalid arguments

**OAuth Scopes**:
- `https://www.googleapis.com/auth/gmail.modify`
- `https://www.googleapis.com/auth/calendar`
- `https://www.googleapis.com/auth/contacts`

**`scripts/lookup_contact_email.rb`**
- Query Google Contacts by name
- Returns email address via JSON output
- Requires: `~/.claude/.google/client_secret.json` and `~/.claude/.google/token.json`

**Usage**:
```bash
~/.claude/skills/email/scripts/lookup_contact_email.rb --name "John Smith"
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

**Gmail API Unavailable**:
- Automatically offer Himalaya CLI fallback
- Provide clear instructions for CLI method
- Confirm user wants to proceed

## Pre-Send Checklist

**🔴 CRITICAL: Security (Check FIRST - MANDATORY)**:
- ✅ **API Tokens**: ALL tokens redacted or removed (ZERO TOLERANCE)
- ✅ **API Keys**: No AWS, Google, or service API keys visible
- ✅ **Passwords**: No passwords or credentials of any kind
- ✅ **Access Tokens**: OAuth, JWT, bearer tokens all redacted
- ✅ **URLs**: Checked for embedded tokens (?token=, ?api_key=, auth parameters)
- ✅ **Code Examples**: Configuration and code snippets sanitized
- ✅ **Log Outputs**: System logs and debug output sanitized
- ✅ **Database Credentials**: Connection strings and DB passwords removed
- ⚠️ **IF ANY SENSITIVE DATA FOUND**: STOP immediately and redact before sending

**🔴 Name Validation (CRITICAL)**:
- ✅ No references to "Arlena" (incorrect name - must be "Arlen")
- ✅ All name references use "Arlen" or "Arlen Greer" or "Arlen A. Greer"
- ✅ Scan entire email body and footer for incorrect name variants

**🚫 Footer & Attribution Validation (CRITICAL)**:
- ✅ NO automation notes ("generated by", "automation", "Claude Code")
- ✅ NO AI attribution ("AI-generated", "Co-Authored-By: Claude")
- ✅ Footer contains ONLY signature (`-Arlen` or `-Arlen A. Greer`)
- ✅ Email ends immediately after signature - no additional text

**Content & Style**:
- ✅ Recipient email resolved
- ✅ **BCC VERIFICATION (CRITICAL)**: If 2+ recipients, `arlenagreer@gmail.com` MUST be in BCC field - NO EXCEPTIONS
- ✅ Current date verified from system clock
- ✅ Appropriate seasonal/holiday theme applied (Halloween theme Oct 30 - Nov 1, 2025)
- ✅ Writing style matches Arlen's voice
- ✅ Proper greeting and closing
- ✅ Mobile responsive HTML

## Quick Reference

**Contact Lookup**:
```bash
~/.claude/skills/email/scripts/lookup_contact_email.rb --name "First Last"
```

**Season Determination**: Check date in `<env>` → Apply corresponding theme from `references/seasonal_themes.md`

**Writing Style**: Follow patterns in `references/writing_style_guide.md`

**HTML Template**: Use `assets/email_template.html` with seasonal styling

**Signature**: `-Arlen` (standard) or `-Arlen A. Greer` (formal) - NO AI attribution

---

## Version History

- **3.1.0** (2025-11-12) - Added preferred email addresses for American Laboratory Trading team members (Jayson Bernstein, Susan Butch, Kevin Blair, Ryan Walsh). Added team aliases: "ALT Team" for american_laboratory_trading project (sends to all four ALT members), and "Dreamanager Team"/"Five Star Team" (sends to Mark Whitney, Julie Whitney, Rose Fletcher, Ed Korkuch at their @dreamanager.com addresses).
- **3.0.0** (2025-11-09) - Migrated to Google CLI pattern using gmail_manager.rb Ruby script. Now uses google-apis-gmail_v1 gem with AUTH_GMAIL_MODIFY scope for direct Gmail API access. Shares OAuth token (~/.claude/.google/token.json) with calendar and contacts skills. Automatic BCC injection handled by script. Himalaya CLI available as fallback. Future-ready for email reading capabilities.
- **2.5.0** (2025-11-04) - Removed Halloween atmospheric theme as scheduled. Emails now return to standard seasonal themes (Fall theme for current period: September 23 - December 20).
- **2.4.0** (2025-10-30) - Added special Halloween atmospheric theme for October 30-31, 2025. Sophisticated dark design with moon, stars, clouds, and autumn leaves. Theme automatically applies to all outgoing emails on these dates. Instructions included to remove theme on November 1st, 2025.
- **2.3.0** (2025-10-30) - Added automatic BCC default behavior: arlenagreer@gmail.com is now automatically included in BCC field when sending to 2+ recipients (no user request needed). Single-recipient emails still require explicit "bcc me" request.
- **2.2.0** (2025-10-29) - Enhanced recipient resolution with preferred email addresses: Mark Whitney, Julie Whitney, and Rose Fletcher now use @dreamanager.com addresses. Added context-sensitive routing for Ed Korkuch (ed@dreamanager.com for Dreamanager project, ekorkuch@versacomputing.com for other topics).
- **2.1.0** (2025-10-28) - **CRITICAL FIX**: Added explicit name validation (Arlen vs Arlena) and strengthened footer/attribution prohibition with comprehensive pre-send checklist
- **2.0.0** (2025-10-23) - Restructured with skill-creator best practices: extracted references/ (seasonal_themes.md, writing_style_guide.md, himalaya_cli.md), moved script to scripts/, created assets/ with email_template.html, streamlined SKILL.md for progressive disclosure
- **1.7.0** (2025-10-20) - Added three new known recipient shortcuts: Mark Whitney, Julie Whitney, Rose Fletcher
- **1.6.0** (2025-10-19) - Added known recipient shortcut: Ed Korkuch
- **1.5.0** (2025-10-19) - Enhanced documentation with robustness improvements
- **1.4.0** (2025-10-19) - Added "bcc me" shorthand
- **1.3.0** (2025-10-19) - Removed AI attribution from emails
- **1.2.0** (2025-10-19) - Enhanced contact lookup error handling
- **1.1.0** (2025-10-19) - Added comprehensive security requirements
- **1.0.0** (2025-10-19) - Initial email skill creation
