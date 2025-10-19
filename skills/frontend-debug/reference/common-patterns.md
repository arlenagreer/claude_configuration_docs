# Common Frontend Issue Patterns

## Investigation Decision Tree

```
Issue Reported
    ├─ Visual/Layout Issue?
    │   ├─ Take screenshot
    │   ├─ Inspect element styles
    │   └─ Check responsive breakpoints
    │
    ├─ Interaction Issue (clicks not working)?
    │   ├─ Take snapshot
    │   ├─ Check console for errors
    │   ├─ Inspect event listeners in DevTools
    │   └─ Verify element exists and is visible
    │
    ├─ Data Not Loading?
    │   ├─ Check network tab for failed requests
    │   ├─ Verify API endpoint and auth headers
    │   └─ Check console for state management errors
    │
    ├─ Performance Issue (slow/laggy)?
    │   ├─ Start performance trace
    │   ├─ Analyze Core Web Vitals
    │   └─ Check for memory leaks
    │
    └─ Authentication/Permission Issue?
        ├─ Verify credentials used
        ├─ Check network for auth failures (401/403)
        └─ Inspect localStorage/cookies for tokens
```

---

## Pattern 1: Event Handler Not Working

### Symptoms
- Clicks don't trigger actions
- Forms don't submit
- No console errors
- Element exists in DOM

### Investigation Steps
1. **Verify element exists**
   ```javascript
   take_snapshot()
   // Check if element UID is present
   ```

2. **Check event listeners**
   ```javascript
   evaluate_script(`(el) => {
     const listeners = getEventListeners(el);
     return Object.keys(listeners);
   }`, [{uid: "element-uid"}])
   ```

3. **Try interaction**
   ```javascript
   click("Button", "uid-123")
   list_console_messages(true)
   ```

### Common Causes
- Event listener not attached (framework lifecycle issue)
- Element is disabled or overlayed
- Event propagation stopped somewhere
- Wrong selector used in event delegation

### Framework-Specific
- **React**: Check useEffect dependencies, stale closures
- **Vue**: Check v-on directive, event modifiers
- **Angular**: Check (click) binding, change detection

---

## Pattern 2: API Data Not Loading

### Symptoms
- UI shows loading state indefinitely
- Empty data displayed
- No visual errors
- Console may show errors

### Investigation Steps
1. **Check network requests**
   ```javascript
   list_network_requests(["xhr", "fetch"])
   ```

2. **Inspect failed requests**
   ```javascript
   // Look for status codes: 400, 401, 403, 404, 500
   get_network_request("https://api.example.com/endpoint")
   ```

3. **Check console for errors**
   ```javascript
   list_console_messages(true)
   ```

4. **Verify auth state**
   ```javascript
   evaluate_script("() => localStorage.getItem('token')")
   evaluate_script("() => document.cookie")
   ```

### Common Causes
- CORS errors (blocked by browser)
- Missing/expired authentication token
- Wrong API endpoint URL
- Network timeout
- Backend service down

### Solutions
- Fix CORS headers on backend
- Refresh auth token before request
- Verify endpoint URL matches backend
- Add retry logic with exponential backoff
- Check backend service status

---

## Pattern 3: UI Not Updating After State Change

### Symptoms
- Action completes successfully
- Network request succeeds
- UI doesn't reflect changes
- Stale data displayed

### Investigation Steps
1. **Verify request succeeded**
   ```javascript
   list_network_requests(["xhr", "fetch"])
   // Check for 200/201 status
   ```

2. **Check state updates**
   ```javascript
   // React DevTools
   evaluate_script("() => window.__REACT_DEVTOOLS_GLOBAL_HOOK__")

   // Vue DevTools
   evaluate_script("() => window.__VUE_DEVTOOLS_GLOBAL_HOOK__")

   // Generic state inspection
   evaluate_script("() => window.__STATE__") // if exposed
   ```

3. **Check for re-render**
   ```javascript
   take_screenshot("before-state-change.png")
   // trigger state change
   wait_for("Expected text", 5000)
   take_screenshot("after-state-change.png")
   ```

### Common Causes
- State mutation instead of immutable update
- Component not subscribed to state changes
- React: Missing key in list rendering
- Vue: Reactivity caveats (nested objects, arrays)
- Angular: Change detection not triggered

### Framework-Specific Solutions
- **React**: Use setState/useState properly, check keys in lists
- **Vue**: Use Vue.set() or array methods for reactivity
- **Angular**: Trigger change detection manually if needed

---

## Pattern 4: Form Validation/Submission Issues

### Symptoms
- Form doesn't submit
- Validation errors not showing
- Submit button disabled incorrectly
- Data not reaching backend

### Investigation Steps
1. **Check form state**
   ```javascript
   take_snapshot()
   // Verify input UIDs and values
   ```

2. **Fill form programmatically**
   ```javascript
   fill_form([
     {uid: "email-uid", value: "test@example.com"},
     {uid: "password-uid", value: "password123"}
   ])
   ```

3. **Attempt submission**
   ```javascript
   click("Submit button", "submit-uid")
   list_console_messages(true)
   list_network_requests(["xhr", "fetch"])
   ```

4. **Check validation logic**
   ```javascript
   evaluate_script("() => {
     const form = document.querySelector('form');
     return form.checkValidity();
   }")
   ```

### Common Causes
- HTML5 validation blocking submission
- JavaScript validation errors
- Submit handler missing/broken
- Form action URL incorrect
- CSRF token missing

### Solutions
- Fix validation logic
- Add proper error message display
- Verify submit handler attached
- Check form action/endpoint
- Include CSRF token in request

---

## Pattern 5: Styling/Layout Broken

### Symptoms
- Elements misaligned
- Content overlapping
- Responsive breakpoints not working
- CSS not applied

### Investigation Steps
1. **Visual inspection**
   ```javascript
   take_screenshot("png", true) // full page
   resize_page(375, 667)  // mobile
   take_screenshot("mobile.png")
   ```

2. **Inspect element styles**
   ```javascript
   evaluate_script(`(el) => {
     const styles = window.getComputedStyle(el);
     return {
       display: styles.display,
       position: styles.position,
       width: styles.width,
       height: styles.height
     };
   }`, [{uid: "element-uid"}])
   ```

3. **Check CSS load**
   ```javascript
   list_network_requests(["stylesheet"])
   ```

### Common Causes
- CSS file failed to load
- CSS specificity conflict
- Missing vendor prefixes
- z-index stacking issues
- Flexbox/Grid misunderstanding

### Solutions
- Verify CSS file loads successfully
- Increase selector specificity or use !important
- Add vendor prefixes for older browsers
- Fix z-index hierarchy
- Review layout documentation

---

## Pattern 6: Authentication Redirect Loop

### Symptoms
- Constant redirects between login/home
- Auth token present but not working
- 401 errors despite logged in

### Investigation Steps
1. **Check redirect pattern**
   ```javascript
   navigate_page("https://app.example.com/dashboard")
   // Observe if redirected to login
   take_snapshot()
   ```

2. **Inspect auth state**
   ```javascript
   evaluate_script("() => localStorage.getItem('token')")
   evaluate_script("() => sessionStorage.getItem('user')")
   ```

3. **Check network auth headers**
   ```javascript
   list_network_requests(["xhr", "fetch"])
   // Look for Authorization headers
   ```

### Common Causes
- Token expired but not refreshed
- Token not included in request headers
- Backend doesn't recognize token format
- Cookie domain mismatch
- CORS credentials not included

### Solutions
- Implement token refresh logic
- Add token to Authorization header
- Verify token format matches backend expectation
- Fix cookie domain configuration
- Add credentials: 'include' to fetch

---

## Pattern 7: Memory Leak / Performance Degradation

### Symptoms
- App slows down over time
- High memory usage
- Browser becomes unresponsive
- Animations janky

### Investigation Steps
1. **Capture performance baseline**
   ```javascript
   performance_start_trace(true, false)
   // Use app normally for 30 seconds
   performance_stop_trace()
   ```

2. **Analyze insights**
   ```javascript
   performance_analyze_insight("LCPBreakdown")
   performance_analyze_insight("DocumentLatency")
   ```

3. **Check for leaks**
   ```javascript
   // Repeat action multiple times and observe memory
   evaluate_script("() => performance.memory.usedJSHeapSize")
   ```

### Common Causes
- Event listeners not removed
- Timers/intervals not cleared
- Large objects retained in closures
- DOM nodes referenced but detached
- Infinite loops in effects/watchers

### Solutions
- Remove event listeners in cleanup
- Clear timers/intervals when component unmounts
- Break references to large objects
- Clean up DOM references
- Add guards to prevent infinite loops

---

## Pattern 8: CORS Errors

### Symptoms
- Network requests fail
- Console shows CORS error
- Preflight OPTIONS request fails

### Investigation Steps
1. **Check console**
   ```javascript
   list_console_messages()
   // Look for "CORS policy" errors
   ```

2. **Inspect network**
   ```javascript
   list_network_requests(["xhr", "fetch"])
   // Check for failed OPTIONS or actual request
   ```

3. **Check request headers**
   ```javascript
   get_network_request("https://api.example.com/endpoint")
   // Review request headers and response headers
   ```

### Common Causes
- Backend missing CORS headers
- Preflight request not handled
- Credentials mode mismatch
- Custom headers not allowed

### Solutions (Backend)
- Add Access-Control-Allow-Origin header
- Handle OPTIONS preflight requests
- Add Access-Control-Allow-Credentials
- Add custom headers to Access-Control-Allow-Headers

### Solutions (Frontend)
- Don't send custom headers if not needed
- Use credentials: 'include' only if needed
- Consider proxy for development

---

## Quick Diagnostic Checklist

Use this for every issue:

```
[ ] Console clean of errors?
[ ] Network requests all successful (200/201)?
[ ] Element exists in DOM (via snapshot)?
[ ] Expected text/content visible on page?
[ ] Visual state matches expected (screenshot)?
[ ] Authentication token present and valid?
[ ] No CORS errors?
[ ] No JavaScript errors?
[ ] Performance acceptable (if relevant)?
[ ] Mobile responsive (if relevant)?
```

If ALL checkboxes pass → Issue resolved
If ANY checkbox fails → Continue investigation
