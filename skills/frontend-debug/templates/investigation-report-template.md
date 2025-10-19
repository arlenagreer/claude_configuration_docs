# Frontend Debug Report - [Issue Title]

**Session ID**: {session-id}
**Date**: {timestamp}
**Duration**: {elapsed-time}
**Status**: ✅ Resolved | ⚠️ Escalated | 🚧 In Progress

---

## Issue Description

**Original Report**:
[Paste original issue description here]

**Reproduction Steps**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Behavior**:
[What should happen]

**Actual Behavior**:
[What actually happens]

**Environment**:
- Browser: [Chrome/Firefox/Safari + version]
- Framework: [React/Vue/Angular/Vanilla]
- Project: [Project name]

---

## Investigation Process

### Phase 1: Initial Observations

**Browser State Captured**:
- Snapshot: ✅ | ❌
- Screenshot: ✅ | ❌
- Console messages: ✅ | ❌
- Network activity: ✅ | ❌

**Console Errors**:
```
[Paste console errors here, or "None" if clean]
```

**Network Failures**:
```
[List failed requests with status codes, or "None" if all successful]
```

**UI State**:
[Describe what was visible/not visible, any visual issues]

**Screenshots**:
- Before: `[path/to/before.png]`
- Issue state: `[path/to/issue.png]`

---

### Phase 2: Root Cause Analysis

**Investigation Tools Used**:
- [ ] Chrome DevTools MCP (snapshot, console, network)
- [ ] Sequential Thinking MCP (complex reasoning)
- [ ] Context7 MCP (framework patterns)
- [ ] Code exploration (Read, Grep)
- [ ] Playwright MCP (cross-browser testing)

**Hypothesis Formation**:

**Primary Cause**:
[Detailed explanation of why the issue occurs]

**Contributing Factors**:
1. [Factor 1]
2. [Factor 2]
3. [Factor 3]

**Confidence Score**: [0.0 - 1.0]

**Evidence Supporting Root Cause**:
- [Evidence 1]
- [Evidence 2]
- [Evidence 3]

**Files/Components Involved**:
- `[path/to/file1.js]:[line-numbers]`
- `[path/to/file2.tsx]:[line-numbers]`

---

### Phase 3: Attempted Fixes

#### Attempt 1
**Fix Description**:
[What was changed and why]

**Files Modified**:
- `[file1]:[lines]`
- `[file2]:[lines]`

**Reasoning**:
[Why this approach was chosen]

**Result**: ✅ Success | ❌ Failed

**Verification**:
- Console: ✅ | ❌
- Network: ✅ | ❌
- UI State: ✅ | ❌
- Interaction: ✅ | ❌

**Failure Reason** (if failed):
[Why this didn't work]

---

#### Attempt 2
[Repeat structure for additional attempts]

---

### Phase 4: Final Resolution

**Successful Fix Applied**:
[Detailed description of what ultimately worked]

**Code Changes**:

```javascript
// Before:
[paste original code]

// After:
[paste fixed code]
```

**Files Modified**:
- `[file1]:[lines]` - [description of change]
- `[file2]:[lines]` - [description of change]

**Why This Worked**:
[Explanation of why this fix resolved the issue]

---

### Phase 5: Empirical Verification

**Verification Checklist**:
- [✅/❌] UI State: Visual appearance matches expected
- [✅/❌] Console: No errors or warnings related to fix
- [✅/❌] Network: All requests succeed (200/201/204)
- [✅/❌] Interaction: User flow completes successfully
- [✅/❌] Regression: Related features still work

**Screenshots After Fix**:
- After: `[path/to/after.png]`
- Comparison: Before vs After

**Console Output** (after fix):
```
[Console output showing clean state]
```

**Network Activity** (after fix):
```
[Network requests showing successful responses]
```

---

## Lessons Learned

**What Was Learned**:
[Key insights from this debugging session]

**Pattern Identified**:
[If this represents a recurring pattern]

**Framework-Specific Quirk**:
[Any framework-specific behavior discovered]

**Project-Specific Context**:
[Any project-specific information learned]

---

## Prevention Artifacts

### Test Cases Created

**File**: `[path/to/test-file.test.js]`

**Test Description**:
[What the test validates]

**Test Code**:
```javascript
describe('[Feature]', () => {
  it('should [expected behavior]', async () => {
    // Test implementation
  });
});
```

---

### Documentation Updates

**Files Updated**:
- `[docs/file1.md]` - [description of update]
- `[README.md]` - [description of update]

**New Documentation Created**:
- `[docs/debugging-guides/feature.md]` - [description]

---

### Code Comments Added

**Location**: `[file]:[line]`

**Comment**:
```javascript
// [Explanation of fix and why it was needed]
```

---

## Knowledge Base Updates

**Learned Patterns**:
- Pattern: [Description]
- Solution: [How to recognize and fix]
- Confidence: [0.0-1.0]

**Framework Quirks**:
- Framework: [React/Vue/Angular]
- Quirk: [Specific behavior]
- Workaround: [How to handle]

**Project-Specific**:
- Project: [Name]
- Context: [Specific context]
- Notes: [Important details]

---

## Recommendations

**Immediate Actions**:
1. [Action 1]
2. [Action 2]

**Long-term Improvements**:
1. [Improvement 1]
2. [Improvement 2]

**Architectural Considerations**:
[Any high-level architectural suggestions]

**Process Improvements**:
[Any suggestions for preventing similar issues]

---

## Metrics

**Time Breakdown**:
- Investigation: [X minutes]
- Analysis: [X minutes]
- Implementation: [X minutes]
- Verification: [X minutes]
- Documentation: [X minutes]
- **Total**: [X minutes]

**Iterations**: [Number of fix attempts]

**Tools Used**: [List of tools/MCPs utilized]

**Confidence Score Evolution**:
- Initial: [0.0-1.0]
- After Investigation: [0.0-1.0]
- Final: [0.0-1.0]

---

## Escalation Details (if escalated)

**Escalation Reason**:
- [ ] Time limit exceeded (>20 minutes)
- [ ] Confidence critically low (<30%)
- [ ] No progress over multiple iterations
- [ ] Infrastructure issues unresolvable
- [ ] Browser/tooling failures

**Attempted Solutions**:
[Summary of what was tried]

**Blockers Encountered**:
[What prevented resolution]

**Recommendations for Human Review**:
[Specific areas needing human expertise]

**Next Steps**:
[Suggested approach for human developer]

---

## Session Artifacts

**Browser Session Details**:
- User Data Dir: `[path]`
- Port: `[port-number]`
- Isolated: ✅ | ❌

**Session State File**: `[.debug-session-{id}.json]`

**Cleanup Status**: ✅ Completed | ⏳ Pending

---

## Additional Notes

[Any other relevant information]

---

**Generated by**: Frontend Debug Skill v1.0.0
**Report Generated**: {timestamp}
