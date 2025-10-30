---
name: email
description: Send and draft professional emails with seasonal HTML formatting, authentic writing style, contact lookup via Google Contacts, security-first approach, and Gmail MCP integration with Himalaya CLI fallback. This skill should be used for ALL email operations (mandatory per RULES.md).
category: communication
version: 2.3.0
---

# Email Agent Skill

## ✅ PRE-FLIGHT VERIFICATION

**CRITICAL: Before proceeding with ANY email operation, verify this skill loaded correctly:**

1. ✅ This SKILL.md file loaded successfully
2. ✅ You can see version 2.4.0 at the bottom of this file
3. ✅ You can see the preferred email addresses section (Mark, Julie, Rose)
4. ✅ You can see the Core Workflow section with recipient resolution

**If ANY of these are missing:**
- 🛑 STOP immediately - do NOT proceed with email
- Report to user: "❌ Email skill did not load correctly"
- Show the error you encountered
- Ask user for guidance on how to proceed
- NEVER use alternative approaches (email search, direct Gmail MCP)

## Purpose

Send and draft professional emails on behalf of Arlen Greer with:
- Automatic contact lookup via Google Contacts
- Seasonal HTML formatting based on current date
- Authentic professional writing style
- Security-first approach with credential redaction
- Gmail MCP primary, Himalaya CLI fallback

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
- **🎃 CRITICAL: HALLOWEEN THEME MANDATORY (October 30 - November 1, 2025)**: Use sophisticated Halloween atmospheric theme for ALL emails during this period
- After November 1, 2025: Check for matching national holiday (takes priority)
- Otherwise use seasonal theme based on date
- See `references/seasonal_themes.md` for detailed styling

**🎃 HALLOWEEN THEME ENFORCEMENT**:
- **Dates**: October 30, October 31, AND November 1, 2025
- **Mandatory**: ALL outgoing emails MUST use Halloween theme during this period
- **No exceptions**: Even routine business emails use the Halloween theme
- **Remove this section**: On November 2, 2025

**🎃 Special Halloween Theme (October 30 - November 1, 2025)**:

**CRITICAL**: This theme MUST be used for ALL outgoing emails on October 30, October 31, AND November 1, 2025. Remove this entire Halloween theme section on November 2nd, 2025.

Use this sophisticated, mature HTML theme:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{SUBJECT}}</title>
  <style>
    @keyframes moonGlow {
      0%, 100% {
        box-shadow: 0 0 40px rgba(255, 255, 255, 0.4),
                    0 0 80px rgba(255, 255, 255, 0.2),
                    0 0 120px rgba(255, 255, 255, 0.1);
      }
      50% {
        box-shadow: 0 0 60px rgba(255, 255, 255, 0.6),
                    0 0 100px rgba(255, 255, 255, 0.3),
                    0 0 160px rgba(255, 255, 255, 0.15);
      }
    }

    @keyframes cloudDrift {
      0% { transform: translateX(0); opacity: 0.8; }
      50% { opacity: 0.4; }
      100% { transform: translateX(-200px); opacity: 0.8; }
    }

    @keyframes twinkle {
      0%, 100% { opacity: 1; transform: scale(1); }
      50% { opacity: 0.3; transform: scale(0.8); }
    }

    @keyframes drift {
      0% { transform: translateY(0) rotate(0deg); opacity: 0; }
      10% { opacity: 1; }
      90% { opacity: 1; }
      100% { transform: translateY(100vh) rotate(360deg); opacity: 0; }
    }

    @keyframes floatSlow {
      0%, 100% { transform: translateY(0); }
      50% { transform: translateY(-20px); }
    }

    body {
      margin: 0;
      padding: 0;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
      background: radial-gradient(ellipse at center, #1a1a2e 0%, #000000 100%);
      min-height: 100vh;
      position: relative;
      overflow-x: hidden;
    }

    .moon {
      position: fixed;
      top: 80px;
      right: 100px;
      width: 120px;
      height: 120px;
      background: radial-gradient(circle at 30% 30%, #ffffff, #f5f5f5, #e0e0e0);
      border-radius: 50%;
      z-index: 1;
      animation: moonGlow 4s ease-in-out infinite;
    }

    .moon::before {
      content: '';
      position: absolute;
      width: 25px;
      height: 25px;
      background: radial-gradient(circle, rgba(180, 180, 180, 0.4), transparent);
      border-radius: 50%;
      top: 35%;
      left: 45%;
    }

    .moon::after {
      content: '';
      position: absolute;
      width: 18px;
      height: 18px;
      background: radial-gradient(circle, rgba(200, 200, 200, 0.3), transparent);
      border-radius: 50%;
      top: 55%;
      left: 25%;
    }

    .stars {
      position: fixed;
      width: 100%;
      height: 100%;
      z-index: 0;
    }

    .star {
      position: absolute;
      width: 2px;
      height: 2px;
      background: white;
      border-radius: 50%;
      animation: twinkle 3s ease-in-out infinite;
    }

    .cloud {
      position: fixed;
      font-size: 80px;
      opacity: 0.2;
      z-index: 2;
      animation: cloudDrift 40s linear infinite;
    }

    .cloud-1 { top: 100px; right: -100px; animation-delay: 0s; }
    .cloud-2 { top: 200px; right: -100px; animation-delay: 10s; }

    .leaf {
      position: fixed;
      font-size: 30px;
      animation: drift 30s linear infinite;
      z-index: 0;
    }

    .fog {
      position: fixed;
      bottom: 0;
      left: 0;
      width: 100%;
      height: 200px;
      background: linear-gradient(to top, rgba(138, 43, 226, 0.3), transparent);
      z-index: 0;
    }

    .email-container {
      position: relative;
      z-index: 10;
      max-width: 600px;
      margin: 60px auto;
      padding: 20px;
    }

    .main-content {
      background: linear-gradient(135deg,
        rgba(25, 20, 35, 0.92),
        rgba(45, 25, 55, 0.92),
        rgba(35, 25, 45, 0.92));
      backdrop-filter: blur(10px);
      border-radius: 12px;
      padding: 50px 40px;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
      border: 1px solid rgba(255, 255, 255, 0.1);
      animation: fadeIn 1s ease-out;
    }

    h1 {
      color: #b794f6;
      font-family: 'Garamond', serif;
      font-size: 28px;
      margin: 0 0 30px 0;
      text-align: center;
      font-weight: 300;
      letter-spacing: 2px;
    }

    p {
      color: #e0e0e0;
      line-height: 1.8;
      margin: 0 0 20px 0;
      font-size: 16px;
    }

    .signature {
      margin-top: 40px;
      padding-top: 20px;
      border-top: 1px solid rgba(255, 255, 255, 0.2);
      color: #d0d0d0;
      font-size: 14px;
    }

    @media only screen and (max-width: 600px) {
      .email-container { padding: 15px; }
      .main-content { padding: 30px 25px; }
      .moon { width: 80px; height: 80px; top: 40px; right: 40px; }
    }
  </style>
</head>
<body>
  <div class="moon"></div>

  <div class="stars">
    <div class="star" style="top: 15%; left: 20%; animation-delay: 0s;"></div>
    <div class="star" style="top: 25%; left: 80%; animation-delay: 0.5s;"></div>
    <div class="star" style="top: 40%; left: 10%; animation-delay: 1s;"></div>
    <div class="star" style="top: 60%; left: 70%; animation-delay: 1.5s;"></div>
    <div class="star" style="top: 70%; left: 30%; animation-delay: 2s;"></div>
    <div class="star" style="top: 35%; left: 50%; animation-delay: 0.7s;"></div>
    <div class="star" style="top: 80%; left: 60%; animation-delay: 2.5s;"></div>
    <div class="star" style="top: 20%; left: 45%; animation-delay: 1.2s;"></div>
    <div class="star" style="top: 50%; left: 85%; animation-delay: 1.8s;"></div>
    <div class="star" style="top: 65%; left: 15%; animation-delay: 2.2s;"></div>
    <div class="star" style="top: 10%; left: 65%; animation-delay: 0.3s;"></div>
    <div class="star" style="top: 75%; left: 40%; animation-delay: 2.7s;"></div>
  </div>

  <div class="cloud cloud-1">☁️</div>
  <div class="cloud cloud-2">☁️</div>

  <div class="leaf" style="left: 10%; animation-delay: 0s;">🍂</div>
  <div class="leaf" style="left: 30%; animation-delay: 5s;">🍁</div>
  <div class="leaf" style="left: 50%; animation-delay: 10s;">🍂</div>
  <div class="leaf" style="left: 70%; animation-delay: 15s;">🍁</div>
  <div class="leaf" style="left: 90%; animation-delay: 20s;">🍂</div>

  <div class="fog"></div>

  <div class="email-container">
    <div class="main-content">
      <p>Hi {{RECIPIENT_NAME}},</p>

      {{CONTENT}}

      <div class="signature">
        <p>-Arlen</p>
      </div>
    </div>
  </div>
</body>
</html>
```

**Theme Features**:
- Sophisticated dark atmospheric design with purple/violet accents
- Detailed moon with realistic glow and crater effects
- Drifting clouds, twinkling stars, floating autumn leaves
- Elegant typography with proper spacing
- Mobile-responsive with adaptive sizing
- No explicit "Halloween" or holiday references (mature thematic approach)

**Season Ranges** (for non-special dates):
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

**Primary Method: Gmail MCP**

Available tools:
- `mcp__gmail__send_email` - Send immediately
- `mcp__gmail__draft_email` - Create draft for review

Example:
```javascript
mcp__gmail__send_email({
  to: ["recipient1@example.com", "recipient2@example.com"],
  subject: "Project Update",
  htmlBody: "<html>...</html>",
  mimeType: "text/html",
  bcc: ["arlenagreer@gmail.com"] // MANDATORY for 2+ recipients - ALWAYS include automatically
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
