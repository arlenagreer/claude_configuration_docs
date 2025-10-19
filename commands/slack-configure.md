# Slack Configuration Command

Configure Slack monitoring for the current project directory.

## Usage

```
/slack-configure [action] [options]
```

## Actions

### init
Initialize Slack configuration for current project.

```
/slack-configure init
```

Creates a `.claude-slack.json` file with default settings.

### set-bot-names
Configure bot names that trigger responses.

```
/slack-configure set-bot-names "@MyBot" "@Assistant" "@Claude"
```

### add-channel
Add a channel to monitor list.

```
/slack-configure add-channel general
/slack-configure add-channel dev --priority
```

### ignore-channel  
Add a channel to ignore list.

```
/slack-configure ignore-channel random
```

### set-signature
Set response signature for this project.

```
/slack-configure set-signature "- MyBot (Project Assistant)"
```

### show
Display current configuration.

```
/slack-configure show
```

## Implementation

```javascript
const SlackProjectConfig = require('../utils/slack-project-config');

async function configureSlack(action, args) {
  const config = new SlackProjectConfig();
  await config.detectCurrentProject();
  
  switch (action) {
    case 'init':
      const projectPath = process.cwd();
      const newConfig = await config.createDefaultConfig(projectPath);
      console.log(`Created configuration for ${newConfig.projectName}`);
      console.log(`Bot names: ${newConfig.botNames.join(', ')}`);
      break;
      
    case 'set-bot-names':
      await config.updateBotNames(args);
      console.log(`Updated bot names: ${args.join(', ')}`);
      break;
      
    case 'add-channel':
      const channels = config.getConfig('channels.monitored') || [];
      if (!channels.includes(args[0])) {
        channels.push(args[0]);
        await config.setConfig('channels.monitored', channels);
        console.log(`Added channel: ${args[0]}`);
      }
      break;
      
    case 'ignore-channel':
      const ignored = config.getConfig('channels.ignored') || [];
      if (!ignored.includes(args[0])) {
        ignored.push(args[0]);
        await config.setConfig('channels.ignored', ignored);
        console.log(`Ignoring channel: ${args[0]}`);
      }
      break;
      
    case 'set-signature':
      await config.setConfig('responseSettings.signature', args.join(' '));
      console.log(`Updated signature: ${args.join(' ')}`);
      break;
      
    case 'show':
      const currentConfig = config.exportConfig();
      console.log(JSON.stringify(currentConfig, null, 2));
      break;
      
    default:
      console.log('Unknown action. Use: init, set-bot-names, add-channel, ignore-channel, set-signature, or show');
  }
}
```

## Examples

### Initialize New Project

```bash
cd /path/to/my-project
/slack-configure init
```

Output:
```
Created configuration for my-project
Bot names: @Claude, @my-project-bot, @Assistant
Configuration saved to .claude-slack.json
```

### Configure Custom Bot Names

```bash
/slack-configure set-bot-names "@ProjectBot" "@Helper" "@AI"
```

### Setup Monitoring

```bash
# Add channels to monitor
/slack-configure add-channel general
/slack-configure add-channel dev
/slack-configure add-channel support --priority

# Ignore social channels
/slack-configure ignore-channel random
/slack-configure ignore-channel watercooler
```

### Set Project Signature

```bash
/slack-configure set-signature "- ProjectBot (powered by Claude)"
```

### View Configuration

```bash
/slack-configure show
```

Output:
```json
{
  "projectId": "a1b2c3d4",
  "projectName": "my-project",
  "projectPath": "/path/to/my-project",
  "botNames": ["@ProjectBot", "@Helper", "@AI"],
  "channels": {
    "monitored": ["general", "dev", "support"],
    "ignored": ["random", "watercooler"],
    "priority": ["support"]
  },
  "responseSettings": {
    "signature": "- ProjectBot (powered by Claude)"
  }
}
```

## Project Configuration File

The `.claude-slack.json` file created in your project:

```json
{
  "projectName": "my-project",
  "botNames": ["@ProjectBot", "@Claude", "@Assistant"],
  "botPatterns": [
    "/@ProjectBot\\b/i",
    "/hey bot/i",
    "/assistant[,:]?\\s+/i"
  ],
  "channels": {
    "monitored": ["general", "dev", "support"],
    "ignored": ["random", "social"],
    "priority": ["support"]
  },
  "responseSettings": {
    "style": "professional",
    "personality": "helpful",
    "signatureEnabled": true,
    "signature": "- Claude (my-project Assistant)"
  },
  "features": {
    "caching": true,
    "learning": true,
    "escalation": true,
    "rateLimiting": true,
    "metrics": true,
    "autoScheduling": false
  }
}
```

## Data Isolation

Each project maintains its own:
- **Cache**: `.claude/cache/slack/` 
- **Metrics**: `.claude/metrics/slack/`
- **Learning**: `.claude/learning/slack/`
- **Logs**: `.claude/logs/slack/`

## Multi-Project Management

### List All Projects

```javascript
const config = new SlackProjectConfig();
const projects = config.listProjects();

projects.forEach(p => {
  console.log(`${p.projectName}: ${p.botNames.join(', ')}`);
});
```

### Switch Between Projects

Simply change directories - the configuration auto-detects:

```bash
cd /path/to/project-a
/check-slack  # Uses project-a configuration

cd /path/to/project-b  
/check-slack  # Uses project-b configuration
```

## Best Practices

1. **Run init** in each project directory
2. **Set appropriate bot names** for each project
3. **Configure channels** specific to the project
4. **Use unique signatures** to identify responses
5. **Keep configurations** in version control (add to .gitignore if sensitive)

## Troubleshooting

### Configuration Not Loading
- Ensure you're in the correct directory
- Check if `.claude-slack.json` exists
- Verify file permissions

### Bot Names Not Working
- Check exact formatting (@ symbol, capitalization)
- Test with simple patterns first
- Review bot patterns in configuration

### Data Mixing Between Projects
- Verify project ID is unique
- Check data directory paths
- Clear cache if needed with `/slack-configure clear-cache`