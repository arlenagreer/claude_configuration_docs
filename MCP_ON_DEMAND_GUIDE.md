# MCP On-Demand Loading Guide

**Created**: 2025-01-09
**Purpose**: Optimize token usage by loading MCP servers only when needed

## Token Savings

| Configuration | Initial Tokens | Savings |
|--------------|----------------|---------|
| **Previous (All enabled)** | ~95,000 | Baseline |
| **Optimized (Essential only)** | ~65,000 | **~30,000 (32%)** |

## Always-Enabled Servers

### Global (`~/.claude/.mcp.json`)
- **serena**: Symbol operations, project memory, codebase navigation
- **gmail**: Email functionality (CRITICAL per RULES.md - never disable)

### SoftTrak-Specific (`/SoftTrak/.mcp.json`)
- **serena**: SoftTrak codebase navigation and symbol operations

## On-Demand Servers

Enable these servers using flags when needed:

### Sequential Thinking
```bash
# Enable for complex analysis, debugging, multi-step reasoning
/analyze --seq
/troubleshoot --seq
--think --seq
```

### Context7
```bash
# Enable for framework documentation, library patterns
/build --c7
/implement --c7
--c7  # Any command
```

### Magic
```bash
# Enable for UI component generation
/build --magic
/implement --magic
--magic  # Any command
```

### Playwright
```bash
# Enable for E2E testing, browser automation
/test --play
--play  # Any command
```

### Chrome DevTools
```bash
# Enable manually by setting disabled: false in .mcp.json
# Use for frontend debugging sessions
```

### Tavily
```bash
# Enable for web research
# Set disabled: false in .mcp.json when needed
```

### Morphllm
```bash
# Enable for bulk code transformations
# Set disabled: false in .mcp.json when needed
```

## Manual Enabling/Disabling

To temporarily enable a server:

1. **Edit `.mcp.json`**:
   ```json
   "server-name": {
     "disabled": false,  // Change from true to false
     ...
   }
   ```

2. **Restart Claude Code session** - MCP config is loaded at startup

## Backup Files

Original configurations saved as:
- `~/.claude/.mcp.json.backup` - Global config backup
- `/SoftTrak/.mcp.json.backup` - SoftTrak config backup

To restore original configuration:
```bash
# Global
cp ~/.claude/.mcp.json.backup ~/.claude/.mcp.json

# SoftTrak
cp /SoftTrak/.mcp.json.backup /SoftTrak/.mcp.json
```

## Expected Behavior

### Session Startup (New)
- Load only Serena + Gmail tools (~65K tokens)
- ~53% more context available for work
- Faster session initialization

### When Using Flags
- `--seq` → Loads Sequential tools on-demand
- `--c7` → Loads Context7 tools on-demand
- `--magic` → Loads Magic tools on-demand
- `--play` → Loads Playwright tools on-demand

### Important Notes

1. **Flag-based loading requires Claude Code restart** - MCP servers can't be dynamically loaded mid-session
2. **Plan ahead** - If you know you'll need multiple servers, enable them before starting session
3. **Gmail always enabled** - Per RULES.md, email skill requires Gmail MCP (never disable)
4. **Serena recommended** - Symbol operations are essential for efficient codebase work

## Recommended Usage Patterns

### General Development
- **Default**: Just Serena (most sessions)
- **Documentation work**: Enable Context7
- **UI work**: Enable Magic + Context7
- **Testing**: Enable Playwright
- **Complex debugging**: Enable Sequential

### SoftTrak Development
- **Backend work**: Serena only
- **Frontend work**: Serena + enable Context7 if needed
- **Full-stack features**: Serena + Sequential
- **E2E testing**: Serena + Playwright

## Troubleshooting

### "Tool not available" error
- Check if server is enabled in `.mcp.json`
- Restart Claude Code session after config changes
- Verify Docker containers are running

### Still using too many tokens
- Check global config: `~/.claude/.mcp.json`
- Check project config: `<project>/.mcp.json`
- Consider disabling more servers if not needed

### Need to re-enable all servers
```bash
cp ~/.claude/.mcp.json.backup ~/.claude/.mcp.json
# Restart Claude Code
```
