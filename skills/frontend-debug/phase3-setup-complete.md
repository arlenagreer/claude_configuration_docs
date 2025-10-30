# Phase 3 Task 3.2: Setup Complete ✅

**Date**: 2025-10-23 13:35
**Test Application**: E-Commerce Checkout Flow
**Server URL**: http://localhost:3000

---

## Application Structure Created

```
test-ecommerce/
├── index.html                 ✅ Home page with product grid
├── checkout/
│   ├── cart.html             ✅ Shopping cart (state bug: localStorage key mismatch)
│   ├── shipping.html         ✅ Shipping form (state bug: undefined preferences, network bugs: CORS, timeout)
│   ├── payment.html          ✅ Payment form (network bug: 404 API, UI bugs: fixed width, missing ARIA, z-index)
│   └── confirmation.html     ✅ Order confirmation
├── js/
│   ├── main.js               ✅ 2.5MB bundle simulation (performance bug)
│   ├── cart-state.js         ✅ State management (localStorage key mismatch)
│   ├── api-client.js         ✅ API calls (404, CORS, timeout bugs)
├── css/
│   └── styles.css            ✅ Styles (fixed width, z-index bugs)
└── images/products/          ✅ Product images (no lazy-loading)
```

---

## Intentional Bugs Implemented

### Network Domain (3 bugs) 🌐
1. **404 Payment Endpoint** (`/api/payment/process` doesn't exist)
   - Location: `js/api-client.js:7-21`
   - Trigger: Submit payment form
   - Expected: Network specialist detects 404, suggests creating endpoint or updating URL

2. **CORS Error** (Cross-origin request to `https://shipping-api.example.com`)
   - Location: `js/api-client.js:25-39`
   - Trigger: Submit shipping form
   - Expected: Network specialist detects CORS, suggests proxy or CORS headers

3. **Timeout** (No timeout configured on address validation)
   - Location: `js/api-client.js:43-59`
   - Trigger: Submit shipping form (if endpoint slow)
   - Expected: Network specialist suggests adding timeout handling

### State Domain (2 bugs) 🔄
4. **Cart Persistence** (localStorage key mismatch: saves to 'shoppingCart', loads from 'cart')
   - Location: `js/cart-state.js:5-18`
   - Trigger: Add item to cart on index.html, navigate to cart.html
   - Expected: State specialist detects empty cart despite items added, identifies key mismatch

5. **Undefined Error** (`user.preferences` is undefined)
   - Location: `checkout/shipping.html:91-104`
   - Trigger: Page load attempts to access `state.user.preferences.defaultShipping`
   - Expected: State specialist detects undefined property access, suggests adding preferences object

### UI Domain (3 bugs) 🎨
6. **Mobile Viewport** (Fixed width `800px` doesn't fit mobile)
   - Location: `css/styles.css:58-66` `.payment-form`
   - Trigger: View payment form on mobile viewport (<800px)
   - Expected: UI specialist detects fixed width, suggests responsive design

7. **Z-Index Conflict** (Modal `z-index: 10` lower than overlay `z-index: 100`)
   - Location: `css/styles.css:91-115` `.modal` and `.overlay`
   - Trigger: Payment processing modal displays
   - Expected: UI specialist detects z-index conflict, suggests increasing modal z-index

8. **Accessibility** (Missing ARIA labels on payment form inputs)
   - Location: `checkout/payment.html:23-47`
   - Trigger: Screen reader or accessibility audit
   - Expected: UI specialist detects missing ARIA labels, suggests adding them

### Performance Domain (2 bugs) ⚡
9. **Large Bundle** (Simulated 2.5MB main.js with entire lodash)
   - Location: `js/main.js:1-10`
   - Trigger: Load any page
   - Expected: Performance specialist detects large bundle, suggests tree-shaking or code-splitting

10. **No Lazy Loading** (All product images load immediately)
    - Location: `index.html:23-35`
    - Trigger: Home page load
    - Expected: Performance specialist suggests lazy-loading for images

---

## Domain Relevance Scoring Expectations

Based on the intentional bugs, expected domain scoring:

```yaml
network_relevance: 0.9
  indicators:
    - API failures (404): +0.3
    - CORS errors: +0.3
    - Timeout issues: +0.2
  threshold: 0.6 ✅ WILL SPAWN

state_relevance: 0.8
  indicators:
    - Cart persistence issue: +0.4
    - Undefined errors: +0.4
  threshold: 0.6 ✅ WILL SPAWN

ui_relevance: 0.7
  indicators:
    - Mobile viewport issue: +0.3
    - Z-index conflict: +0.2
    - Accessibility violations: +0.2
  threshold: 0.6 ✅ WILL SPAWN

performance_relevance: 0.6
  indicators:
    - Large bundle: +0.3
    - No lazy-loading: +0.3
  threshold: 0.6 ✅ WILL SPAWN (borderline)
```

**All 4 specialists should spawn** (scores ≥0.6 threshold)

---

## Test Execution Plan

### Step 1: Reproduce Multi-Domain Issue
User symptom report: "Checkout flow is broken - cart is empty after adding items, payment fails with errors, and the app is slow on mobile"

### Step 2: Invoke frontend-debug Skill
```
@~/.claude/skills/frontend-debug/SKILL.md "Debug the checkout flow at http://localhost:3000. Users report: cart appears empty after adding items, payment processing fails, form doesn't fit on mobile, and the page loads slowly."
```

### Step 3: Observe Complexity Detection
- Skill analyzes symptoms
- Detects multi-domain issue (network + state + UI + performance)
- Calculates confidence score (<60% expected due to multiple interacting systems)
- Makes delegation decision

### Step 4: Verify Specialist Spawning
- If Task tool available: frontend-debug-agent spawns
- Agent performs domain relevance scoring
- All 4 specialists should spawn (scores >0.6)
- Specialists execute Phase 1-6 workflows

### Step 5: Validate Bug Discovery
Each specialist should find their domain-specific bugs:
- **network-specialist**: 404, CORS, timeout
- **state-specialist**: localStorage mismatch, undefined preferences
- **ui-specialist**: fixed width, z-index, missing ARIA
- **performance-specialist**: bundle size, lazy-loading

### Step 6: Check Aggregation
- Systemic issue detection: API endpoint changes (404 suggests backend changes)
- Bug prioritization: CRITICAL (404) > HIGH (state persistence) > MEDIUM (UI, performance)
- Fix recommendations provided
- Unified report generated

---

## Success Criteria

- [x] Test application created with 10 intentional bugs
- [x] Server running on http://localhost:3000
- [x] All 4 domains represented (network, state, UI, performance)
- [ ] Complexity detection correctly identifies multi-domain issue
- [ ] Confidence score calculated <60%
- [ ] All 4 specialists spawn (domain scores >0.6)
- [ ] Each specialist finds their domain-specific bugs
- [ ] Aggregation identifies systemic issue
- [ ] Bugs prioritized correctly
- [ ] Fix recommendations provided

---

## Next Steps

1. ✅ Test application setup complete
2. 🔄 Invoke frontend-debug skill with multi-domain symptom description
3. ⏳ Monitor complexity assessment and specialist spawning
4. ⏳ Validate bug discovery across all 4 domains
5. ⏳ Check aggregation quality and systemic issue detection

---

**Test Prepared By**: Implementation Specialist
**Ready for Execution**: YES
**Expected Duration**: 60-90 minutes (if all specialists execute in parallel)
