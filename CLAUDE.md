# SuperClaude Entry Point - Optimized

@COMMANDS.md
@FLAGS.md
@PRINCIPLES.md
@RULES.md
@MCP.md
@PERSONAS.md
@ORCHESTRATOR.md
@MODES.md
@WORKFLOW.md

# Testing Protocols

- IMPORTANT: If I ask you to perform end to end tests of one or more user stories with puppeteer or playwright, you MUST verify that the user stories pass these tests with direct, empirical operations and interactions with the user interface via those MCP tools.  You must be fully transparent about whether the tests actually passed before declaring the job complete.  If you find an error or problem that prevents you from completing the test, you MUST report this to the engineering team subagents so that they can address the problem.

# System References

- CRITICAL: When referring to dates, you MUST reference the system clock.  Do not use your cut-off date as a reference when applying a timestamp or referencing any date relative to 'now'

# Github Issue Management

- Before closing a Github Issue, you MUST:
  - write regression tests and confirm that these are passing to ensure that the issue does not reoccur
  - post a comment to the Github Issue, summarizing the work done to resolve the issue.  If the issue was a problem or bug report, include a description of what was found to be the cause.
  - commit your changes, then merge the feature branch you were using to address the Github Issue into the development branch
  - prune the feature branch you were using to address the Github Issue (after confirming that it's been merged into development)
  - update the project documentation with what was learned from resolving this Github Issue

- When working to resolve a Github Issue, you MUST:
  - confirm that you have the development branch checked out in git
  - create a new feature branch from development, for the GitHub Issue and check it out (or just check it out if it already exists)
  - use an agile and test-driven development approach while working to resolve the issue
  - CRITICAL: TEST your work! VERIFY that the fix you implement actually resolves the issue!
    - Whenever possible, verify empirically, using MCP tools such as playwright and puppeteer to actually observe that the fix is working as expected
    - If the test fails, then address the failure and test again.  Iterate until the issue is confirmed to be resolved.
    - If an issue can not be resolved, adjust the status of the Github Issue to 'escalate to human'
  - if you pause to provide a mid-job summary, you MUST
    - be completely honest, transparent and up-front about any portion of the job that has not yet been addressed
    - provide recommendations for the next steps.

# Email Communication - MANDATORY SKILL USAGE

**🔴 CRITICAL: ALL email operations MUST use the Email Agent Skill**

**Command**: `@~/.claude/skills/email/email.md [request]`

**NEVER use direct Gmail MCP calls** (`mcp__gmail__send_email`, `mcp__gmail__draft_email`)
**NO exceptions for "simple" emails** - ALL emails require the skill

## Why This Matters

The email skill provides essential features that direct MCP calls bypass:
- ✅ **Arlen's authentic writing style** - Maintains consistent voice and tone
- ✅ **Seasonal HTML formatting** - Professional themed templates based on current date
- ✅ **Automatic contact lookup** - Google Contacts integration by name
- ✅ **Mobile-responsive templates** - Proper formatting on all devices
- ✅ **Date-aware theming** - Spring, summer, fall, winter, holiday styles
- ✅ **Himalaya CLI fallback** - Works even when Gmail MCP unavailable

## Technical Stack

**Primary Method**: Gmail MCP integration (through skill)
**Fallback Method**: Himalaya CLI (when MCP unavailable)
**Contact Resolution**: `~/.claude/skills/email/lookup_contact_email.rb --name "First Last"`

## Usage Examples

```bash
# Send email to contact by name
@~/.claude/skills/email/email.md "Send Rob a summary of the frontend-debug skill"

# Email with specific formatting
@~/.claude/skills/email/email.md "Draft professional email to team about Q4 planning"

# Quick message
@~/.claude/skills/email/email.md "Email Sarah about tomorrow's meeting"
```

## Enforcement

This rule is enforced in RULES.md as 🔴 CRITICAL priority. Any direct Gmail MCP usage is a behavioral violation.

# Text Message Communication

## Built-in iMessage Command
- When asked to send a text message, you MUST:
  - Ask the user for the recipient's phone number in international format (e.g., +1XXXXXXXXXX)
  - Use the imessage command with the provided phone number

## Task Master AI Instructions

### Complete CLI Command Reference

#### Project Setup & Configuration
```bash
# Initialize new project
task-master init [--name=<name>] [--description=<desc>] [-y]

# Configure AI models
task-master models                                    # View current configuration
task-master models --setup                           # Interactive setup
task-master models --set-main <model_id>            # Set primary model
task-master models --set-research <model_id>        # Set research model
task-master models --set-fallback <model_id>        # Set fallback model

# Language settings
task-master lang [--language=<lang>]                # Set response language

# Rule profiles management
task-master rules add <profile1> <profile2>         # Add rule profiles
task-master rules remove <profile1>                 # Remove rule profiles

# Migrate existing project structure
task-master migrate                                 # Migrate to .taskmaster directory
```

#### Task Generation & Management
```bash
# Parse PRD and generate tasks
task-master parse-prd --input=<file.txt> [--num-tasks=10] [--append]

# Task status management
task-master list [--status=<status>] [--with-subtasks]
task-master set-status --id=<id> --status=<status>
task-master next                                    # Show next task to work on
task-master show <id>                              # Show task details

# Add and remove tasks
task-master add-task --prompt="description" [--research] [--dependencies=<ids>]
task-master remove-task --id=<id> [-y]

# Update tasks
task-master update --from=<id> --prompt="changes"   # Update multiple tasks
task-master update-task --id=<id> --prompt="changes" # Update single task
task-master update-subtask --id=<id> --prompt="notes" # Update subtask

# Task scoping adjustments
task-master scope-up --id=<id> [--strength=regular] [--research]
task-master scope-down --id=<id> [--strength=regular] [--research]

# Move tasks in hierarchy
task-master move --from=<id> --to=<id>
```

#### Subtask Management
```bash
# Add subtasks
task-master add-subtask --parent=<id> --title="title" [--description="desc"]
task-master add-subtask --parent=<id> --task-id=<id>  # Convert task to subtask

# Remove and clear subtasks
task-master remove-subtask --id=<parentId.subtaskId> [--convert]
task-master clear-subtasks --id=<id>
task-master clear-subtasks --all

# Expand tasks into subtasks
task-master expand --id=<id> [--num=5] [--research] [--force]
task-master expand --all [--force] [--research]
```

#### Analysis & Research
```bash
# Complexity analysis
task-master analyze-complexity [--research] [--threshold=5]
task-master complexity-report [--file=<path>]

# AI-powered research
task-master research "<prompt>" [-i=<task_ids>] [-f=<file_paths>]
                    [-c="<context>"] [--tree] [-s=<save_file>]
                    [-d=<detail_level>]
```

#### Tag Management (Multi-Context Support)
```bash
# List and manage tags
task-master tags [--show-metadata]                  # List all tags
task-master add-tag <tagName> [--copy-from-current] [--copy-from=<tag>] [-d="desc"]
task-master use-tag <tagName>                       # Switch to tag context
task-master delete-tag <tagName> [--yes]
task-master rename-tag <oldName> <newName>
task-master copy-tag <sourceName> <targetName> [-d="desc"]
```

#### Dependency Management
```bash
task-master add-dependency --id=<id> --depends-on=<id>
task-master remove-dependency --id=<id> --depends-on=<id>
task-master validate-dependencies                   # Check for issues
task-master fix-dependencies                        # Auto-fix issues
```

#### Export & Synchronization
```bash
# Sync tasks to README.md
task-master sync-readme [--with-subtasks] [--status=<status>]

# Generate individual task files
task-master generate
```

### Quick Reference Examples

#### Daily Workflow
```bash
# Morning startup
task-master next                                    # Find next task
task-master show 1.2                               # View task details
task-master set-status --id=1.2 --status=in-progress

# During development
task-master update-subtask --id=1.2.1 --prompt="Implemented auth middleware"
task-master add-dependency --id=2.1 --depends-on=1.2

# Task completion
task-master set-status --id=1.2 --status=done
task-master next                                    # Get next task
```

#### Complex Operations
```bash
# Research and expand all tasks
task-master analyze-complexity --research
task-master expand --all --research --force

# Scope adjustments
task-master scope-up --id=3 --strength=heavy --research
task-master scope-down --id=4 --strength=light

# Multi-context development
task-master add-tag feature-auth --copy-from-current
task-master use-tag feature-auth
task-master list --with-subtasks
```

#### AI-Powered Research
```bash
# Research with task context
task-master research "Best authentication patterns" -i=1.2,1.3 --tree

# Research with file context
task-master research "Security vulnerabilities" -f="backend/auth.js" -s=research.md

# Research with custom context
task-master research "Performance optimization" -c="Using Redis cache" -d=high
```

**Import Task Master's additional development workflow commands and guidelines:**
@./.taskmaster/CLAUDE.md

# iMessage Command-Line Integration

## Overview
The `imessage-ruby` package is installed and available for sending messages via Apple's Messages app from the command line.

## Basic Usage

### Command-Line Interface
```bash
# Send a simple text message
imessage -t "Your message text" -c "+1234567890"

# Send to email address (if iMessage-enabled)
imessage -t "Hello!" -c "email@example.com"

# Send with attachment
imessage -t "Check this file" -c "+1234567890" -a "/path/to/file.pdf"

# Send to multiple recipients
imessage -t "Group message" -c "+1234567890,email@example.com"
```

### Command Options
- `-t, --text [TEXT]` - The text message to send
- `-c, --contacts x,y,z` - Recipients (phone numbers or email addresses)
- `-a, --attachment [FILE]` - Path to file attachment
- `-h, --help` - Show help information

## Important Notes

### Requirements
- **macOS only** - Requires Apple Messages app
- **Authentication** - Messages app must be signed in with Apple ID
- **Permissions** - May prompt for accessibility/automation permissions on first use
- **Recipients** - Must be in contacts or have previous message history

### Recipient Format
- **Phone numbers**: Use international format with country code (e.g., "+1234567890")
- **Email addresses**: Must be iMessage-enabled Apple IDs
- **Multiple recipients**: Comma-separated list without spaces

### Limitations
- Cannot send to non-iMessage numbers (green bubble SMS)
- Attachments limited to file types supported by Messages
- Rate limiting may apply for bulk messages
- Requires GUI session (cannot run in pure SSH/headless mode)

### Error Handling
- Check exit code: 0 for success, non-zero for failure
- No delivery confirmation available via CLI
- Check Messages app for send status

## Integration Examples

### Shell Script
```bash
#!/bin/bash
# Send notification when job completes
if ./long-running-job.sh; then
    imessage -t "✅ Job completed successfully" -c "+1234567890"
else
    imessage -t "❌ Job failed" -c "+1234567890"
fi
```

### Ruby Integration
```ruby
# Using system call
system("imessage", "-t", "Hello from Ruby", "-c", "+1234567890")

# With error handling
if system("imessage", "-t", message, "-c", recipient)
  puts "Message sent"
else
  puts "Failed to send"
end
```

### Python Integration
```python
import subprocess

def send_imessage(recipient, message):
    result = subprocess.run([
        'imessage',
        '-t', message,
        '-c', recipient
    ], capture_output=True)
    return result.returncode == 0
```

- IMPORTANT/CRITICAL When you send an email message that references the current date, you MUST use the local system clock to calculate the current date

# ===================================================
# SuperClaude Framework Components
# ===================================================

# Additional Behavioral Modes (not in MODES.md)
@MODE_Brainstorming.md
@MODE_Business_Panel.md
@MODE_DeepResearch.md
@MODE_Orchestration.md

# Core Business Framework
@BUSINESS_PANEL_EXAMPLES.md
@BUSINESS_SYMBOLS.md
@RESEARCH_CONFIG.md

- Remember to offer to use the Himalaya CLI to send emails in the event that the Gmail MCP is not available
