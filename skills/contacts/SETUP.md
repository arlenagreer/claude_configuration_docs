# Google Contacts Skill - Setup Guide

## Quick Start

The contacts skill has been created with full CRUD operations for Google Contacts. It shares authentication with your calendar skill.

## Re-authorization Required

Since the Google Contacts scope has been upgraded from readonly to full access (read/write), you need to re-authorize once.

### Step 1: Delete Existing Token

```bash
rm ~/.claude/.google/token.json
```

This will force re-authorization with the new scopes.

### Step 2: Run Any Contacts Operation

```bash
~/.claude/skills/contacts/scripts/contacts_manager.rb --list
```

This will:
1. Detect missing token
2. Display an authorization URL
3. Open your browser to authorize
4. Ask you to paste the authorization code

### Step 3: Authorize in Browser

1. Click the authorization URL shown
2. Sign in with your Google account
3. Grant permissions for:
   - Google Calendar access
   - Google Contacts access (read and write)
4. Copy the authorization code

### Step 4: Paste Authorization Code

Paste the code into the terminal when prompted.

The token will be saved to `~/.claude/.google/token.json` and will be used by both:
- Calendar skill (`~/.claude/skills/calendar/`)
- Contacts skill (`~/.claude/skills/contacts/`)

## Verify Setup

Test the skill with a simple search:

```bash
~/.claude/skills/contacts/scripts/contacts_manager.rb --search "your name"
```

You should see JSON output with your contact information.

## What's Included

### Scripts
- `contacts_manager.rb` - Full CRUD operations for Google Contacts

### References
- `contact_fields.md` - Comprehensive field documentation

### Capabilities
- ✅ Search contacts by name
- ✅ Get full contact details
- ✅ List all contacts with pagination
- ✅ Create new contacts
- ✅ Update existing contacts
- ✅ Delete contacts

### Supported Fields
- Names (first, last, display)
- Emails (multiple, with types)
- Phone numbers (multiple, with types)
- Addresses (physical, with types)
- Organizations (company, title)
- Birthdays
- Notes/Biography
- URLs
- And more (see `references/contact_fields.md`)

## Integration

### With Calendar Skill
Since both skills share authentication, they work seamlessly:

```bash
# List calendar events
~/.claude/skills/calendar/scripts/calendar_manager.rb --list-events

# Add attendee to contacts
~/.claude/skills/contacts/scripts/contacts_manager.rb --create '{"name":{...}}'
```

### With Email Skill
The email skill already has a contact lookup script at:
`~/.claude/skills/email/scripts/lookup_contact_email.rb`

The new contacts skill provides full CRUD operations beyond just lookup.

## Usage Examples

See `SKILL.md` for comprehensive usage examples including:
- Searching contacts
- Creating contacts with all fields
- Updating specific fields
- Batch operations
- Workflow patterns

## Troubleshooting

### Scope Errors
If you see "insufficient permissions" errors:

```bash
# Check current scopes
cat ~/.claude/.google/token.json | python3 -m json.tool | grep scope

# Should show both:
# - https://www.googleapis.com/auth/calendar
# - https://www.googleapis.com/auth/contacts
```

### Re-authorization
If authentication fails, simply delete the token and re-run:

```bash
rm ~/.claude/.google/token.json
~/.claude/skills/contacts/scripts/contacts_manager.rb --list
```

## Next Steps

1. ✅ Complete re-authorization (Steps 1-4 above)
2. ✅ Test basic search operation
3. ✅ Try creating a test contact
4. ✅ Explore all operations in `SKILL.md`
5. ✅ Use the skill in Claude Code conversations

## Support

For detailed documentation:
- Operation examples: See `SKILL.md`
- Field reference: See `references/contact_fields.md`
- Script help: Run `contacts_manager.rb --help`
