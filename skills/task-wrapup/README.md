# Task Wrap-Up Skill

**Comprehensive work session wrap-up orchestrator** for professional project communication and record-keeping.

## Quick Start

### 1. Invoke the Skill
```
User: "Wrap up this session"
```

### 2. First-Time Setup
If no configuration exists, you'll be prompted to create one:
- Project name
- Email recipients (first name, last name, email)
- SMS recipients (first name, last name, phone with E.164 format)
- Slack channel (optional)
- Worklog settings

### 3. Review & Confirm
The skill will:
- Generate summary from git commits and file changes
- Display preview of content and distribution plan
- Allow you to edit, customize, or modify before sending

### 4. Send Notifications
Parallel execution across all configured channels:
- 📧 Email (group message with seasonal theming)
- 💬 SMS (individual messages to each recipient)
- 💼 Slack (channel post with optional mentions)
- ⏱️ Worklog (billable hours entry)
- 📝 Documentation (README/CHANGELOG updates)

## Features

✅ **Intelligent Summary Generation**
- Analyzes git commits from last 12 hours
- Extracts key points and file statistics
- Generates both full and concise versions
- Supports user-provided custom summaries

✅ **Multi-Channel Communication**
- Email with professional seasonal HTML formatting
- SMS with E.164 phone format and apostrophe handling
- Slack with channel posts and @mentions
- All channels execute in parallel for speed

✅ **Interactive Preview**
- Review content before sending
- Edit summaries or customize per channel
- Modify distribution settings
- Cancel anytime

✅ **Time Tracking**
- Worklog integration for billable hours
- Date-aware logging (checks system clock)
- Configurable duration prompting
- Client association from project name

✅ **Documentation Updates**
- Append to CHANGELOG
- Update README sections
- Create new sections as needed
- Smart merge strategy

✅ **Per-Project Configuration**
- Configuration file in project directory (`.task_wrapup_skill_data.json`)
- Auto-migration for schema updates
- Separate recipient lists per project
- Customizable behavior per project

✅ **Extension Architecture**
- Core integrations: email, SMS, worklog
- Optional integrations: Slack, Calendar, GitHub
- Future extensions: Discord, Teams, JIRA, Asana, Linear
- Plugin system for custom integrations

## File Structure

```
~/.claude/skills/task-wrapup/
├── SKILL.md                          # Main orchestrator documentation
├── README.md                         # This file
├── scripts/
│   ├── config_manager.py             # Configuration CRUD operations
│   ├── summary_generator.py          # Intelligent summary generation
│   ├── preview_interface.py          # Interactive preview workflow
│   └── notification_dispatcher.py    # Parallel notification execution
├── extensions/
│   ├── README.md                     # Extension architecture guide
│   ├── base.py                       # Base extension interface
│   ├── core/                         # Core integrations (required)
│   ├── optional/                     # Optional integrations
│   └── future/                       # Planned extensions
└── templates/                        # Message templates (future)
```

## Configuration

Configuration is stored in `.task_wrapup_skill_data.json` in your project directory (NOT in ~/.claude/skills/).

### Example Configuration

```json
{
  "schema_version": "1.0",
  "project_name": "MyProject",

  "communication": {
    "email": {
      "enabled": true,
      "recipients": [
        {"first_name": "John", "last_name": "Doe", "email": "john@example.com"}
      ]
    },
    "sms": {
      "enabled": true,
      "recipients": [
        {"first_name": "Jane", "last_name": "Smith", "phone": "+15551234567"}
      ],
      "max_length": 320
    },
    "slack": {
      "enabled": false,
      "channel": "project-updates"
    }
  },

  "worklog": {
    "enabled": true,
    "prompt_for_duration": true
  },

  "documentation": {
    "enabled": true,
    "paths": ["README.md"],
    "strategy": "smart_merge"
  }
}
```

### Managing Configuration

#### Create New Config
```bash
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py \
  create --project-name "MyProject" --directory .
```

#### View Current Config
```bash
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py \
  show --directory .
```

#### Add Email Recipient
```bash
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py \
  add-recipient --type email \
  --first-name John --last-name Doe \
  --contact john@example.com
```

#### Add SMS Recipient
```bash
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py \
  add-recipient --type sms \
  --first-name Jane --last-name Smith \
  --contact +15551234567
```

## Usage Examples

### Basic Wrap-Up
```
User: "Wrap up this work session"
```

Generates summary from git commits, shows preview, sends to all configured channels.

### Custom Summary
```
User: "Wrap up with summary: Completed authentication system with OAuth2 integration, added comprehensive tests, updated API documentation"
```

Uses your custom summary instead of auto-generated.

### Worklog Only
```
User: "Just log my work time"
```

Disable email/SMS in config, keep only worklog enabled.

### With Calendar Event
```
User: "Wrap up and schedule demo for tomorrow"
```

Enables optional calendar integration.

## Integration with Other Skills

### Email Skill
- Path: `~/.claude/skills/email/SKILL.md`
- Provides seasonal HTML theming, authentic writing style
- Shares OAuth token at `~/.claude/.google/token.json`

### Text-Message Skill
- Path: `~/.claude/skills/text-message/SKILL.md`
- Individual messages (NEVER group texts)
- E.164 phone format required: `+1XXXXXXXXXX`
- Removes apostrophes for AppleScript compatibility

### Worklog Skill
- Path: `~/.claude/skills/worklog/SKILL.md`
- Billable hours tracking
- Date-aware logging (checks system clock)
- Client association from project name

### Calendar Skill (Optional)
- Path: `~/.claude/skills/calendar/SKILL.md`
- Event creation and reminders
- Date-aware scheduling

### Contacts Skill
- Automatic contact lookup for email addresses and phone numbers
- Resolves names to contact information

## Error Handling

| Error | Cause | Recovery |
|-------|-------|----------|
| Missing Config | No `.task_wrapup_skill_data.json` | Prompts for configuration info |
| Email Failure | Gmail API error or network issue | Logs error, continues with other channels |
| SMS Failure | Invalid phone format or Messages unavailable | Shows failed recipients for manual retry |
| Worklog Failure | Missing client or invalid date | Displays error, offers retry or skip |
| Git Unavailable | Not a git repository | Uses fallback summary generation |

## Critical Implementation Notes

### Phone Format (SMS)
- **Required**: E.164 format (`+1XXXXXXXXXX`)
- **Validation**: Check format before sending
- **Contact Lookup**: Uses contacts skill for name resolution

### Message Types
- **Email**: Group messages allowed
- **SMS**: Individual messages only (NEVER group text)
- **Slack**: Single channel post with optional @mentions

### Date Handling
- **Worklog**: Always check system clock for current date
- **Calendar**: Support relative dates ("tomorrow", "next week")
- **No business-day filtering**: Includes weekends

### Security
- Configuration file may contain sensitive data (emails, phones)
- Add `.task_wrapup_skill_data.json` to `.gitignore`
- Never commit configuration to version control

## Extension Development

See `extensions/README.md` for:
- Extension architecture guide
- Interface specification
- Creating new extensions
- Configuration patterns
- Testing guidelines

Planned extensions:
- Discord webhook notifications
- Microsoft Teams integration
- JIRA issue creation
- Asana task updates
- Linear integration
- Notion page updates

## Troubleshooting

### Configuration Not Found
```bash
# Create new configuration
cd /path/to/your/project
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py \
  create --project-name "YourProject"
```

### SMS Not Sending
- Verify E.164 phone format: `+1XXXXXXXXXX`
- Check macOS Messages app permissions
- Ensure Messages automation enabled in System Preferences

### Email Not Sending
- Check Gmail OAuth token at `~/.claude/.google/token.json`
- Verify email skill is working: `@~/.claude/skills/email/SKILL.md "test"`
- Check recipient email addresses are valid

### Worklog Date Issues
- Ensure system clock is correct
- Check timezone in config: `"timezone": "America/New_York"`
- Verify worklog skill is functioning

### No Git Summary
- Not a git repository: Use custom summary
- No recent commits: Provide manual summary
- Git command timeout: Check git installation

## Version History

**v1.0.0** (2025-11-14)
- Initial release
- Core features: email, SMS, Slack, worklog, documentation
- Intelligent summary generation from git commits
- Interactive preview and confirmation workflow
- Parallel notification dispatch
- Per-project configuration with auto-migration
- Extension plugin architecture

## License

MIT License - Part of Claude Code SuperClaude Framework

## Support

For issues or questions:
1. Check this README and `SKILL.md`
2. Review `extensions/README.md` for extension help
3. Test individual scripts with `--help` flag
4. Check configuration with `validate` command

---

**Quick Reference Commands**

```bash
# Create config
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py create --project-name "MyProject"

# Show config
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py show

# Validate config
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py validate

# Test summary generation
python3 ~/.claude/skills/task-wrapup/scripts/summary_generator.py \
  --config .task_wrapup_skill_data.json --format full

# Add recipient
python3 ~/.claude/skills/task-wrapup/scripts/config_manager.py add-recipient \
  --type email --first-name John --last-name Doe --contact john@example.com
```
