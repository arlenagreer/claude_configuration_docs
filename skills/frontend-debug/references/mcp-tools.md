# Frontend Debug Skill - MCP Tool Reference

**Purpose**: Detailed reference for Chrome DevTools MCP, Sequential Thinking MCP, and Context7 MCP tools used during debugging.

**Load when**: Agent needs specific tool usage instructions or encounters tool-related errors.

---

## GitHub CLI Commands

**Issue Retrieval**:
```bash
# Get current repository info
gh repo view --json nameWithOwner -q .nameWithOwner

# View issue details (JSON output)
gh issue view <number> --json title,body,labels,comments,author,state

# View issue details (human-readable)
gh issue view <number>

# List all open issues
gh issue list --state open --json number,title,labels
```

**Issue Comments**:
```bash
# Post comment
gh issue comment <number> --body "Comment text here"

# Post multi-line comment (heredoc)
gh issue comment <number> --body "$(cat <<'EOF'
🤖 **Debugging session started**

Automated investigation initiated.
Progress updates will be posted here.
EOF
)"

# Edit last comment (if needed)
gh issue comment <number> --edit <comment-id>
```

**Issue Labels**:
```bash
# Add labels (comma-separated)
gh issue edit <number> --add-label "automated-debug,in-progress"

# Remove labels
gh issue edit <number> --remove-label "automated-debug,in-progress"

# Replace all labels
gh issue edit <number> --label "resolved-by-claude,bug"

# List available labels
gh label list
```

**Issue State Management**:
```bash
# Close issue with comment
gh issue close <number> --comment "Issue resolved"

# Reopen issue
gh issue reopen <number>

# Edit issue title/body
gh issue edit <number> --title "New title"
gh issue edit <number> --body "New body"
```

**Authentication & Setup**:
```bash
# Check authentication status
gh auth status

# Login to GitHub
gh auth login

# Check rate limits
gh api rate_limit
```

**Error Handling**:
```yaml
common_errors:
  "GraphQL: Could not resolve to an Issue":
    cause: "Issue number doesn't exist"
    action: "Verify issue number and repository"

  "Must have push access":
    cause: "No permission to edit issue"
    action: "Continue investigation, but skip issue updates"

  "API rate limit exceeded":
    cause: "Too many API calls"
    action: "Wait for rate limit reset, cache data"

  "gh: command not found":
    cause: "GitHub CLI not installed"
    action: "Warn user, fall back to manual description"
```

---

## Chrome DevTools MCP Tools

**Navigation**:
- `navigate_page(url)`: Navigate to URL
- `navigate_page_history(direction)`: Go back/forward

**State Capture**:
- `take_snapshot()`: Text representation of page
- `take_screenshot(format, fullPage)`: Visual capture
- `list_console_messages()`: Console logs
- `list_network_requests()`: Network activity

**Interaction**:
- `click(uid)`: Click element
- `fill(uid, value)`: Fill input
- `hover(uid)`: Hover element
- `drag(from_uid, to_uid)`: Drag and drop

**Advanced**:
- `evaluate_script(function)`: Run JavaScript
- `performance_start_trace()`: Start perf trace
- `performance_stop_trace()`: Stop and analyze
- `emulate_network(throttling)`: Simulate network conditions
- `emulate_cpu(rate)`: Simulate CPU throttling

**Session Management**:
- `list_pages()`: List open tabs
- `select_page(index)`: Switch tab
- `new_page(url)`: Open new tab
- `close_page(index)`: Close tab

---

## Sequential Thinking MCP Tools

**Complex Reasoning**:
- `sequentialthinking(thought, next_thought_needed, thought_number, total_thoughts)`

**Usage Pattern**:
```yaml
for_root_cause_analysis:
  - Break problem into reasoning steps
  - Analyze each component systematically
  - Build hypothesis through logical progression
  - Validate with evidence at each step
```

---

## Context7 MCP Tools

**Documentation Lookup**:
- `resolve-library-id(libraryName)`: Get library ID
- `get-library-docs(libraryID, topic, tokens)`: Fetch docs

**Usage Pattern**:
```yaml
for_framework_issues:
  - Identify framework (React, Vue, etc.)
  - Search for relevant API documentation
  - Find known issues or gotchas
  - Apply framework-specific solutions
```
