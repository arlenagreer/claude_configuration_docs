# Common Slack API Error Codes

## Authentication Errors

### `invalid_auth`
**Meaning**: The token is invalid, expired, or revoked
**HTTP Status**: 401 Unauthorized

**Causes**:
- Token has been revoked
- Token has expired (bot tokens don't expire, but can be revoked)
- Wrong token type (user token vs bot token)
- Wrong workspace token used

**Solutions**:
1. Verify token in `~/.claude/.slack/workspaces/[workspace_id].json`
2. Regenerate token in Slack App settings for that workspace
3. Ensure token starts with `xoxb-` for bot token
4. Confirm you're using the correct workspace ID

### `token_revoked`
**Meaning**: The token was explicitly revoked
**HTTP Status**: 401 Unauthorized

**Solutions**:
1. Reinstall app to workspace
2. Copy new bot token to `~/.claude/.slack/workspaces/[workspace_id].json`
3. Verify correct workspace configuration

### `not_authed`
**Meaning**: No authentication token provided
**HTTP Status**: 401 Unauthorized

**Solutions**:
1. Verify token file exists at `~/.claude/.slack/workspaces/[workspace_id].json`
2. Check file permissions (should be 600)
3. Ensure `--workspace` parameter is provided

## Permission Errors

### `missing_scope`
**Meaning**: Token lacks required OAuth scope
**HTTP Status**: 403 Forbidden

**Example**:
```json
{
  "ok": false,
  "error": "missing_scope",
  "needed": "channels:read",
  "provided": "chat:write,users:read"
}
```

**Solutions**:
1. Add missing scope in Slack App settings → OAuth & Permissions
2. Required scopes for this skill:
   - `chat:write` - Send messages
   - `channels:read` - List/view public channels
   - `channels:join` - Auto-join public channels
   - `users:read` - List/lookup users
   - `conversations:history` - Read message history (optional)
3. Reinstall app to workspace after adding scopes
4. Update workspace config file with new token

## Channel Errors

### `channel_not_found`
**Meaning**: Channel ID is invalid or bot doesn't have access
**HTTP Status**: 404 Not Found

**Causes**:
- Typo in channel ID
- Channel was deleted
- Bot doesn't have permission to see private channel
- Channel doesn't exist in specified workspace

**Solutions**:
1. Use `lookup_channel.rb --name CHANNEL --workspace WORKSPACE_ID` to get correct channel ID
2. Verify channel exists with `slack_manager.rb list-channels --workspace WORKSPACE_ID`
3. For private channels, invite bot first: `/invite @BotName`
4. Confirm you're using the correct workspace ID

### `not_in_channel`
**Meaning**: Bot is not a member of the channel
**HTTP Status**: 403 Forbidden

**Solutions**:
1. Automatically join: Scripts attempt `conversations.join` (requires `channels:join` scope)
2. Manual join: Invite bot in Slack UI with `/invite @BotName`
3. Check if channel is private (bot can't auto-join private channels)
4. For private channels, manual invitation is required

### `is_archived`
**Meaning**: Cannot post to archived channel
**HTTP Status**: 403 Forbidden

**Solutions**:
1. Unarchive the channel in Slack
2. Choose different active channel
3. Verify channel status with `get-channel-info` operation

## User Errors

### `user_not_found`
**Meaning**: User ID is invalid
**HTTP Status**: 404 Not Found

**Causes**:
- User doesn't exist in workspace
- User was deactivated
- Wrong workspace specified

**Solutions**:
1. Use `lookup_user.rb --name USER --workspace WORKSPACE_ID` to get correct user ID
2. Verify user exists with `users.list` API
3. Check if user was deactivated
4. Confirm you're using the correct workspace ID

## Rate Limit Errors

### `rate_limited`
**Meaning**: Too many requests sent to API
**HTTP Status**: 429 Too Many Requests

**Response Headers**:
```http
Retry-After: 30
```

**Rate Limit Tiers**:
- **Tier 1** (1+ req/min): `conversations.history`
- **Tier 2** (20+ req/min): `chat.postMessage`, `conversations.list`
- **Tier 3** (50+ req/min): `users.lookupByEmail`
- **Tier 4** (100+ req/min): `auth.test`

**Solutions**:
1. Implement exponential backoff (already in scripts)
2. Respect `Retry-After` header
3. Review caching strategies
4. Monitor API usage per workspace
5. Remember: Rate limits are **per workspace**

**Automatic Handling**: All scripts implement exponential backoff automatically with max 5 retries

## Message Errors

### `msg_too_long`
**Meaning**: Message text exceeds 40,000 characters
**HTTP Status**: 400 Bad Request

**Solutions**:
1. Split long messages into multiple posts
2. Use file upload for long content
3. Truncate with "read more" link

### `no_text`
**Meaning**: Message has no text content
**HTTP Status**: 400 Bad Request

**Solutions**:
1. Ensure `text` parameter is provided and non-empty
2. For attachments-only messages, provide fallback text
3. Check JSON input format

## Network Errors

### `service_unavailable`
**Meaning**: Slack API is temporarily down
**HTTP Status**: 503 Service Unavailable

**Solutions**:
1. Wait and retry with exponential backoff
2. Check Slack Status page: https://status.slack.com/
3. Queue messages for later retry

### `timeout`
**Meaning**: Request took too long
**HTTP Status**: 408 Request Timeout

**Solutions**:
1. Retry the request
2. Check network connectivity
3. Report persistent timeouts to Slack

## Multi-Workspace Errors

### `workspace_not_found`
**Meaning**: Workspace configuration file doesn't exist
**HTTP Status**: N/A (Local error)

**Causes**:
- Typo in workspace ID
- Workspace not configured
- Missing workspace config file

**Solutions**:
1. List available workspaces: `ls ~/.claude/.slack/workspaces/`
2. Valid workspace IDs: `dreamanager`, `american_laboratory_trading`, `softtrak`
3. Create missing workspace config if needed
4. Check workspace ID spelling exactly matches filename

**Error Response**:
```json
{
  "status": "error",
  "workspace": "invalid_workspace",
  "error": "workspace_not_found",
  "message": "Workspace 'invalid_workspace' not configured",
  "config_path": "/Users/.../.claude/.slack/workspaces/invalid_workspace.json",
  "available_workspaces": ["dreamanager", "american_laboratory_trading", "softtrak"]
}
```

### `config_load_failed`
**Meaning**: Workspace config file exists but can't be parsed
**HTTP Status**: N/A (Local error)

**Causes**:
- Invalid JSON in config file
- Corrupted config file
- Wrong file permissions

**Solutions**:
1. Check JSON syntax in `~/.claude/.slack/workspaces/[workspace_id].json`
2. Verify file permissions (should be 600)
3. Regenerate config file if corrupted

## Error Response Format

### Standard Slack API Errors
```json
{
  "ok": false,
  "error": "channel_not_found"
}
```

### Errors with Details
```json
{
  "ok": false,
  "error": "missing_scope",
  "needed": "channels:read",
  "provided": "chat:write,users:read"
}
```

### Script Error Output
All scripts return structured error JSON:
```json
{
  "status": "error",
  "workspace": "dreamanager",
  "error": "channel_not_found",
  "message": "Channel '#nonexistent' not found in dreamanager workspace",
  "suggestion": "Use list-channels to see available channels"
}
```

## Error Handling Best Practices

1. **Always Include Workspace Context**: Error messages specify which workspace
2. **Provide Actionable Suggestions**: Errors include next steps
3. **Exit Codes**: Scripts use exit code 1 for errors, 0 for success
4. **Automatic Retry**: Rate limit errors auto-retry with exponential backoff
5. **Clear Messages**: Error messages explain the problem and solution
6. **Workspace Isolation**: Track errors separately per workspace

## Debugging Checklist

When encountering errors:
1. ✅ Verify workspace ID is correct
2. ✅ Check token in workspace config file
3. ✅ Confirm OAuth scopes are complete
4. ✅ Test with `list-channels` to verify basic connectivity
5. ✅ Check channel/user exists in correct workspace
6. ✅ Review rate limit tier for the operation
7. ✅ Check Slack Status page for outages
8. ✅ Verify file permissions (600 for configs)

## References
- [Slack API Errors](https://api.slack.com/methods/errors)
- [HTTP Status Codes](https://api.slack.com/docs/http-status-codes)
- [Rate Limits](https://api.slack.com/docs/rate-limits)
- [OAuth Scopes](https://api.slack.com/scopes)
