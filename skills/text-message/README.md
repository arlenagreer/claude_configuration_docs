# Text Message Agent Skill

Send text messages via Apple Messages app with intelligent contact lookup and interactive prompts.

## 🔴 CRITICAL: Individual Messages Only

**ALL text messages are sent INDIVIDUALLY to each recipient - NEVER as group messages**

- ✅ Multiple recipients = Multiple individual 1-on-1 messages
- ❌ Group chats are NEVER created
- 📧 Note: Email skill CAN send to multiple recipients; text-message skill CANNOT

## Quick Start

### Basic Usage (via Skill invocation)

```
User: "Send Rob a text saying I'm running late"
```

Claude Code will:
1. Look up "Rob" in Google Contacts
2. Extract mobile phone number
3. Send message: "I'm running late"
4. Confirm delivery

### Multiple Recipients (Individual Sends)

```
User: "Text Rob, Julie, and Mark that the meeting is postponed"
```

Claude Code will:
1. Look up all three contacts
2. Send INDIVIDUALLY to each (three separate messages)
3. Confirm: "Message sent individually to Rob, Julie, and Mark"

### Direct Script Usage

```bash
# Send to phone number directly
~/.claude/skills/text-message/scripts/send_message.sh "+15551234567" "Hello, this is a test"

# Send via contact lookup
CONTACT=$(~/.claude/skills/contacts/scripts/contacts_manager.rb --search "Rob")
PHONE=$(echo "$CONTACT" | jq -r '.contacts[0].phones[] | select(.type == "mobile") | .value')
~/.claude/skills/text-message/scripts/send_message.sh "$PHONE" "Your message here"
```

## Features

✅ **Individual Message Delivery**
- **CRITICAL**: Multiple recipients = multiple individual sends
- Each recipient gets separate 1-on-1 message
- NO group messages ever created

✅ **Automatic Contact Lookup**
- Name-based recipient resolution via Google Contacts
- Intelligent mobile number extraction
- Fallback to manual phone number entry

✅ **Interactive Prompts**
- Prompts for missing recipient
- Prompts for missing message
- User confirmation for send

✅ **Phone Number Support**
- Multiple formats: (555) 123-4567, 555-123-4567, +15551234567
- Automatic normalization to E.164 format
- International number support

✅ **Messages App Integration**
- Uses native Apple Messages app
- Supports both iMessage and SMS
- Automatic delivery method selection

✅ **Message Reading & Monitoring** (NEW)
- Read existing message threads from Messages database
- Filter by read/unread status
- Filter by sender name or number
- Retrieve conversation history with timestamps
- Check for new unread messages

## File Structure

```
text-message/
├── SKILL.md                              # Main skill documentation
├── README.md                             # This file
├── scripts/
│   ├── send_message.sh                   # Message sending script
│   └── read_messages.sh                  # Message reading script (NEW)
└── references/
    ├── phone_number_formats.md           # Phone format reference
    ├── contact_integration.md            # Contact lookup patterns
    └── reading_messages.md               # Message reading reference (NEW)
```

## Requirements

- macOS with Apple Messages app
- Messages app configured with iMessage or SMS
- Google Contacts integration (via contacts skill)
- Automation permissions granted to Terminal/Claude Code
- Full Disk Access for Terminal (required for reading messages)

## Permission Setup

### First-Time Setup

#### Sending Messages (Automation Permission)
1. **System Settings** → **Privacy & Security** → **Automation**
2. Find your terminal app (Terminal, iTerm2, etc.)
3. Enable checkbox for **Messages**
4. Restart terminal if needed

#### Reading Messages (Full Disk Access)
1. **System Settings** → **Privacy & Security** → **Full Disk Access**
2. Find your terminal app (Terminal, iTerm2, etc.)
3. Enable the toggle switch
4. Restart terminal if needed

### Testing Permissions

```bash
# Test if automation is allowed
osascript -e 'tell application "Messages" to get name'

# Test if database access is allowed
ls -l ~/Library/Messages/chat.db
```

If you see permission errors, follow the setup steps above.

## Usage Examples

### Example 1: Send to Named Contact

```
User: "Send Julie a text: Meeting confirmed for 2pm tomorrow"
```

**Flow**:
1. ✅ Look up "Julie" → Find "Julie Whitney"
2. ✅ Extract mobile: +1-555-123-4567
3. ✅ Send: "Meeting confirmed for 2pm tomorrow"
4. ✅ Confirm: "Message sent to Julie Whitney"

### Example 2: Missing Recipient

```
User: "Send a text message"
Claude: "Who would you like to send a text message to?"
User: "Mark Whitney"
Claude: "What message would you like to send?"
User: "Project update ready for review"
```

**Flow**:
1. ❓ Prompt for recipient
2. ✅ Look up "Mark Whitney"
3. ❓ Prompt for message
4. ✅ Send message
5. ✅ Confirm delivery

### Example 3: Direct Phone Number

```
User: "Text 555-123-4567 that I'll call back in 10 minutes"
```

**Flow**:
1. ✅ Parse phone: 555-123-4567
2. ✅ Normalize: +15551234567
3. ✅ Send: "I'll call back in 10 minutes"
4. ✅ Confirm: "Message sent to 555-123-4567"

### Example 4: Contact Not Found

```
User: "Send John a text"
Claude: "No contact found for 'John'. Please provide a phone number."
User: "(555) 987-6543"
Claude: "What message would you like to send?"
User: "Thanks for the help today"
```

**Flow**:
1. ❌ Contact lookup fails
2. ❓ Prompt for phone number
3. ✅ Normalize phone
4. ❓ Prompt for message
5. ✅ Send message

### Example 5: Check Unread Messages (NEW)

```
User: "Do I have any unread text messages?"
```

**Flow**:
1. ✅ Run read_messages.sh --unread
2. ✅ Parse JSON response
3. ✅ Display: "📱 You have 3 unread messages:
   - Rob: 'Hey, are you free for lunch?'
   - Julie: 'Meeting confirmed for 2pm'
   - Mark: 'Thanks for the update'"

### Example 6: Read Recent Conversation (NEW)

```
User: "Show me my recent messages with Rob"
```

**Flow**:
1. ✅ Run read_messages.sh --from "Rob" --limit 10
2. ✅ Display conversation thread with timestamps

### Example 7: Check and Reply to Unread (NEW)

```
User: "Check my unread messages and reply to Rob"
```

**Flow**:
1. ✅ Get unread from Rob
2. ✅ Display message
3. ❓ Prompt for reply
4. ✅ Look up Rob's number
5. ✅ Send reply
6. ✅ Confirm delivery

## Script Reference

### send_message.sh

**Signature**:
```bash
send_message.sh PHONE_NUMBER MESSAGE_TEXT
```

**Arguments**:
- `PHONE_NUMBER`: Phone number in any format
- `MESSAGE_TEXT`: Message text (quoted if contains spaces)

**Exit Codes**:
- `0`: Success
- `1`: Invalid arguments
- `2`: Messages app error
- `3`: AppleScript execution error

**Output**: JSON status message

**Success**:
```json
{
  "status": "success",
  "recipient": "+15551234567",
  "message": "Your message text"
}
```

**Error**:
```json
{
  "status": "error",
  "code": "ERROR_CODE",
  "message": "Error description"
}
```

### read_messages.sh (NEW)

**Signature**:
```bash
read_messages.sh [OPTIONS]
```

**Options**:
- `--unread`: Show only unread messages
- `--limit N`: Limit results to N messages (default: 10)
- `--from "Name"`: Filter messages from specific contact
- `--verbose`: Include additional message metadata
- `--help`: Show help message

**Exit Codes**:
- `0`: Success
- `1`: Database not found or invalid arguments
- `2`: Permission denied (need Full Disk Access)
- `3`: Query execution failed

**Output**: JSON with messages array

**Success**:
```json
{
  "status": "success",
  "count": 3,
  "messages": [
    {
      "text": "Hey, are you free for lunch?",
      "from": "+15551234567",
      "date": "2025-11-01 14:32:15",
      "is_from_me": false,
      "is_read": false,
      "conversation": "Rob"
    }
  ]
}
```

**Common Usage**:
```bash
# Get all unread messages
~/.claude/skills/text-message/scripts/read_messages.sh --unread

# Get last 20 messages from Rob
~/.claude/skills/text-message/scripts/read_messages.sh --from "Rob" --limit 20

# Get unread from Julie
~/.claude/skills/text-message/scripts/read_messages.sh --unread --from "Julie"
```

## Integration with Contacts Skill

The text-message skill automatically integrates with the contacts skill for name-based lookups:

**Priority Order**:
1. Phone with type "mobile"
2. Phone with type "iPhone"
3. First available phone number
4. Prompt user if no phone found

**Example Integration**:
```bash
# Search contact
CONTACT=$(~/.claude/skills/contacts/scripts/contacts_manager.rb --search "Rob")

# Extract mobile (prioritize "mobile" type)
MOBILE=$(echo "$CONTACT" | jq -r '.contacts[0].phones[] | select(.type == "mobile") | .value' | head -n 1)

# Fall back to first phone
if [ -z "$MOBILE" ]; then
  MOBILE=$(echo "$CONTACT" | jq -r '.contacts[0].phones[0].value')
fi

# Send message
~/.claude/skills/text-message/scripts/send_message.sh "$MOBILE" "Your message"
```

## Troubleshooting

### Permission Denied Error

**Error**: `Permission denied. Please grant automation permissions...`

**Solution**:
1. System Settings → Privacy & Security → Automation
2. Enable Terminal/iTerm for Messages
3. Restart terminal

### Messages App Not Found

**Error**: `Messages app not found`

**Solution**:
- Ensure you're running macOS (not Linux/Windows)
- Verify Messages app exists in /Applications/
- This skill requires macOS with Apple Messages

### Contact Lookup Failed

**Error**: `No contact found for 'Name'`

**Solution**:
- Verify contact exists in Google Contacts
- Try full name instead of first name only
- Provide phone number manually when prompted

### Invalid Phone Number

**Error**: `Invalid phone number format`

**Solution**:
- Ensure at least 10 digits
- Use format: (555) 123-4567 or +15551234567
- Remove invalid characters

### Message Not Delivered

**Issue**: Message sent but recipient doesn't receive

**Check**:
- Verify phone number is correct
- Check Messages app is signed in
- Ensure iMessage/SMS is configured
- Verify network connectivity

### Cannot Read Messages

**Error**: `Permission denied to read Messages database`

**Solution**:
1. System Settings → Privacy & Security → Full Disk Access
2. Enable Terminal/iTerm
3. Restart terminal
4. Test: `ls -l ~/Library/Messages/chat.db`

### Empty Message Results

**Issue**: No messages returned when they should exist

**Check**:
- Verify filters (remove --unread, --from to see all)
- Check database exists: `ls ~/Library/Messages/chat.db`
- Verify Messages app has conversations
- Try increasing --limit value

## Best Practices

1. **Use Full Names**: "John Smith" instead of "John" for accurate lookups
2. **Confirm Recipients**: Review phone number before sending
3. **Format Numbers**: Use consistent format for storing contacts
4. **Test First**: Send test message to yourself before important sends
5. **Handle Errors**: Always check script output for errors
6. **Rate Limit**: Add delays when sending multiple messages
7. **Check Unread Regularly**: Use `--unread` to monitor new messages
8. **Privacy Awareness**: Message reading accesses your Messages database - use responsibly

## Security & Privacy

- ✅ Messages are sent via your authenticated Messages app
- ✅ No message logging beyond confirmation
- ✅ Contact lookups use secure OAuth2
- ✅ Phone numbers normalized locally
- ✅ No third-party services involved
- ✅ Database reading is read-only (never modifies Messages data)
- ✅ Full Disk Access required for reading (macOS security feature)

## Future Enhancements

Potential improvements:

- [x] ~~Read message threads~~ (v1.2.0)
- [x] ~~Unread message filtering~~ (v1.2.0)
- [ ] Message templates for common responses
- [ ] Scheduled message sending
- [ ] Read receipt monitoring
- [ ] Attachment support (images, files)
- [ ] Voice message sending
- [ ] Contact cache for frequent recipients
- [ ] Message search by keyword
- [ ] Export conversation threads

## Support

For issues or questions:

1. Check troubleshooting section above
2. Verify permissions in System Settings
3. Test with direct phone number (bypass contact lookup)
4. Review script output for detailed errors

## Version

Current version: 1.2.0

See `SKILL.md` for detailed documentation and version history.

### Version History
- **1.2.0** - Added message reading capability with `read_messages.sh`
- **1.1.0** - Enforced individual message delivery for multiple recipients
- **1.0.0** - Initial release with sending functionality

---

*This skill enables seamless text messaging through Apple Messages with intelligent contact integration.*
