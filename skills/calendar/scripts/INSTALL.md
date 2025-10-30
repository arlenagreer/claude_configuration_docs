# Calendar Skill Installation

## Ruby Requirements

This skill requires Ruby 3.0 or later due to Google API gem dependencies.

### Check Your Ruby Version

```bash
ruby --version
```

If you see `ruby 2.x.x`, you need to upgrade or use rbenv to switch versions.

### Option 1: Using rbenv (Recommended)

If you have rbenv installed with Ruby 3.x available:

```bash
# Check available versions
rbenv versions

# If you have Ruby 3.x (e.g., 3.3.7), create a wrapper
# The calendar_manager.rb script will automatically use the correct Ruby version
```

### Option 2: System Ruby Upgrade

If you don't have rbenv or prefer system Ruby:

```bash
# macOS with Homebrew
brew install ruby

# Add to PATH in ~/.zshrc or ~/.bashrc:
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
```

## Required Gems

Install the required Google API gems:

```bash
# For Ruby 3.x
gem install google-apis-calendar_v3 google-apis-people_v1 googleauth --user-install

# Or if using rbenv
RBENV_VERSION=3.3.7 gem install google-apis-calendar_v3 google-apis-people_v1 googleauth --user-install
```

## Authentication Setup

The calendar skill shares authentication with the email skill:

1. **Credentials file**: `~/.claude/.google/client_secret.json`
2. **Token file**: `~/.claude/.google/token.json`

If you already have the email skill set up, no additional authentication is needed! The calendar skill will use the same credentials.

### First-Time Google Cloud Console Setup

If you don't have `client_secret.json` yet:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable APIs:
   - Google Calendar API
   - Google People API (for contacts)
4. Create OAuth 2.0 credentials:
   - Application type: Desktop app
   - Download credentials JSON
5. Save as `~/.claude/.google/client_secret.json`

### Authorization Flow

First time running any calendar operation:

```bash
scripts/calendar_manager.rb --operation list
```

1. Script will display authorization URL
2. Visit URL in browser
3. Authorize the application
4. Copy authorization code
5. Paste code into terminal
6. Token saved to `~/.claude/.google/token.json`

Future operations will use the saved token automatically.

## Testing Installation

### Test 1: Help Command

```bash
cd /Users/arlenagreer/.claude/skills/calendar
scripts/calendar_manager.rb --help
```

Should display usage information without errors.

### Test 2: List Events

```bash
scripts/calendar_manager.rb --operation list
```

Should either:
- Display today's calendar events (if authorized)
- OR prompt for authorization (first time)

### Test 3: Find Free Time

```bash
scripts/calendar_manager.rb --operation find_free \
  --time-min "$(date -u +%Y-%m-%dT00:00:00)" \
  --time-max "$(date -u -v+7d +%Y-%m-%dT23:59:59)"
```

Should display available time slots.

## Troubleshooting

### "cannot load such file -- google/apis/calendar_v3"

**Problem**: Google Calendar API gem not installed

**Solution**:
```bash
gem install google-apis-calendar_v3 --user-install
```

### "Ruby version >= 3.0 required"

**Problem**: Using Ruby 2.x

**Solution**: Upgrade to Ruby 3.x or use rbenv:
```bash
rbenv install 3.3.7
rbenv local 3.3.7  # In skill directory
```

### "Credentials file not found"

**Problem**: Missing `~/.claude/.google/client_secret.json`

**Solution**: Follow "First-Time Google Cloud Console Setup" above

### "Token refresh failed"

**Problem**: Saved token expired or invalid

**Solution**: Delete token and re-authorize:
```bash
rm ~/.claude/.google/token.json
scripts/calendar_manager.rb --operation list
# Follow authorization flow
```

### "Attendee not found"

**Problem**: Contact name lookup failed

**Solution**: Use email address instead of name, or add contact to Google Contacts

## Ruby Version Detection

The script includes Ruby version detection. If you have rbenv installed with Ruby 3.x, the script will automatically attempt to use it.

To force a specific Ruby version:

```bash
RBENV_VERSION=3.3.7 scripts/calendar_manager.rb --operation list
```

Or create a `.ruby-version` file in the skills/calendar directory:

```bash
echo "3.3.7" > /Users/arlenagreer/.claude/skills/calendar/.ruby-version
```

## Verification Checklist

- [ ] Ruby 3.0+ installed and accessible
- [ ] Google Calendar API gem installed
- [ ] Google People API gem installed
- [ ] Googleauth gem installed
- [ ] Credentials file exists: `~/.claude/.google/client_secret.json`
- [ ] Script help command works
- [ ] Authorization flow completed (or token exists)
- [ ] Can list calendar events
- [ ] Can find free time slots

## Support

If you encounter issues not covered here, check:
1. Ruby version: `ruby --version` (must be >= 3.0)
2. Gem installation: `gem list | grep google-apis`
3. Credentials permissions: `ls -la ~/.claude/.google/`
4. Script permissions: `ls -la scripts/calendar_manager.rb` (should be executable)

For skill-specific help:
```bash
scripts/calendar_manager.rb --help
```
