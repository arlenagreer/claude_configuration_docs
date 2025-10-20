---
name: frontend-debug
description: Autonomously debug frontend issues through empirical browser observation using Chrome DevTools MCP
category: debugging
version: 1.0.0
---

# Frontend Debug Skill - Empirical Browser-Based Debugging

**Purpose**: Autonomously debug frontend issues through empirical browser observation, investigation, and verification using Chrome DevTools MCP.

**Core Principle**: No issue is considered "fixed" until empirically verified through direct browser interaction and UI observation.

---

## Activation

### Trigger Patterns
```bash
# Primary invocation
@~/.claude/skills/frontend-debug.md [issue-description]

# With optional flags
@~/.claude/skills/frontend-debug.md [issue-description] --ultrathink --loop

# From GitHub issue (automated)
@~/.claude/skills/frontend-debug.md --github-issue <issue-number>
```

### Auto-Detection
- User reports frontend bugs with UI-specific symptoms
- Visual/interaction issues mentioned (clicks not working, elements missing, styling broken)
- Console errors or network failures in frontend context

---

## Workflow Architecture

### Phase 0: Initialization & Context Gathering

**Objective**: Establish debugging session and gather issue details

**Actions**:
1. **Issue Description Check**
   - If no issue description provided → Ask user for details
   - If GitHub issue → Extract issue body and comments
   - Parse description for: symptoms, reproduction steps, expected vs actual behavior

2. **Session Isolation Setup**
   ```json
   {
     "browser_config": {
       "isolated": true,
       "user_data_dir": "/tmp/claude-debug-{session-id}-{timestamp}",
       "headless": false,
       "port": "dynamic"
     },
     "session_state_file": ".debug-session-{session-id}.json"
   }
   ```

3. **Project Context Detection**
   - Check for SoftTrak project (see SoftTrak Context section)
   - Identify framework (React, Vue, Angular, etc.)
   - Locate relevant configuration files

4. **Crash Recovery Check**
   - Look for incomplete session files (`.debug-session-*.json`)
   - If found → Offer to resume from last checkpoint
   - Load previous investigation state if resuming

5. **TodoWrite Session Tracking**
   ```yaml
   todos:
     - content: "Initialize browser session"
       status: "in_progress"
     - content: "Gather issue details"
       status: "pending"
     - content: "Investigate in browser"
       status: "pending"
     - content: "Implement fix"
       status: "pending"
     - content: "Verify fix empirically"
       status: "pending"
     - content: "Generate investigation report"
       status: "pending"
   ```

**Checkpoint**: Session initialized, issue understood, ready for investigation

---

### Phase 1: Browser Investigation & Observation

**Objective**: Systematically investigate the issue through direct browser observation

**Primary Tool**: Chrome DevTools MCP (mandatory)
**Fallback Tool**: Playwright MCP (investigation only, not for verification)

**Investigation Sequence**:

1. **Launch Browser & Navigate**
   ```yaml
   actions:
     - Launch isolated Chrome instance via DevTools MCP
     - Navigate to application URL
     - Handle authentication if required (see SoftTrak section)
     - Navigate to problematic page/feature
   ```

2. **Capture Initial State**
   ```yaml
   required_captures:
     - take_snapshot: "Document current UI state"
     - take_screenshot: "Visual baseline"
     - list_console_messages: "All console output (errors, warnings, logs)"
     - list_network_requests: "All network activity since page load"

   optional_captures:
     - performance_profile: "If slowness reported"
     - memory_snapshot: "If memory leak suspected"
     - coverage_report: "If dead code suspected"
     - lighthouse_audit: "If performance/a11y issue"
   ```

3. **Reproduce Issue**
   - Follow reproduction steps from issue description
   - Interact with UI elements systematically
   - Observe behavior vs expected behavior
   - Document exact failure mode

4. **Deep Investigation Tools**
   ```yaml
   mandatory_checks:
     - Console Logs: Errors, warnings, info messages
     - Network Activity: Failed requests, slow requests, payload inspection
     - DOM State: Elements present/missing, styles applied, event listeners
     - Application State: LocalStorage, SessionStorage, IndexedDB, Cookies

   conditional_checks:
     - Service Workers: For PWA or caching issues
     - WebSockets: For real-time features
     - Performance: For slowness/lag issues
     - Memory: For leak detection
     - Security: For CSP, CORS, authentication issues
   ```

5. **Parallel Analysis** (if needed)
   - Use Sequential MCP for complex root cause analysis
   - Use Context7 MCP for framework-specific patterns
   - Explore codebase for relevant files (components, services, etc.)

**Checkpoint**: Issue reproduced, root cause hypothesis formed

---

### Phase 2: Root Cause Analysis & Fix Strategy

**Objective**: Determine why the issue occurs and plan the fix

**Actions**:

1. **Invoke /sc:troubleshoot**
   ```bash
   /sc:troubleshoot [issue-description] --validate --c7 --seq --persona-analyzer
   ```
   - Let SuperClaude coordinate persona activation
   - Leverage Sequential MCP for structured reasoning
   - Use Context7 MCP for framework patterns

2. **Hypothesis Formation**
   ```yaml
   analysis_output:
     root_cause: "Detailed explanation of why issue occurs"
     contributing_factors: ["Factor 1", "Factor 2"]
     confidence_score: 0.0-1.0
     fix_strategy: "High-level approach to resolution"
   ```

3. **Fix Candidates**
   - Generate 1-3 potential fixes
   - Rank by confidence and risk
   - Consider rollback strategy if fix introduces new issues

4. **User Confirmation** (if confidence < 70%)
   - Present analysis and proposed fix
   - Request user approval to proceed
   - Allow user to provide additional context

**Checkpoint**: Root cause identified, fix strategy approved

---

### Phase 3: Implementation

**Objective**: Apply the fix to the codebase

**Actions**:

1. **Code Modification**
   - Use Read, Edit, MultiEdit tools as needed
   - Follow existing code patterns and conventions
   - Add inline comments explaining the fix
   - Consider edge cases and defensive programming

2. **Backend Verification** (if applicable)
   - Use curl or similar tools to verify API changes
   - Check database state if relevant
   - Validate backend services are available

3. **Build & Restart** (if required)
   - Rebuild application if needed
   - Restart dev server if needed
   - Clear caches if needed

**Checkpoint**: Fix implemented, application ready for testing

---

### Phase 4: Empirical Verification (MANDATORY)

**Objective**: Verify the fix through direct browser observation

**Primary Tool**: Chrome DevTools MCP (MANDATORY - no substitutes)

**Verification Criteria** (ALL must pass):

1. ✅ **UI State Verification**
   - Visual appearance matches expected state
   - Elements present and correctly styled
   - Interactions work as expected
   - Screenshot comparison (before/after)

2. ✅ **Console Verification**
   - No errors related to the fix
   - No new warnings introduced
   - Expected log messages present (if any)

3. ✅ **Network Verification**
   - All requests succeed (200/201/204 status codes)
   - Payloads are correct
   - Response times acceptable
   - No failed requests

4. ✅ **Interaction Verification**
   - Complete user flow end-to-end
   - All clickable elements respond correctly
   - Forms submit successfully
   - Navigation works as expected

5. ✅ **Regression Check**
   - Related features still work
   - No new issues introduced
   - Core workflows unaffected

**Verification Process**:

```yaml
verification_steps:
  1_prepare:
    - Refresh browser or restart if needed
    - Clear console and network logs
    - Return to starting point (e.g., login page)

  2_execute:
    - Follow reproduction steps exactly
    - Observe UI state at each step
    - Capture console, network, screenshots

  3_evaluate:
    - Compare actual vs expected for ALL criteria
    - Document any deviations
    - Calculate confidence score

  4_decide:
    - If ALL criteria pass → Success, proceed to Phase 5
    - If ANY criteria fail → Iterate (return to Phase 2)
    - If 3+ iterations with no progress → Escalate
```

**Iteration Handling**:
```yaml
iteration_rules:
  max_iterations: 5

  escalation_triggers:
    time_based:
      warning: 15 minutes
      critical: 20 minutes

    confidence_based:
      low: "< 40% after 2 attempts"
      critical: "< 30% after 3 attempts"

    progress_based:
      stagnation: "No improvement over 2 consecutive iterations"

  escalation_action:
    - Generate detailed investigation report
    - Document attempted fixes and results
    - Provide recommendations for human intervention
    - Update skill knowledge base
```

**Auto-Correction** (for known issues):
- If wrong credentials detected → Auto-correct to correct credentials (see SoftTrak)
- If build error → Attempt rebuild
- If service unavailable → Attempt restart/reconnection

**Checkpoint**: Fix verified empirically, all criteria pass

---

### Phase 5: Documentation & Knowledge Update

**Objective**: Document the investigation and update skill knowledge

**Actions**:

1. **Generate Investigation Report**
   ```markdown
   # Frontend Debug Report - [Issue Title]

   **Session ID**: {session-id}
   **Date**: {timestamp}
   **Duration**: {elapsed-time}
   **Status**: ✅ Resolved | ⚠️ Escalated

   ## Issue Description
   [Original issue description and symptoms]

   ## Investigation Process

   ### Initial Observations
   - Console errors: [list]
   - Network failures: [list]
   - UI state: [description]
   - Screenshots: [before state]

   ### Root Cause Analysis
   - Primary cause: [explanation]
   - Contributing factors: [list]
   - Confidence: {score}

   ### Attempted Fixes
   1. **Attempt 1**: [description]
      - Result: [success/failure]
      - Reason: [why it worked/didn't work]

   2. **Attempt 2**: [description]
      - Result: [success/failure]
      - Reason: [why it worked/didn't work]

   ### Final Resolution
   - **Fix applied**: [detailed description]
   - **Files modified**: [list with line numbers]
   - **Verification results**:
     - UI State: ✅
     - Console: ✅
     - Network: ✅
     - Interaction: ✅
     - Regression: ✅

   ### Screenshots
   - Before: [path]
   - After: [path]

   ## Lessons Learned
   [What was learned from this investigation]

   ## Prevention Artifacts

   ### Test Cases Created
   [List of test cases to prevent regression]

   ### Documentation Updates
   [List of documentation files updated]

   ### Code Comments
   [Explanation of inline comments added]

   ## Recommendations
   [Any architectural or process improvements suggested]
   ```

2. **Create Regression Prevention Artifacts**
   ```yaml
   artifacts:
     test_cases:
       - path: "tests/frontend/[feature]-regression.test.js"
         description: "Automated test to prevent issue recurrence"

     documentation:
       - path: "docs/known-issues/[issue-number].md"
         description: "Known issue documentation"
       - path: "docs/debugging-guides/[feature].md"
         description: "Debugging guide for similar issues"

     code_comments:
       - location: "[file]:[line]"
         content: "Explanation of fix and why it was needed"
   ```

3. **Update Skill Knowledge Base**
   ```yaml
   knowledge_update:
     learned_patterns:
       - pattern: "[Description of recurring pattern]"
         solution: "[How to recognize and fix]"
         confidence: 0.0-1.0

     framework_quirks:
       - framework: "[React/Vue/Angular/etc]"
         quirk: "[Specific behavior or gotcha]"
         workaround: "[How to handle]"

     project_specific:
       - project: "[SoftTrak/Other]"
         context: "[Specific context or configuration]"
         notes: "[Important details]"
   ```

4. **Session Cleanup**
   ```yaml
   cleanup_actions:
     - Close browser session
     - Delete temporary user data dir
     - Archive session state file
     - Update TodoWrite (mark all completed)
     - Delete .debug-session-{id}.json (if successful)
   ```

**Checkpoint**: Investigation documented, knowledge updated, session complete

---

## SoftTrak Application Context

**Auto-Activation**: Hardcoded - always active when debugging

**Project Detection**:
```yaml
detection_patterns:
  - package.json contains "softtrak"
  - Directory structure matches SoftTrak patterns
  - .softtrak/ directory exists
```

**Test Credentials** (CRITICAL):
```yaml
primary_credentials:
  username: "admin@example.com"
  password: "Kakellna123!"
  organization: "Acme Corporation"

important_notes:
  - ALL test users use the same password: "Kakellna123!"
  - NEVER use different credentials
  - NEVER attempt to "fix" login with wrong credentials

auto_correction:
  - If wrong credentials detected → HALT and AUTO-CORRECT
  - Alert: "⚠️ Wrong credentials detected! Using admin@example.com / Kakellna123!"
  - Continue with correct credentials
```

**Test Data Context**:
```yaml
organizations:
  - "Acme Corporation" (primary)
  - [Others to be learned and added]

users:
  - admin@example.com (primary admin)
  - [Others to be learned and added]

projects:
  - [To be learned and added]
```

**Knowledge Base Updates**:
```yaml
update_after_each_session:
  - New test users discovered
  - Organization structures learned
  - Common workflows and navigation patterns
  - Known quirks or workarounds
  - API endpoints and payloads
```

---

## MCP Server Configuration

### Primary: Chrome DevTools MCP

**Configuration** (per debugging session):
```json
{
  "mcpServers": {
    "chrome-devtools-debug-{session-id}": {
      "command": "npx",
      "args": [
        "chrome-devtools-mcp@latest",
        "--isolated=true",
        "--headless=false"
      ],
      "env": {
        "USER_DATA_DIR": "/tmp/claude-debug-{session-id}-{timestamp}"
      }
    }
  }
}
```

**Key Features**:
- Session isolation via `--isolated` flag
- Automatic cleanup of temp directories
- Non-headless mode for visual debugging
- Dynamic port allocation (avoids conflicts)

**Essential Tools**:
```yaml
mandatory_tools:
  - navigate_page: "Navigate to URLs"
  - take_snapshot: "Capture UI state text representation"
  - take_screenshot: "Visual state capture"
  - list_console_messages: "Console errors/warnings/logs"
  - list_network_requests: "Network activity inspection"
  - click: "UI interaction"
  - fill: "Form input"
  - evaluate_script: "JavaScript execution for state inspection"

conditional_tools:
  - performance_start_trace: "For performance issues"
  - performance_stop_trace: "For performance issues"
  - performance_analyze_insight: "For performance bottlenecks"
  - emulate_network: "For network condition testing"
  - emulate_cpu: "For performance testing"
```

### Fallback: Playwright MCP

**Usage**: Investigation only (NOT for final verification)

**When to Use**:
- Chrome DevTools MCP unavailable or failing
- Need cross-browser validation during investigation
- Need specific Playwright capabilities

**Restriction**: NEVER use for Phase 4 (Verification) - Chrome DevTools is mandatory

### Analysis: Sequential Thinking MCP

**Usage**: Complex multi-step reasoning

**Integration**: Automatic via /sc:troubleshoot command

**When to Use**:
- Root cause analysis with multiple factors
- Complex debugging logic
- Hypothesis testing and validation
- Pattern recognition in error chains

### Documentation: Context7 MCP

**Usage**: Framework-specific patterns and best practices

**Integration**: Automatic via /sc:troubleshoot --c7 flag

**When to Use**:
- React/Vue/Angular specific issues
- Framework API usage questions
- Best practice validation
- Known issue lookup

---

## SuperClaude Integration

### Primary Command: /sc:troubleshoot

**Invocation** (from Phase 2):
```bash
/sc:troubleshoot [issue-description] --validate --c7 --seq --persona-analyzer
```

**Always-On Flags**:
- `--validate`: Mandatory verification gates
- `--c7`: Context7 for framework patterns
- `--seq`: Sequential for structured reasoning
- `--persona-analyzer`: Root cause analysis focus

**Optional Flags** (user-configurable):
- `--ultrathink`: Deep analysis for complex issues
- `--loop`: Iterative refinement (handled by this skill's iteration logic)

**Persona Coordination**:
- Let SuperClaude auto-activate personas based on issue type
- Frontend persona for UI issues
- Backend persona for API integration issues
- Security persona for auth/permission issues
- Performance persona for slowness issues

---

## Crash Recovery & State Persistence

### Session State File

**Location**: `.debug-session-{session-id}.json`

**Contents**:
```json
{
  "session_id": "unique-id",
  "timestamp_start": "ISO-8601",
  "timestamp_last_update": "ISO-8601",
  "status": "active|completed|crashed",
  "issue_description": "...",
  "current_phase": "0|1|2|3|4|5",
  "browser_config": {
    "user_data_dir": "/tmp/...",
    "port": 9222,
    "isolated": true
  },
  "investigation_state": {
    "root_cause_hypothesis": "...",
    "confidence": 0.75,
    "attempts": [
      {
        "attempt_number": 1,
        "fix_description": "...",
        "result": "success|failure",
        "reason": "..."
      }
    ]
  },
  "todos": [...],
  "artifacts": {
    "screenshots": ["path1", "path2"],
    "logs": ["console.log", "network.log"]
  }
}
```

### Recovery Process

**On Skill Invocation**:
1. Check for incomplete session files (status != "completed")
2. If found, calculate age (timestamp_last_update)
3. If age < 24 hours:
   - Display session summary
   - Ask: "Found incomplete debugging session from [time]. Resume? (yes/no)"
   - If yes → Load state and continue from current_phase
   - If no → Archive old session, start fresh

**State Restoration**:
```yaml
restorable_state:
  - Browser session (if still running)
  - Investigation findings
  - Attempted fixes and results
  - TodoWrite state
  - Captured screenshots/logs

non_restorable:
  - Live browser connection (will reconnect)
  - Running performance traces (will restart)
```

### Cleanup Strategy

```yaml
automatic_cleanup:
  on_success:
    - Mark session as "completed"
    - Archive report
    - Delete temp browser data
    - Delete session state file (after 24h)

  on_crash:
    - Keep session state file for recovery
    - Preserve temp browser data for 24h
    - Allow manual inspection

manual_cleanup:
  - Prompt user after successful recovery
  - Offer to clean up old sessions (>24h)
  - List and delete archived sessions (>7 days)
```

---

## Git Worktree Support

**Scenario**: Multiple concurrent debugging sessions using git worktrees

**Detection**:
```bash
# Check if current directory is a worktree
git rev-parse --git-dir | grep "\.git/worktrees"
```

**Worktree-Aware Behavior**:
```yaml
when_in_worktree:
  - Use worktree-specific session ID: "{worktree-name}-{timestamp}"
  - Isolate browser sessions per worktree
  - Separate state files per worktree
  - Coordinate with main worktree if needed (shared test database, etc.)

coordination_with_main:
  - Shared test credentials (from SoftTrak context)
  - Shared knowledge base updates
  - Separate browser instances (isolated)
  - Separate temp directories
```

**Multi-Session Management**:
```yaml
list_active_sessions:
  - Detect all .debug-session-*.json files
  - Show worktree, status, age
  - Allow user to inspect or terminate

conflict_resolution:
  - Each worktree gets its own browser instance
  - No shared state between concurrent sessions
  - Knowledge base updates queued and merged
```

---

## Edge Cases & Error Handling

### Issue Cannot Be Reproduced

**Actions**:
1. Document inability to reproduce
2. Ask user for additional details:
   - More specific reproduction steps?
   - Browser version, OS, screen size?
   - Any browser extensions installed?
   - Network conditions (slow connection)?
3. If user unavailable (GitHub issue) → Post comment requesting details
4. Generate "could not reproduce" report

### Fix Introduces New Issues

**Actions**:
1. Detect new issues during verification
2. Log the regression
3. Continue iterating (new issue becomes part of fix criteria)
4. If iteration limit reached → Escalate with both original and new issues documented

### Infrastructure Issues

**Detection**:
- Backend API unavailable (network errors)
- Database connection failure
- External services down (auth provider, CDN, etc.)

**Actions**:
1. Attempt to make facilities available:
   - Start backend server if local
   - Check database connection and restart if needed
   - Wait and retry for external services (with timeout)
2. If cannot resolve → Document infrastructure issue
3. Report to user or escalate

### Browser/DevTools Issues

**Actions**:
- Chrome DevTools MCP timeout → Retry with increased timeout
- Browser crash → Restart isolated instance
- DevTools protocol error → Try Playwright as fallback (investigation only)
- If persistent → Escalate with technical details

---

## Performance Considerations

### Token Efficiency

**Optimization Strategies**:
- Use structured logs (don't dump everything)
- Screenshot selectively (only when state changes)
- Cache investigation findings
- Reuse analysis from Sequential/Context7 MCPs

**Token Budget**:
- Phase 1 (Investigation): ~15K tokens
- Phase 2 (Analysis): ~20K tokens (includes /sc:troubleshoot)
- Phase 3 (Implementation): ~10K tokens
- Phase 4 (Verification): ~10K tokens
- Phase 5 (Documentation): ~5K tokens
- **Total**: ~60K tokens per debugging session

### Time Efficiency

**Expected Duration**:
- Simple issues: 5-10 minutes
- Moderate issues: 10-15 minutes
- Complex issues: 15-20 minutes
- Escalation threshold: 20 minutes

**Optimization**:
- Parallel tool calls where possible
- Cache repeated analyses
- Reuse browser session across iterations
- Batch verification checks

---

## Quality Assurance

### Skill Self-Validation

**Before deployment, verify**:
- [ ] Browser isolation works (test concurrent sessions)
- [ ] Crash recovery restores state correctly
- [ ] SoftTrak credentials auto-correct triggers
- [ ] All DevTools tools accessible
- [ ] Verification phase cannot be skipped
- [ ] Iteration limits enforced
- [ ] Escalation produces useful report
- [ ] Knowledge base updates persist

### Ongoing Improvement

**After each session**:
- Review investigation report
- Identify patterns in successful/failed investigations
- Update skill knowledge base
- Refine investigation strategies
- Improve escalation criteria

**Metrics to Track**:
- Success rate (issues resolved vs escalated)
- Average iterations to resolution
- Average time to resolution
- Common root causes
- Framework-specific patterns

---

## Example Invocations

### Scenario 1: Direct Issue Description

```bash
@~/.claude/skills/frontend-debug.md "Login button not working - clicks don't trigger login"
```

**Expected Flow**:
1. Initialize session with isolated browser
2. Navigate to login page
3. Observe console, network, UI state
4. Attempt login, capture failure
5. Investigate event listeners, API calls
6. Hypothesize root cause (e.g., event handler not attached)
7. Fix code
8. Verify login works empirically
9. Generate report

### Scenario 2: GitHub Issue Integration

```bash
@~/.claude/skills/frontend-debug.md --github-issue 123
```

**Expected Flow**:
1. Fetch issue #123 from GitHub
2. Extract description, labels, comments
3. Proceed with standard investigation flow
4. Post progress updates as GitHub comments (optional)
5. Close issue with resolution comment

### Scenario 3: SoftTrak with Wrong Credentials

```bash
@~/.claude/skills/frontend-debug.md "Dashboard not loading for test users"
```

**Expected Flow**:
1. Detect SoftTrak project
2. Navigate to login
3. Agent attempts login with "test@example.com / password123"
4. **Auto-correction triggers**: "⚠️ Wrong credentials! Using admin@example.com / Kakellna123!"
5. Login succeeds
6. Continue investigation
7. Fix dashboard issue
8. Verify empirically
9. Update knowledge base with: "Dashboard requires admin privileges to access analytics"

### Scenario 4: Concurrent Sessions in Worktrees

**Terminal 1**:
```bash
cd ~/projects/softtrak-main
@~/.claude/skills/frontend-debug.md "Issue A: Search bar broken"
```

**Terminal 2**:
```bash
cd ~/projects/softtrak-feature-x
@~/.claude/skills/frontend-debug.md "Issue B: Export button not exporting"
```

**Expected Flow**:
- Session A: Isolated browser instance, user-data-dir-A, port 9222
- Session B: Isolated browser instance, user-data-dir-B, port 9223
- Both sessions run independently
- Knowledge base updates queued and merged
- No interference between sessions

---

## Success Criteria

**A debugging session is successful when**:

✅ **ALL verification criteria pass** (UI, console, network, interaction, regression)
✅ **Investigation report generated** (markdown format, all sections complete)
✅ **Regression prevention artifacts created** (tests, docs, comments)
✅ **Knowledge base updated** (learned patterns, project context)
✅ **Session cleanup completed** (browser closed, temp files removed)

**A debugging session requires escalation when**:

⚠️ **Time limit exceeded** (>20 minutes)
⚠️ **Confidence critically low** (<30% after 3 attempts)
⚠️ **No progress over iterations** (2+ consecutive attempts with no improvement)
⚠️ **Infrastructure issues unresolvable** (backend unavailable, cannot start services)
⚠️ **Browser/tooling failures** (persistent Chrome DevTools issues)

---

## Skill Maintenance

### Knowledge Base Location

```
~/.claude/skills/frontend-debug/
├── knowledge-base.json          # Learned patterns and solutions
├── framework-quirks.json        # Framework-specific behaviors
├── project-contexts/            # Project-specific contexts
│   ├── softtrak.json
│   └── [other-projects].json
└── investigation-reports/       # Archived reports for learning
    ├── 2025-10-19-login-fix.md
    └── [other-reports].md
```

### Version History

```yaml
skill_version: "1.0.0"
last_updated: "2025-10-19"
changelog:
  - "1.0.0 (2025-10-19): Initial specification"
```

### Feedback Loop

**After each debugging session**:
1. Analyze what worked well
2. Identify pain points or inefficiencies
3. Propose skill improvements
4. Update this file with lessons learned

---

## Advanced Features (Future Enhancements)

### Phase 6: Automated Testing (Optional Future)

Generate automated E2E tests to prevent regression:
```yaml
test_generation:
  - Use Playwright to record user flow
  - Generate test code (Playwright/Cypress)
  - Add assertions for verification criteria
  - Save to project test directory
  - Run test to verify it passes
```

### GitHub Issue Integration (Future)

```yaml
github_integration:
  on_start:
    - Comment: "🤖 Debugging session started by Claude Agent"
    - Add label: "automated-debug"

  during_investigation:
    - Comment with progress updates (optional)

  on_completion:
    - Comment with resolution summary
    - Add label: "resolved-by-claude"
    - Close issue (if authorized)

  on_escalation:
    - Comment with investigation report
    - Add label: "needs-human-review"
    - Tag appropriate team members
```

### Multi-Browser Support (Future)

```yaml
browser_support:
  primary: "Chrome (via Chrome DevTools MCP)"
  secondary: "Firefox, Safari (via Playwright MCP)"

  cross_browser_verification:
    - Reproduce issue in Chrome first
    - If fixed in Chrome, optionally verify in other browsers
    - Document browser-specific issues
```

---

## Appendix: Tool Reference

### Chrome DevTools MCP Tools

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

### Sequential Thinking MCP Tools

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

### Context7 MCP Tools

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

---

## Contact & Feedback

**Skill Author**: Claude Code User (Arlen Greer)
**Version**: 1.0.0
**Last Updated**: 2025-10-19

**Feedback**: Continuously improve this skill based on real debugging sessions and lessons learned.
