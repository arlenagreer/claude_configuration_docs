---
name: email
description: Send and draft professional emails with seasonal HTML formatting
category: communication
version: 1.6.0
---

# Email Agent Skill

**Purpose**: Send and draft professional emails on behalf of Arlen Greer with automatic contact lookup, seasonal HTML formatting, and authentic writing style.

## Core Capabilities

1. **Send & Draft Emails**: Using Gmail MCP or Himalaya CLI fallback
2. **Contact Lookup**: Automatic recipient email resolution by name
3. **Seasonal HTML Formatting**: Dynamic styling based on season/holidays
4. **Authentic Writing Style**: Maintains Arlen's professional communication voice
5. **Date Awareness**: Uses system clock for current date references
6. **Security-First Drafting**: Automatic sensitive information detection and redaction
7. **Natural Authorship**: Emails appear to come directly from Arlen with no AI attribution

---

## ⚠️ SECURITY REQUIREMENTS - READ FIRST

**🔒 CRITICAL: All outgoing emails MUST be drafted with security in mind.**

### Mandatory Security Practices

**NEVER include in emails**:
- ❌ **Passwords** - Never send passwords via email (current, temporary, or default)
- ❌ **API Keys** - Redact all API keys, access tokens, and authentication credentials
- ❌ **Private Keys** - Never include SSH keys, PGP keys, or certificate private keys
- ❌ **Authentication Tokens** - Redact JWT tokens, session tokens, OAuth tokens
- ❌ **Database Credentials** - Never send database passwords, connection strings with credentials
- ❌ **Credit Card Information** - No full credit card numbers (use last 4 digits only)
- ❌ **Social Security Numbers** - Never include SSNs or other government IDs
- ❌ **Secret Environment Variables** - Redact any secret values from .env files

### Information Requiring Caution

**Handle with care**:
- ⚠️ **File Paths** - Consider if paths reveal sensitive system information
- ⚠️ **URLs with tokens** - Redact any authentication parameters in URLs
- ⚠️ **Configuration snippets** - Review for embedded credentials
- ⚠️ **Log outputs** - Redact any sensitive data from logs
- ⚠️ **Personal Information** - Be cautious with PII (addresses, phone numbers, etc.)

### Redaction Guidelines

**When sensitive information must be referenced**:
```
✅ Good: "I've configured the API key (redacted for security)"
✅ Good: "Password format: 8+ chars, 1 uppercase, 1 number, 1 special"
✅ Good: "Database connection uses credentials from .env file"
✅ Good: "API key: sk-proj-...XXXX (last 4 chars for verification)"

❌ Bad: "Here's your password: MyP@ssw0rd123"
❌ Bad: "API key: sk-proj-1234567890abcdefghijklmnop"
❌ Bad: "Connect using: postgresql://user:password@host/db"
```

### Pre-Send Security Checklist

Before sending ANY email, verify:
- [ ] No passwords or credentials visible
- [ ] API keys and tokens redacted
- [ ] Configuration files reviewed for secrets
- [ ] URLs checked for embedded authentication
- [ ] Log outputs sanitized
- [ ] Personal information appropriately handled
- [ ] File paths don't reveal sensitive structure

### Security-First Mindset

**Remember**:
- Email is **NOT ENCRYPTED** by default
- Email can be forwarded, archived, and accessed by third parties
- Once sent, you cannot recall or control an email
- Assume email will be read by unintended recipients
- **When in doubt, redact it out**

---

## 1. Email Sending Methods

### Primary Method: Gmail MCP

**Preferred approach when Gmail MCP is available.**

#### Available MCP Tools

**Core Operations**:
- `mcp__gmail__send_email` - Send a new email with HTML support
- `mcp__gmail__draft_email` - Create email draft for review
- `mcp__gmail__read_email` - Read email by message ID
- `mcp__gmail__search_emails` - Search using Gmail syntax

**Management**:
- `mcp__gmail__modify_email` - Change labels/folders
- `mcp__gmail__delete_email` - Permanently delete
- `mcp__gmail__batch_modify_emails` - Batch label operations
- `mcp__gmail__batch_delete_emails` - Batch delete operations

**Labels & Organization**:
- `mcp__gmail__list_email_labels` - Get all labels
- `mcp__gmail__create_label` - Create new label
- `mcp__gmail__update_label` - Update existing label
- `mcp__gmail__delete_label` - Delete label
- `mcp__gmail__get_or_create_label` - Get or create label

**Filters**:
- `mcp__gmail__create_filter` - Create custom filter
- `mcp__gmail__list_filters` - List all filters
- `mcp__gmail__get_filter` - Get filter details
- `mcp__gmail__delete_filter` - Delete filter
- `mcp__gmail__create_filter_from_template` - Use pre-defined templates

**Attachments**:
- `mcp__gmail__download_attachment` - Download email attachments

#### Gmail MCP Usage Example

```javascript
// Send HTML email with Gmail MCP
mcp__gmail__send_email({
  to: ["recipient@example.com"],
  subject: "Project Update",
  htmlBody: "<html>...</html>",
  mimeType: "text/html"
})
```

### Fallback Method: Himalaya CLI

**Use when Gmail MCP is unavailable.**

#### Configuration
- **Location**: `~/Library/Application Support/himalaya/config.toml`
- **Account**: arlenagreer@gmail.com
- **Status**: ✅ Configured and tested (Oct 9, 2025)
- **Documentation**: `~/.claude/skills/email/HIMALAYA_EMAIL_CLI.md`

#### Send Plain Text Email
```bash
himalaya message send << 'EOF'
From: arlenagreer@gmail.com
To: recipient@example.com
Subject: Your Subject

Message body here
EOF
```

#### Send HTML Email
```bash
himalaya message send << 'EOF'
From: arlenagreer@gmail.com
To: recipient@example.com
Subject: HTML Email
MIME-Version: 1.0
Content-Type: text/html; charset=utf-8

<!DOCTYPE html>
<html>
<body>
  <h1>HTML Content</h1>
  <p>Your content here</p>
</body>
</html>
EOF
```

---

## 2. Contact Lookup System

**Automatically resolve recipient names to email addresses using Google Contacts.**

### Contact Lookup Script

**Location**: `~/.claude/skills/email/lookup_contact_email.rb`

**Purpose**: Query Google Contacts by exact name match and return email address

**Authentication**:
- **Credentials**: `~/.claude/.google/client_secret.json`
- **Token**: `~/.claude/.google/token.json` (auto-managed)
- **Scope**: Google Contacts Read-Only

### Usage

```bash
# Basic lookup
~/.claude/skills/email/lookup_contact_email.rb --name "John Doe"

# With options
~/.claude/skills/email/lookup_contact_email.rb --help
~/.claude/skills/email/lookup_contact_email.rb --version
```

### Output Format

**Success (single match)**:
```json
{
  "status": "success",
  "email": "john.doe@example.com",
  "name": "John Doe",
  "matched_contact_id": "people/c1234567890"
}
```

**Success (multiple matches)**:
```json
{
  "status": "success",
  "email": "john.doe@example.com",
  "name": "John Doe",
  "matched_contact_id": "people/c1234567890",
  "note": "Multiple contacts found with this name. Returning first match."
}
```

**Error (no match)**:
```json
{
  "status": "error",
  "code": "NO_MATCH_FOUND",
  "message": "No contact found matching 'Jane Smith'",
  "query": "Jane Smith"
}
```

**Error (auth failure)**:
```json
{
  "status": "error",
  "code": "AUTH_ERROR",
  "message": "Credentials file not found at ~/.claude/.google/client_secret.json",
  "query": null
}
```

### Exit Codes
- `0` - Success (email found)
- `1` - No match found
- `2` - Authentication error
- `3` - API error
- `4` - Invalid arguments

### Integration Workflow

1. **Detect Name Reference**: When user mentions recipient by name
2. **Execute Lookup**: Run `lookup_contact_email.rb --name "First Last"`
3. **Parse JSON**: Extract email from JSON output and check status field
4. **Handle Errors**:
   - **If status = "error"**: **STOP immediately** and prompt user for email address
   - **If status = "success" with note**: Inform user of multiple matches, proceed with first
   - **Do NOT proceed** with email composition until valid email obtained
5. **Use Email**: Only after successful lookup or user-provided email, proceed with composition

### Lookup Requirements

**⚠️ CRITICAL NAME FORMAT REQUIREMENT**

**YOU MUST provide BOTH first AND last name for contact lookup to work.**

**❌ WRONG - These will FAIL**:
```bash
~/.claude/skills/email/lookup_contact_email.rb --name "John"      # Missing last name
~/.claude/skills/email/lookup_contact_email.rb --name "Smith"     # Missing first name
~/.claude/skills/email/lookup_contact_email.rb --name "john"      # Missing last name (case doesn't matter)
```

**✅ RIGHT - These will WORK**:
```bash
~/.claude/skills/email/lookup_contact_email.rb --name "John Smith"      # First + Last
~/.claude/skills/email/lookup_contact_email.rb --name "Mary O'Brien"    # Handles special chars
~/.claude/skills/email/lookup_contact_email.rb --name "jean-paul jones" # Case-insensitive
```

**Additional Lookup Details**:
- **Matching**: Case-insensitive exact match on first and last names
- **Multiple Matches**: Returns first match with note
- **Email Priority**: Returns primary email if marked, otherwise first available
- **Special Characters**: Include apostrophes, hyphens, spaces as they appear in contacts

---

## 3. Seasonal & Holiday HTML Formatting

**All outgoing emails MUST be formatted in clear, visually-appealing HTML with seasonal/holiday theming.**

### Formatting Requirements

1. **Always use HTML formatting** (never plain text unless explicitly requested)
2. **Apply seasonal theming** based on current date
3. **Include holiday styling** if current date coincides with national holiday
4. **Maintain professional readability** while being visually appealing
5. **Ensure mobile responsiveness** with proper HTML structure

### Seasonal Themes

#### Spring (March 20 - June 20)
**Color Palette**: Fresh greens, pastels, light blues
**Styling Elements**:
- Light, airy backgrounds (#f0f8f0, #e8f5e9)
- Green accent colors (#4caf50, #66bb6a)
- Floral borders or subtle patterns
- Pastel highlights

```html
<!-- Spring Example -->
<style>
  body { background: linear-gradient(to bottom, #f0f8f0, #ffffff); }
  h1 { color: #2e7d32; border-bottom: 3px solid #66bb6a; }
  a { color: #4caf50; }
</style>
```

#### Summer (June 21 - September 22)
**Color Palette**: Bright blues, sunny yellows, warm oranges
**Styling Elements**:
- Vibrant, energetic backgrounds (#e3f2fd, #fff9c4)
- Blue accent colors (#2196f3, #03a9f4)
- Sun-inspired elements
- Beach/ocean themes

```html
<!-- Summer Example -->
<style>
  body { background: linear-gradient(135deg, #e3f2fd, #fff9c4); }
  h1 { color: #1976d2; border-bottom: 3px solid #03a9f4; }
  a { color: #2196f3; }
</style>
```

#### Fall/Autumn (September 23 - December 20)
**Color Palette**: Warm oranges, deep reds, golden yellows, browns
**Styling Elements**:
- Warm, cozy backgrounds (#fff3e0, #fbe9e7)
- Orange/red accent colors (#ff6f00, #d84315)
- Autumn leaf imagery
- Harvest-inspired elements

```html
<!-- Fall Example -->
<style>
  body { background: linear-gradient(to bottom, #fff3e0, #ffffff); }
  h1 { color: #e65100; border-bottom: 3px solid #ff6f00; }
  a { color: #d84315; }
</style>
```

#### Winter (December 21 - March 19)
**Color Palette**: Cool blues, silver, white, deep purples
**Styling Elements**:
- Cool, crisp backgrounds (#e1f5fe, #f3e5f5)
- Blue/purple accent colors (#1565c0, #6a1b9a)
- Snowflake or winter imagery
- Elegant, formal styling

```html
<!-- Winter Example -->
<style>
  body { background: linear-gradient(135deg, #e1f5fe, #f3e5f5); }
  h1 { color: #0d47a1; border-bottom: 3px solid #1565c0; }
  a { color: #1976d2; }
</style>
```

### National Holiday Themes

**Priority**: Holiday themes override seasonal themes when date matches.

#### Major U.S. Holidays

**New Year's Day** (January 1)
- Colors: Gold, silver, midnight blue
- Elements: Fireworks, champagne, celebration

**Martin Luther King Jr. Day** (3rd Monday in January)
- Colors: Red, black, green (Pan-African colors)
- Elements: Unity, justice, equality themes

**Presidents' Day** (3rd Monday in February)
- Colors: Red, white, blue
- Elements: American flag, presidential seals

**Memorial Day** (Last Monday in May)
- Colors: Red, white, blue with somber tone
- Elements: American flag, remembrance

**Independence Day** (July 4)
- Colors: Patriotic red, white, blue
- Elements: Stars, stripes, fireworks
- Bold, celebratory styling

**Labor Day** (1st Monday in September)
- Colors: Red, white, blue with work themes
- Elements: Industry, workers, achievement

**Thanksgiving** (4th Thursday in November)
- Colors: Warm autumn tones, orange, brown, gold
- Elements: Harvest, gratitude, family
- Cozy, welcoming styling

**Christmas** (December 25)
- Colors: Red, green, gold, white
- Elements: Snow, holly, festive decorations
- Warm, joyful styling

**Halloween** (October 31)
- Colors: Orange, black, purple
- Elements: Pumpkins, autumn leaves
- Fun but professional styling

**Valentine's Day** (February 14)
- Colors: Red, pink, white
- Elements: Hearts, roses (subtle, professional)
- Warm, friendly styling

### HTML Email Template Structure

**⚠️ IMPORTANT: NO AI ATTRIBUTION**
- **DO NOT include** "Generated with Claude Code" footer
- **DO NOT include** "Co-Authored-By: Claude" attribution
- **DO NOT include** any references to AI, Claude, or automated generation
- **Emails must appear** to come naturally and directly from Arlen
- **Only include** Arlen's signature (`-Arlen`) - nothing more

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Email Subject</title>
  <style>
    /* Reset styles */
    body {
      margin: 0;
      padding: 0;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
      line-height: 1.6;
      color: #333333;
    }

    /* Container for email content */
    .email-container {
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
      background: #ffffff;
    }

    /* Seasonal/Holiday theming applied here */
    .seasonal-header {
      padding: 20px;
      border-radius: 8px;
      margin-bottom: 20px;
      /* Season-specific background */
    }

    h1 {
      margin: 0 0 20px 0;
      font-size: 24px;
      font-weight: 600;
      /* Season-specific color */
    }

    p {
      margin: 0 0 15px 0;
      font-size: 16px;
    }

    a {
      /* Season-specific color */
      text-decoration: none;
    }

    a:hover {
      text-decoration: underline;
    }

    .signature {
      margin-top: 30px;
      padding-top: 20px;
      border-top: 2px solid #eeeeee;
      font-size: 14px;
    }

    /* Responsive design */
    @media only screen and (max-width: 600px) {
      .email-container {
        padding: 15px;
      }
      h1 {
        font-size: 20px;
      }
    }
  </style>
</head>
<body>
  <div class="email-container">
    <div class="seasonal-header">
      <!-- Optional seasonal decoration -->
    </div>

    <p>Hi [Name],</p>

    <!-- Email content here -->

    <div class="signature">
      <p>-Arlen</p>
    </div>
    <!-- NO FOOTER - Email ends with signature only -->
  </div>
</body>
</html>
```

---

## 4. Writing Style Guidelines

**Maintain Arlen's authentic professional communication voice.**

### Core Communication Traits

**Tone & Approach**:
- **Professional but approachable** - Formal without being stiff
- **Direct and solution-oriented** - Gets to the point, focuses on actions
- **Collaborative** - Uses "we," acknowledges team efforts
- **Helpful** - Offers assistance, follows up proactively

### Greeting Patterns

**Standard Greetings** (in order of frequency):
1. `Hi [Name],` - Most common, warm but professional
2. `Good morning, [Name],` - For formal business communications
3. `Hi [Name] -` - Often includes dash after greeting

### Email Structure

#### Opening Lines
- State main purpose or accomplishment immediately
- Examples:
  - *"I've successfully integrated the database connection..."*
  - *"I have updated the utility to require..."*
  - *"Mark and I have just completed a Google Meeting..."*

#### Body Content Organization
1. **Status/Result First** - Lead with accomplishment
2. **Details Section** - Use bullets or numbered lists
3. **Next Steps** - Clear action items or recommendations
4. **Offer of Support** - Proactive help offering

#### Information Presentation
- **Bullet points** (•) or numbered lists for multiple items
- **Section headers** when appropriate (*"What's New:"*, *"Setup Steps:"*)
- **Code blocks** properly formatted for technical content
- **Specific details** - URLs, file names, transaction IDs, dates

### Language Patterns

**Professional Vocabulary**:
- "I've" rather than "I have" (conversational contraction)
- "Please find attached..." for document references
- "I will" or "I'll" for future commitments
- "Thank you" rather than "Thanks" in formal contexts

**Technical Communication**:
- Provide **step-by-step instructions** with numbered lists
- Include **specific technical details** (paths, credentials, commands)
- Offer **fallback options** and error handling
- Use **professional technical language** without over-explaining

**Problem-Solving Approach**:
- Acknowledge issues directly: *"I'm not sure I understand why..."*
- Request specifics: *"I need one or more concrete examples"*
- Provide context: *"This change will be made live with the next deployment"*

### Closings & Signatures

**Standard Closings** (in order of frequency):
1. `-Arlen` - Most common, simple and clean
2. `Thank you, -Arlen` - For requests or formal communications
3. `Let me know if you run into any issues` - Often before signature

**Follow-up Offers**:
- *"I can help you set that up next week if you'd like"*
- *"Let me know if there's a time that works better"*
- *"I'm looking forward to seeing this in action!"*

**⚠️ Email Ending Requirements**:
- **End with signature only** - no additional footers
- **NO AI attribution** - never include "Generated with Claude Code" or similar
- **NO co-author credits** - never include "Co-Authored-By: Claude"
- Emails must appear to come directly and naturally from Arlen

### Subject Line Patterns

**Effective Subject Lines**:
- **Action-oriented**: *"Activity Log Retrieval: Integrated"*
- **Status updates**: *"Stripe // Tenant Screening Payments"*
- **Reference items**: *"CVPM Invoice/Receipt: Transaction 22835"*
- **Clear and descriptive** without being overly long

### Communication Scenarios

#### Technical Updates
- Lead with successful completion
- Provide detailed "What's New" section
- Include setup instructions
- Offer additional support

#### Problem Resolution
- Acknowledge the issue
- Explain solution implemented
- Provide next steps or requirements
- Set timeline expectations

#### Requests for Information
- Be specific about what's needed
- Provide context for why needed
- Include examples when helpful
- Set reasonable timelines

#### Meeting Coordination
- Use Google Calendar references
- Offer flexible scheduling
- Provide current availability context
- Keep brief and actionable

### Things to Avoid

- ❌ Overly casual language in business contexts
- ❌ Lengthy explanations without clear structure
- ❌ Assumptions - ask for clarification when needed
- ❌ Pressure tactics - maintain patient, helpful tone
- ❌ Technical jargon without context

### Key Strengths to Emulate

1. **Clarity** - Messages easy to understand and act upon
2. **Completeness** - Includes all necessary details and context
3. **Proactivity** - Anticipates needs and offers solutions
4. **Professionalism** - Maintains appropriate business tone
5. **Follow-through** - Commits to specific actions and timelines

---

## 5. Date & Time Awareness

**CRITICAL: Always use system clock for current date references.**

### Date Reference Rules

1. **Check System Date**: Always verify current date in `<env>` context
2. **Never Assume**: Don't default to knowledge cutoff dates (January 2025)
3. **Explicit Sources**: State source of date/time information
4. **Version Context**: When discussing "latest" versions, verify against current date
5. **Temporal Calculations**: Base all time math on verified current date

### Determining Season & Holidays

```javascript
// Pseudo-code for season determination
const today = new Date(); // From system clock
const month = today.getMonth() + 1; // 1-12
const day = today.getDate();

// Season determination
if ((month == 3 && day >= 20) || month == 4 || month == 5 || (month == 6 && day <= 20)) {
  season = "spring";
} else if ((month == 6 && day >= 21) || month == 7 || month == 8 || (month == 9 && day <= 22)) {
  season = "summer";
} else if ((month == 9 && day >= 23) || month == 10 || month == 11 || (month == 12 && day <= 20)) {
  season = "fall";
} else {
  season = "winter";
}

// Check for holidays
const holidays = {
  "1-1": "New Year's Day",
  "7-4": "Independence Day",
  "10-31": "Halloween",
  "12-25": "Christmas",
  // Add other holidays with calculated dates
};
```

---

## 6. Complete Email Workflow

### Step-by-Step Process

1. **Identify Recipients**
   - If mentioned by name, run contact lookup using `lookup_contact_email.rb`
   - If email provided directly, use it and skip lookup
   - **Known recipient shortcuts** - Skip lookup for these recipients:
     - **Ed Korkuch** → `ekorkuch@versacomputing.com` (no lookup needed)
   - **"BCC me" shorthand**: When user says "bcc me", add `arlenagreer@gmail.com` to BCC field
   - **⚠️ CRITICAL**: If contact lookup fails (no match found):
     - **STOP the email composition workflow immediately**
     - **PROMPT the user**: "No contact found for '[Name]'. Please provide an email address for this recipient."
     - **WAIT for user response** before proceeding
     - Do NOT attempt to guess, assume, or continue without a valid email address

2. **Determine Current Date**
   - Check system clock from `<env>` context
   - Determine current season
   - Check if current date matches national holiday

3. **Select Theme**
   - Holiday theme if applicable (takes priority)
   - Seasonal theme otherwise
   - Apply corresponding color palette and styling

4. **Compose Content**
   - Apply Arlen's writing style guidelines
   - Structure content appropriately (greeting, body, closing)
   - Include all necessary details
   - Maintain professional but approachable tone

5. **🔒 SECURITY REVIEW (MANDATORY)**
   - **Scan for sensitive information** using Pre-Send Security Checklist
   - **Redact credentials**: passwords, API keys, tokens, private keys
   - **Sanitize logs**: remove sensitive data from any log outputs
   - **Review URLs**: check for embedded authentication parameters
   - **Verify PII handling**: ensure personal information appropriately protected
   - **When in doubt, redact it out**

6. **Create HTML Email**
   - Use template structure with seasonal/holiday styling
   - Ensure mobile responsiveness
   - Include proper DOCTYPE and meta tags
   - Apply CSS styling inline or in `<style>` tag
   - **End with signature only** (`-Arlen`) - NO footer or AI attribution

7. **Send or Draft**
   - **Primary**: Use Gmail MCP (`mcp__gmail__send_email`)
   - **Fallback**: Use Himalaya CLI if MCP unavailable
   - Confirm successful delivery

### Example Complete Workflow

**Enhanced JSON Parsing with Status Checking**:

```bash
# 1. Lookup recipient contact
CONTACT_JSON=$(~/.claude/skills/email/lookup_contact_email.rb --name "John Smith")
EXIT_CODE=$?

# 2. Parse JSON and check status field
STATUS=$(echo $CONTACT_JSON | jq -r '.status')

# 3. Handle based on status and exit code
if [ "$STATUS" = "success" ]; then
  RECIPIENT_EMAIL=$(echo $CONTACT_JSON | jq -r '.email')
  NOTE=$(echo $CONTACT_JSON | jq -r '.note // empty')

  # Check for multiple matches
  if [ -n "$NOTE" ]; then
    echo "⚠️ Multiple contacts found. Using first match: $RECIPIENT_EMAIL"
  fi

  # Proceed with email composition
  echo "Sending to: $RECIPIENT_EMAIL"
  # ... compose and send email

elif [ "$STATUS" = "error" ]; then
  ERROR_CODE=$(echo $CONTACT_JSON | jq -r '.code')
  ERROR_MSG=$(echo $CONTACT_JSON | jq -r '.message')

  # Handle specific error types
  case $ERROR_CODE in
    "NO_MATCH_FOUND")
      echo "❌ Contact not found. Please provide email address for John Smith."
      # STOP workflow and wait for user input
      ;;
    "AUTH_ERROR")
      echo "❌ Authentication failed. Check credentials or provide email directly."
      # STOP workflow and wait for user input
      ;;
    *)
      echo "❌ Error: $ERROR_MSG"
      # STOP workflow
      ;;
  esac
else
  echo "❌ Unexpected response format"
  # STOP workflow
fi
```

**Exit Code Handling Examples**:

```bash
# Check exit code for quick validation
CONTACT_JSON=$(~/.claude/skills/email/lookup_contact_email.rb --name "John Smith")
case $? in
  0)
    echo "✅ Contact found successfully"
    ;;
  1)
    echo "❌ No match found - check spelling or provide email"
    # STOP and prompt user
    ;;
  2)
    echo "❌ Authentication error - verify credentials"
    # STOP and prompt user
    ;;
  3)
    echo "❌ API error - network or service issue"
    # STOP and retry or use fallback
    ;;
  4)
    echo "❌ Invalid arguments - check name format"
    # STOP and prompt user
    ;;
esac
```

---

## 7. Error Handling

### Contact Lookup Errors

**No Match Found** (STOP IMMEDIATELY):
- **STOP email composition workflow** - do not proceed to next steps
- **Display clear error message**: "❌ Contact lookup failed: No contact found for '[Name]'"
- **PROMPT user explicitly**: "Please provide an email address for [Name] to continue."
- **WAIT for user response** - do not assume, guess, or attempt workarounds
- **Suggestions to user**:
  - Check spelling of recipient name
  - Provide full name (first and last)
  - Or provide email address directly
- **Only proceed** once valid email address is provided by user

**Multiple Matches**:
- **Note to user**: "⚠️ Multiple contacts found with name '[Name]'. Using first match: [email@example.com]"
- Proceed with first match email address (as per script behavior)
- Inform user they can provide specific email address if different contact intended

**Authentication Errors** (STOP IMMEDIATELY):
- **STOP email composition workflow**
- **Display error**: "❌ Google Contacts authentication failed"
- Check credentials file exists: `~/.claude/.google/client_secret.json`
- Verify token file: `~/.claude/.google/token.json`
- **PROMPT user**: "Please verify Google Contacts credentials or provide email address directly."
- Re-authenticate if token expired or provide manual email address

### Email Sending Errors

**Gmail MCP Unavailable**:
- Automatically offer Himalaya CLI fallback
- Provide clear instructions for fallback method
- Confirm user wants to proceed with CLI

**Himalaya CLI Errors**:
- Check configuration: `~/Library/Application Support/himalaya/config.toml`
- Verify account credentials
- Test with simple plain text email first

**Attachment Errors**:
- Verify file paths exist
- Check file size limits
- Confirm file permissions

### Troubleshooting Guide

#### Common Issue 1: "Contact not found" for known contact

**Symptoms**: Lookup fails even though contact exists in Google Contacts

**Possible Causes & Solutions**:
1. **Name spelling mismatch**
   - Solution: Check exact spelling in Google Contacts, try variations
   - Example: "Bob Smith" vs "Robert Smith"

2. **Missing first or last name**
   - Solution: Provide both first AND last name
   - ❌ Wrong: `--name "John"` or `--name "Smith"`
   - ✅ Right: `--name "John Smith"`

3. **Special characters in name**
   - Solution: Include exact characters as they appear in contacts
   - Example: `--name "Mary O'Brien"` (with apostrophe)

4. **Multiple contacts with similar names**
   - Solution: Check contact list for duplicates, use specific email directly
   - Script returns first match - may not be intended contact

**Quick Fix**: When in doubt, provide email address directly instead of name

#### Common Issue 2: Authentication failures

**Symptoms**: `AUTH_ERROR` or exit code 2

**Possible Causes & Solutions**:
1. **Missing credentials file**
   - Check: `ls ~/.claude/.google/client_secret.json`
   - Solution: Restore credentials from backup or reconfigure

2. **Expired token**
   - Check: `ls ~/.claude/.google/token.json`
   - Solution: Delete token file and re-authenticate on next run

3. **Insufficient permissions**
   - Solution: Re-authenticate with correct Google Contacts scope
   - Required: `https://www.googleapis.com/auth/contacts.readonly`

4. **File permission issues**
   - Check: `ls -l ~/.claude/.google/`
   - Solution: Ensure files are readable: `chmod 600 ~/.claude/.google/*`

**Quick Fix**: Provide email address directly to bypass authentication

#### Common Issue 3: Seasonal theme not displaying correctly

**Symptoms**: Email displays without colors or styling

**Possible Causes & Solutions**:
1. **Email client blocking HTML**
   - Some clients disable HTML by default
   - Solution: Check recipient's email client settings

2. **CSS not rendering**
   - Solution: Use inline styles (already done in skill)
   - Verify HTML structure is valid

3. **Wrong date detection**
   - Solution: Verify system clock is correct in `<env>` context
   - Check: Season determination logic matches current date

**Quick Fix**: Plain text emails work universally but lose theming

#### Common Issue 4: Script not found or permission denied

**Symptoms**: `command not found` or `Permission denied`

**Solutions**:
1. **Check script exists**: `ls -l ~/.claude/skills/email/lookup_contact_email.rb`
2. **Make executable**: `chmod +x ~/.claude/skills/email/lookup_contact_email.rb`
3. **Verify Ruby installed**: `ruby --version` (requires Ruby 2.7+)
4. **Check PATH**: Use full path `~/.claude/skills/email/lookup_contact_email.rb`

#### Common Issue 5: Invalid JSON response

**Symptoms**: `jq` parsing errors, unexpected output format

**Solutions**:
1. **Verify jq installed**: `jq --version`
2. **Check script output**: Run script directly and inspect output
3. **Look for error messages**: Script may output errors before JSON
4. **Validate JSON**: `echo "$CONTACT_JSON" | jq .` to check format

**Quick Fix**: Check script logs and ensure Ruby gems installed correctly

---

## 8. Testing & Validation

### Pre-Send Checklist

**🔒 Security (MANDATORY - Check FIRST)**:
- ✅ No passwords or credentials visible
- ✅ API keys and tokens redacted
- ✅ Configuration files reviewed for secrets
- ✅ URLs checked for embedded authentication
- ✅ Log outputs sanitized
- ✅ Personal information appropriately handled
- ✅ File paths don't reveal sensitive structure

**Content & Style**:
- ✅ Recipient email resolved (if name provided)
- ✅ Current date verified from system clock
- ✅ Appropriate seasonal/holiday theme applied
- ✅ HTML validates and renders properly
- ✅ Mobile responsive design
- ✅ Writing style matches Arlen's voice
- ✅ All necessary information included
- ✅ Proper greeting and closing
- ✅ Subject line clear and descriptive

### Quality Checks

**Content Quality**:
- Professional tone maintained
- Clear and actionable
- Properly structured
- No typos or grammatical errors

**HTML Quality**:
- Valid HTML structure
- CSS properly formatted
- Responsive on mobile
- Accessible (alt text, semantic HTML)

**Branding Consistency**:
- Seasonal theme appropriate
- Colors professional yet appealing
- Styling enhances readability

---

## 9. Quick Reference

### User Shorthands
- **"bcc me"** → Add `arlenagreer@gmail.com` to BCC field
- **"send to [Name]"** → Look up contact email for [Name]
- **"send to [email]"** → Use email address directly

### Known Recipients (Skip Lookup)
- **Ed Korkuch** → `ekorkuch@versacomputing.com`

### Contact Lookup
```bash
~/.claude/skills/email/lookup_contact_email.rb --name "First Last"
```

### Gmail MCP Send
```javascript
mcp__gmail__send_email({
  to: ["email@example.com"],
  subject: "Subject Line",
  htmlBody: "<html>...</html>",
  mimeType: "text/html"
})
```

### Himalaya Send HTML
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

### Season Date Ranges
- **Spring**: March 20 - June 20
- **Summer**: June 21 - September 22
- **Fall**: September 23 - December 20
- **Winter**: December 21 - March 19

---

## Version History

- **1.6.0** (2025-10-19) - Added known recipient shortcut: Ed Korkuch automatically maps to ekorkuch@versacomputing.com, skipping contact lookup for improved efficiency
- **1.5.0** (2025-10-19) - Enhanced documentation with 4 robustness improvements: (1) Prominent name format requirements with clear wrong/right examples, (2) Enhanced JSON parsing examples with status field checking, (3) Comprehensive exit code handling examples for all 5 error codes, (4) Expanded troubleshooting guide with 5 common issues and solutions
- **1.4.0** (2025-10-19) - Added "bcc me" shorthand: when user says "bcc me", automatically add arlenagreer@gmail.com to BCC field for convenient self-copying
- **1.3.0** (2025-10-19) - Removed AI attribution: emails now end with signature only, no Claude Code or AI-generation footers, ensuring emails appear naturally from Arlen
- **1.2.0** (2025-10-19) - Enhanced contact lookup error handling: workflow now stops immediately and prompts user for email when contact lookup fails, preventing any attempts to proceed without valid recipient address
- **1.1.0** (2025-10-19) - Added comprehensive security requirements: mandatory sensitive information detection and redaction, pre-send security checklist, security-first mindset integration into workflow
- **1.0.0** (2025-10-19) - Initial email skill creation with seasonal HTML, contact lookup, and writing style integration
