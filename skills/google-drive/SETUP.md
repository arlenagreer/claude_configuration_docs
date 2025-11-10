# Google Drive Skill Setup Guide

## Overview

The Google Drive skill shares authentication with your existing calendar and contacts skills. If you've already set up those skills, you only need to re-authorize once to add the Drive scope.

## Prerequisites

- Ruby 3.3.7 (same version used by calendar and contacts skills)
- Google OAuth credentials (`~/.claude/.google/client_secret.json`)
- Existing calendar/contacts setup (optional but recommended)

## Installation Steps

### 1. Install Required Gems

The Google Drive skill requires the `google-apis-drive_v3` gem in addition to the gems already used by calendar and contacts:

```bash
# Install the Drive API gem
gem install google-apis-drive_v3

# Verify other required gems are installed (should already be present)
gem list | grep google
```

Expected output should include:
- `google-apis-drive_v3`
- `google-apis-calendar_v3`
- `google-apis-people_v1`
- `googleauth`

### 2. Re-authorize with Drive Scope

Since the Drive scope is new, you need to re-authorize once:

```bash
# Delete existing token to force re-authorization
rm ~/.claude/.google/token.json

# Run any Drive operation to trigger OAuth flow
~/.claude/skills/google-drive/scripts/drive_manager.rb --list
```

**What happens**:
1. Script will display an authorization URL
2. Open the URL in your browser
3. Sign in to your Google account
4. Grant permissions for Drive, Calendar, and Contacts
5. Copy the authorization code
6. Paste the code into the terminal

**The new token will have all three scopes**:
- `https://www.googleapis.com/auth/drive` (Google Drive)
- `https://www.googleapis.com/auth/calendar` (Google Calendar)
- `https://www.googleapis.com/auth/contacts` (Google Contacts)

### 3. Verify Setup

Test that everything works:

```bash
# List your Drive files
~/.claude/skills/google-drive/scripts/drive_manager.rb --list

# Check the script version
~/.claude/skills/google-drive/scripts/drive_manager.rb --version
```

If successful, you'll see a JSON response with your Drive files.

### 4. Test Calendar and Contacts Still Work

After re-authorizing, verify your other skills still work:

```bash
# Test calendar
~/.claude/skills/calendar/scripts/calendar_manager.rb --operation list

# Test contacts
~/.claude/skills/contacts/scripts/contacts_manager.rb --list
```

All three skills should now work seamlessly with the shared token.

## Shared Authentication Architecture

### File Locations

**Credentials** (never changes):
- Location: `~/.claude/.google/client_secret.json`
- Contains: OAuth 2.0 client ID and secret
- Shared by: All Google skills

**Token** (refreshed automatically):
- Location: `~/.claude/.google/token.json`
- Contains: Access token, refresh token, scopes
- Shared by: All Google skills
- Auto-refreshes: When expired

### How It Works

1. **Single Authorization**: You authorize once for all three services
2. **Shared Token**: All skills use the same token file
3. **Auto-Refresh**: When any skill refreshes the token, all benefit
4. **Scope Preservation**: Token maintains all scopes (Drive, Calendar, Contacts)

### Re-authorization Scenarios

You'll need to re-authorize if:
- Adding new scopes (like this Drive scope)
- Token refresh fails
- Credentials are revoked in Google Account settings
- Token file is deleted or corrupted

**How to re-authorize**:
```bash
rm ~/.claude/.google/token.json
# Then run any operation from any skill
```

## Troubleshooting

### Error: "Credentials file not found"

**Problem**: `client_secret.json` doesn't exist

**Solution**:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create OAuth 2.0 credentials (Desktop application type)
3. Download credentials JSON
4. Save to `~/.claude/.google/client_secret.json`

### Error: "Token refresh failed"

**Problem**: Existing token can't be refreshed

**Solution**: Delete token and re-authorize:
```bash
rm ~/.claude/.google/token.json
~/.claude/skills/google-drive/scripts/drive_manager.rb --list
```

### Error: "Insufficient Permission" or "Access Not Configured"

**Problem**: Token doesn't have Drive scope

**Solution**: Re-authorize to add Drive scope:
```bash
rm ~/.claude/.google/token.json
~/.claude/skills/google-drive/scripts/drive_manager.rb --list
```

### Calendar or Contacts Stopped Working

**Problem**: Token was replaced without all scopes

**Solution**: Re-authorize to restore all scopes:
```bash
rm ~/.claude/.google/token.json
# Run operation from skill that's not working
~/.claude/skills/calendar/scripts/calendar_manager.rb --operation list
```

### "Authorization failed"

**Problem**: Invalid authorization code or credentials

**Solution**:
1. Verify `client_secret.json` is correct
2. Try authorization URL again
3. Make sure to copy entire authorization code
4. Ensure you're authorizing with correct Google account

## Advanced Configuration

### Custom Token Location

To use a different token location, modify the `TOKEN_PATH` constant in each script:

```ruby
# Default
TOKEN_PATH = File.join(Dir.home, '.claude', '.google', 'token.json')

# Custom location
TOKEN_PATH = '/path/to/custom/token.json'
```

**Note**: Change in all three skills to maintain shared authentication.

### Multiple Google Accounts

To use different accounts for different skills:

1. Create separate credential files:
   - `~/.claude/.google/client_secret_work.json`
   - `~/.claude/.google/client_secret_personal.json`

2. Create separate token files:
   - `~/.claude/.google/token_work.json`
   - `~/.claude/.google/token_personal.json`

3. Modify script constants to point to appropriate files

4. Authorize each separately

## API Quotas and Limits

### Google Drive API Limits

**Queries per day**: 1,000,000,000
**Queries per 100 seconds per user**: 1,000

If you hit limits:
- Wait a few minutes
- Reduce batch operation sizes
- Implement exponential backoff

### Check Current Usage

View quota usage in [Google Cloud Console](https://console.cloud.google.com/apis/api/drive.googleapis.com/quotas)

## Security Best Practices

1. **Protect credentials file**: Never commit `client_secret.json` to version control
2. **Limit token access**: Only share token file with trusted scripts
3. **Regular rotation**: Periodically re-authorize to refresh credentials
4. **Minimal scopes**: Only request scopes you actually need
5. **Monitor access**: Check [Google Account Activity](https://myaccount.google.com/permissions)

## Next Steps

Now that setup is complete, try these operations:

```bash
# List your files
drive_manager.rb --list

# Search for a file
drive_manager.rb --search "important document"

# Upload a file
drive_manager.rb --upload "/path/to/file.pdf"

# Create a folder
drive_manager.rb --create-folder "Work Documents"

# Share a file
drive_manager.rb --share FILE_ID --email "colleague@example.com" --role reader
```

See `SKILL.md` for complete usage documentation.

## Support

If you encounter issues:

1. Check this setup guide
2. Review error messages for specific guidance
3. Verify Ruby and gem installations
4. Check Google Cloud Console for API status
5. Review OAuth consent screen configuration

## Version Information

- **Skill Version**: 1.0.0
- **Ruby Version**: 3.3.7
- **Drive API Version**: v3
- **Calendar API Version**: v3
- **Contacts API Version**: v1 (People API)
