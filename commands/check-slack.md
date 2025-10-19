# Check Slack - Project-Aware Slack Monitor

Check all Slack channels for unanswered questions and technical issues, with project-specific configuration.

## Usage
```
/check-slack [--channels channel1,channel2] [--respond] [--configure]
```

## Options
- `--channels`: Specific channels to check (comma-separated)
- `--respond`: Automatically respond to found issues (default: true)
- `--configure`: Set up project-specific Slack configuration
- `--status`: Show current project Slack configuration
- `--verbose`: Detailed output of what was checked

## Implementation

This command uses a Task subagent to comprehensively check Slack for unanswered questions, including thread follow-ups.

Steps:
1. **Detect Current Project**: Identify project from directory path
2. **Load Project Config**: Load Slack configuration for this project  
3. **Delegate to Task Subagent**: Use Task tool with general-purpose subagent
4. **Comprehensive Thread Checking**: 
   - Check ALL threads where bot has previously responded
   - Look for follow-up questions even without direct mentions
   - Maintain full conversation context
5. **Respond to ALL Questions**: 
   - Direct mentions
   - Thread follow-ups (even without mentions)
   - Technical or business questions
6. **Report Results**: Summary of channels checked and actions taken

## Project Configuration

Each project can have its own Slack workspace and bot configuration:

### Auto-Detection
The command automatically creates configuration for new projects:
- **SoftTrak**: Uses SoftTrak Slack workspace, responds as "SoftTrak Assistant"
- **american_laboratory_trading**: Uses ALT Slack workspace, responds as "ALT System Bot"
- **dreamanager**: Uses project Slack workspace, responds as "DreamAnager Assistant"
- **Other Projects**: Creates default configuration with comprehensive thread checking

### Manual Configuration
Use `--configure` to set up project-specific settings:
```
/check-slack --configure
```

This will create a `.claude-slack.json` file in your project with:
- Bot names and mention patterns
- Channel preferences
- Response style and signature
- Workspace configuration

### Example Project Config (`.claude-slack.json`)
```json
{
  "projectName": "american_laboratory_trading",
  "botNames": ["@ALT System Bot", "@U09FK1T6VFS", "@Claude"],
  "channels": {
    "monitored": ["#all-american-laboratory-trading", "#technical-support"],
    "priority": ["#all-american-laboratory-trading"]
  },
  "responseSettings": {
    "style": "professional",
    "signature": "- ALT System Bot"
  }
}
```

## Multi-Project Workflow

1. **SoftTrak Project**:
   ```bash
   cd ~/GitHub\ Projects/SoftTrak
   /check-slack  # Uses SoftTrak Slack configuration
   ```

2. **ALT Project**:
   ```bash
   cd ~/GitHub\ Projects/american_laboratory_trading  
   /check-slack  # Uses ALT Slack configuration
   ```

3. **Any Project**:
   ```bash
   cd ~/any-project
   /check-slack  # Auto-creates appropriate configuration
   ```

## Integration with MCP Tools

The command leverages:
- **Slack MCP Server**: For channel access and message posting
- **Project Config Manager**: For per-directory configuration
- **Response Cache**: To avoid duplicate responses
- **Learning System**: To improve responses over time

## Response Behavior

**For SoftTrak**:
- Responds to: `@Claude`, `@SoftTrak-bot`, technical questions, thread follow-ups
- Channels: `#all-softtrak`, `#quality-assurance`
- Style: Professional development assistant
- Signature: "- Claude (SoftTrak Assistant)"
- **Thread Behavior**: Responds to ALL follow-ups in threads

**For ALT**:
- Responds to: `@ALT System Bot`, `@U09FK1T6VFS`, business questions, thread follow-ups
- Channels: `#all-american-laboratory-trading`, `#t-rex`, `#sales-raptor`
- Style: Business/operational assistant
- Signature: "- ALT System Bot"
- **Thread Behavior**: Responds to ALL follow-ups in threads

**For DreamAnager**:
- Responds to: `@DreamAnager Bot`, `@Claude`, technical questions, thread follow-ups
- Channels: `#dreamanager`, `#development`, `#support`
- Style: Professional technical assistant
- Signature: "- DreamAnager Assistant"
- **Thread Behavior**: Responds to ALL follow-ups in threads

## Setup for New Projects

When you first run `/check-slack` in a new project directory:

1. **Auto-detection**: Identifies project name from directory
2. **Config Creation**: Creates appropriate `.claude-slack.json`
3. **Directory Setup**: Creates cache/logs directories
4. **Integration**: Links with global project registry
5. **Ready**: Command works immediately with sensible defaults

## Advanced Features

- **Learning**: Remembers successful response patterns per project
- **Escalation**: Routes complex issues to appropriate team members
- **Metrics**: Tracks response effectiveness per project
- **Caching**: Avoids duplicate responses across sessions
- **Scheduling**: Can be automated with project-specific intervals

This ensures each project has its own Slack identity while using the same global command.