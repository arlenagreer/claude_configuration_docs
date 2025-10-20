Send an email: $ARGUMENTS

**CRITICAL: Follow the email skill workflow exactly as documented in ~/.claude/skills/email/email.md**

Steps:

1. **Read the email skill**: Read `~/.claude/skills/email/email.md` for complete instructions
2. **Parse the request**: Extract recipient, subject, and message from $ARGUMENTS
3. **Contact lookup** (if recipient is a name):
   - Run `~/.claude/skills/email/lookup_contact_email.rb --name "First Last"`
   - Check JSON response status field
   - If status = "error": STOP and prompt user for email address
   - If status = "success": Use the email address returned
   - Known recipients (skip lookup):
     - Ed Korkuch → ekorkuch@versacomputing.com
   - "bcc me" → Add arlenagreer@gmail.com to BCC
4. **Security review**: Scan content for passwords, API keys, credentials, tokens - redact if found
5. **Determine theme**: Based on current date (from <env>), apply seasonal or holiday HTML theme
6. **Compose email**: Using Arlen's writing style (professional, direct, helpful)
7. **Send via Gmail MCP**: Use `mcp__gmail__send_email` with HTML formatting
8. **Confirm**: Report success or error

**Seasonal Themes** (based on current date):
- Spring (Mar 20-Jun 20): Fresh greens, pastels (#f0f8f0, #4caf50)
- Summer (Jun 21-Sep 22): Bright blues, yellows (#e3f2fd, #2196f3)
- Fall (Sep 23-Dec 20): Warm oranges, browns (#fff3e0, #ff6f00)
- Winter (Dec 21-Mar 19): Cool blues, purples (#e1f5fe, #1565c0)

**Email must**:
- End with signature `-Arlen` only (NO AI attribution, NO footers)
- Be mobile-responsive HTML
- Match seasonal/holiday theme
- Use Arlen's authentic voice
