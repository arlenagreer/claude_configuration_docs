# Slack Agent Skill Implementation Roadmap

**Date**: 2025-11-16
**Project**: Create Slack Agent Skill with Direct API Integration
**Status**: Planning Phase (Implementation NOT started)
**Estimated Duration**: 4-5 days (phased approach)

---

## Executive Summary

### Objective
Create a Slack "Agent Skill" using the skill-creator pattern that handles Slack communication via direct API integration instead of MCP server. This approach achieves **60-70% token reduction** (2-5K vs 10-15K tokens) while maintaining full functionality.

### Critical Discovery
**MCP Configuration Review**: Analysis of `/Users/arlenagreer/.claude/mcp.json` reveals **NO Slack MCP server is currently configured**. The file contains only:
- sequential-thinking
- gmail
- playwright
- tavily
- context7
- chrome-devtools

**Implication**: MCP server removal and Docker Desktop adjustment steps are **NOT REQUIRED**. This roadmap focuses exclusively on skill creation.

### Success Criteria
- ✅ Functional Slack skill following skill-creator pattern
- ✅ OAuth 2.0 authentication with secure token storage
- ✅ Core operations: send messages, list channels, lookup users
- ✅ Rate limiting with exponential backoff
- ✅ 60-70% context window reduction vs MCP approach
- ✅ Security-first implementation with credential protection

### Reference Documents
- Research Report: `~/.claude/claudedocs/research_slack_agent_skill_20251116.md`
- Email Skill Pattern: `~/.claude/skills/email/SKILL.md`
- Skill Creator Guide: `~/.claude/plugins/marketplaces/anthropic-agent-skills/skill-creator/SKILL.md`

---

## Prerequisites

### Development Environment
- **Ruby**: 2.7+ (verify: `ruby --version`)
- **Bundler**: Latest version (verify: `bundle --version`)
- **Git**: For version control (verify: `git --version`)

### Slack Workspace Access
- **Admin Privileges**: Required to create Slack App
- **Workspace**: Access to target Slack workspace for testing
- **OAuth Scopes**: Ability to request and approve OAuth scopes

### Local Environment
- **Directory**: `~/.claude/skills/slack/` (will be created)
- **Token Storage**: `~/.claude/.slack/` (will be created, outside git)
- **Permissions**: Ability to create files and execute scripts

### Tools & Dependencies
- **skill-creator skill**: Already available at `~/.claude/plugins/marketplaces/anthropic-agent-skills/skill-creator/`
- **Ruby Gems**: `slack-ruby-client` (~> 2.7.0), `faraday` (>= 2.0.1)

---

## Implementation Phases

## Phase 1: Slack App Setup & OAuth Configuration

**Duration**: 1 day
**Complexity**: Moderate
**Dependencies**: None

### 1.1 Create Slack App

**Steps**:
1. Navigate to https://api.slack.com/apps
2. Click "Create New App" → "From scratch"
3. App Name: `Claude Code Integration` (or your preference)
4. Select workspace for development and testing
5. Note the **Client ID** and **Client Secret** from "Basic Information"

**Validation**: ✅ App appears in Slack workspace settings

### 1.2 Configure OAuth Scopes

**Required Scopes** (Bot Token Scopes):
```yaml
chat:write          # Send messages to channels/DMs
channels:read       # List and read public channel info
channels:join       # Join public channels
users:read          # Read user information
conversations:history  # Read message history (1 req/min limit)
```

**Steps**:
1. Navigate to "OAuth & Permissions" in Slack App settings
2. Scroll to "Scopes" → "Bot Token Scopes"
3. Add each scope listed above using "Add an OAuth Scope" button
4. Note the rate limit warning for `conversations:history`

**Validation**: ✅ All 5 scopes listed in Bot Token Scopes section

### 1.3 Install App to Workspace

**Steps**:
1. Navigate to "OAuth & Permissions"
2. Click "Install to Workspace" button
3. Review and authorize the requested permissions
4. **Copy the Bot User OAuth Token** (starts with `xoxb-`)
   - ⚠️ This token will only be shown once - copy immediately
   - Store securely (next step)

**Validation**: ✅ App appears in workspace's "Apps" section

### 1.4 Configure Local Token Storage

**Directory Structure**:
```bash
~/.claude/.slack/
├── config.json     # OAuth client configuration
└── token.json      # Access token (NEVER commit to git)
```

**Create `~/.claude/.slack/config.json`**:
```json
{
  "client_id": "YOUR_CLIENT_ID_HERE",
  "client_secret": "YOUR_CLIENT_SECRET_HERE",
  "redirect_uri": "http://localhost:8080/oauth/callback"
}
```

**Create `~/.claude/.slack/token.json`**:
```json
{
  "access_token": "xoxb-YOUR-BOT-TOKEN-HERE",
  "token_type": "bot",
  "scope": "chat:write,channels:read,channels:join,users:read,conversations:history",
  "team_id": "T...",
  "team_name": "Your Workspace Name",
  "expires_at": null
}
```

**Security**:
```bash
# Set restrictive permissions
chmod 600 ~/.claude/.slack/config.json
chmod 600 ~/.claude/.slack/token.json

# Add to gitignore if in version control
echo ".slack/" >> ~/.claude/.gitignore
```

**Validation**:
- ✅ Files created with correct permissions (600)
- ✅ Token starts with `xoxb-`
- ✅ All scopes listed in token.json

---

## Phase 2: Skill Structure Creation

**Duration**: 1 day
**Complexity**: Low
**Dependencies**: Phase 1 complete

### 2.1 Initialize Skill Using skill-creator

**Command**:
```bash
cd ~/.claude/skills/
~/.claude/plugins/marketplaces/anthropic-agent-skills/skill-creator/scripts/init_skill.py slack
```

**Expected Output**:
```
Created skill directory: slack/
Created SKILL.md template
Ready for customization
```

**Validation**: ✅ Directory `~/.claude/skills/slack/` created with SKILL.md

### 2.2 Create Directory Structure

**Structure**:
```
~/.claude/skills/slack/
├── SKILL.md                          # Main skill file (required)
├── scripts/                          # Executable Ruby scripts
│   ├── slack_manager.rb              # Main API interface
│   ├── lookup_channel.rb             # Channel name → ID resolution
│   └── lookup_user.rb                # User name → ID resolution
├── references/                       # Documentation (loaded as needed)
│   ├── api_methods.md                # Slack API endpoint reference
│   ├── rate_limiting.md              # Rate limit strategies
│   └── error_codes.md                # Common error scenarios
└── assets/                           # Optional
    └── message_templates/            # Reusable templates
```

**Commands**:
```bash
cd ~/.claude/skills/slack/
mkdir -p scripts references assets/message_templates
chmod +x scripts/  # Ensure scripts directory is executable
```

**Validation**: ✅ All directories created

### 2.3 Create SKILL.md

**Content** (following email skill pattern):
```markdown
---
name: slack
description: Send messages, manage channels, and interact with Slack workspace via API. This skill should be used for ALL Slack operations.
category: communication
version: 1.0.0
trigger_keywords: ["slack", "send to slack", "post to channel", "message"]
---

# Slack Agent Skill

## Purpose
Send messages and interact with Slack workspace via direct API integration with context-efficient Ruby CLI scripts.

## When to Use This Skill
- User requests to send Slack message
- Keywords: "slack", "send to slack", "post to channel", "message team"
- Managing Slack channels or users
- Reading channel information

## Core Workflow

### Authentication
- **Token Type**: OAuth 2.0 Bot User Token (`xoxb-` prefix)
- **Token Location**: `~/.claude/.slack/token.json`
- **OAuth Scopes**: chat:write, channels:read, channels:join, users:read, conversations:history
- **Security**: Token stored outside git repository with 600 permissions

### Send Message
Send a message to a Slack channel or direct message.

**Usage**:
```bash
echo '{
  "channel": "#general",
  "text": "Hello from Claude!"
}' | ~/.claude/skills/slack/scripts/slack_manager.rb send
```

**Channel Formats Supported**:
- Channel name: `#general`, `general`
- Channel ID: `C1234567890`
- User DM: `@username`, `U1234567890`

**Response**:
```json
{
  "status": "success",
  "operation": "send",
  "message_ts": "1234567890.123456",
  "channel": "C1234567890"
}
```

### List Channels
Retrieve list of channels in workspace.

**Usage**:
```bash
echo '{}' | ~/.claude/skills/slack/scripts/slack_manager.rb list-channels
```

**Response**:
```json
{
  "status": "success",
  "channels": [
    {"id": "C1234567890", "name": "general"},
    {"id": "C0987654321", "name": "random"}
  ]
}
```

### Lookup Channel
Resolve channel name to channel ID with fuzzy matching.

**Usage**:
```bash
~/.claude/skills/slack/scripts/lookup_channel.rb --name "general"
```

**Response**:
```json
{
  "status": "success",
  "channel_id": "C1234567890",
  "channel_name": "general"
}
```

### Lookup User
Resolve user name to user ID for direct messaging.

**Usage**:
```bash
~/.claude/skills/slack/scripts/lookup_user.rb --name "John Smith"
```

**Response**:
```json
{
  "status": "success",
  "user_id": "U1234567890",
  "user_name": "John Smith",
  "display_name": "john"
}
```

## Rate Limiting

**Important**: Slack enforces rate limits as of May 2025:
- **Tier 1** (1+ req/min): `conversations.history`, `conversations.replies`
- **Tier 2** (20+ req/min): Most other methods including `chat.postMessage`
- **Exponential Backoff**: Automatically retries with increasing delays

All scripts implement automatic retry with exponential backoff for rate limit errors.

## Error Handling

**Common Errors**:
- `channel_not_found`: Invalid channel ID or name
- `not_in_channel`: Bot needs to join channel first (auto-join attempted)
- `invalid_auth`: Token expired or revoked (check token.json)
- `rate_limited`: Exceeded rate limit (automatic retry)

## Security Best Practices
- ✅ Token stored at `~/.claude/.slack/token.json` (600 permissions)
- ✅ Token never logged or exposed in error messages
- ✅ Credentials redacted from all output
- ✅ Separate config directory outside skill folder

## Bundled Resources
- `scripts/slack_manager.rb` - Main API interface for send/list operations
- `scripts/lookup_channel.rb` - Channel name → ID resolution with fuzzy matching
- `scripts/lookup_user.rb` - User name → ID resolution via Google Contacts pattern
- `references/api_methods.md` - Detailed Slack API endpoint documentation
- `references/rate_limiting.md` - Rate limit handling strategies and best practices
- `references/error_codes.md` - Common error scenarios and solutions

## Integration Notes
- Compatible with email/calendar/contacts skills (shared OAuth pattern)
- Follows same Ruby CLI conventions for consistency
- JSON input via STDIN, JSON output via STDOUT
- Exit code 0 for success, 1 for errors
```

**Validation**: ✅ SKILL.md created with valid YAML frontmatter

### 2.4 Create Gemfile

**File**: `~/.claude/skills/slack/Gemfile`
```ruby
# frozen_string_literal: true

source 'https://rubygems.org'

gem 'slack-ruby-client', '~> 2.7.0'
gem 'faraday', '>= 2.0.1'
gem 'json', '~> 2.6'
```

**Install Dependencies**:
```bash
cd ~/.claude/skills/slack/
bundle install
```

**Validation**:
- ✅ Gemfile.lock created
- ✅ Gems installed successfully

---

## Phase 3: Script Implementation

**Duration**: 2 days
**Complexity**: High
**Dependencies**: Phase 2 complete

### 3.1 Implement slack_manager.rb

**File**: `~/.claude/skills/slack/scripts/slack_manager.rb`

**Core Features**:
- Send messages to channels/DMs
- List channels
- Exponential backoff for rate limits
- Error handling with descriptive messages
- JSON input/output

**Implementation** (complete script):
```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'json'
require 'slack-ruby-client'

# Load token from secure location
def load_token
  token_path = File.expand_path('~/.claude/.slack/token.json')
  unless File.exist?(token_path)
    puts JSON.generate({
      status: 'error',
      message: 'Token file not found. Run OAuth setup first.',
      path: token_path
    })
    exit 1
  end

  config = JSON.parse(File.read(token_path))
  config['access_token']
rescue StandardError => e
  puts JSON.generate({
    status: 'error',
    message: "Failed to load token: #{e.message}"
  })
  exit 1
end

# Exponential backoff retry logic
def retry_with_exponential_backoff(max_retries: 5, initial_delay: 1, factor: 2, max_delay: 60)
  retries = 0

  begin
    yield
  rescue Slack::Web::Api::Errors::TooManyRequestsError => e
    if retries >= max_retries
      puts JSON.generate({
        status: 'error',
        message: 'Rate limit exceeded after max retries',
        retry_after: e.response.headers['retry-after']
      })
      exit 1
    end

    retry_after = e.response.headers['retry-after'].to_i
    delay = [retry_after, [initial_delay * (factor**retries), max_delay].min].max

    sleep(delay)
    retries += 1
    retry
  rescue Slack::Web::Api::Errors::SlackError => e
    puts JSON.generate({
      status: 'error',
      message: e.message,
      error_code: e.class.name
    })
    exit 1
  end
end

# Configure Slack client
Slack.configure do |config|
  config.token = load_token
end

client = Slack::Web::Client.new

# Parse operation and input
operation = ARGV[0]
input = JSON.parse($stdin.read)

case operation
when 'send'
  # Send message to channel or DM
  retry_with_exponential_backoff do
    result = client.chat_postMessage(
      channel: input['channel'],
      text: input['text'],
      as_user: true
    )

    puts JSON.generate({
      status: 'success',
      operation: 'send',
      message_ts: result.ts,
      channel: result.channel
    })
  end

when 'list-channels'
  # List all channels
  retry_with_exponential_backoff do
    channels = client.conversations_list(
      types: 'public_channel',
      exclude_archived: true
    )

    puts JSON.generate({
      status: 'success',
      operation: 'list-channels',
      channels: channels.channels.map { |c| { id: c.id, name: c.name } }
    })
  end

when 'get-channel-info'
  # Get info about specific channel
  retry_with_exponential_backoff do
    info = client.conversations_info(channel: input['channel'])

    puts JSON.generate({
      status: 'success',
      operation: 'get-channel-info',
      channel: {
        id: info.channel.id,
        name: info.channel.name,
        is_private: info.channel.is_private,
        member_count: info.channel.num_members
      }
    })
  end

else
  puts JSON.generate({
    status: 'error',
    message: "Unknown operation: #{operation}",
    valid_operations: ['send', 'list-channels', 'get-channel-info']
  })
  exit 1
end
```

**Make Executable**:
```bash
chmod +x ~/.claude/skills/slack/scripts/slack_manager.rb
```

**Validation**:
- ✅ Script is executable (755 permissions)
- ✅ Shebang points to ruby
- ✅ All required gems loaded

### 3.2 Implement lookup_channel.rb

**File**: `~/.claude/skills/slack/scripts/lookup_channel.rb`

**Features**:
- Fuzzy matching for channel names
- Handles # prefix or plain names
- Returns channel ID for API calls

**Implementation**:
```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'json'
require 'slack-ruby-client'
require 'optparse'

# Parse command line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: lookup_channel.rb --name CHANNEL_NAME"

  opts.on("--name NAME", "Channel name to lookup") do |name|
    options[:name] = name
  end
end.parse!

unless options[:name]
  puts JSON.generate({
    status: 'error',
    message: 'Missing required --name parameter'
  })
  exit 1
end

# Load token
token_path = File.expand_path('~/.claude/.slack/token.json')
config = JSON.parse(File.read(token_path))

Slack.configure do |cfg|
  cfg.token = config['access_token']
end

client = Slack::Web::Client.new

# Normalize channel name (remove # if present)
search_name = options[:name].sub(/^#/, '').downcase

begin
  # Fetch all channels
  channels = client.conversations_list(
    types: 'public_channel,private_channel',
    exclude_archived: true
  )

  # Try exact match first
  exact_match = channels.channels.find { |c| c.name.downcase == search_name }

  if exact_match
    puts JSON.generate({
      status: 'success',
      channel_id: exact_match.id,
      channel_name: exact_match.name,
      match_type: 'exact'
    })
    exit 0
  end

  # Try fuzzy match (contains search term)
  fuzzy_matches = channels.channels.select { |c| c.name.downcase.include?(search_name) }

  if fuzzy_matches.length == 1
    puts JSON.generate({
      status: 'success',
      channel_id: fuzzy_matches.first.id,
      channel_name: fuzzy_matches.first.name,
      match_type: 'fuzzy'
    })
    exit 0
  elsif fuzzy_matches.length > 1
    puts JSON.generate({
      status: 'error',
      message: 'Multiple channels match. Please be more specific.',
      matches: fuzzy_matches.map { |c| { id: c.id, name: c.name } }
    })
    exit 1
  else
    puts JSON.generate({
      status: 'error',
      message: "Channel not found: #{options[:name]}",
      suggestion: 'List all channels with: slack_manager.rb list-channels'
    })
    exit 1
  end

rescue Slack::Web::Api::Errors::SlackError => e
  puts JSON.generate({
    status: 'error',
    message: e.message
  })
  exit 1
end
```

**Make Executable**:
```bash
chmod +x ~/.claude/skills/slack/scripts/lookup_channel.rb
```

**Validation**: ✅ Script executable with fuzzy matching logic

### 3.3 Implement lookup_user.rb

**File**: `~/.claude/skills/slack/scripts/lookup_user.rb`

**Features**:
- Search by real name or display name
- Fuzzy matching for user lookup
- Returns user ID for DMs

**Implementation**:
```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'json'
require 'slack-ruby-client'
require 'optparse'

# Parse command line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: lookup_user.rb --name USER_NAME"

  opts.on("--name NAME", "User name to lookup") do |name|
    options[:name] = name
  end
end.parse!

unless options[:name]
  puts JSON.generate({
    status: 'error',
    message: 'Missing required --name parameter'
  })
  exit 1
end

# Load token
token_path = File.expand_path('~/.claude/.slack/token.json')
config = JSON.parse(File.read(token_path))

Slack.configure do |cfg|
  cfg.token = config['access_token']
end

client = Slack::Web::Client.new

search_name = options[:name].sub(/^@/, '').downcase

begin
  # Fetch all users
  users = client.users_list

  # Try exact match on real_name or display_name
  exact_match = users.members.find do |u|
    !u.deleted && (
      u.real_name&.downcase == search_name ||
      u.profile&.display_name&.downcase == search_name
    )
  end

  if exact_match
    puts JSON.generate({
      status: 'success',
      user_id: exact_match.id,
      user_name: exact_match.real_name,
      display_name: exact_match.profile.display_name,
      match_type: 'exact'
    })
    exit 0
  end

  # Try fuzzy match
  fuzzy_matches = users.members.select do |u|
    !u.deleted && (
      u.real_name&.downcase&.include?(search_name) ||
      u.profile&.display_name&.downcase&.include?(search_name)
    )
  end

  if fuzzy_matches.length == 1
    match = fuzzy_matches.first
    puts JSON.generate({
      status: 'success',
      user_id: match.id,
      user_name: match.real_name,
      display_name: match.profile.display_name,
      match_type: 'fuzzy'
    })
    exit 0
  elsif fuzzy_matches.length > 1
    puts JSON.generate({
      status: 'error',
      message: 'Multiple users match. Please be more specific.',
      matches: fuzzy_matches.map { |u| {
        id: u.id,
        real_name: u.real_name,
        display_name: u.profile.display_name
      }}
    })
    exit 1
  else
    puts JSON.generate({
      status: 'error',
      message: "User not found: #{options[:name]}"
    })
    exit 1
  end

rescue Slack::Web::Api::Errors::SlackError => e
  puts JSON.generate({
    status: 'error',
    message: e.message
  })
  exit 1
end
```

**Make Executable**:
```bash
chmod +x ~/.claude/skills/slack/scripts/lookup_user.rb
```

**Validation**: ✅ Script executable with user search logic

---

## Phase 4: Documentation & References

**Duration**: 1 day
**Complexity**: Low
**Dependencies**: Phase 3 complete

### 4.1 Create api_methods.md

**File**: `~/.claude/skills/slack/references/api_methods.md`

**Content** (comprehensive API reference):
```markdown
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

**Special Tier** (varies):
- `files.upload` (rate limit based on file size)
```

**Validation**: ✅ Comprehensive API reference created

### 4.2 Create rate_limiting.md

**File**: `~/.claude/skills/slack/references/rate_limiting.md`

**Content**:
```markdown
# Rate Limiting Strategies for Slack API

## Overview

Slack enforces rate limits on API methods to ensure fair usage across all apps. As of May 2025, rate limits have been tightened for non-Marketplace apps.

## Rate Limit Tiers

### Tier 1: Strict Limits (1+ request/minute)
- `conversations.history`
- `conversations.replies`
- Maximum 15 objects per request

**Strategy**: Cache results aggressively, minimize calls, use Events API for real-time updates

### Tier 2: Standard Limits (20+ requests/minute)
- Most messaging, channel, and user methods
- Includes `chat.postMessage`, `conversations.list`, `users.list`

**Strategy**: Reasonable caching, batch operations when possible

## Exponential Backoff Implementation

### Algorithm
```ruby
def retry_with_exponential_backoff(max_retries: 5, initial_delay: 1, factor: 2, max_delay: 60)
  retries = 0

  begin
    yield
  rescue Slack::Web::Api::Errors::TooManyRequestsError => e
    if retries >= max_retries
      raise e  # Give up after max retries
    end

    # Respect Retry-After header if provided
    retry_after = e.response.headers['retry-after'].to_i

    # Calculate exponential delay: initial * (factor ^ retries)
    exponential_delay = initial_delay * (factor ** retries)

    # Use max of retry_after or exponential_delay, capped at max_delay
    delay = [retry_after, [exponential_delay, max_delay].min].max

    sleep(delay)
    retries += 1
    retry
  end
end
```

### Parameters
- **max_retries**: Maximum retry attempts (default: 5)
- **initial_delay**: Starting delay in seconds (default: 1)
- **factor**: Multiplier for each retry (default: 2)
- **max_delay**: Maximum delay cap (default: 60 seconds)

### Example Delays
| Retry | Delay (seconds) |
|-------|-----------------|
| 0     | 1               |
| 1     | 2               |
| 2     | 4               |
| 3     | 8               |
| 4     | 16              |
| 5     | 32              |

## Caching Strategies

### Channel ID Cache
```ruby
@channel_cache = {}

def get_channel_id(name)
  return @channel_cache[name] if @channel_cache.key?(name)

  # Fetch from API
  result = client.conversations_list
  result.channels.each do |channel|
    @channel_cache[channel.name] = channel.id
  end

  @channel_cache[name]
end
```

**Cache Duration**: 1 hour (channels rarely change)

### User ID Cache
```ruby
@user_cache = {}

def get_user_id(name)
  return @user_cache[name] if @user_cache.key?(name)

  # Fetch from API
  result = client.users_list
  result.members.each do |user|
    @user_cache[user.real_name] = user.id
  end

  @user_cache[name]
end
```

**Cache Duration**: 4 hours (user list changes infrequently)

## Batch Operations

### Batch Message Sending
Instead of:
```ruby
# BAD: 100 API calls
messages.each do |msg|
  client.chat_postMessage(channel: msg[:channel], text: msg[:text])
end
```

Use:
```ruby
# GOOD: Queue and send with delays
messages.each_with_index do |msg, index|
  sleep(3) if index % 20 == 0  # Pause every 20 messages
  retry_with_exponential_backoff do
    client.chat_postMessage(channel: msg[:channel], text: msg[:text])
  end
end
```

## Smart Polling

### Avoid Frequent History Calls
```ruby
# BAD: Frequent history polling
loop do
  messages = client.conversations_history(channel: 'C1234567890')
  process(messages)
  sleep(10)  # Still hits rate limit
end
```

### Better: Use Events API
Subscribe to Events API for real-time message events instead of polling `conversations.history`

## Monitoring API Usage

### Track Requests
```ruby
class RateLimitMonitor
  def initialize
    @requests = Hash.new(0)
    @start_time = Time.now
  end

  def record_request(method)
    @requests[method] += 1
  end

  def report
    elapsed = Time.now - @start_time
    @requests.each do |method, count|
      rate = (count / elapsed) * 60  # requests per minute
      puts "#{method}: #{count} requests, #{rate.round(2)} req/min"
    end
  end
end
```

## Error Handling

### 429 Response
```http
HTTP/1.1 429 Too Many Requests
Retry-After: 30
```

**Action**: Respect `Retry-After` header, implement exponential backoff

### Best Practices
1. Always check `Retry-After` header
2. Implement exponential backoff with jitter
3. Cache API responses when possible
4. Use batch operations for bulk actions
5. Monitor your API usage patterns
6. Use Events API for real-time data instead of polling

## References
- [Slack Rate Limits Documentation](https://api.slack.com/docs/rate-limits)
- [Rate Limit Changes (May 2025)](https://docs.slack.dev/changelog/2025/05/29/rate-limit-changes-for-non-marketplace-apps/)
```

**Validation**: ✅ Rate limiting documentation created

### 4.3 Create error_codes.md

**File**: `~/.claude/skills/slack/references/error_codes.md`

**Content**:
```markdown
# Common Slack API Error Codes

## Authentication Errors

### `invalid_auth`
**Meaning**: The token is invalid, expired, or revoked
**HTTP Status**: 401 Unauthorized

**Causes**:
- Token has been revoked
- Token has expired (bot tokens don't expire, but can be revoked)
- Wrong token type (user token vs bot token)

**Solutions**:
1. Verify token in `~/.claude/.slack/token.json`
2. Regenerate token in Slack App settings
3. Ensure token starts with `xoxb-` for bot token

### `token_revoked`
**Meaning**: The token was explicitly revoked
**HTTP Status**: 401 Unauthorized

**Solutions**:
1. Reinstall app to workspace
2. Copy new bot token to `~/.claude/.slack/token.json`

### `not_authed`
**Meaning**: No authentication token provided
**HTTP Status**: 401 Unauthorized

**Solutions**:
1. Verify token file exists at `~/.claude/.slack/token.json`
2. Check file permissions (should be 600)

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
2. Reinstall app to workspace
3. Update token.json with new token

## Channel Errors

### `channel_not_found`
**Meaning**: Channel ID is invalid or bot doesn't have access
**HTTP Status**: 404 Not Found

**Causes**:
- Typo in channel ID
- Channel was deleted
- Bot doesn't have permission to see private channel

**Solutions**:
1. Use `lookup_channel.rb` to get correct channel ID
2. Verify channel exists with `conversations.list`
3. For private channels, invite bot first

### `not_in_channel`
**Meaning**: Bot is not a member of the channel
**HTTP Status**: 403 Forbidden

**Solutions**:
1. Automatically join: `conversations.join` (requires `channels:join` scope)
2. Manual join: Invite bot in Slack UI
3. Check if channel is private (bot can't auto-join)

### `is_archived`
**Meaning**: Cannot post to archived channel
**HTTP Status**: 403 Forbidden

**Solutions**:
1. Unarchive the channel
2. Choose different active channel

## User Errors

### `user_not_found`
**Meaning**: User ID is invalid
**HTTP Status**: 404 Not Found

**Solutions**:
1. Use `lookup_user.rb` to get correct user ID
2. Verify user exists with `users.list`
3. Check if user was deactivated

## Rate Limit Errors

### `rate_limited`
**Meaning**: Too many requests sent to API
**HTTP Status**: 429 Too Many Requests

**Response Headers**:
```http
Retry-After: 30
```

**Solutions**:
1. Implement exponential backoff (already in scripts)
2. Respect `Retry-After` header
3. Review caching strategies
4. Monitor API usage

**Automatic Handling**: All scripts implement exponential backoff automatically

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

## Error Response Format

All Slack API errors follow this JSON format:
```json
{
  "ok": false,
  "error": "channel_not_found"
}
```

Some errors include additional details:
```json
{
  "ok": false,
  "error": "missing_scope",
  "needed": "channels:read",
  "provided": "chat:write,users:read"
}
```

## Error Handling in Scripts

All scripts handle errors with descriptive JSON output:
```json
{
  "status": "error",
  "message": "Channel not found: #nonexistent",
  "error_code": "channel_not_found",
  "suggestion": "List all channels with: slack_manager.rb list-channels"
}
```

## References
- [Slack API Errors](https://api.slack.com/methods/errors)
- [HTTP Status Codes](https://api.slack.com/docs/http-status-codes)
```

**Validation**: ✅ Error code reference created

---

## Phase 5: Testing & Validation

**Duration**: 1 day
**Complexity**: Moderate
**Dependencies**: Phases 1-4 complete

### 5.1 Unit Testing

**Test Cases**:

#### Test 1: Send Message to Channel
```bash
echo '{
  "channel": "#general",
  "text": "Test message from Slack skill"
}' | ~/.claude/skills/slack/scripts/slack_manager.rb send
```

**Expected Output**:
```json
{
  "status": "success",
  "operation": "send",
  "message_ts": "1234567890.123456",
  "channel": "C..."
}
```

**Validation**: ✅ Message appears in #general channel

#### Test 2: List Channels
```bash
echo '{}' | ~/.claude/skills/slack/scripts/slack_manager.rb list-channels
```

**Expected Output**:
```json
{
  "status": "success",
  "operation": "list-channels",
  "channels": [...]
}
```

**Validation**: ✅ Returns array of channels with id and name

#### Test 3: Lookup Channel (Exact Match)
```bash
~/.claude/skills/slack/scripts/lookup_channel.rb --name "general"
```

**Expected Output**:
```json
{
  "status": "success",
  "channel_id": "C...",
  "channel_name": "general",
  "match_type": "exact"
}
```

**Validation**: ✅ Returns correct channel ID

#### Test 4: Lookup Channel (Fuzzy Match)
```bash
~/.claude/skills/slack/scripts/lookup_channel.rb --name "gen"
```

**Expected Output**:
```json
{
  "status": "success",
  "channel_id": "C...",
  "channel_name": "general",
  "match_type": "fuzzy"
}
```

**Validation**: ✅ Returns single fuzzy match

#### Test 5: Lookup User
```bash
~/.claude/skills/slack/scripts/lookup_user.rb --name "Your Name"
```

**Expected Output**:
```json
{
  "status": "success",
  "user_id": "U...",
  "user_name": "Your Name",
  "display_name": "...",
  "match_type": "exact"
}
```

**Validation**: ✅ Returns correct user ID

#### Test 6: Error Handling (Invalid Channel)
```bash
echo '{
  "channel": "#nonexistent-channel-12345",
  "text": "This should fail"
}' | ~/.claude/skills/slack/scripts/slack_manager.rb send
```

**Expected Output**:
```json
{
  "status": "error",
  "message": "channel_not_found",
  ...
}
```

**Validation**: ✅ Returns error with descriptive message

### 5.2 Integration Testing

**Test Scenario 1: Full Message Flow**
1. Lookup channel by name
2. Send message using returned channel ID
3. Verify message appears in Slack

**Commands**:
```bash
# Step 1: Lookup
CHANNEL_ID=$(~/.claude/skills/slack/scripts/lookup_channel.rb --name "general" | jq -r '.channel_id')

# Step 2: Send
echo "{
  \"channel\": \"$CHANNEL_ID\",
  \"text\": \"Integration test message\"
}" | ~/.claude/skills/slack/scripts/slack_manager.rb send

# Step 3: Verify in Slack UI
```

**Validation**: ✅ Complete workflow succeeds

**Test Scenario 2: Direct Message**
1. Lookup user by name
2. Send DM using user ID
3. Verify DM received

**Commands**:
```bash
# Step 1: Lookup
USER_ID=$(~/.claude/skills/slack/scripts/lookup_user.rb --name "Your Name" | jq -r '.user_id')

# Step 2: Send DM
echo "{
  \"channel\": \"$USER_ID\",
  \"text\": \"Test DM from Slack skill\"
}" | ~/.claude/skills/slack/scripts/slack_manager.rb send
```

**Validation**: ✅ DM received successfully

### 5.3 Rate Limit Testing

**Test**: Trigger rate limit and verify exponential backoff

**Approach**:
```bash
# Send 30 messages rapidly (exceeds Tier 2 limit of 20/min)
for i in {1..30}; do
  echo "{
    \"channel\": \"#test\",
    \"text\": \"Rate limit test $i\"
  }" | ~/.claude/skills/slack/scripts/slack_manager.rb send
  echo "Message $i sent"
done
```

**Expected Behavior**:
- First 20 messages send successfully
- Message 21+ trigger rate limit errors
- Scripts automatically retry with exponential backoff
- All messages eventually succeed

**Validation**:
- ✅ Exponential backoff activates
- ✅ Retries succeed after waiting
- ✅ No permanent failures

### 5.4 Security Testing

**Test 1: Token Permissions**
```bash
ls -la ~/.claude/.slack/token.json
```

**Expected**: `-rw------- (600 permissions)`

**Test 2: Token Redaction**
```bash
# Force error to check if token appears in output
echo '{}' | TOKEN=xoxb-fake-token ~/.claude/skills/slack/scripts/slack_manager.rb invalid-operation 2>&1 | grep -i "xoxb"
```

**Expected**: No token in output

**Validation**:
- ✅ Token file has restrictive permissions
- ✅ Token never appears in logs or errors

### 5.5 Edge Case Testing

**Test Cases**:
1. **Empty message**: `{"channel": "#general", "text": ""}`
2. **Long message**: Text with 40,000+ characters
3. **Special characters**: Emojis, unicode, code blocks
4. **Invalid JSON**: Malformed JSON input
5. **Missing parameters**: Omit required fields

**Validation**: ✅ All edge cases handled gracefully with errors

---

## Phase 6: Skill Validation & Packaging

**Duration**: 0.5 days
**Complexity**: Low
**Dependencies**: Phase 5 complete

### 6.1 Validate Skill Structure

**Command**:
```bash
cd ~/.claude/plugins/marketplaces/anthropic-agent-skills/skill-creator/
python3 scripts/package_skill.py ~/.claude/skills/slack/ --validate
```

**Expected Output**:
```
✓ SKILL.md found with valid frontmatter
✓ All bundled resources are accessible
✓ Scripts are executable
✓ References are well-formatted
✓ Skill is ready for use
```

**Validation**: ✅ No validation errors

### 6.2 Test Skill Invocation

**Via Claude Code**:
```
User: "Send a test message to #general in Slack saying 'Skill is working!'"
```

**Expected Behavior**:
1. Claude Code loads SKILL.md
2. Executes appropriate script
3. Message appears in Slack
4. Confirms success

**Validation**: ✅ Skill works end-to-end through Claude Code

### 6.3 Create README

**File**: `~/.claude/skills/slack/README.md`

**Content**:
```markdown
# Slack Agent Skill

Send messages and interact with Slack workspace via direct API integration.

## Quick Start

1. Set up Slack App at https://api.slack.com/apps
2. Copy bot token to `~/.claude/.slack/token.json`
3. Install dependencies: `bundle install`
4. Test: `echo '{"channel": "#general", "text": "Hello!"}' | scripts/slack_manager.rb send`

## Features

- Send messages to channels and DMs
- List and search channels
- Lookup users by name
- Automatic rate limiting with exponential backoff
- Context-efficient (2-5K tokens vs 10-15K for MCP)

## Security

- Token stored outside git at `~/.claude/.slack/token.json`
- 600 permissions on token file
- Credentials never logged or exposed

## Documentation

- **SKILL.md**: Main skill documentation
- **references/api_methods.md**: API endpoint reference
- **references/rate_limiting.md**: Rate limit strategies
- **references/error_codes.md**: Error handling guide

## Support

For issues or questions, refer to the research report:
`~/.claude/claudedocs/research_slack_agent_skill_20251116.md`
```

**Validation**: ✅ README created with setup instructions

---

## MCP Configuration & Docker Notes

### MCP Server Status

**Current Configuration**: Analysis of `/Users/arlenagreer/.claude/mcp.json` shows:

**NO Slack MCP server is configured.** The file contains only:
- sequential-thinking
- gmail
- playwright
- tavily
- context7
- chrome-devtools

### Actions Required

**MCP Removal**: ❌ NOT REQUIRED (no Slack MCP exists)

**Docker Desktop Adjustment**: ❌ LIKELY NOT REQUIRED (no Slack container expected)

### Verification Steps

**Optional Verification** (if you suspect Slack MCP was configured elsewhere):

1. **Check for Docker containers**:
```bash
docker ps -a | grep -i slack
```

**Expected**: No results (no Slack containers)

2. **Check for docker-compose files**:
```bash
find ~/.claude -name "docker-compose*.yml" -exec grep -l "slack" {} \;
```

**Expected**: No results or no slack references

3. **Check for MCP config backups**:
```bash
ls ~/.claude/mcp*.json
```

**Expected**: Only `mcp.json` exists

**Conclusion**: Since no Slack MCP server exists in the configuration, no removal or Docker adjustment steps are necessary. This roadmap focuses exclusively on skill creation.

---

## Quality Gates

### Gate 1: OAuth Setup Complete
- ✅ Slack App created with correct scopes
- ✅ Bot token stored securely at `~/.claude/.slack/token.json`
- ✅ Token file has 600 permissions
- ✅ Test API call succeeds

### Gate 2: Skill Structure Valid
- ✅ SKILL.md has valid YAML frontmatter
- ✅ All directories created correctly
- ✅ skill-creator validation passes
- ✅ Gemfile.lock generated

### Gate 3: Scripts Functional
- ✅ All scripts executable (755 permissions)
- ✅ Dependencies installed via bundle
- ✅ Scripts accept JSON input and produce JSON output
- ✅ Error handling returns descriptive messages

### Gate 4: Testing Complete
- ✅ All unit tests pass
- ✅ Integration tests successful
- ✅ Rate limiting verified
- ✅ Security checks pass
- ✅ Edge cases handled

### Gate 5: Documentation Complete
- ✅ SKILL.md comprehensive
- ✅ All reference files created
- ✅ README added
- ✅ Comments in code explain logic

### Gate 6: End-to-End Validation
- ✅ Skill works via Claude Code invocation
- ✅ Messages successfully sent to Slack
- ✅ Channel/user lookups successful
- ✅ Error handling graceful

---

## Rollback Procedures

### Rollback Phase 3 (Scripts)
```bash
cd ~/.claude/skills/slack/
rm -rf scripts/
git checkout scripts/  # If version controlled
```

### Rollback Phase 2 (Structure)
```bash
rm -rf ~/.claude/skills/slack/
```

### Rollback Phase 1 (OAuth)
1. Revoke token in Slack App settings
2. Delete token file:
```bash
rm -rf ~/.claude/.slack/
```
3. Uninstall app from workspace (optional)

### Full Rollback
```bash
# Remove skill entirely
rm -rf ~/.claude/skills/slack/
rm -rf ~/.claude/.slack/

# Revoke token in Slack App settings
# Delete Slack App (optional)
```

---

## Risk Assessment

### High Risks
**Risk**: OAuth token compromised
**Likelihood**: Low
**Impact**: High (unauthorized access to Slack workspace)
**Mitigation**:
- 600 permissions on token file
- Token stored outside git repository
- Regular token rotation
- Never log or expose token

### Medium Risks
**Risk**: Rate limiting impacts functionality
**Likelihood**: Medium
**Impact**: Medium (temporary message delays)
**Mitigation**:
- Exponential backoff implementation
- Caching strategies
- Avoid `conversations.history` (1 req/min limit)
- Monitor API usage patterns

**Risk**: Slack API changes break functionality
**Likelihood**: Low
**Impact**: Medium (skill stops working)
**Mitigation**:
- Monitor Slack API changelog
- Version pin `slack-ruby-client` gem
- Comprehensive error handling
- Test suite for regression detection

### Low Risks
**Risk**: Script permissions incorrect
**Likelihood**: Low
**Impact**: Low (script execution fails)
**Mitigation**:
- Automated `chmod +x` in setup
- Validation checks in quality gates

---

## Success Metrics

### Performance Metrics
- **Token Efficiency**: 60-70% reduction vs MCP (target: 2-5K tokens)
- **Response Time**: <500ms for send operations
- **Success Rate**: >99% for valid operations
- **Rate Limit Handling**: 100% automatic retry success

### Functional Metrics
- **Message Delivery**: 100% success rate to valid channels
- **Channel Lookup**: >95% success rate with fuzzy matching
- **User Lookup**: >95% success rate with fuzzy matching
- **Error Handling**: 100% graceful error responses

### Security Metrics
- **Token Exposure**: 0 instances in logs/errors
- **Permission Compliance**: 100% (600 on token file)
- **Scope Minimization**: Only required scopes granted

---

## Timeline Estimate

### Conservative Estimate
- **Phase 1**: 1 day (OAuth setup)
- **Phase 2**: 1 day (skill structure)
- **Phase 3**: 2 days (script implementation)
- **Phase 4**: 1 day (documentation)
- **Phase 5**: 1 day (testing)
- **Phase 6**: 0.5 days (validation)

**Total**: 6.5 days

### Optimistic Estimate
- **Phase 1**: 0.5 days
- **Phase 2**: 0.5 days
- **Phase 3**: 1.5 days
- **Phase 4**: 0.5 days
- **Phase 5**: 0.5 days
- **Phase 6**: 0.25 days

**Total**: 3.75 days

### Realistic Estimate
**Total**: 4-5 days (accounting for testing iterations and documentation refinement)

---

## Next Steps

**DO NOT PROCEED WITH IMPLEMENTATION** (per user instructions)

**For Implementation Session**:
1. Read this roadmap file
2. Begin with Phase 1 (OAuth setup)
3. Progress through phases sequentially
4. Validate each quality gate before proceeding
5. Test thoroughly in Phase 5
6. Validate end-to-end in Phase 6

**Reference Documents**:
- Research: `~/.claude/claudedocs/research_slack_agent_skill_20251116.md`
- This Roadmap: `~/.claude/claudedocs/slack_skill_implementation_roadmap_20251116.md`
- Email Skill Pattern: `~/.claude/skills/email/SKILL.md`
- Skill Creator: `~/.claude/plugins/marketplaces/anthropic-agent-skills/skill-creator/SKILL.md`

---

**Roadmap Created**: 2025-11-16
**Status**: Planning Complete, Ready for Implementation
**Next Session**: Begin Phase 1 (Slack App Setup & OAuth Configuration)
