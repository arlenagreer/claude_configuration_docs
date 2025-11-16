---
name: slack
description: Send messages, manage channels, and interact with multiple Slack workspaces via API. This skill should be used for ALL Slack operations across dreamanager, american_laboratory_trading, and softtrak workspaces.
category: communication
version: 1.0.0
trigger_keywords: ["slack", "send to slack", "post to channel", "message", "slack workspace"]
---

# Slack Agent Skill

## Purpose
Send messages and interact with multiple Slack workspaces via direct API integration with context-efficient Ruby CLI scripts. Supports three configured workspaces: **dreamanager**, **american_laboratory_trading**, and **softtrak**.

## When to Use This Skill
- User requests to send Slack message to any workspace
- Keywords: "slack", "send to slack", "post to channel", "message team", "notify slack"
- Managing Slack channels or users across workspaces
- Reading channel information from specific workspaces

## Multi-Workspace Architecture

### Configured Workspaces
1. **dreamanager** - Dreamanager workspace
2. **american_laboratory_trading** - American Laboratory Trading workspace
3. **softtrak** - SoftTrak workspace

### Workspace Selection

The skill automatically detects which workspace to use based on the current project directory. You can also explicitly specify a workspace if needed.

**Selection Priority**:
1. **Auto-Detection** (NEW): Automatically uses the appropriate workspace when Claude Code is in a project directory
2. **Explicit**: Use `--workspace [workspace_id]` flag to override auto-detection
3. **Natural Language**: Extract workspace from user request context
4. **Default Behavior**: If workspace cannot be detected, prompt user to choose

**Auto-Detection Behavior**:
- When in `/Users/arlenagreer/Desktop/GitHub Projects/dreamanager` → Uses `dreamanager` workspace
- When in `/Users/arlenagreer/Github_Projects/dreamanager` → Uses `dreamanager` workspace
- When in `/Users/arlenagreer/Desktop/GitHub Projects/american_laboratory_trading` → Uses `american_laboratory_trading` workspace
- When in `/Users/arlenagreer/Github_Projects/american_laboratory_trading` → Uses `american_laboratory_trading` workspace
- When in `/Users/arlenagreer/Desktop/GitHub Projects/SoftTrak` → Uses `softtrak` workspace
- When in `/Users/arlenagreer/Github_Projects/SoftTrak` → Uses `softtrak` workspace

**Configuration**: Project-to-workspace mappings stored in `~/.claude/.slack/workspace_mappings.json`

**Examples**:
```
# Auto-detection (when in dreamanager project directory)
User: "Send message to #general: Deployment complete"
→ Automatically uses dreamanager workspace

# Explicit override
User: "Send message to #general in american_laboratory_trading"
→ Uses american_laboratory_trading workspace (even if in different project)

# Manual specification
echo '{"channel": "#general", "text": "Hello"}' | slack_manager.rb send --workspace softtrak
→ Uses softtrak workspace explicitly
```

## Core Workflow

### Authentication
- **Token Type**: OAuth 2.0 Bot User Token (`xoxb-` prefix)
- **Token Storage**: `~/.claude/.slack/workspaces/[workspace_id].json`
- **OAuth Scopes**: chat:write, channels:read, channels:join, users:read, conversations:history
- **Security**: Tokens stored outside git repository with 600 permissions

### Send Message
Send a message to a Slack channel or direct message in specified workspace.

**Basic Usage**:
```bash
# With auto-detection (when in project directory)
echo '{
  "channel": "#general",
  "text": "Hello from Claude!"
}' | ~/.claude/skills/slack/scripts/slack_manager.rb send

# With explicit workspace
echo '{
  "channel": "#general",
  "text": "Hello from Claude!"
}' | ~/.claude/skills/slack/scripts/slack_manager.rb send --workspace dreamanager
```

**Natural Language Examples**:
- "Send message to #engineering in dreamanager: Deployment complete"
- "Post to ALT slack #alerts: System health check passed"
- "Message softtrak team in #general: Meeting in 10 minutes"

**Channel Formats Supported**:
- Channel name: `#general`, `general`
- Channel ID: `C1234567890`
- User DM: `@username`, `U1234567890`

**Response**:
```json
{
  "status": "success",
  "operation": "send",
  "workspace": "dreamanager",
  "message_ts": "1234567890.123456",
  "channel": "C1234567890"
}
```

### List Channels
Retrieve list of channels in specified workspace.

**Usage**:
```bash
# With auto-detection (when in project directory)
echo '{}' | ~/.claude/skills/slack/scripts/slack_manager.rb list-channels

# With explicit workspace
echo '{}' | ~/.claude/skills/slack/scripts/slack_manager.rb list-channels --workspace american_laboratory_trading
```

**Natural Language Example**:
- "Show me all channels in American Laboratory Trading slack"
- "List dreamanager slack channels"

**Response**:
```json
{
  "status": "success",
  "workspace": "american_laboratory_trading",
  "channels": [
    {"id": "C1234567890", "name": "general"},
    {"id": "C0987654321", "name": "alerts"}
  ]
}
```

### Get Channel Info
Retrieve detailed information about a specific channel in workspace.

**Usage**:
```bash
# With auto-detection (when in project directory)
echo '{
  "channel": "#general"
}' | ~/.claude/skills/slack/scripts/slack_manager.rb get-channel-info

# With explicit workspace
echo '{
  "channel": "#general"
}' | ~/.claude/skills/slack/scripts/slack_manager.rb get-channel-info --workspace softtrak
```

**Response**:
```json
{
  "status": "success",
  "workspace": "softtrak",
  "channel": {
    "id": "C1234567890",
    "name": "general",
    "is_private": false,
    "num_members": 42
  }
}
```

### Lookup Channel
Resolve channel name to channel ID with fuzzy matching in specified workspace.

**Usage**:
```bash
# With auto-detection (when in project directory)
~/.claude/skills/slack/scripts/lookup_channel.rb --name "general"

# With explicit workspace
~/.claude/skills/slack/scripts/lookup_channel.rb --name "general" --workspace dreamanager
```

**Response**:
```json
{
  "status": "success",
  "workspace": "dreamanager",
  "channel_id": "C1234567890",
  "channel_name": "general"
}
```

### Lookup User
Resolve user name to user ID for direct messaging in specified workspace.

**Usage**:
```bash
~/.claude/skills/slack/scripts/lookup_user.rb --name "John Smith" --workspace american_laboratory_trading
```

**Response**:
```json
{
  "status": "success",
  "workspace": "american_laboratory_trading",
  "user_id": "U1234567890",
  "user_name": "John Smith",
  "display_name": "john"
}
```

## Multi-Workspace Usage Patterns

### Explicit Workspace Selection
Always use `--workspace` flag when calling scripts directly:
```bash
# Send to dreamanager
echo '{"channel": "#general", "text": "Hello"}' | \
  ~/.claude/skills/slack/scripts/slack_manager.rb send --workspace dreamanager

# List channels in ALT
echo '{}' | \
  ~/.claude/skills/slack/scripts/slack_manager.rb list-channels --workspace american_laboratory_trading
```

### Natural Language Routing
Claude will extract workspace from context:
```
"Send to dreamanager slack: Meeting at 2pm"
→ Automatically routes to dreamanager workspace

"Post ALT system alert to #engineering"
→ Automatically routes to american_laboratory_trading workspace

"Message softtrak team about deployment"
→ Automatically routes to softtrak workspace
```

### Workspace Aliases
These terms map to workspace IDs:
- **dreamanager**: "dreamanager", "dream"
- **american_laboratory_trading**: "ALT", "american laboratory trading", "american lab", "laboratory"
- **softtrak**: "softtrak", "soft trak", "softrak"

## Adding New Workspaces

To add a new Slack workspace:

1. **Create Slack App** (via Slack Web UI):
   - Go to https://api.slack.com/apps
   - Click "Create New App" → "From scratch"
   - Enter app name and select workspace
   - Navigate to "OAuth & Permissions"
   - Add scopes: `chat:write`, `channels:read`, `channels:join`, `users:read`, `conversations:history`
   - Install app to workspace
   - Copy "Bot User OAuth Token" (starts with `xoxb-`)

2. **Create Workspace Config File**:
   ```bash
   cat > ~/.claude/.slack/workspaces/[workspace_id].json <<EOF
   {
     "workspace_name": "[Workspace Display Name]",
     "workspace_id": "[workspace_id]",
     "access_token": "xoxb-...",
     "token_type": "bot",
     "scope": "chat:write,channels:read,channels:join,users:read,conversations:history",
     "team_id": null,
     "team_name": null,
     "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
     "verified": false
   }
   EOF
   chmod 600 ~/.claude/.slack/workspaces/[workspace_id].json
   ```

3. **Verify Token**:
   ```bash
   echo '{}' | ~/.claude/skills/slack/scripts/slack_manager.rb list-channels --workspace [workspace_id]
   ```

## Rate Limiting

**Important**: Slack enforces rate limits as of May 2025:
- **Tier 1** (1+ req/min): `conversations.history`, `conversations.replies`
- **Tier 2** (20+ req/min): Most other methods including `chat.postMessage`
- **Tier 3** (50+ req/min): `users.list`, `conversations.list`
- **Tier 4** (100+ req/min): `auth.test`, `team.info`
- **Exponential Backoff**: Automatically retries with increasing delays

All scripts implement automatic retry with exponential backoff for rate limit errors.

## Error Handling

**Common Errors**:
- `channel_not_found`: Invalid channel ID or name in specified workspace
- `not_in_channel`: Bot needs to join channel first (auto-join attempted)
- `invalid_auth`: Token expired or revoked for workspace (check workspace config)
- `rate_limited`: Exceeded rate limit (automatic retry with backoff)
- `workspace_not_found`: Invalid workspace ID (check ~/.claude/.slack/workspaces/)
- `workspace_not_configured`: Missing workspace config file

**Error Response Format**:
```json
{
  "status": "error",
  "workspace": "dreamanager",
  "error": "channel_not_found",
  "message": "Channel '#nonexistent' not found in dreamanager workspace"
}
```

## Security Best Practices
- ✅ Tokens stored at `~/.claude/.slack/workspaces/[workspace_id].json` (600 permissions)
- ✅ Parent directory `~/.claude/.slack/` has 700 permissions
- ✅ Tokens never logged or exposed in error messages
- ✅ Credentials redacted from all output
- ✅ Separate config directory outside skill folder
- ✅ Multi-workspace isolation - tokens never cross workspaces

## Workspace Token Management

### Verify All Tokens
```bash
# Check dreamanager
echo '{}' | ~/.claude/skills/slack/scripts/slack_manager.rb list-channels --workspace dreamanager

# Check american_laboratory_trading
echo '{}' | ~/.claude/skills/slack/scripts/slack_manager.rb list-channels --workspace american_laboratory_trading

# Check softtrak
echo '{}' | ~/.claude/skills/slack/scripts/slack_manager.rb list-channels --workspace softtrak
```

### Token Rotation
When rotating a workspace token:
1. Generate new token in Slack Web UI (OAuth & Permissions)
2. Update `~/.claude/.slack/workspaces/[workspace_id].json`
3. Set `verified: false` to trigger re-verification
4. Test with list-channels operation

### Token Security Audit
```bash
# Check permissions
ls -la ~/.claude/.slack/workspaces/

# Should show:
# drwx------ (700) for ~/.claude/.slack/
# -rw------- (600) for all .json files
```

## Bundled Resources
- `scripts/slack_manager.rb` - Main API interface for send/list/info operations with workspace support
- `scripts/lookup_channel.rb` - Channel name → ID resolution with fuzzy matching per workspace
- `scripts/lookup_user.rb` - User name → ID resolution with workspace isolation
- `references/api_methods.md` - Detailed Slack API endpoint documentation
- `references/rate_limiting.md` - Rate limit handling strategies and best practices
- `references/error_codes.md` - Common error scenarios and solutions
- `assets/message_templates/` - Optional: Pre-built message templates

## Integration Notes
- Compatible with email/calendar/contacts skills (shared OAuth pattern)
- Follows same Ruby CLI conventions for consistency
- JSON input via STDIN, JSON output via STDOUT
- Exit code 0 for success, 1 for errors
- Multi-workspace architecture allows project-specific Slack communication

## Troubleshooting

### "workspace_not_found" error
- Check workspace ID spelling matches filename exactly
- List available workspaces: `ls ~/.claude/.slack/workspaces/`
- Valid IDs: dreamanager, american_laboratory_trading, softtrak

### "invalid_auth" error for specific workspace
- Verify token in `~/.claude/.slack/workspaces/[workspace_id].json`
- Check token starts with `xoxb-`
- Verify bot is still installed in Slack workspace
- Try reinstalling app in Slack Web UI

### Bot can't post to channel
- Ensure bot is invited to channel: `/invite @[BotName]`
- Scripts auto-join public channels but not private channels
- Check OAuth scopes include `chat:write` and `channels:join`

### Can't find channel by name
- Use `list-channels` to see available channels
- Channel lookup is case-insensitive and fuzzy
- Try using channel ID directly: `C1234567890`
