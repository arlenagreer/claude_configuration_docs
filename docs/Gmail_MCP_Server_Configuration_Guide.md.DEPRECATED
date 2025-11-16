# Gmail MCP Server Configuration Guide

## Overview

The Gmail MCP server allows Claude Code to interact with Gmail through the Model Context Protocol (MCP). This guide provides comprehensive instructions for setting up the `@gongrzhe/server-gmail-autoauth-mcp` package in your projects.

## Package Information

- **Package Name**: `@gongrzhe/server-gmail-autoauth-mcp`
- **NPM URL**: https://www.npmjs.com/package/@gongrzhe/server-gmail-autoauth-mcp
- **GitHub**: https://github.com/GongRzhe/Gmail-MCP-Server
- **Latest Version**: 1.1.8 (as of documentation date)

## Features

The Gmail MCP server provides:
- Send emails with attachments
- Read email messages and download attachments
- Search emails with various criteria
- Manage Gmail labels (create, update, delete)
- Batch operations for emails
- Full international character support
- Auto-authentication with OAuth2

## Prerequisites

1. **Google Cloud Platform (GCP) OAuth Credentials**
   - Create a project in Google Cloud Console
   - Enable Gmail API for your project
   - Create OAuth 2.0 credentials (Desktop or Web application)
   - Download the credentials as `gcp-oauth.keys.json`

2. **Node.js and NPM**
   - Ensure you have Node.js installed (v14 or higher recommended)
   - NPM comes bundled with Node.js

## Installation and Setup

### Step 1: Configure MCP in Your Project

Add the Gmail server to your project's `.mcp.json` file:

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

**Note**: The `-y` flag ensures the package runs without installation prompts.

### Step 2: Set Up OAuth Authentication

#### Option A: Global Configuration (Recommended)

1. Create the Gmail MCP directory in your home folder:
   ```bash
   mkdir -p ~/.gmail-mcp
   ```

2. Copy your OAuth credentials:
   ```bash
   cp /path/to/your/gcp-oauth.keys.json ~/.gmail-mcp/
   ```

3. Run the authentication command:
   ```bash
   npx @gongrzhe/server-gmail-autoauth-mcp auth
   ```

4. Follow the browser authentication flow

#### Option B: Local Configuration

1. Place `gcp-oauth.keys.json` in your current directory

2. Run authentication:
   ```bash
   npx @gongrzhe/server-gmail-autoauth-mcp auth
   ```

   The credentials will be automatically copied to the global config location.

### Step 3: OAuth Redirect URI Configuration

For **Web application** credentials:
- Add `http://localhost:3000/oauth2callback` to your authorized redirect URIs in Google Cloud Console

For **Desktop application** credentials:
- No additional redirect URI configuration needed

## Usage in Claude Code

Once configured, Claude Code can use Gmail functions through the MCP integration:

### Available Functions

- `mcp__gmail__send_email` - Send new emails
- `mcp__gmail__draft_email` - Create email drafts
- `mcp__gmail__read_email` - Read specific emails
- `mcp__gmail__search_emails` - Search emails with Gmail query syntax
- `mcp__gmail__modify_email` - Modify email labels
- `mcp__gmail__delete_email` - Delete emails
- `mcp__gmail__list_email_labels` - List all Gmail labels
- `mcp__gmail__batch_modify_emails` - Batch modify multiple emails
- `mcp__gmail__batch_delete_emails` - Batch delete multiple emails
- `mcp__gmail__create_label` - Create new labels
- `mcp__gmail__update_label` - Update existing labels
- `mcp__gmail__delete_label` - Delete labels
- `mcp__gmail__get_or_create_label` - Get or create a label
- `mcp__gmail__download_attachment` - Download email attachments

## Troubleshooting

### Common Issues

1. **Authentication Failures**
   - Ensure your OAuth credentials are valid
   - Check that Gmail API is enabled in your GCP project
   - Verify redirect URIs match your credential type

2. **MCP Connection Issues**
   - Verify Node.js is installed: `node --version`
   - Check if the package runs manually: `npx @gongrzhe/server-gmail-autoauth-mcp`
   - Look for error messages in Claude Code logs

3. **Permission Errors**
   - Ensure the authenticated account has necessary Gmail permissions
   - Re-run the authentication process if permissions have changed

### Debug Commands

Test the Gmail MCP server directly:
```bash
# Test authentication status
npx @gongrzhe/server-gmail-autoauth-mcp auth

# Run the server manually to see output
npx @gongrzhe/server-gmail-autoauth-mcp
```

## Advanced Configuration

### Docker Deployment

For containerized environments:

```json
{
  "mcpServers": {
    "gmail": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-v", "mcp-gmail:/gmail-server",
        "-e", "GMAIL_CREDENTIALS_PATH=/gmail-server/credentials.json",
        "mcp/gmail"
      ]
    }
  }
}
```

### Cloud Server Deployment

For cloud environments with custom domains:

1. Set up authentication with custom callback:
   ```bash
   npx @gongrzhe/server-gmail-autoauth-mcp auth https://yourdomain.com/oauth2callback
   ```

2. Configure reverse proxy to forward to the OAuth callback port

3. Add your custom domain to Google Cloud Console authorized redirect URIs

## Security Considerations

1. **Credential Storage**
   - OAuth credentials are stored in `~/.gmail-mcp/credentials.json`
   - Keep your `gcp-oauth.keys.json` file secure
   - Never commit OAuth credentials to version control

2. **Permissions**
   - The MCP server requests full Gmail access
   - Consider using a dedicated Gmail account for automation
   - Regularly review OAuth permissions in Google Account settings

3. **Token Refresh**
   - Tokens are automatically refreshed by the server
   - Re-authentication may be needed if tokens expire

## Best Practices

1. **Project Structure**
   - Keep `.mcp.json` in your project root
   - Add `gcp-oauth.keys.json` to `.gitignore`
   - Document Gmail-specific functionality in your project README

2. **Error Handling**
   - Implement proper error handling for email operations
   - Check for rate limits when performing bulk operations
   - Log email operations for debugging

3. **Testing**
   - Use a test Gmail account for development
   - Create email fixtures for consistent testing
   - Mock Gmail operations in unit tests

## Example Project Structure

```
your-project/
├── .mcp.json              # MCP configuration with Gmail server
├── .gitignore             # Include gcp-oauth.keys.json
├── CLAUDE.md              # Project-specific Claude instructions
├── README.md              # Document Gmail integration
└── src/
    └── email/             # Email-related functionality
        ├── templates/     # Email templates
        └── handlers/      # Email handling logic
```

## Additional Resources

- [Gmail API Documentation](https://developers.google.com/gmail/api)
- [Google Cloud Console](https://console.cloud.google.com)
- [MCP Documentation](https://modelcontextprotocol.io)
- [Claude Code Documentation](https://docs.anthropic.com/claude/docs/claude-code)

---

## Quick Reference

### Minimal Setup Steps

1. Add to `.mcp.json`:
   ```json
   {
     "mcpServers": {
       "gmail": {
         "command": "npx",
         "args": ["-y", "@gongrzhe/server-gmail-autoauth-mcp"]
       }
     }
   }
   ```

2. Get OAuth credentials from Google Cloud Console

3. Authenticate:
   ```bash
   mkdir -p ~/.gmail-mcp
   cp gcp-oauth.keys.json ~/.gmail-mcp/
   npx @gongrzhe/server-gmail-autoauth-mcp auth
   ```

4. Use in Claude Code with `mcp__gmail__*` functions

---

*Last updated: January 2025*