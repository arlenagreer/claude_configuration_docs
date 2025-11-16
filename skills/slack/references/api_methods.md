# Slack Web API Methods Reference

## Message Operations

### chat.postMessage
**Purpose**: Send a message to a channel or DM
**Rate Limit**: Tier 2 (20+ requests/minute)
**Endpoint**: `POST https://slack.com/api/chat.postMessage`

**Parameters**:
- `channel` (required): Channel ID, DM ID, or channel name
- `text` (required): Message content (plain text or markdown)
- `as_user` (optional): Post as authenticated user (true/false)
- `thread_ts` (optional): Thread timestamp to reply in thread

**Response**:
```json
{
  "ok": true,
  "channel": "C1234567890",
  "ts": "1234567890.123456",
  "message": { ... }
}
```

**Common Errors**:
- `channel_not_found`: Invalid channel ID
- `not_in_channel`: Bot not member of channel
- `is_archived`: Channel is archived

## Channel Operations

### conversations.list
**Purpose**: List all channels in workspace
**Rate Limit**: Tier 2 (20+ requests/minute)
**Endpoint**: `GET https://slack.com/api/conversations.list`

**Parameters**:
- `types` (optional): Channel types (public_channel, private_channel, mpim, im)
- `exclude_archived` (optional): Exclude archived channels (true/false)
- `limit` (optional): Max channels to return (default: 100, max: 1000)

**Response**:
```json
{
  "ok": true,
  "channels": [
    {
      "id": "C1234567890",
      "name": "general",
      "is_private": false,
      "is_archived": false
    }
  ]
}
```

### conversations.info
**Purpose**: Get info about a specific channel
**Rate Limit**: Tier 2 (20+ requests/minute)
**Endpoint**: `GET https://slack.com/api/conversations.info`

**Parameters**:
- `channel` (required): Channel ID

**Response**:
```json
{
  "ok": true,
  "channel": {
    "id": "C1234567890",
    "name": "general",
    "num_members": 42,
    "topic": { ... },
    "purpose": { ... }
  }
}
```

### conversations.join
**Purpose**: Join a public channel
**Rate Limit**: Tier 2 (20+ requests/minute)
**Endpoint**: `POST https://slack.com/api/conversations.join`

**Parameters**:
- `channel` (required): Channel ID to join

**Note**: Bot must have `channels:join` scope

### conversations.history
**Purpose**: Fetch message history from channel
**Rate Limit**: **Tier 1 (1 request/minute)** - CRITICAL LIMIT
**Endpoint**: `GET https://slack.com/api/conversations.history`

**Parameters**:
- `channel` (required): Channel ID
- `limit` (optional): Max messages (default: 100, max: 1000)
- `oldest` (optional): Timestamp for start of range
- `latest` (optional): Timestamp for end of range

**Important**: This method has strict rate limiting as of May 2025. Use sparingly.

## User Operations

### users.list
**Purpose**: List all users in workspace
**Rate Limit**: Tier 2 (20+ requests/minute)
**Endpoint**: `GET https://slack.com/api/users.list`

**Parameters**:
- `limit` (optional): Max users to return (default: 0 = all)

**Response**:
```json
{
  "ok": true,
  "members": [
    {
      "id": "U1234567890",
      "name": "john.smith",
      "real_name": "John Smith",
      "profile": {
        "display_name": "john",
        "email": "john@example.com"
      }
    }
  ]
}
```

### users.info
**Purpose**: Get info about a specific user
**Rate Limit**: Tier 2 (20+ requests/minute)
**Endpoint**: `GET https://slack.com/api/users.info`

**Parameters**:
- `user` (required): User ID

**Response**:
```json
{
  "ok": true,
  "user": {
    "id": "U1234567890",
    "name": "john.smith",
    "real_name": "John Smith",
    "tz": "America/Los_Angeles"
  }
}
```

## Multi-Workspace Considerations

### Workspace Isolation
- Each workspace has its own API token
- Channel IDs, User IDs are workspace-specific
- Rate limits apply per workspace (not globally)
- Always specify `--workspace` parameter

### Cross-Workspace Operations
- Channel/user lookups must specify workspace
- No cross-workspace message sending (Slack limitation)
- Each workspace maintains separate caches

## Rate Limit Reference

**Tier 1** (1+ request/minute):
- `conversations.history`
- `conversations.replies`

**Tier 2** (20+ requests/minute):
- `chat.postMessage`
- `conversations.list`
- `conversations.info`
- `conversations.join`
- `users.list`
- `users.info`

**Tier 3** (50+ requests/minute):
- `users.lookupByEmail`
- `team.info`

**Tier 4** (100+ requests/minute):
- `auth.test`

## Error Reference

### Authentication Errors
- `invalid_auth`: Token expired or revoked
- `account_inactive`: Workspace has been deactivated
- `token_revoked`: Token has been revoked

### Channel Errors
- `channel_not_found`: Invalid channel ID or bot doesn't have access
- `not_in_channel`: Bot needs to join channel first
- `is_archived`: Cannot post to archived channel
- `channel_not_found`: Channel doesn't exist in workspace

### User Errors
- `user_not_found`: Invalid user ID
- `user_not_visible`: User is not visible to bot

### Rate Limit Errors
- `rate_limited`: Exceeded rate limit (check Retry-After header)

## Best Practices

1. **Always Use Workspace Parameter**: Never omit `--workspace` flag
2. **Cache Channel/User Lists**: Minimize API calls for lookups
3. **Respect Rate Limits**: Implement exponential backoff
4. **Use Retry-After Header**: When rate limited, respect the header
5. **Handle Errors Gracefully**: Provide clear error messages with workspace context
