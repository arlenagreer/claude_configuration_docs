# frontend-qc Complexity Detection Test Scenarios

## Scenario 1: Simple Case (Should NOT delegate)
**Input**: "Test the login form"
**Expected**: Continue with skill-based testing (no agent invocation)
**Reason**: 1 component only

## Scenario 2: Complex Case (SHOULD delegate)
**Input**: "Test login, registration, password reset, and profile pages"
**Expected**: Invoke frontend-qc-agent with 4 components
**Reason**: 4 components (>3 threshold)

## Scenario 3: Explicit Parallel Request (SHOULD delegate)
**Input**: "Test the checkout flow in parallel"
**Expected**: Invoke frontend-qc-agent even if <3 components
**Reason**: Explicit "parallel" keyword

## Scenario 4: Boundary Case (Should NOT delegate)
**Input**: "Test navigation, footer, and header"
**Expected**: Continue with skill (3 components = threshold, not exceeded)
**Reason**: Exactly 3 components (threshold is >3)

## Scenario 5: Multi-Workflow Campaign (SHOULD delegate)
**Input**: "Test the entire user onboarding flow and checkout process"
**Expected**: Invoke frontend-qc-agent
**Reason**: Multiple user workflows spanning multiple components

## Scenario 6: Time-Constrained Testing (SHOULD delegate)
**Input**: "Need to test dashboard, analytics, and reports quickly before deployment"
**Expected**: Invoke frontend-qc-agent
**Reason**: Time constraint indicator ("quickly before deployment")

## Validation Checklist

- [ ] Scenario 1 correctly continues with skill (no delegation)
- [ ] Scenario 2 correctly delegates to agent (>3 components)
- [ ] Scenario 3 correctly delegates due to "parallel" keyword
- [ ] Scenario 4 correctly continues with skill (exactly 3 components)
- [ ] Scenario 5 correctly delegates (multiple workflows)
- [ ] Scenario 6 correctly delegates (time constraint)
- [ ] All decision logic follows complexity indicators
- [ ] Agent invocation pattern includes all required context
