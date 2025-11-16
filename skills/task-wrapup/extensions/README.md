# Task Wrap-Up Skill Extensions

**Plugin architecture** for extending task-wrapup functionality with additional notification channels and integrations.

## Architecture Overview

The task-wrapup skill uses a **hybrid core + extensions** architecture:

- **Core Functionality**: Email, SMS, Worklog (always available)
- **Optional Integrations**: Slack, Calendar, GitHub (configurable)
- **Future Extensions**: Discord, Teams, JIRA, Asana, Linear (pluggable)

## Extension Categories

### Core Extensions (`core/`)
Required integrations that are always available:
- `email.py` - Email via gmail_manager.rb
- `sms.py` - SMS via send_message.sh
- `worklog.py` - Time tracking via worklog_manager.py

### Optional Extensions (`optional/`)
Configurable integrations enabled per-project:
- `slack.py` - Slack notifications via API
- `calendar.py` - Google Calendar event creation
- `github.py` - GitHub issue/PR creation
- `documentation.py` - Project docs updates via /sc:document

### Future Extensions (`future/`)
Planned integrations for future releases:
- `discord.py` - Discord webhook notifications
- `teams.py` - Microsoft Teams channel posts
- `jira.py` - JIRA issue creation/updates
- `asana.py` - Asana task creation
- `linear.py` - Linear issue creation
- `notion.py` - Notion page updates

## Extension Interface

All extensions implement a common interface:

```python
class Extension:
    """Base class for task-wrapup extensions."""

    def __init__(self, config: Dict[str, Any]):
        """Initialize extension with configuration."""
        self.config = config
        self.enabled = config.get("enabled", False)

    def validate_config(self) -> tuple[bool, List[str]]:
        """Validate extension configuration.

        Returns:
            (is_valid, error_messages)
        """
        raise NotImplementedError

    def execute(self, summary: Dict[str, Any]) -> Dict[str, Any]:
        """Execute extension action.

        Args:
            summary: Generated summary with full_summary, concise_summary, etc.

        Returns:
            {
                "status": "success" | "error" | "skipped",
                "message": "Description of result",
                "details": {...}  # Extension-specific details
            }
        """
        raise NotImplementedError

    def get_name(self) -> str:
        """Return extension name for display."""
        raise NotImplementedError

    def get_description(self) -> str:
        """Return extension description."""
        raise NotImplementedError
```

## Creating a New Extension

### Step 1: Create Extension File

Create `extensions/future/your_extension.py`:

```python
#!/usr/bin/env python3
"""
Your Extension for Task Wrap-Up Skill

Description of what this extension does.
"""

import json
from typing import Dict, List, Any, Optional


class YourExtension:
    """Your extension implementation."""

    def __init__(self, config: Dict[str, Any]):
        self.config = config.get("your_extension", {})
        self.enabled = self.config.get("enabled", False)

    def validate_config(self) -> tuple[bool, List[str]]:
        """Validate configuration."""
        errors = []

        if self.enabled:
            # Check required fields
            if not self.config.get("api_key"):
                errors.append("API key is required")

            if not self.config.get("channel"):
                errors.append("Channel is required")

        return len(errors) == 0, errors

    def execute(self, summary: Dict[str, Any]) -> Dict[str, Any]:
        """Execute extension action."""
        if not self.enabled:
            return {
                "status": "skipped",
                "message": "Extension disabled"
            }

        try:
            # Your implementation here
            # Use summary["full_summary"] or summary["concise_summary"]

            return {
                "status": "success",
                "message": "Action completed",
                "details": {
                    # Your response details
                }
            }

        except Exception as e:
            return {
                "status": "error",
                "message": str(e)
            }

    def get_name(self) -> str:
        return "your_extension"

    def get_description(self) -> str:
        return "Description of your extension"
```

### Step 2: Add Configuration Schema

Update config schema in `scripts/config_manager.py`:

```python
DEFAULT_CONFIG = {
    # ... existing config ...

    "extensions": {
        "your_extension": {
            "enabled": false,
            "api_key": "",
            "channel": "",
            # Your extension-specific settings
        }
    }
}
```

### Step 3: Register Extension

Update `scripts/notification_dispatcher.py` to load your extension:

```python
# Import your extension
from extensions.future.your_extension import YourExtension

# Add to dispatch tasks
tasks = {
    # ... existing tasks ...
    "your_extension": lambda: execute_extension(YourExtension, summary, config)
}
```

### Step 4: Document Extension

Add documentation to this README and SKILL.md.

## Extension Examples

### Slack Extension (`optional/slack.py`)

```python
class SlackExtension:
    def __init__(self, config: Dict[str, Any]):
        slack_config = config.get("communication", {}).get("slack", {})
        self.enabled = slack_config.get("enabled", False)
        self.channel = slack_config.get("channel", "")
        self.webhook_url = slack_config.get("webhook_url", "")
        self.mention_users = slack_config.get("mention_users", [])

    def execute(self, summary: Dict[str, Any]) -> Dict[str, Any]:
        if not self.enabled:
            return {"status": "skipped", "message": "Slack disabled"}

        # Build message
        content = summary.get("slack_summary", summary["full_summary"])

        if self.mention_users:
            mentions = " ".join([f"<@{u}>" for u in self.mention_users])
            content = f"{mentions}\n\n{content}"

        # Send to Slack via webhook
        import requests
        response = requests.post(
            self.webhook_url,
            json={"channel": self.channel, "text": content}
        )

        if response.status_code == 200:
            return {
                "status": "success",
                "message": f"Posted to #{self.channel}"
            }
        else:
            return {
                "status": "error",
                "message": f"Slack API error: {response.status_code}"
            }
```

### Discord Extension (`future/discord.py`)

```python
class DiscordExtension:
    def __init__(self, config: Dict[str, Any]):
        discord_config = config.get("extensions", {}).get("discord", {})
        self.enabled = discord_config.get("enabled", False)
        self.webhook_url = discord_config.get("webhook_url", "")
        self.mention_roles = discord_config.get("mention_roles", [])

    def execute(self, summary: Dict[str, Any]) -> Dict[str, Any]:
        if not self.enabled:
            return {"status": "skipped", "message": "Discord disabled"}

        content = summary.get("discord_summary", summary["full_summary"])

        # Add role mentions
        if self.mention_roles:
            mentions = " ".join([f"<@&{r}>" for r in self.mention_roles])
            content = f"{mentions}\n\n{content}"

        # Send to Discord webhook
        import requests
        response = requests.post(
            self.webhook_url,
            json={"content": content}
        )

        if response.status_code in [200, 204]:
            return {
                "status": "success",
                "message": "Posted to Discord channel"
            }
        else:
            return {
                "status": "error",
                "message": f"Discord webhook error: {response.status_code}"
            }
```

## Configuration Examples

### Slack Configuration

```json
{
  "communication": {
    "slack": {
      "enabled": true,
      "channel": "project-updates",
      "webhook_url": "https://hooks.slack.com/services/YOUR/WEBHOOK/URL",
      "mention_users": ["U1234", "U5678"],
      "thread_mode": "new_message"
    }
  }
}
```

### Discord Configuration

```json
{
  "extensions": {
    "discord": {
      "enabled": true,
      "webhook_url": "https://discord.com/api/webhooks/YOUR/WEBHOOK",
      "mention_roles": ["123456789", "987654321"]
    }
  }
}
```

### JIRA Configuration

```json
{
  "extensions": {
    "jira": {
      "enabled": true,
      "base_url": "https://your-domain.atlassian.net",
      "api_token": "your_api_token",
      "project_key": "PROJ",
      "issue_type": "Task",
      "assignee": "john.doe@example.com"
    }
  }
}
```

## Best Practices

### Error Handling
- Always return proper status: "success", "error", or "skipped"
- Include detailed error messages for troubleshooting
- Never throw unhandled exceptions
- Log failures for user review

### Configuration Validation
- Validate all required fields in `validate_config()`
- Provide clear error messages for missing/invalid config
- Support graceful degradation when optional fields missing

### Summary Content
- Use `summary["full_summary"]` for detailed channels (email, Slack)
- Use `summary["concise_summary"]` for brief channels (SMS, notifications)
- Support custom summaries: `summary.get("extension_summary", default)`

### API Integration
- Use proper authentication (API keys, OAuth tokens)
- Handle rate limiting and retries
- Respect API quotas and limits
- Cache responses when appropriate

### Testing
- Create unit tests for each extension
- Mock external API calls
- Test error scenarios
- Validate configuration parsing

## Extension Lifecycle

1. **Initialization**: Load configuration and validate settings
2. **Validation**: Check required fields and API credentials
3. **Execution**: Perform extension action with error handling
4. **Reporting**: Return status and detailed results
5. **Cleanup**: Close connections and release resources

## Dependency Management

Extensions may require additional Python packages:

```bash
# Example: Slack extension requires requests
pip3 install requests

# Example: JIRA extension requires jira-python
pip3 install jira

# Example: Notion extension requires notion-client
pip3 install notion-client
```

Add requirements to `extensions/requirements.txt`:

```
requests>=2.28.0
jira>=3.4.0
notion-client>=2.0.0
discord-webhook>=1.0.0
```

## Security Considerations

### API Keys and Tokens
- **Never commit** API keys or tokens to version control
- Store sensitive data in environment variables or secure keychain
- Use `.gitignore` to exclude configuration files with secrets
- Consider using system keychain for credential storage

### Data Privacy
- Be mindful of sensitive information in summaries
- Respect GDPR and data protection regulations
- Provide options to redact sensitive data
- Support encrypted communication channels

### Rate Limiting
- Implement exponential backoff for API retries
- Respect API rate limits
- Queue messages when limits reached
- Provide user feedback on rate limit status

## Testing Extensions

Create test file `extensions/tests/test_your_extension.py`:

```python
#!/usr/bin/env python3
"""Tests for your extension."""

import unittest
from unittest.mock import Mock, patch
from extensions.future.your_extension import YourExtension


class TestYourExtension(unittest.TestCase):
    def setUp(self):
        self.config = {
            "extensions": {
                "your_extension": {
                    "enabled": True,
                    "api_key": "test_key",
                    "channel": "test_channel"
                }
            }
        }

    def test_validate_config_success(self):
        ext = YourExtension(self.config)
        valid, errors = ext.validate_config()
        self.assertTrue(valid)
        self.assertEqual(len(errors), 0)

    def test_validate_config_missing_api_key(self):
        config = {"extensions": {"your_extension": {"enabled": True}}}
        ext = YourExtension(config)
        valid, errors = ext.validate_config()
        self.assertFalse(valid)
        self.assertIn("API key", str(errors))

    @patch('requests.post')
    def test_execute_success(self, mock_post):
        mock_post.return_value.status_code = 200

        ext = YourExtension(self.config)
        summary = {"full_summary": "Test summary"}

        result = ext.execute(summary)

        self.assertEqual(result["status"], "success")
        mock_post.assert_called_once()


if __name__ == "__main__":
    unittest.main()
```

Run tests:
```bash
python3 -m unittest extensions/tests/test_your_extension.py
```

## Contributing

To contribute a new extension:

1. Create extension file in `extensions/future/`
2. Implement the Extension interface
3. Add configuration schema
4. Write comprehensive tests
5. Update documentation
6. Submit for review

---

**Next Steps**:
- Review existing extensions for patterns
- Implement your extension following the interface
- Test thoroughly with mock data
- Document configuration and usage
- Consider security and privacy implications
