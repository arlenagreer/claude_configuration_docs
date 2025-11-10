# Contact Integration Reference

## Overview

The text-message skill integrates with the contacts skill to enable name-based recipient lookup. This document describes integration patterns, mobile number extraction, and fallback strategies.

## Integration Architecture

```
User Request
    ↓
[Text-Message Skill]
    ↓
Name Detected?
    ↓ Yes
[Contacts Skill Lookup]
    ↓
Extract Mobile Number
    ↓
[Send via Messages App]
    ↓
Confirmation
```

## Contact Lookup Workflow

### 1. Search for Contact

```bash
# Search by full name (preferred)
CONTACT=$(~/.claude/skills/contacts/scripts/contacts_manager.rb --search "John Smith")

# Search by first name only (if full name unknown)
CONTACT=$(~/.claude/skills/contacts/scripts/contacts_manager.rb --search "John")

# Search by partial match
CONTACT=$(~/.claude/skills/contacts/scripts/contacts_manager.rb --search "Smith")
```

**Best Practice**: Always use full name (first + last) when available for accurate matching.

### 2. Extract Phone Number

**Priority Order**:
1. Mobile phone (type: "mobile")
2. iPhone (type: "iPhone")
3. First available phone number
4. Prompt user if no phone found

**Extraction Script**:
```bash
# Priority 1: Mobile phone
MOBILE=$(echo "$CONTACT" | jq -r '.contacts[0].phones[]? | select(.type == "mobile") | .value' | head -n 1)

# Priority 2: iPhone
if [ -z "$MOBILE" ]; then
  MOBILE=$(echo "$CONTACT" | jq -r '.contacts[0].phones[]? | select(.type == "iPhone") | .value' | head -n 1)
fi

# Priority 3: First phone
if [ -z "$MOBILE" ]; then
  MOBILE=$(echo "$CONTACT" | jq -r '.contacts[0].phones[0].value')
fi

# Validate we got a number
if [ -z "$MOBILE" ]; then
  echo "❌ No phone number found for contact"
  exit 1
fi
```

### 3. Phone Number Types

Google Contacts supports various phone number types:

**Common Types**:
- `mobile` - Mobile/cell phone (preferred for texting)
- `iPhone` - Specific iPhone number
- `home` - Home phone
- `work` - Work phone
- `main` - Main number
- `other` - Other/unspecified

**Type Selection Strategy**:
- Text messages: Use `mobile` or `iPhone` types
- Fall back to any available number if no mobile
- Warn user if using non-mobile number for texting

## Contact JSON Structure

**Expected Response Format**:
```json
{
  "status": "success",
  "contacts": [
    {
      "resource_name": "people/c1234567890",
      "name": {
        "given_name": "John",
        "family_name": "Smith",
        "display_name": "John Smith"
      },
      "emails": [
        {
          "value": "john@example.com",
          "type": "work"
        }
      ],
      "phones": [
        {
          "value": "+1-555-123-4567",
          "type": "mobile"
        },
        {
          "value": "(555) 987-6543",
          "type": "home"
        }
      ]
    }
  ]
}
```

**Handling Multiple Contacts**:
```bash
# Get count of matching contacts
COUNT=$(echo "$CONTACT" | jq '.contacts | length')

if [ "$COUNT" -gt 1 ]; then
  echo "⚠️ Multiple contacts found for name. Using first match."
  # Show matches to user for confirmation
  echo "$CONTACT" | jq -r '.contacts[] | "\(.name.display_name) - \(.phones[0].value)"'
fi

# Extract first contact's mobile number
PHONE=$(echo "$CONTACT" | jq -r '.contacts[0].phones[] | select(.type == "mobile") | .value' | head -n 1)
```

## Error Handling Patterns

### No Contact Found

```bash
RESULT=$(~/.claude/skills/contacts/scripts/contacts_manager.rb --search "Unknown Person")

# Check status
STATUS=$(echo "$RESULT" | jq -r '.status')

if [ "$STATUS" = "error" ] || [ "$(echo "$RESULT" | jq '.contacts | length')" -eq 0 ]; then
  echo "❌ No contact found for 'Unknown Person'"
  echo "💬 Please provide a phone number to continue."
  # Wait for user input
  read -p "Phone number: " PHONE_NUMBER
  # Validate and proceed with provided number
fi
```

### No Phone Number in Contact

```bash
PHONES=$(echo "$CONTACT" | jq -r '.contacts[0].phones[]?.value' 2>/dev/null)

if [ -z "$PHONES" ]; then
  NAME=$(echo "$CONTACT" | jq -r '.contacts[0].name.display_name')
  echo "❌ $NAME doesn't have a phone number in contacts"
  echo "💬 Please provide a phone number to send the message."
  # Wait for user input
  read -p "Phone number: " PHONE_NUMBER
  # Validate and proceed
fi
```

### Multiple Phone Numbers

```bash
PHONE_COUNT=$(echo "$CONTACT" | jq '.contacts[0].phones | length')

if [ "$PHONE_COUNT" -gt 1 ]; then
  echo "📱 Multiple phone numbers found:"
  echo "$CONTACT" | jq -r '.contacts[0].phones[] | "\(.type): \(.value)"'

  # Prioritize mobile
  MOBILE=$(echo "$CONTACT" | jq -r '.contacts[0].phones[] | select(.type == "mobile") | .value' | head -n 1)

  if [ -n "$MOBILE" ]; then
    echo "✅ Using mobile number: $MOBILE"
  else
    echo "⚠️ No mobile number found. Using first number."
    PHONE=$(echo "$CONTACT" | jq -r '.contacts[0].phones[0].value')
  fi
fi
```

## Workflow Integration Examples

### Example 1: Simple Name Lookup

```bash
#!/bin/bash

RECIPIENT_NAME="$1"
MESSAGE="$2"

# Look up contact
CONTACT=$(~/.claude/skills/contacts/scripts/contacts_manager.rb --search "$RECIPIENT_NAME")

# Extract mobile number
PHONE=$(echo "$CONTACT" | jq -r '.contacts[0].phones[] | select(.type == "mobile") | .value' | head -n 1)

# Fall back to first phone
if [ -z "$PHONE" ]; then
  PHONE=$(echo "$CONTACT" | jq -r '.contacts[0].phones[0].value')
fi

# Validate
if [ -z "$PHONE" ]; then
  echo "❌ No phone number found"
  exit 1
fi

# Send message
~/.claude/skills/text-message/scripts/send_message.sh "$PHONE" "$MESSAGE"
```

### Example 2: With User Confirmation

```bash
#!/bin/bash

RECIPIENT_NAME="$1"
MESSAGE="$2"

# Look up contact
CONTACT=$(~/.claude/skills/contacts/scripts/contacts_manager.rb --search "$RECIPIENT_NAME")

# Get display name and phone
DISPLAY_NAME=$(echo "$CONTACT" | jq -r '.contacts[0].name.display_name')
PHONE=$(echo "$CONTACT" | jq -r '.contacts[0].phones[] | select(.type == "mobile") | .value' | head -n 1)

# Confirm with user
echo "📱 Ready to send message to:"
echo "   Name: $DISPLAY_NAME"
echo "   Phone: $PHONE"
echo "   Message: $MESSAGE"
read -p "Send? (y/n): " CONFIRM

if [ "$CONFIRM" = "y" ]; then
  # Send message
  RESULT=$(~/.claude/skills/text-message/scripts/send_message.sh "$PHONE" "$MESSAGE")

  if [ $? -eq 0 ]; then
    echo "✅ Message sent successfully"
  else
    echo "❌ Failed to send message"
    echo "$RESULT"
  fi
else
  echo "❌ Message cancelled"
fi
```

### Example 3: Batch Messaging

```bash
#!/bin/bash

MESSAGE="$1"
shift  # Remove first argument, rest are recipient names

for NAME in "$@"; do
  echo "Processing: $NAME"

  # Look up contact
  CONTACT=$(~/.claude/skills/contacts/scripts/contacts_manager.rb --search "$NAME")

  # Extract mobile
  PHONE=$(echo "$CONTACT" | jq -r '.contacts[0].phones[] | select(.type == "mobile") | .value' | head -n 1)

  if [ -z "$PHONE" ]; then
    echo "⚠️ Skipping $NAME - no mobile number"
    continue
  fi

  # Send message
  echo "📤 Sending to $NAME ($PHONE)..."
  ~/.claude/skills/text-message/scripts/send_message.sh "$PHONE" "$MESSAGE"

  # Rate limit (be nice to Messages app)
  sleep 2
done

echo "✅ Batch messaging complete"
```

## Contact Data Caching

For frequently messaged contacts, consider caching:

```bash
# Cache contact phone numbers
CACHE_FILE=~/.claude/skills/text-message/.contact_cache.json

# Update cache
function update_cache() {
  local name="$1"
  local phone="$2"

  # Add to cache with timestamp
  jq -n \
    --arg name "$name" \
    --arg phone "$phone" \
    --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    '{($name): {phone: $phone, updated: $ts}}' \
    | jq -s 'add' "$CACHE_FILE" - > "$CACHE_FILE.tmp"

  mv "$CACHE_FILE.tmp" "$CACHE_FILE"
}

# Check cache first
function check_cache() {
  local name="$1"

  if [ -f "$CACHE_FILE" ]; then
    jq -r --arg name "$name" '.[$name].phone // empty' "$CACHE_FILE"
  fi
}
```

## Best Practices

1. **Full Name Lookup**: Always use first + last name when available
2. **Prioritize Mobile**: Prefer mobile/iPhone types for text messages
3. **Confirm Recipients**: Show user the resolved phone number before sending
4. **Handle Errors Gracefully**: Prompt for manual input when lookup fails
5. **Cache Wisely**: Cache frequently used contact phone numbers
6. **Validate Numbers**: Always validate phone number format before sending
7. **Update Contacts**: If phone number fails, prompt to update contact

## Troubleshooting

### Contact lookup returns empty

**Cause**: Name doesn't match exactly or contact doesn't exist
**Solution**:
- Try partial name search
- Check spelling
- Prompt user for phone number manually

### Multiple contacts with same name

**Cause**: Common name (e.g., "John Smith")
**Solution**:
- Show all matches to user
- Ask user to specify which contact
- Use email or other identifying information

### Phone number exists but wrong type

**Cause**: Contact has phone but not marked as "mobile"
**Solution**:
- Use first available phone number
- Warn user it may not be a mobile number
- Suggest updating contact with correct type

---

*This integration pattern ensures reliable contact lookup and phone number resolution for text messaging.*
