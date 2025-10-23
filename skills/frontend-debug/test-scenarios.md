# frontend-debug Complexity Escalation Test Scenarios

## Scenario 1: Simple Bug (Should NOT escalate)
**Input**: "Login button not responding"
**Root Cause**: Click handler missing
**Confidence**: 85%
**Expected**: Continue with skill-based fix
**Reason**: High confidence, single-domain (UI only)

## Scenario 2: Low Confidence (SHOULD escalate)
**Input**: "Login sometimes fails randomly"
**Root Cause**: Unknown timing issue
**Confidence**: 45%
**Expected**: Invoke frontend-debug-agent
**Reason**: Confidence <60%

## Scenario 3: Multi-Domain Issue (SHOULD escalate)
**Input**: "User data not persisting after login"
**Domains Affected**: Network (API), State (Redux), UI (rendering)
**Confidence**: 70%
**Expected**: Invoke frontend-debug-agent with specialists
**Reason**: Multiple interacting systems (network + state + UI)

## Scenario 4: Systemic Issue (SHOULD escalate)
**Input**: "All forms fail validation in production"
**Scope**: 8 different forms across application
**Files**: 12+ files need investigation
**Expected**: Invoke frontend-debug-agent
**Reason**: Systemic problem affecting multiple components, deep investigation required (>5 files)

## Scenario 5: Loop Escalation (Should escalate after iteration 1)
**Input**: "Checkout process broken"
**Iteration 1**: Fix applied, verification fails, confidence drops to 40%
**Expected**: Iteration 2 invokes frontend-debug-agent
**Reason**: Skill-based fix insufficient, confidence <50%, escalate to agent

## Scenario 6: Multiple Unrelated Issues (SHOULD escalate)
**Input**: "Debug login failing AND checkout page crashing"
**Issues**: 2 separate unrelated problems
**Expected**: Invoke frontend-debug-agent with parallel specialists
**Reason**: Multiple issues indicator - need parallel investigation

## Scenario 7: Specialized Domain Request (SHOULD escalate)
**Input**: "Need deep performance analysis of dashboard rendering"
**User Request**: Explicit specialized domain analysis
**Expected**: Invoke frontend-debug-agent with performance specialist
**Reason**: User explicitly requests specialized domain-specific investigation

## Scenario 8: High-Confidence Single-Domain (Should NOT escalate)
**Input**: "Button color is wrong"
**Root Cause**: CSS class mismatch
**Confidence**: 95%
**Domains**: UI only
**Expected**: Continue with skill-based fix
**Reason**: High confidence (95%), single domain, straightforward fix

## Validation Checklist

- [ ] Scenario 1: Correctly continues with skill (high confidence, single domain)
- [ ] Scenario 2: Correctly escalates (low confidence <60%)
- [ ] Scenario 3: Correctly escalates (multi-domain: network + state + UI)
- [ ] Scenario 4: Correctly escalates (systemic issue, >5 files)
- [ ] Scenario 5: Correctly escalates after iteration 1 failure
- [ ] Scenario 6: Correctly escalates (multiple unrelated issues)
- [ ] Scenario 7: Correctly escalates (explicit specialized request)
- [ ] Scenario 8: Correctly continues with skill (high confidence, simple fix)
- [ ] All escalation decisions follow complexity indicators
- [ ] Agent invocation pattern includes all required context
- [ ] Loop behavior correctly escalates on iteration 1 failure
