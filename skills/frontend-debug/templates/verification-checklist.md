# Verification Checklist Template

**Session ID**: {session-id}
**Issue**: [Brief description]
**Fix Applied**: [Brief description of fix]

---

## Pre-Verification Setup

- [ ] Refresh browser or restart if needed
- [ ] Clear console logs
- [ ] Clear network activity
- [ ] Return to starting point (e.g., login page, home page)
- [ ] Ensure fix has been properly deployed/rebuilt

---

## Criterion 1: UI State Verification

**Objective**: Visual appearance matches expected state

### Checks
- [ ] Elements are present where expected
- [ ] Elements are correctly styled (colors, fonts, spacing)
- [ ] Layout is correct (no overlapping, proper alignment)
- [ ] Responsive behavior works (if applicable)
- [ ] Animations/transitions work smoothly (if applicable)

### Visual Evidence
- [ ] Screenshot captured: `[path/to/screenshot.png]`
- [ ] Screenshot shows expected state
- [ ] Comparison with "before" screenshot confirms fix

### Notes
[Any observations about UI state]

**Status**: ✅ Pass | ❌ Fail

---

## Criterion 2: Console Verification

**Objective**: No errors or warnings related to the fix

### Checks
- [ ] No JavaScript errors in console
- [ ] No warnings related to the feature being fixed
- [ ] No deprecation warnings
- [ ] No network errors logged in console
- [ ] Expected log messages present (if any)

### Console Output
```
[Paste console output here]
```

### Error Analysis (if any errors present)
- Error: `[error message]`
- Related to fix? ✅ Yes | ❌ No
- Severity: Critical | High | Medium | Low

**Status**: ✅ Pass | ❌ Fail

---

## Criterion 3: Network Verification

**Objective**: All network requests succeed with appropriate status codes

### API Requests
- [ ] All API calls succeed (200/201/204)
- [ ] Request payloads are correct
- [ ] Response payloads contain expected data
- [ ] Response times are acceptable
- [ ] No CORS errors

### Network Analysis
| Endpoint | Method | Status | Time | Notes |
|----------|--------|--------|------|-------|
| [URL] | [GET/POST/etc] | [200/etc] | [ms] | [Pass/Fail] |

### Failed Requests (if any)
- URL: `[url]`
- Status: `[code]`
- Error: `[message]`
- Related to fix? ✅ Yes | ❌ No

**Status**: ✅ Pass | ❌ Fail

---

## Criterion 4: Interaction Verification

**Objective**: Complete user flow works end-to-end

### User Flow Steps
1. [ ] Step 1: [Description] - ✅ Pass | ❌ Fail
2. [ ] Step 2: [Description] - ✅ Pass | ❌ Fail
3. [ ] Step 3: [Description] - ✅ Pass | ❌ Fail
4. [ ] Step 4: [Description] - ✅ Pass | ❌ Fail
5. [ ] Step 5: [Description] - ✅ Pass | ❌ Fail

### Interaction Checks
- [ ] Buttons/links respond to clicks
- [ ] Forms accept input correctly
- [ ] Form submission works
- [ ] Navigation works as expected
- [ ] Keyboard navigation works (accessibility)
- [ ] Touch interactions work (mobile)

### Flow Completion
- [ ] User flow completes without errors
- [ ] Success state is reached
- [ ] User receives appropriate feedback

**Status**: ✅ Pass | ❌ Fail

---

## Criterion 5: Regression Check

**Objective**: Related features still work, no new issues introduced

### Related Features to Test
- [ ] Feature A: [Description] - ✅ Pass | ❌ Fail
- [ ] Feature B: [Description] - ✅ Pass | ❌ Fail
- [ ] Feature C: [Description] - ✅ Pass | ❌ Fail

### Core Workflows to Verify
- [ ] User login/authentication
- [ ] Main navigation
- [ ] Critical user actions
- [ ] Data persistence
- [ ] Third-party integrations

### New Issues Detected
| Issue | Severity | Related to Fix? | Action |
|-------|----------|----------------|--------|
| [Description] | [High/Med/Low] | ✅/❌ | [Fix/Log/Ignore] |

**Status**: ✅ Pass | ❌ Fail

---

## Overall Verification Result

**Summary**:
- UI State: ✅ | ❌
- Console: ✅ | ❌
- Network: ✅ | ❌
- Interaction: ✅ | ❌
- Regression: ✅ | ❌

**Overall Status**: ✅ ALL PASS | ❌ FAIL

**Confidence Score**: [0.0 - 1.0]

---

## Decision

### If ALL criteria pass:
- ✅ Issue is RESOLVED
- Proceed to documentation phase
- Generate investigation report
- Update knowledge base
- Close debugging session

### If ANY criteria fail:
- ❌ Continue iteration
- Document what failed and why
- Formulate new hypothesis
- Return to fix implementation phase
- Iteration count: [X of 5]

### If iteration limit reached:
- ⚠️ ESCALATE
- Generate comprehensive report
- Document all attempts and findings
- Provide recommendations for human review
- Preserve session state for follow-up

---

## Additional Verification (Optional)

### Performance Check
- [ ] Page load time: [X seconds] - ✅ Acceptable | ❌ Too slow
- [ ] Time to interactive: [X seconds]
- [ ] Core Web Vitals: [Pass/Fail]

### Accessibility Check
- [ ] Keyboard navigation works
- [ ] Screen reader compatible
- [ ] ARIA labels present
- [ ] Color contrast sufficient

### Cross-Browser Check (if applicable)
- [ ] Chrome: ✅ | ❌
- [ ] Firefox: ✅ | ❌
- [ ] Safari: ✅ | ❌
- [ ] Edge: ✅ | ❌

### Mobile Check (if applicable)
- [ ] iOS: ✅ | ❌
- [ ] Android: ✅ | ❌
- [ ] Responsive breakpoints: ✅ | ❌

---

## Notes & Observations

[Any additional observations during verification]

---

**Verified By**: Frontend Debug Skill v1.0.0
**Verification Date**: {timestamp}
**Total Verification Time**: [X minutes]
