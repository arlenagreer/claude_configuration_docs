#!/bin/bash

# read_messages.sh - Read messages from Apple Messages app database
# Usage: read_messages.sh [--unread] [--limit N] [--from "Name/Number"]

set -euo pipefail

# Messages database location
MESSAGES_DB="$HOME/Library/Messages/chat.db"

# Default values
UNREAD_ONLY=false
LIMIT=10
FROM_FILTER=""
VERBOSE=false

# Function to output JSON
output_json() {
  echo "$1"
}

# Function to output error JSON
output_error() {
  local message="$1"
  local code="${2:-ERROR}"
  echo "{\"status\":\"error\",\"code\":\"$code\",\"message\":\"$message\"}"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --unread)
      UNREAD_ONLY=true
      shift
      ;;
    --limit)
      LIMIT="$2"
      shift 2
      ;;
    --from)
      FROM_FILTER="$2"
      shift 2
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    --help)
      cat << EOF
Usage: read_messages.sh [OPTIONS]

Read messages from Apple Messages app database.

OPTIONS:
  --unread           Show only unread messages
  --limit N          Limit results to N messages (default: 10)
  --from "Name"      Filter messages from specific contact
  --verbose          Include additional message metadata
  --help             Show this help message

EXAMPLES:
  # Get 10 most recent messages
  read_messages.sh

  # Get unread messages only
  read_messages.sh --unread

  # Get last 20 messages from Rob
  read_messages.sh --from "Rob" --limit 20

  # Get all unread messages with full details
  read_messages.sh --unread --verbose

OUTPUT:
  JSON array of messages with:
  - text: Message content
  - from: Sender (phone number or name)
  - date: Timestamp
  - is_from_me: Boolean indicating if you sent it
  - is_read: Boolean indicating read status
  - chat_identifier: Conversation identifier
EOF
      exit 0
      ;;
    *)
      output_error "Unknown option: $1" "INVALID_ARGS"
      exit 1
      ;;
  esac
done

# Check if Messages database exists
if [ ! -f "$MESSAGES_DB" ]; then
  output_error "Messages database not found at $MESSAGES_DB" "DB_NOT_FOUND"
  exit 1
fi

# Check if we have read permission
if [ ! -r "$MESSAGES_DB" ]; then
  output_error "Permission denied to read Messages database. Grant Full Disk Access to Terminal in System Settings > Privacy & Security" "PERMISSION_DENIED"
  exit 1
fi

# Build SQL query
# Note: attributedBody contains the message text when text field is NULL (common for newer messages)
SQL_QUERY="
SELECT
  COALESCE(message.text, '') as text,
  message.attributedBody,
  handle.id as sender,
  datetime(message.date/1000000000 + strftime('%s', '2001-01-01'), 'unixepoch', 'localtime') as message_date,
  message.is_from_me,
  message.is_read,
  chat.chat_identifier,
  chat.display_name,
  message.cache_has_attachments
FROM message
LEFT JOIN handle ON message.handle_id = handle.ROWID
LEFT JOIN chat_message_join ON message.ROWID = chat_message_join.message_id
LEFT JOIN chat ON chat_message_join.chat_id = chat.ROWID
WHERE (message.text IS NOT NULL OR message.attributedBody IS NOT NULL OR message.cache_has_attachments = 1)
"

# Add unread filter if requested
if [ "$UNREAD_ONLY" = true ]; then
  SQL_QUERY="$SQL_QUERY AND message.is_read = 0 AND message.is_from_me = 0"
fi

# Add sender filter if requested
# Note: This filter shows the CONVERSATION with a contact, including both their messages and yours
if [ -n "$FROM_FILTER" ]; then
  SQL_QUERY="$SQL_QUERY AND (
    handle.id LIKE '%$FROM_FILTER%'
    OR chat.display_name LIKE '%$FROM_FILTER%'
    OR chat.chat_identifier LIKE '%$FROM_FILTER%'
  )"
fi

# Add ordering and limit
SQL_QUERY="$SQL_QUERY ORDER BY message.date DESC LIMIT $LIMIT"

# Execute query and format as JSON
RESULT=$(sqlite3 -json "$MESSAGES_DB" "$SQL_QUERY" 2>&1)

# Check if query was successful
if [ $? -ne 0 ]; then
  output_error "Database query failed: $RESULT" "QUERY_FAILED"
  exit 1
fi

# Function to extract text from attributedBody BLOB
# attributedBody is a binary plist that often contains the message text
extract_text_from_blob() {
  local blob="$1"
  local text="$2"

  # If text field has content, use it
  if [ -n "$text" ] && [ "$text" != "null" ]; then
    echo "$text"
    return
  fi

  # Try to extract from attributedBody using strings command
  # The attributedBody BLOB contains the text as a UTF-8 string
  if [ -n "$blob" ] && [ "$blob" != "null" ]; then
    # Extract printable strings from the BLOB (this is a simple approach)
    echo "$blob" | xxd -r -p 2>/dev/null | strings | head -1
  else
    echo "[No text content]"
  fi
}

# Parse and format the result
if [ "$VERBOSE" = true ]; then
  # Return full result with all fields
  echo "{\"status\":\"success\",\"count\":$(echo "$RESULT" | jq 'length'),\"messages\":$RESULT}"
else
  # Return simplified result with text extraction from attributedBody when needed
  # Use a temporary file to store intermediate results
  TEMP_FILE=$(mktemp)
  trap "rm -f $TEMP_FILE" EXIT

  # Write each message to temp file as we process it
  echo "$RESULT" | jq -c '.[]' | while IFS= read -r msg; do
    # Extract fields from message
    text=$(echo "$msg" | jq -r '.text // ""')
    blob=$(echo "$msg" | jq -r '.attributedBody // ""')
    sender=$(echo "$msg" | jq -r 'if .is_from_me == 1 then "You" else (.sender // .display_name // "Unknown") end')
    date=$(echo "$msg" | jq -r '.message_date')
    from_me=$(echo "$msg" | jq -r '.is_from_me == 1')
    is_read=$(echo "$msg" | jq -r '.is_read == 1')
    conv=$(echo "$msg" | jq -r '.display_name // .chat_identifier // .sender')
    has_attach=$(echo "$msg" | jq -r '.cache_has_attachments == 1')

    # Determine final text content
    final_text="$text"
    if [ -z "$final_text" ] || [ "$final_text" = "null" ]; then
      if [ -n "$blob" ] && [ "$blob" != "null" ] && [ "$blob" != "" ]; then
        # Extract text from BLOB using Perl to find text after NSString marker
        # The attributedBody is a binary plist containing the text
        # SQLite returns it as raw binary data in JSON output
        # Pattern: NSString is followed by some bytes, then a length byte, then the actual text
        final_text=$(echo "$blob" | perl -ne '
          if (/NSString.*?[\x01-\x7F]([\x20-\x7E]{3,})/s) {
            print "$1\n";
            exit;
          }
        ' | head -1)
        # Fallback to strings method if Perl extraction fails
        if [ -z "$final_text" ] || [ "$final_text" = "" ] || [ "$final_text" = "NSDictionary" ]; then
          final_text=$(echo "$blob" | strings -n 10 | grep -v '^\s*$' | grep -v '^NS' | grep -v '^__kIM' | grep -v 'streamtyped' | head -1)
        fi
        if [ -z "$final_text" ] || [ "$final_text" = "" ] || [ "$final_text" = "NSDictionary" ]; then
          final_text=$(echo "$blob" | strings -n 5 | grep -v '^\s*$' | grep -v '^NS' | grep -v '^__kIM' | grep -v 'streamtyped' | grep -v '^typed' | head -1)
        fi
        [ -z "$final_text" ] && final_text="[Message content]"
      elif [ "$has_attach" = "true" ]; then
        final_text="[Attachment]"
      else
        final_text="[No text]"
      fi
    fi

    # Write JSON to temp file
    jq -n \
      --arg text "$final_text" \
      --arg sender "$sender" \
      --arg date "$date" \
      --argjson from_me "$from_me" \
      --argjson is_read "$is_read" \
      --arg conv "$conv" \
      '{
        text: $text,
        from: $sender,
        date: $date,
        is_from_me: $from_me,
        is_read: $is_read,
        conversation: $conv
      }' >> "$TEMP_FILE"
  done

  # Collect all messages into JSON array
  SIMPLIFIED=$(jq -s '.' "$TEMP_FILE")
  echo "{\"status\":\"success\",\"count\":$(echo "$SIMPLIFIED" | jq 'length'),\"messages\":$SIMPLIFIED}"
fi

exit 0
