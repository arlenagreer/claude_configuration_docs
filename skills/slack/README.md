# Slack Agent Skill (Multi-Workspace)

Send messages and interact with multiple Slack workspaces via direct API integration.

## Quick Start

1. Set up Slack Apps at https://api.slack.com/apps (one per workspace)
2. Configure workspace tokens in `~/.claude/.slack/workspaces/[workspace_id].json`
3. Install dependencies: `cd ~/.claude/skills/slack && bundle install`
4. Test: `echo '{"channel": "#general", "text": "Hello!"}' | scripts/slack_manager.rb send --workspace dreamanager`

## Features

- **Automatic Workspace Detection**: Detects workspace based on current project directory
- **Multi-Workspace Support**: Manage 3+ separate Slack workspaces from one skill
- **Send Messages**: Post to channels and DMs across all workspaces
- **List Channels**: Browse available channels per workspace
- **User Lookup**: Find users by name with fuzzy matching
- **Channel Lookup**: Resolve channel names to IDs (exact and fuzzy matching)
- **Automatic Rate Limiting**: Exponential backoff with per-workspace tracking
- **Context-Efficient**: 2-5K tokens vs 10-15K for MCP

## Supported Workspaces

This skill currently supports:
- **dreamanager** - Dreamanager workspace
- **american_laboratory_trading** - American Laboratory Trading workspace
- **softtrak** - SoftTrak workspace

## Security

- Tokens stored outside git at `~/.claude/.slack/workspaces/*.json`
- 600 permissions on token files, 700 on parent directory
- Credentials never logged or exposed
- Workspace isolation prevents cross-workspace data leaks

## Multi-Workspace Architecture

Each workspace has:
- Independent OAuth bot token
- Separate channel and user namespaces
- Independent rate limit tracking
- Isolated error handling and reporting

**Key Principle**: Rate limits apply PER WORKSPACE, not globally. You can send 20 messages/minute to EACH workspace simultaneously.

## Automatic Workspace Detection

The skill automatically detects which workspace to use based on your current directory:

**Project Directory Mappings**:
- `~/Desktop/GitHub Projects/dreamanager` → `dreamanager` workspace
- `~/Github_Projects/dreamanager` → `dreamanager` workspace
- `~/Desktop/GitHub Projects/american_laboratory_trading` → `american_laboratory_trading` workspace
- `~/Github_Projects/american_laboratory_trading` → `american_laboratory_trading` workspace
- `~/Desktop/GitHub Projects/SoftTrak` → `softtrak` workspace
- `~/Github_Projects/SoftTrak` → `softtrak` workspace

**Configuration**: Mappings stored in `~/.claude/.slack/workspace_mappings.json`

**Override**: Use `--workspace [workspace_id]` flag to explicitly specify a different workspace

## Scripts

### slack_manager.rb
Main script for sending messages and managing channels.

**Operations**:
- `send` - Send message to channel or DM
- `list-channels` - List all accessible channels
- `get-channel-info` - Get channel details

**Usage**:
```bash
# Auto-detection (when in project directory)
echo '{"channel": "#general", "text": "Hello!"}' | \
  scripts/slack_manager.rb send

# Explicit workspace
echo '{"channel": "#general", "text": "Hello!"}' | \
  scripts/slack_manager.rb send --workspace dreamanager
```

### lookup_channel.rb
Resolve channel names to IDs with fuzzy matching.

**Usage**:
```bash
# Auto-detection (when in project directory)
scripts/lookup_channel.rb --name "general"

# Explicit workspace
scripts/lookup_channel.rb --name "general" --workspace softtrak
```

### lookup_user.rb
Find users by name with fuzzy matching.

**Usage**:
```bash
# Auto-detection (when in project directory)
scripts/lookup_user.rb --name "John Smith"

# Explicit workspace
scripts/lookup_user.rb --name "John Smith" --workspace american_laboratory_trading
```

## Workspace Configuration

**File Format**: `~/.claude/.slack/workspaces/[workspace_id].json`

```json
{
  "workspace_name": "Dreamanager",
  "workspace_id": "dreamanager",
  "access_token": "xoxb-...",
  "token_type": "bot",
  "scope": "chat:write,channels:read,channels:join,users:read,conversations:history",
  "team_id": null,
  "team_name": null,
  "created_at": "2025-11-16T00:00:00Z",
  "verified": true
}
```

## Adding New Workspaces

1. Create Slack App at https://api.slack.com/apps
2. Add OAuth scopes: `chat:write`, `channels:read`, `channels:join`, `users:read`, `conversations:history`
3. Install app to workspace
4. Copy Bot User OAuth Token (starts with `xoxb-`)
5. Create config file: `~/.claude/.slack/workspaces/[workspace_id].json`
6. Set permissions: `chmod 600 ~/.claude/.slack/workspaces/[workspace_id].json`
7. Test: `echo '{}' | scripts/slack_manager.rb list-channels --workspace [workspace_id]`

## Documentation

- **SKILL.md**: Main skill documentation with usage examples
- **references/api_methods.md**: Slack API endpoint reference
- **references/rate_limiting.md**: Rate limit strategies and multi-workspace considerations
- **references/error_codes.md**: Comprehensive error handling guide

## Testing

**List channels in a workspace**:
```bash
echo '{}' | scripts/slack_manager.rb list-channels --workspace dreamanager
```

**Send test message**:
```bash
echo '{"channel": "#general", "text": "Test message"}' | \
  scripts/slack_manager.rb send --workspace dreamanager
```

**Lookup channel**:
```bash
scripts/lookup_channel.rb --name "social" --workspace softtrak
```

## Error Handling

All scripts return JSON with workspace context:

**Success**:
```json
{
  "status": "success",
  "workspace": "dreamanager",
  "operation": "send",
  "message_ts": "1234567890.123456",
  "channel": "C1234567890"
}
```

**Error**:
```json
{
  "status": "error",
  "workspace": "dreamanager",
  "error": "channel_not_found",
  "message": "Channel not found in workspace",
  "suggestion": "Use list-channels to see available channels"
}
```

## Rate Limits

**Tier 1** (1+ req/min): conversations.history
**Tier 2** (20+ req/min): chat.postMessage, conversations.list, users.list
**Tier 3** (50+ req/min): users.lookupByEmail
**Tier 4** (100+ req/min): auth.test

**Multi-Workspace**: Limits are per workspace, not global. Can send 20 msg/min to EACH workspace.

## Support

For issues or questions, refer to:
- Implementation roadmap: `~/.claude/claudedocs/slack_skill_implementation_roadmap_20251116.md`
- Research report: `~/.claude/claudedocs/research_slack_agent_skill_20251116.md`

## License

This skill is for internal use with the SuperClaude framework.
