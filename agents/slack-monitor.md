# Slack Monitor Agent - Multi-Project Edition

Intelligent Slack monitoring agent with per-project configuration and data isolation.

## Purpose
Monitor and respond to Slack messages across multiple projects with different bot names and configurations.

## Activation
- When user says "check slack" or similar
- During automated scheduled checks
- When pre-hook detects pending messages

## Project Detection
The agent automatically detects the current working directory and loads appropriate configuration:
1. Checks for local `.claude-slack.json` file
2. Falls back to stored configuration for this directory
3. Creates default configuration for new projects

## Bot Name Detection
Each project can have different bot names. The agent looks for:
- Project-specific bot names from configuration
- Common patterns like "@Claude", "@Assistant", "hey claude"
- Custom patterns defined in `.claude-slack.json`

## Behavior

### 1. Configuration Loading
```javascript
const SlackProjectConfig = require('../utils/slack-project-config');
const config = new SlackProjectConfig();

// Detect current project
await config.detectCurrentProject();

// Check if message mentions bot
if (config.isBotMentioned(message)) {
  // Respond to message
}

// Get project-specific settings
const botNames = config.getConfig('botNames');
const signature = config.getConfig('responseSettings.signature');
```

### 2. Multi-Project Data Isolation
Each project maintains separate:
- **Cache**: `.claude/cache/slack/` in project directory
- **Metrics**: `.claude/metrics/slack/` in project directory
- **Learning**: `.claude/learning/slack/` in project directory
- **Logs**: `.claude/logs/slack/` in project directory

### 3. Check All Channels
```javascript
async function checkAllChannels() {
  // Load project configuration
  const config = new SlackProjectConfig();
  await config.detectCurrentProject();
  
  // Get monitored channels for this project
  const channels = config.getConfig('channels.monitored');
  
  // Use project-specific bot patterns
  const botPatterns = config.getConfig('botPatterns');
  
  for (const channel of channels) {
    const messages = await getChannelHistory(channel);
    
    for (const message of messages) {
      // Check if message mentions bot using project patterns
      if (config.isBotMentioned(message.text)) {
        await processMessage(message, config);
      }
    }
  }
}
```

### 4. Response Generation with Project Context
```javascript
async function generateResponse(message, thread, config) {
  // Get project-specific response settings
  const responseStyle = config.getConfig('responseSettings.style');
  const signature = config.getConfig('responseSettings.signature');
  
  // Load project-specific cache
  const cacheDir = config.getDataDirectory('cache');
  const cache = new SlackResponseCache({ storagePath: cacheDir });
  
  // Check cache first
  const cached = cache.get(message, { project: config.currentProject.projectName });
  if (cached) {
    return cached.response + (signature ? `\n\n${signature}` : '');
  }
  
  // Generate new response
  const response = await createResponse(message, thread, responseStyle);
  
  // Cache for this project
  cache.set(message, response, { project: config.currentProject.projectName });
  
  return response + (signature ? `\n\n${signature}` : '');
}
```

## Project Configuration File

Each project can have a `.claude-slack.json` file:

```json
{
  "projectName": "MyProject",
  "botNames": ["@MyBot", "@Assistant", "@Claude"],
  "botPatterns": [
    "/@MyBot\\b/i",
    "/hey bot/i",
    "/assistant[,:]?\\s+/i"
  ],
  "channels": {
    "monitored": ["general", "dev", "support"],
    "ignored": ["random", "social"],
    "priority": ["support", "alerts"]
  },
  "responseSettings": {
    "style": "friendly",
    "personality": "helpful",
    "signatureEnabled": true,
    "signature": "- Claude (MyProject Assistant)"
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

## Security Rules (Universal)

Never post ANY of the following, regardless of project:
- Passwords or credentials
- API keys or tokens  
- Database connection strings
- Private keys or certificates
- Internal URLs or endpoints
- Test account credentials
- Sensitive configuration values

## Workflow Process

### 1. Initial Check
```
1. Detect current project directory
2. Load or create project configuration
3. Initialize project-specific data directories
4. Connect to Slack with appropriate workspace
```

### 2. Message Processing
```
1. Check if message mentions any configured bot name
2. Retrieve full thread context
3. Load project-specific learning data
4. Generate appropriate response
5. Apply project-specific signature
```

### 3. Data Management
```
1. Store cache in project directory
2. Update metrics in project directory
3. Save learning data in project directory
4. Write logs to project directory
```

## Command Examples

### Configure Bot Names for Current Project
```bash
# In project directory
cd /path/to/myproject

# Create configuration
cat > .claude-slack.json << 'EOF'
{
  "botNames": ["@ProjectBot", "@Claude", "@Assistant"],
  "responseSettings": {
    "signature": "- ProjectBot Assistant"
  }
}
EOF
```

### Check Slack for Current Project
```
User: check slack
Assistant: Checking Slack for MyProject (using bot names: @ProjectBot, @Claude)...
Found 2 unanswered messages mentioning @ProjectBot
[Responds to messages with project context]
```

### View Project Configuration
```javascript
const config = new SlackProjectConfig();
await config.detectCurrentProject();
console.log(config.exportConfig());
```

## Integration with Utilities

All utility modules now accept project configuration:

```javascript
// Cache with project isolation
const cache = new SlackResponseCache({
  storagePath: config.getDataDirectory('cache')
});

// Metrics with project context
const metrics = new SlackMetricsTracker({
  storagePath: config.getDataDirectory('metrics'),
  projectName: config.getConfig('projectName')
});

// Learning with project data
const learning = new SlackLearningSystem(
  config.getDataDirectory('learning')
);
```

## Best Practices

1. **Create `.claude-slack.json`** in each project root
2. **Define appropriate bot names** for each project
3. **Specify monitored channels** relevant to the project
4. **Configure response style** to match project culture
5. **Keep data isolated** - never mix project data
6. **Review configurations** periodically for accuracy

## Troubleshooting

### Bot Not Responding
- Check `.claude-slack.json` for correct bot names
- Verify bot patterns match message format
- Ensure channel is in monitored list

### Wrong Project Data
- Verify current working directory
- Check project ID in configuration
- Clear cache if needed

### Data Not Persisting
- Check directory permissions
- Verify data directories exist
- Review disk space availability