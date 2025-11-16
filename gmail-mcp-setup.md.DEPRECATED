# Gmail MCP Tool Global Setup

The Gmail MCP tool has been successfully installed globally for all Claude Code instances.

## Configuration Details

### 1. MCP Server Configuration
Location: `/Users/arlenagreer/.claude/mcp.json`
```json
{
  "mcpServers": {
    "gmail": {
      "command": "npx",
      "args": [
        "-y",
        "@gongrzhe/server-gmail-autoauth-mcp"
      ]
    }
  }
}
```

### 2. Global Permissions
Location: `/Users/arlenagreer/.claude/settings.json`
- Added `"mcp__gmail__*"` to the `allowedTools` array

### 3. User-Level MCP Registration
The Gmail MCP tool is registered at the user level using:
```bash
claude mcp add-json gmail '{"command": "npx", "args": ["-y", "@gongrzhe/server-gmail-autoauth-mcp"]}' -s user
```

## Authentication Setup

### Initial Authentication
1. **Prepare OAuth Credentials**:
   - Get OAuth 2.0 credentials from Google Cloud Console
   - Save as `gcp-oauth.keys.json`

2. **Authentication Process**:
   ```bash
   # Create config directory
   mkdir -p ~/.gmail-mcp
   
   # Copy OAuth credentials
   cp gcp-oauth.keys.json ~/.gmail-mcp/
   
   # Ensure port 3000 is free (critical!)
   lsof -i :3000 || echo "Port 3000 is available"
   # If occupied, kill the process: kill -9 $(lsof -t -i:3000)
   
   # Run authentication
   cd ~/.gmail-mcp && npx @gongrzhe/server-gmail-autoauth-mcp auth
   ```

3. **Post-Authentication**:
   - **CRITICAL**: Restart Claude Code after authentication!
   - Verify `~/.gmail-mcp/credentials.json` contains actual tokens

### Authentication File Structure

The `~/.gmail-mcp/` directory should contain:
- `gcp-oauth.keys.json` - OAuth client credentials
- `credentials.json` - Authentication tokens (created after auth)

**Valid credentials.json structure**:
```json
{
  "access_token": "ya29...",
  "refresh_token": "1//...",
  "scope": "https://www.googleapis.com/auth/gmail.modify",
  "token_type": "Bearer",
  "expiry_date": 1234567890
}
```

## Verification

Run the following commands to verify the installation:
```bash
# List all MCP tools
claude mcp list

# Get Gmail MCP details
claude mcp get gmail

# Check authentication status
cat ~/.gmail-mcp/credentials.json | jq .
```

The Gmail tool should show:
- Scope: User (available in all your projects)
- Type: stdio
- Command: npx
- Args: -y @gongrzhe/server-gmail-autoauth-mcp

## Available Gmail MCP Functions

Once configured, the following functions are available in all Claude Code instances:
- `mcp__gmail__send_email`
- `mcp__gmail__draft_email`
- `mcp__gmail__read_email`
- `mcp__gmail__search_emails`
- `mcp__gmail__modify_email`
- `mcp__gmail__delete_email`
- `mcp__gmail__list_email_labels`
- `mcp__gmail__batch_modify_emails`
- `mcp__gmail__batch_delete_emails`
- `mcp__gmail__create_label`
- `mcp__gmail__update_label`
- `mcp__gmail__delete_label`
- `mcp__gmail__get_or_create_label`
- `mcp__gmail__download_attachment`

## Critical Troubleshooting

### "No access, refresh token, API key or refresh handler callback is set" Error

**This is the most common error!** It occurs when:
1. Authentication tokens are missing from `~/.gmail-mcp/credentials.json`
2. The file only contains OAuth client config (not actual tokens)
3. Claude Code hasn't been restarted after authentication

**Solution**:
1. Check credentials file: `cat ~/.gmail-mcp/credentials.json | jq .`
2. If missing tokens, re-authenticate:
   ```bash
   # Free up port 3000
   kill -9 $(lsof -t -i:3000) 2>/dev/null || true
   
   # Re-authenticate
   cd ~/.gmail-mcp && npx @gongrzhe/server-gmail-autoauth-mcp auth
   ```
3. **Restart Claude Code** - This is essential!

### Port 3000 Conflicts

Docker or other services often use port 3000:
```bash
# Check what's using the port
lsof -i :3000

# Kill the process
kill -9 $(lsof -t -i:3000)
```

### Token Expiration

- Tokens expire after ~7 days
- Re-authenticate when you see authentication errors
- Check token expiry: `cat ~/.gmail-mcp/credentials.json | jq .expiry_date`

### Multiple Projects Issue

If Gmail works in one project but not another:
1. Ensure the project doesn't have its own `.mcp.json` conflicting
2. Restart Claude Code in the problematic project
3. Check for project-specific MCP overrides

## Best Practices

1. **Always restart Claude Code** after any authentication changes
2. **Check port 3000** before authentication attempts
3. **Verify token structure** after authentication
4. **Monitor token expiry** - re-auth every week if needed
5. **Keep backups** of working credentials.json

## Quick Debug Checklist

When Gmail MCP fails:
- [ ] Is port 3000 free? (`lsof -i :3000`)
- [ ] Does credentials.json contain tokens? (`cat ~/.gmail-mcp/credentials.json | jq .`)
- [ ] Has Claude Code been restarted after auth?
- [ ] Are tokens expired? (check expiry_date)
- [ ] Any conflicting .mcp.json in current project?

## Notes

- The Gmail MCP tool uses OAuth2 for Gmail API access
- Authentication tokens are stored in `~/.gmail-mcp/credentials.json`
- The tool requires full Gmail access permissions
- Consider using a dedicated Gmail account for automation

---

*Last updated: January 2025 - Enhanced with troubleshooting insights*