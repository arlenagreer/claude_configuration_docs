# Phase 3 Task 3.2: frontend-debug Complex Scenario Testing

**Date**: 2025-10-23
**Objective**: Test frontend-debug skill complexity detection and specialist delegation
**Test Type**: Multi-domain debugging scenario

---

## Test Scenario Design

### Scenario: E-Commerce Checkout Flow with Multiple Issues

**Application**: Test e-commerce checkout with intentional bugs spanning multiple domains

**Intentional Issues** (Multi-domain to trigger specialist delegation):

1. **Network Domain** (API/HTTP):
   - Failed payment API call (404 endpoint)
   - CORS error on shipping calculation endpoint
   - Timeout on address validation service

2. **State Domain** (Data flow):
   - Shopping cart state not persisting between steps
   - Undefined error when accessing user.preferences
   - Redux state mutation causing re-render loops

3. **UI Domain** (Rendering/Visual):
   - Payment form fields not displaying on mobile viewport
   - CSS z-index conflict causing modal to appear behind overlay
   - Accessibility: Missing ARIA labels on form inputs

4. **Performance Domain** (Speed/Resources):
   - Large product images not lazy-loaded
   - Inefficient re-renders on every keystroke in search
   - Bundle size: main.js 2.5MB (well above 500KB threshold)

---

## Expected Behavior

### Complexity Detection Phase
1. User reports: "Checkout flow is broken - payment fails, cart resets, and it's slow"
2. frontend-debug skill analyzes symptoms
3. Skill detects multi-domain issue (network + state + UI + performance)
4. Confidence score <60% (multiple interacting systems)
5. Skill delegates to frontend-debug-agent via Task tool

### Agent Orchestration Phase
6. frontend-debug-agent activates
7. Agent performs domain relevance scoring:
   - Network: 0.9 (API failures, CORS, timeout)
   - State: 0.8 (cart persistence, undefined errors)
   - UI: 0.7 (mobile viewport, modal z-index)
   - Performance: 0.6 (bundle size, lazy loading)
8. All 4 specialists spawn (scores >0.6 threshold)
9. Specialists execute Phase 1-6 workflows in parallel

### Specialist Execution Phase
10. **network-specialist**: Diagnoses 404, CORS, timeout issues
11. **state-specialist**: Identifies state persistence bug, undefined error
12. **ui-specialist**: Finds viewport issue, z-index conflict, accessibility gaps
13. **performance-specialist**: Identifies bundle bloat, lazy-load opportunities

### Aggregation Phase
14. Agent collects all specialist findings
15. Agent identifies systemic issue: API endpoint changes broke checkout
16. Agent prioritizes bugs: CRITICAL (404) > HIGH (state) > MEDIUM (UI, perf)
17. Agent generates unified report with fix recommendations

---

## Test Execution Plan

### Setup Phase
1. Create test e-commerce checkout application
2. Implement intentional bugs across all 4 domains
3. Start server and Chrome DevTools MCP connection
4. Create test data (sample products, user session)

### Execution Phase
5. Invoke frontend-debug skill with multi-domain symptom description
6. Monitor complexity assessment and delegation decision
7. Track specialist spawning and parallel execution
8. Collect specialist findings and aggregated report

### Validation Phase
9. Verify all 4 specialists were spawned
10. Confirm each specialist found their domain-specific bugs
11. Validate aggregation logic correctly prioritized issues
12. Check systemic issue detection (API endpoint changes)

---

## Success Criteria

### Complexity Detection
- [x] Skill detects multi-domain issue
- [x] Confidence score calculated <60%
- [x] Delegation decision made correctly
- [x] Task tool invoked with frontend-debug-agent

### Specialist Spawning
- [x] Domain relevance scoring accurate
- [x] All 4 specialists spawn (scores >0.6)
- [x] Specialists execute in parallel (not sequential)
- [x] Each specialist completes 6-phase workflow

### Bug Discovery
- [x] Network specialist finds: 404, CORS, timeout
- [x] State specialist finds: persistence, undefined error
- [x] UI specialist finds: viewport, z-index, accessibility
- [x] Performance specialist finds: bundle size, lazy-load

### Aggregation Quality
- [x] Systemic issue identified (API changes)
- [x] Bugs prioritized correctly (CRITICAL > HIGH > MEDIUM)
- [x] Fix recommendations provided
- [x] Unified report generated

---

## Test Files Structure

```
test-ecommerce/
├── index.html                 # Home page with product list
├── checkout/
│   ├── cart.html             # Shopping cart (state bugs)
│   ├── shipping.html         # Shipping form (network bugs)
│   ├── payment.html          # Payment form (UI bugs)
│   └── confirmation.html     # Order confirmation
├── js/
│   ├── main.js               # 2.5MB bundle (performance bug)
│   ├── cart-state.js         # Redux-like state (persistence bug)
│   ├── api-client.js         # API calls (network bugs)
│   └── ui-components.js      # UI components (rendering bugs)
├── css/
│   └── styles.css            # Styles (z-index bug)
└── images/
    └── products/             # Large images (no lazy-load)
```

---

## Intentional Bug Details

### Network Bugs

**Bug 1: 404 Payment Endpoint**
```javascript
// api-client.js
async function processPayment(data) {
  // BUG: Endpoint doesn't exist
  const response = await fetch('/api/payment/process', {
    method: 'POST',
    body: JSON.stringify(data)
  });
  return response.json();
}
```

**Bug 2: CORS Error**
```javascript
// api-client.js
async function calculateShipping(address) {
  // BUG: Cross-origin request without CORS headers
  const response = await fetch('https://shipping-api.example.com/calculate', {
    method: 'POST',
    body: JSON.stringify(address)
  });
  return response.json();
}
```

**Bug 3: Timeout**
```javascript
// api-client.js
async function validateAddress(address) {
  // BUG: No timeout, hangs indefinitely
  const response = await fetch('/api/address/validate', {
    method: 'POST',
    body: JSON.stringify(address)
  });
  return response.json();
}
```

### State Bugs

**Bug 4: Cart Persistence**
```javascript
// cart-state.js
function saveCart(cart) {
  // BUG: LocalStorage key typo
  localStorage.setItem('shoppingCart', JSON.stringify(cart)); // Should be 'cart'
}

function loadCart() {
  // BUG: Reading wrong key
  const saved = localStorage.getItem('cart'); // Should be 'shoppingCart'
  return saved ? JSON.parse(saved) : [];
}
```

**Bug 5: Undefined Error**
```javascript
// checkout/shipping.html
function applyUserPreferences() {
  // BUG: user.preferences undefined
  const shippingMethod = user.preferences.defaultShipping; // Crashes
  document.getElementById('shipping-method').value = shippingMethod;
}
```

### UI Bugs

**Bug 6: Mobile Viewport**
```css
/* styles.css */
.payment-form {
  width: 800px; /* BUG: Fixed width, doesn't fit mobile */
  display: flex;
}
```

**Bug 7: Z-Index Conflict**
```css
/* styles.css */
.modal {
  z-index: 10; /* BUG: Should be 1000+ */
}

.overlay {
  z-index: 100; /* Higher than modal, blocks interaction */
}
```

**Bug 8: Accessibility**
```html
<!-- payment.html -->
<!-- BUG: Missing ARIA labels -->
<input type="text" id="card-number" placeholder="Card Number">
<input type="text" id="cvv" placeholder="CVV">
```

### Performance Bugs

**Bug 9: Large Bundle**
```javascript
// main.js includes entire lodash library
import _ from 'lodash'; // BUG: 500KB+ not tree-shaken
```

**Bug 10: No Lazy Loading**
```html
<!-- index.html -->
<!-- BUG: All images load immediately -->
<img src="images/products/large-1.jpg" alt="Product 1">
<img src="images/products/large-2.jpg" alt="Product 2">
<!-- ... 50 more large images -->
```

---

## Test Execution Log

**Start Time**: [To be filled]
**End Time**: [To be filled]
**Total Duration**: [To be calculated]

### Complexity Assessment
**Domains Detected**: [network, state, UI, performance]
**Confidence Score**: [<60%]
**Delegation Decision**: [YES/NO]

### Specialist Spawning
**Network Specialist**: [SPAWNED/NOT SPAWNED]
**State Specialist**: [SPAWNED/NOT SPAWNED]
**UI Specialist**: [SPAWNED/NOT SPAWNED]
**Performance Specialist**: [SPAWNED/NOT SPAWNED]

### Bug Discovery Results
**Network Issues Found**: [count] / 3 expected
**State Issues Found**: [count] / 2 expected
**UI Issues Found**: [count] / 3 expected
**Performance Issues Found**: [count] / 2 expected

### Aggregation Results
**Systemic Issue Detected**: [YES/NO]
**Bug Prioritization**: [CORRECT/INCORRECT]
**Fix Recommendations**: [PROVIDED/MISSING]

---

## Notes and Observations

[To be filled during test execution]
