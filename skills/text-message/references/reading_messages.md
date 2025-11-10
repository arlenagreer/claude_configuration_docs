# Reading Messages Reference

## Overview

The text-message skill can read existing message threads from the Apple Messages database, including retrieving unread messages, filtering by sender, and viewing conversation history.

## Database Access

Apple Messages stores all conversations in a SQLite database:
- **Location**: `~/Library/Messages/chat.db`
- **Format**: SQLite3 database
- **Permission Required**: Full Disk Access for Terminal app

## Permission Setup

### Grant Full Disk Access

1. **System Settings** → **Privacy & Security** → **Full Disk Access**
2. Find your terminal app (Terminal, iTerm2, etc.)
3. Enable the toggle switch
4. Restart terminal app

### Verify Access

```bash
# Test database access
ls -l ~/Library/Messages/chat.db

# Should show file info, not "Permission denied"
```

## read_messages.sh Script

### Basic Usage

```bash
# Get 10 most recent messages
~/.claude/skills/text-message/scripts/read_messages.sh

# Get unread messages only
~/.claude/skills/text-message/scripts/read_messages.sh --unread

# Get last 20 messages
~/.claude/skills/text-message/scripts/read_messages.sh --limit 20

# Get messages from specific contact
~/.claude/skills/text-message/scripts/read_messages.sh --from "Rob"

# Combine filters
~/.claude/skills/text-message/scripts/read_messages.sh --unread --from "Julie" --limit 5
```

### Command-Line Options

| Option | Description | Example |
|--------|-------------|---------|
| `--unread` | Show only unread messages | `--unread` |
| `--limit N` | Limit results to N messages (default: 10) | `--limit 20` |
| `--from "Name"` | Filter by sender name/number | `--from "Rob"` |
| `--verbose` | Include all metadata | `--verbose` |
| `--help` | Show help message | `--help` |

### Output Format

**Standard Output** (simplified):
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
    },
    {
      "text": "Sure! What time?",
      "from": "You",
      "date": "2025-11-01 14:30:10",
      "is_from_me": true,
      "is_read": true,
      "conversation": "Rob"
    },
    {
      "text": "Want to grab lunch?",
      "from": "+15551234567",
      "date": "2025-11-01 14:28:45",
      "is_from_me": false,
      "is_read": true,
      "conversation": "Rob"
    }
  ]
}
```

**Verbose Output** (full metadata):
```json
{
  "status": "success",
  "count": 1,
  "messages": [
    {
      "text": "Message content here",
      "sender": "+15551234567",
      "message_date": "2025-11-01 14:32:15",
      "is_from_me": 0,
      "is_read": 0,
      "chat_identifier": "chat123456789",
      "display_name": "Rob"
    }
  ]
}
```

### Exit Codes

- `0` - Success
- `1` - Database not found or invalid arguments
- `2` - Permission denied (need Full Disk Access)
- `3` - Query execution failed

## Use Cases

### Check for Unread Messages

```bash
# Get all unread messages
UNREAD=$(~/.claude/skills/text-message/scripts/read_messages.sh --unread)

# Count unread messages
COUNT=$(echo "$UNREAD" | jq '.count')
echo "You have $COUNT unread messages"

# Display unread messages
echo "$UNREAD" | jq -r '.messages[] | "\(.from): \(.text)"'
```

### View Recent Conversation

```bash
# Get last 20 messages from Rob
~/.claude/skills/text-message/scripts/read_messages.sh --from "Rob" --limit 20 \
  | jq -r '.messages[] | "\(.date) - \(.from): \(.text)"'
```

### Monitor New Messages

```bash
# Simple polling script
while true; do
  UNREAD=$(~/.claude/skills/text-message/scripts/read_messages.sh --unread)
  COUNT=$(echo "$UNREAD" | jq '.count')

  if [ "$COUNT" -gt 0 ]; then
    echo "📱 You have $COUNT new messages:"
    echo "$UNREAD" | jq -r '.messages[] | "  • \(.from): \(.text)"'
  fi

  sleep 60  # Check every minute
done
```

### Respond to Unread Messages

```bash
# Get unread messages
UNREAD=$(~/.claude/skills/text-message/scripts/read_messages.sh --unread --limit 1)

# Extract sender
SENDER=$(echo "$UNREAD" | jq -r '.messages[0].from')
MESSAGE=$(echo "$UNREAD" | jq -r '.messages[0].text')

# Show to user
echo "Unread from $SENDER: $MESSAGE"

# Send reply
~/.claude/skills/text-message/scripts/send_message.sh "$SENDER" "Thanks for your message!"
```

## Database Schema Reference

The Messages database contains several key tables:

### message table
- `ROWID` - Unique message ID
- `text` - Message content (NULL for non-text messages)
- `handle_id` - Foreign key to handle table
- `date` - Timestamp (nanoseconds since 2001-01-01)
- `is_from_me` - 1 if sent by you, 0 if received
- `is_read` - 1 if read, 0 if unread
- `is_sent` - 1 if sent successfully
- `is_delivered` - 1 if delivered to recipient

### handle table
- `ROWID` - Unique handle ID
- `id` - Phone number or email address
- `service` - "iMessage" or "SMS"

### chat table
- `ROWID` - Unique chat ID
- `chat_identifier` - Unique conversation identifier
- `display_name` - Contact name (if available)
- `service_name` - "iMessage" or "SMS"

### chat_message_join table
- Links messages to chats (many-to-many relationship)
- `chat_id` - Foreign key to chat table
- `message_id` - Foreign key to message table

## Advanced Queries

### Get Conversation Thread

```sql
SELECT
  message.text,
  handle.id as sender,
  datetime(message.date/1000000000 + strftime('%s', '2001-01-01'), 'unixepoch', 'localtime') as message_date,
  message.is_from_me
FROM message
LEFT JOIN handle ON message.handle_id = handle.ROWID
LEFT JOIN chat_message_join ON message.ROWID = chat_message_join.message_id
LEFT JOIN chat ON chat_message_join.chat_id = chat.ROWID
WHERE chat.chat_identifier = 'CHAT_ID'
  AND message.text IS NOT NULL
ORDER BY message.date ASC
```

### Count Unread by Sender

```sql
SELECT
  handle.id as sender,
  COUNT(*) as unread_count
FROM message
LEFT JOIN handle ON message.handle_id = handle.ROWID
WHERE message.is_read = 0
  AND message.is_from_me = 0
  AND message.text IS NOT NULL
GROUP BY handle.id
ORDER BY unread_count DESC
```

### Get Recent Active Conversations

```sql
SELECT
  chat.display_name,
  chat.chat_identifier,
  COUNT(message.ROWID) as message_count,
  MAX(datetime(message.date/1000000000 + strftime('%s', '2001-01-01'), 'unixepoch', 'localtime')) as last_message
FROM chat
LEFT JOIN chat_message_join ON chat.ROWID = chat_message_join.chat_id
LEFT JOIN message ON chat_message_join.message_id = message.ROWID
WHERE message.text IS NOT NULL
GROUP BY chat.ROWID
ORDER BY last_message DESC
LIMIT 10
```

## Integration with Skill

The read_messages.sh script integrates with the text-message skill:

### Workflow Pattern

```bash
# 1. Check for unread messages
UNREAD=$(~/.claude/skills/text-message/scripts/read_messages.sh --unread)

# 2. Parse results
echo "$UNREAD" | jq -r '.messages[] | "From: \(.from)\nMessage: \(.text)\n"'

# 3. User decides to reply
# ... contact lookup if needed ...

# 4. Send reply
~/.claude/skills/text-message/scripts/send_message.sh "PHONE" "Reply message"
```

### Automatic Response Workflow

```bash
# Get unread messages from specific person
MESSAGES=$(~/.claude/skills/text-message/scripts/read_messages.sh --unread --from "Rob")

# Check if any exist
COUNT=$(echo "$MESSAGES" | jq '.count')

if [ "$COUNT" -gt 0 ]; then
  # Extract latest message
  LATEST=$(echo "$MESSAGES" | jq -r '.messages[0].text')
  SENDER=$(echo "$MESSAGES" | jq -r '.messages[0].from')

  # Process and respond
  echo "Rob says: $LATEST"
  # ... generate response ...
  # ... send reply ...
fi
```

## Best Practices

1. **Full Disk Access Required**: Always verify permissions before attempting to read
2. **Handle Errors Gracefully**: Check JSON status field before processing results
3. **Respect Privacy**: Don't log message contents unnecessarily
4. **Rate Limiting**: Don't query database too frequently (max once per minute)
5. **Filter Efficiently**: Use SQL filters rather than processing all messages
6. **Parse Dates Carefully**: Messages database uses non-standard epoch (2001-01-01)
7. **NULL Handling**: Not all messages have text (attachments, reactions, etc.)

## Troubleshooting

### "Permission denied" Error

**Cause**: Terminal doesn't have Full Disk Access
**Solution**: Grant Full Disk Access in System Settings > Privacy & Security

### "Database is locked" Error

**Cause**: Messages app is actively writing to database
**Solution**: Retry after a moment, or close Messages app temporarily

### Empty Results

**Possible Causes**:
- No messages match filters
- Incorrect sender name/number
- All messages are read (when using --unread)

**Solution**: Try without filters first, then add filters incrementally

### Wrong Timestamps

**Cause**: macOS Messages uses non-standard epoch (2001-01-01 instead of 1970-01-01)
**Solution**: Script handles conversion automatically via SQL

## Security Considerations

- **Database Read-Only**: Script only reads, never modifies database
- **No Message Deletion**: Cannot delete messages via this script
- **Privacy**: Message contents are sensitive - handle carefully
- **Permission Scope**: Full Disk Access grants broad permissions - use responsibly

## Future Enhancements

Potential improvements:

- [ ] Search messages by keyword
- [ ] Export conversation threads
- [ ] Message statistics (count by sender, date ranges)
- [ ] Attachment listing and metadata
- [ ] Group chat support
- [ ] Read receipt tracking
- [ ] iMessage vs SMS differentiation

---

*This reference enables reading message threads and unread messages from Apple Messages database.*
