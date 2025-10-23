# GitHub Issue Integration

**Load when**: `--github-issue` flag used or GitHub issue reference detected (#123, URLs)

---

## Issue Description Check

```yaml
input_detection:
  github_issue_reference:
    patterns: ["#123", "issue 123", "--github-issue 123", "github.com/.../issues/123"]
    action: "Fetch issue via gh CLI"

  inline_description:
    patterns: ["Direct problem description"]
    action: "Use as-is"

  no_description:
    patterns: ["Empty or unclear"]
    action: "Ask user for details"
```

---

## GitHub Issue Processing

```bash
# Detect current repository
gh repo view --json nameWithOwner -q .nameWithOwner

# Fetch issue details
gh issue view <issue-number> --json title,body,labels,comments,author,state

# Parse and extract:
# - Issue title (use as session name)
# - Issue body (primary problem description)
# - Labels (framework tags, priority, etc.)
# - Comments (additional context, reproduction steps)
# - Author (for direct questions if needed)
# - Current state (open/closed - reopen if closed)
```

---

## GitHub Issue Lifecycle Management

```yaml
on_session_start:
  - Post comment: "🤖 **Debugging session started**\n\nAutomated investigation initiated by Claude Agent.\nI'll post progress updates here as I work through the issue."
  - Add label: "automated-debug"
  - Update to "in-progress" if supported (or add label: "in-progress")

during_investigation:
  phase_1_start:
    - Comment: "📊 **Investigation Phase**\nReproducing issue in isolated browser environment..."

  phase_2_start:
    - Comment: "🔍 **Root Cause Analysis**\nAnalyzing findings and forming hypothesis..."

  if_needs_clarification:
    - Comment: "@{author} I need more information to proceed:\n\n{questions}\n\nPlease provide these details when possible."
    - Wait for user response or timeout (continue with best effort)

on_iteration:
  - Comment: "🔄 **Iteration {n}**\nPrevious fix unsuccessful. Trying alternate approach:\n\n{approach_description}"

on_escalation:
  - Comment: "⚠️ **Investigation Summary - Manual Review Needed**\n\n{detailed_report}\n\n**Findings so far**:\n{findings}\n\n**Questions for submitter**:\n{questions}\n\n**Recommended next steps**:\n{recommendations}"
  - Add label: "needs-human-review"
  - Remove label: "automated-debug"
  - Keep issue open

on_success:
  - Comment: "✅ **Issue Resolved**\n\n{resolution_summary}\n\n**Root Cause**: {cause}\n**Fix Applied**: {fix}\n**Verification**: All criteria passed\n\nFull investigation report attached below."
  - Add label: "resolved-by-claude"
  - Remove labels: "automated-debug", "in-progress"
  - Close issue (with resolution comment)
```

---

## Error Handling

```yaml
gh_cli_not_available:
  - Warn user: "GitHub CLI not found. Install with: brew install gh"
  - Fall back to manual issue description request

issue_not_found:
  - Error: "Issue #{number} not found in current repository"
  - Ask user to verify issue number and repository

api_rate_limit:
  - Wait and retry with exponential backoff
  - If persistent: continue with cached issue data (if any)
```
