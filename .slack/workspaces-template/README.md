# Workspace Configuration Templates

## Setup Instructions

To configure Slack workspaces for the slack agent skill:

1. **Create Slack App** (per workspace):
   - Go to https://api.slack.com/apps
   - Click "Create New App" → "From scratch"
   - Enter app name and select workspace
   - Navigate to "OAuth & Permissions"
   - Add Bot Token Scopes:
     - `chat:write`
     - `channels:read`
     - `channels:join`
     - `users:read`
     - `conversations:history`
   - Install app to workspace
   - Copy "Bot User OAuth Token" (starts with `xoxb-`)

2. **Create Workspace Configuration**:
   ```bash
   cp workspaces-template/workspace.json.template workspaces/YOUR_WORKSPACE_ID.json
   chmod 600 workspaces/YOUR_WORKSPACE_ID.json
   ```

3. **Edit Configuration File**:
   - Replace `YOUR_WORKSPACE_NAME` with workspace display name
   - Replace `workspace_id` with your workspace identifier (used in --workspace flag)
   - Replace `xoxb-YOUR-SLACK-BOT-TOKEN-HERE` with your actual bot token
   - Save the file

4. **Set Proper Permissions**:
   ```bash
   chmod 600 workspaces/*.json
   chmod 700 ../workspaces/
   ```

5. **Verify Token**:
   ```bash
   echo '{}' | ~/.claude/skills/slack/scripts/slack_manager.rb list-channels --workspace YOUR_WORKSPACE_ID
   ```

## Security Notes

- **NEVER commit workspace token files to version control**
- Token files are in `.gitignore` to prevent accidental commits
- Always use 600 permissions (read/write for owner only)
- Store tokens outside public repositories
- Rotate tokens if exposed

## Workspace IDs

The workspace_id in each configuration file must match:
- The filename (without .json extension)
- The --workspace flag value when calling scripts
- The workspace_id in workspace_mappings.json for auto-detection

## Example Workspace IDs

- `dreamanager`
- `american_laboratory_trading`
- `softtrak`
