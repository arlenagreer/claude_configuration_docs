# Frontend Debug Skill - Usage Examples

**Purpose**: Example invocations and expected workflows for common debugging scenarios.

**Load when**: User requests examples or agent needs clarification on usage patterns.

---

## Scenario 1: Direct Issue Description

```bash
@~/.claude/skills/frontend-debug/SKILL.md "Login button not working - clicks don't trigger login"
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

---

## Scenario 2: GitHub Issue Integration (Comprehensive Tracking)

```bash
@~/.claude/skills/frontend-debug/SKILL.md --github-issue 123
# or shorthand:
@~/.claude/skills/frontend-debug/SKILL.md "#123"
```

**Expected Flow**:
1. **Fetch issue via gh CLI**:
   ```bash
   gh issue view 123 --json title,body,labels,comments,author
   ```

2. **Post session start comment**:
   ```bash
   gh issue comment 123 --body "🤖 **Debugging session started**..."
   ```

3. **Add tracking labels**:
   ```bash
   gh issue edit 123 --add-label "automated-debug,in-progress"
   ```

4. **Investigation proceeds** (standard flow)

5. **Post progress updates**:
   - Phase 1 start: "📊 **Investigation Phase**..."
   - Phase 2 start: "🔍 **Root Cause Analysis**..."
   - Each iteration: "🔄 **Iteration {n}**..."

6. **Request clarification if needed**:
   ```bash
   gh issue comment 123 --body "@author I need more info:\n\n{questions}"
   ```

7. **On successful resolution**:
   ```bash
   gh issue comment 123 --body "✅ **Issue Resolved**\n\n{resolution}"
   gh issue edit 123 --add-label "resolved-by-claude"
   gh issue edit 123 --remove-label "automated-debug,in-progress"
   gh issue close 123 --comment "Verified fix working empirically"
   ```

8. **On escalation**:
   ```bash
   gh issue comment 123 --body "⚠️ **Manual Review Needed**\n\n{report}"
   gh issue edit 123 --add-label "needs-human-review"
   gh issue edit 123 --remove-label "automated-debug"
   # Keep issue open for human review
   ```

---

## Scenario 3: SoftTrak with Wrong Credentials

```bash
@~/.claude/skills/frontend-debug/SKILL.md "Dashboard not loading for test users"
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

---

## Scenario 4: Concurrent Sessions in Worktrees

**Terminal 1**:
```bash
cd ~/projects/softtrak-main
@~/.claude/skills/frontend-debug/SKILL.md "Issue A: Search bar broken"
```

**Terminal 2**:
```bash
cd ~/projects/softtrak-feature-x
@~/.claude/skills/frontend-debug/SKILL.md "Issue B: Export button not exporting"
```

**Expected Flow**:
- Session A: Isolated browser instance, user-data-dir-A, port 9222
- Session B: Isolated browser instance, user-data-dir-B, port 9223
- Both sessions run independently
- Knowledge base updates queued and merged
- No interference between sessions
