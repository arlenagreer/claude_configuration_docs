# Frontend Debug Skill

**Version**: 1.0.0
**Author**: Arlen Greer
**Last Updated**: 2025-10-19

An autonomous, empirical browser-based debugging skill for Claude Code that investigates and resolves frontend issues through direct browser observation and verification.

---

## Quick Start

### Basic Usage

```bash
# Debug an issue
@~/.claude/skills/frontend-debug/frontend-debug.md "Login button not working"

# With optional flags
@~/.claude/skills/frontend-debug/frontend-debug.md "Dashboard slow" --ultrathink

# Resume crashed session
@~/.claude/skills/frontend-debug/frontend-debug.md
```

### Prerequisites

1. **Chrome DevTools MCP** installed and configured
2. **Sequential Thinking MCP** (optional but recommended)
3. **Context7 MCP** (optional but recommended)

---

## Directory Structure

```
frontend-debug/
├── frontend-debug.md           # Main skill file
├── README.md                   # This file
├── knowledge-base.json         # Learned patterns and metrics
├── framework-quirks.json       # Framework-specific gotchas
│
├── project-contexts/          # Project-specific configurations
│   └── softtrak.json          # SoftTrak test credentials and context
│
├── investigation-reports/     # Archived debugging reports
│   └── [reports will be saved here]
│
├── reference/                 # Quick reference materials
│   ├── devtools-quick-reference.md
│   └── common-patterns.md
│
├── templates/                 # Reusable templates
│   ├── investigation-report-template.md
│   ├── verification-checklist.md
│   ├── session-state-schema.json
│   └── mcp-config-example.json
│
└── scripts/                   # Helper scripts
    └── cleanup-sessions.sh    # Session cleanup utility
```

---

## Features

### ✅ Core Capabilities

- **Empirical Verification**: No issue is "fixed" until verified in real browser
- **Session Isolation**: Multiple concurrent debugging sessions without interference
- **Crash Recovery**: Resume from checkpoints after interruptions
- **Autonomous Iteration**: Continues until issue is empirically resolved
- **Knowledge Learning**: Builds project-specific knowledge over time

### 🔧 Technical Features

- Chrome DevTools MCP integration (primary)
- Playwright MCP support (fallback)
- Sequential Thinking MCP for root cause analysis
- Context7 MCP for framework patterns
- Git worktree support for concurrent sessions
- SoftTrak auto-credential correction

---

## Workflow Phases

1. **Phase 0: Initialization** - Session setup, context gathering
2. **Phase 1: Investigation** - Browser observation, state capture
3. **Phase 2: Analysis** - Root cause identification, fix planning
4. **Phase 3: Implementation** - Code modification, fix application
5. **Phase 4: Verification** - Empirical verification (5-point criteria)
6. **Phase 5: Documentation** - Report generation, knowledge update

---

## Configuration

### MCP Setup

See `templates/mcp-config-example.json` for complete configuration.

Basic setup:
```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["chrome-devtools-mcp@latest", "--isolated=true", "--headless=false"]
    }
  }
}
```

### Project Context

Add project-specific configuration to `project-contexts/[project-name].json`:

```json
{
  "project": "MyProject",
  "credentials": {
    "primary": {
      "username": "test@example.com",
      "password": "password123"
    }
  },
  "known_quirks": [],
  "navigation_patterns": {}
}
```

---

## Verification Criteria

ALL five criteria must pass for successful resolution:

1. ✅ **UI State**: Visual appearance matches expected
2. ✅ **Console**: No errors or warnings
3. ✅ **Network**: All requests succeed (200/201/204)
4. ✅ **Interaction**: User flow completes end-to-end
5. ✅ **Regression**: Related features still work

---

## Escalation

Session escalates if:

- ⏱️ Time exceeds 20 minutes
- 📉 Confidence drops below 30% (after 3 attempts)
- 🔁 No progress over 2+ consecutive iterations
- 🚧 Infrastructure issues unresolvable
- 🛠️ Browser/tooling failures persist

---

## Maintenance

### Cleanup Old Sessions

```bash
# Run cleanup script
~/.claude/skills/frontend-debug/scripts/cleanup-sessions.sh

# Manual cleanup
rm ~/.claude/skills/frontend-debug/.debug-session-*.json
rm -rf /tmp/claude-debug-*
```

### Update Knowledge Base

Knowledge base automatically updates after each successful session. Manual updates:

```json
// Edit knowledge-base.json
{
  "learned_patterns": [
    {
      "pattern": "Description",
      "solution": "How to fix",
      "confidence": 0.85
    }
  ]
}
```

---

## SoftTrak Project

SoftTrak-specific behavior:

- **Auto-detects** SoftTrak project structure
- **Test Credentials**: admin@example.com / Kakellna123!
- **Auto-correction**: Prevents wrong credential attempts
- **Test Organization**: Acme Corporation

All test users use password: `Kakellna123!`

---

## Troubleshooting

### Browser Won't Launch
```bash
# Check Chrome DevTools MCP installation
npx chrome-devtools-mcp@latest --version

# Verify port availability
lsof -i :9222
```

### Session Won't Resume
```bash
# Check session state file
cat ~/.claude/skills/frontend-debug/.debug-session-*.json

# Reset session
rm ~/.claude/skills/frontend-debug/.debug-session-*.json
```

### Cleanup Not Working
```bash
# Manual cleanup
rm -rf /tmp/claude-debug-*
rm ~/.claude/skills/frontend-debug/.debug-session-*.json
```

---

## Reference Materials

- **DevTools Quick Reference**: `reference/devtools-quick-reference.md`
- **Common Patterns**: `reference/common-patterns.md`
- **Report Template**: `templates/investigation-report-template.md`
- **Verification Checklist**: `templates/verification-checklist.md`

---

## Examples

### Simple Bug Fix
```bash
@~/.claude/skills/frontend-debug/frontend-debug.md "Submit button disabled incorrectly"
```

### Performance Issue
```bash
@~/.claude/skills/frontend-debug/frontend-debug.md "Page loading slowly" --ultrathink
```

### Concurrent Debugging (Git Worktrees)
```bash
# Terminal 1
cd ~/project-main
@~/.claude/skills/frontend-debug/frontend-debug.md "Issue A"

# Terminal 2
cd ~/project-feature-branch
@~/.claude/skills/frontend-debug/frontend-debug.md "Issue B"
```

---

## Metrics

Track success metrics in `knowledge-base.json`:

- Total debugging sessions
- Success rate (resolved vs escalated)
- Average time to resolution
- Average iterations per session
- Common root causes

---

## Contributing

To improve this skill:

1. Add learned patterns to `knowledge-base.json`
2. Document framework quirks in `framework-quirks.json`
3. Update investigation reports in `investigation-reports/`
4. Refine workflow based on real sessions

---

## Version History

- **v1.0.0** (2025-10-19): Initial release
  - Core debugging workflow
  - Session isolation support
  - Crash recovery
  - SoftTrak integration
  - Knowledge base system

---

## Support

**Author**: Arlen Greer
**Skill Path**: `~/.claude/skills/frontend-debug/`
**MCP Servers**: Chrome DevTools, Sequential, Context7, Playwright (optional)

For issues or improvements, update the skill files and knowledge base based on real debugging sessions.
