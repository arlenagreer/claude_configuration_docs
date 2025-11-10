#!/bin/bash

# send_message.sh - Send text message via Apple Messages app
# Usage: send_message.sh "PHONE_NUMBER" "MESSAGE_TEXT" [ATTACHMENT_PATH]
#
# Arguments:
#   PHONE_NUMBER    - Phone number to send to (any format)
#   MESSAGE_TEXT    - Text message to send (can be empty string if only sending attachment)
#   ATTACHMENT_PATH - Optional path to file attachment (image, video, etc.)

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to output JSON
output_json() {
  local status="$1"
  local message="$2"
  local code="${3:-}"
  local recipient="${4:-}"
  local attachment="${5:-}"

  if [ "$status" = "success" ]; then
    if [ -n "$attachment" ]; then
      echo "{\"status\":\"success\",\"recipient\":\"$recipient\",\"message\":\"$message\",\"attachment\":\"$attachment\"}"
    else
      echo "{\"status\":\"success\",\"recipient\":\"$recipient\",\"message\":\"$message\"}"
    fi
  else
    echo "{\"status\":\"error\",\"code\":\"$code\",\"message\":\"$message\"}"
  fi
}

# Function to normalize phone number
normalize_phone() {
  local phone="$1"

  # Remove all non-digit characters
  local digits=$(echo "$phone" | tr -cd '0-9')

  # If it's 10 digits, assume US number and add +1
  if [ ${#digits} -eq 10 ]; then
    echo "+1$digits"
  # If it's 11 digits starting with 1, add +
  elif [ ${#digits} -eq 11 ] && [[ $digits == 1* ]]; then
    echo "+$digits"
  # Otherwise, return as-is with + prefix if not present
  elif [[ $phone == +* ]]; then
    echo "$phone"
  else
    echo "+$digits"
  fi
}

# Function to validate phone number
validate_phone() {
  local phone="$1"

  # Remove all non-digit characters for validation
  local digits=$(echo "$phone" | tr -cd '0-9')

  # Must have at least 10 digits
  if [ ${#digits} -lt 10 ]; then
    return 1
  fi

  return 0
}

# Check arguments
if [ $# -lt 2 ]; then
  output_json "error" "Missing required arguments. Usage: send_message.sh PHONE_NUMBER MESSAGE_TEXT [ATTACHMENT_PATH]" "INVALID_ARGS"
  exit 1
fi

PHONE_NUMBER="$1"
MESSAGE_TEXT="$2"
ATTACHMENT_PATH="${3:-}"

# Validate attachment if provided
if [ -n "$ATTACHMENT_PATH" ]; then
  # Check if file exists
  if [ ! -f "$ATTACHMENT_PATH" ]; then
    output_json "error" "Attachment file not found: $ATTACHMENT_PATH" "ATTACHMENT_NOT_FOUND"
    exit 1
  fi

  # Check if file is readable
  if [ ! -r "$ATTACHMENT_PATH" ]; then
    output_json "error" "Attachment file not readable: $ATTACHMENT_PATH" "ATTACHMENT_NOT_READABLE"
    exit 1
  fi

  # Get absolute path for AppleScript
  ATTACHMENT_PATH=$(cd "$(dirname "$ATTACHMENT_PATH")" && pwd)/$(basename "$ATTACHMENT_PATH")

  # Validate file type (common media types supported by Messages)
  FILE_EXT="${ATTACHMENT_PATH##*.}"
  FILE_EXT_LOWER=$(echo "$FILE_EXT" | tr '[:upper:]' '[:lower:]')

  case "$FILE_EXT_LOWER" in
    jpg|jpeg|png|gif|heic|heif|bmp|tiff|tif|webp|svg)
      # Image formats
      ;;
    mp4|mov|m4v|avi|mkv|wmv|flv|webm)
      # Video formats
      ;;
    mp3|m4a|wav|aac|flac|ogg|wma)
      # Audio formats
      ;;
    pdf|doc|docx|txt|rtf|pages)
      # Document formats
      ;;
    zip|rar|7z|tar|gz)
      # Archive formats
      ;;
    vcf|vcard)
      # Contact card
      ;;
    *)
      # Allow any file type - Messages app will determine if it's supported
      # Just warn user
      >&2 echo "Warning: File type '$FILE_EXT' may not be supported by Messages app"
      ;;
  esac
fi

# Validate phone number
if ! validate_phone "$PHONE_NUMBER"; then
  output_json "error" "Invalid phone number format: $PHONE_NUMBER" "INVALID_PHONE"
  exit 1
fi

# Normalize phone number for Messages app
NORMALIZED_PHONE=$(normalize_phone "$PHONE_NUMBER")

# Check if Messages app exists
if ! [ -d "/System/Applications/Messages.app" ] && ! [ -d "/Applications/Messages.app" ]; then
  output_json "error" "Messages app not found. This script requires macOS with Messages app installed." "MESSAGES_NOT_FOUND"
  exit 2
fi

# Escape single quotes in message for AppleScript
ESCAPED_MESSAGE=$(echo "$MESSAGE_TEXT" | sed "s/'/\\\\'/g")

# Create AppleScript to send message with or without attachment
# Let Messages app auto-route to iMessage or SMS as appropriate
if [ -n "$ATTACHMENT_PATH" ]; then
  # Sending message with attachment
  APPLESCRIPT=$(cat <<EOF
tell application "Messages"
    set targetBuddy to buddy "$NORMALIZED_PHONE"
    if "$ESCAPED_MESSAGE" is not "" then
        send "$ESCAPED_MESSAGE" to targetBuddy
    end if
    send POSIX file "$ATTACHMENT_PATH" to targetBuddy
end tell
EOF
)
else
  # Sending text-only message
  APPLESCRIPT=$(cat <<EOF
tell application "Messages"
    send "$ESCAPED_MESSAGE" to buddy "$NORMALIZED_PHONE"
end tell
EOF
)
fi

# Execute AppleScript
if osascript -e "$APPLESCRIPT" 2>/dev/null; then
  if [ -n "$ATTACHMENT_PATH" ]; then
    output_json "success" "$MESSAGE_TEXT" "" "$NORMALIZED_PHONE" "$ATTACHMENT_PATH"
  else
    output_json "success" "$MESSAGE_TEXT" "" "$NORMALIZED_PHONE"
  fi
  exit 0
else
  # Check if it's a permission issue
  if osascript -e "tell application \"System Events\" to get name of first process" 2>&1 | grep -q "not allowed"; then
    output_json "error" "Permission denied. Please grant automation permissions in System Settings > Privacy & Security > Automation" "PERMISSION_DENIED"
    exit 2
  else
    output_json "error" "Failed to send message via Messages app. Check that Messages is configured with iMessage or SMS capability." "SEND_FAILED"
    exit 3
  fi
fi
