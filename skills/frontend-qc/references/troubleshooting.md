# Frontend QA Troubleshooting Guide

## Common Chrome DevTools MCP Issues

### Connection Issues

**Symptom**: `Error: Unable to connect to Chrome DevTools`

**Causes**:
- Browser not running
- MCP server not configured
- Port conflicts

**Solutions**:
1. Verify browser is running: `mcp__chrome-devtools__list_pages`
2. Check MCP configuration in `.mcp.json`
3. Restart browser and MCP server
4. Check for port conflicts (default: 9222)

---

**Symptom**: `Error: Page not found` when trying to interact with page

**Causes**:
- Page closed or navigated away
- Wrong page index used
- Page crashed

**Solutions**:
1. List current pages: `mcp__chrome-devtools__list_pages`
2. Select correct page: `mcp__chrome-devtools__select_page` with valid index
3. Navigate to target URL: `mcp__chrome-devtools__navigate_page`
4. Check browser console for JavaScript errors

---

### Interaction Issues

**Symptom**: `Error: Element not found` when clicking or filling

**Causes**:
- Element not in current snapshot
- Element hidden or disabled
- Incorrect UID
- Element loaded after snapshot taken

**Solutions**:
1. Take fresh snapshot: `mcp__chrome-devtools__take_snapshot`
2. Verify element UID from new snapshot
3. Wait for element to load: `mcp__chrome-devtools__wait_for` with text
4. Check if element is in a modal or hidden section
5. Scroll element into view first if needed

---

**Symptom**: Fill operation fails silently (no error but value not set)

**Causes**:
- JavaScript validation blocking input
- Field is read-only or disabled
- Value format doesn't match expected pattern
- React/Vue controlled component not updating

**Solutions**:
1. Take screenshot to verify field state
2. Check browser console for validation errors
3. Try typing value character by character instead of paste
4. Verify field accepts the value format (e.g., date format)
5. Check if field has onBlur validation that clears invalid values

---

### Screenshot Issues

**Symptom**: Screenshot is blank or shows wrong content

**Causes**:
- Page still loading
- Wrong page selected
- Element off-screen
- JavaScript rendering issue

**Solutions**:
1. Wait for page load: `mcp__chrome-devtools__wait_for` with key text
2. Verify correct page selected: `mcp__chrome-devtools__list_pages`
3. Scroll to element before screenshot
4. Take full page screenshot instead: `fullPage: true`
5. Check if page requires authentication/navigation

---

### Timeout Issues

**Symptom**: `Error: Operation timed out`

**Causes**:
- Slow page load
- Network issues
- Heavy JavaScript execution
- Infinite loading states

**Solutions**:
1. Increase timeout: Pass higher `timeout` value (default: 30000ms)
2. Check network tab for slow requests
3. Verify page actually loads (not stuck in loading state)
4. Check browser console for JavaScript errors preventing completion
5. Try navigating to page again

---

## Application-Specific Issues

### Authentication Problems

**Symptom**: Can't log in to application

**Causes**:
- Wrong credentials
- Session expired
- CSRF token issues
- MFA/2FA enabled

**Solutions**:
1. Verify credentials from test-credentials.md
2. Clear browser cookies/storage
3. Navigate to login page fresh: `mcp__chrome-devtools__navigate_page`
4. Check if MFA is enabled (requires manual code entry)
5. Look for CSRF errors in browser console

---

**Symptom**: Logged out unexpectedly during testing

**Causes**:
- Session timeout
- Token expiration
- Browser cleared cookies
- Backend session invalidation

**Solutions**:
1. Re-authenticate using login flow
2. Check session duration in application settings
3. Use longer-lived test tokens if available
4. Enable "remember me" option during login

---

### Form Validation Issues

**Symptom**: Form won't submit (button disabled or no action)

**Causes**:
- Required fields not filled
- Validation errors not visible
- JavaScript validation blocking
- Network request failing

**Solutions**:
1. Take screenshot to check form state
2. Inspect button element for disabled state
3. Check browser console for validation errors
4. Verify all required fields have valid values
5. Check network tab for failed API requests

---

**Symptom**: Form submits but shows unexpected error

**Causes**:
- Backend validation different from frontend
- Data format mismatch
- Missing required backend fields
- API endpoint error

**Solutions**:
1. Check browser console for error details
2. Inspect network request/response in DevTools
3. Verify data format matches API expectations (dates, numbers, etc.)
4. Check if error message provides specific field information
5. Try submitting with minimal valid data first

---

### Modal/Dialog Issues

**Symptom**: Can't interact with modal content

**Causes**:
- Modal not fully rendered
- Wrong page context
- Modal in nested iframe
- Z-index stacking issues

**Solutions**:
1. Wait for modal appearance: `mcp__chrome-devtools__wait_for` with modal text
2. Take snapshot after modal opens
3. Verify modal elements in snapshot
4. Check if modal uses iframe (may need separate handling)
5. Take screenshot to confirm modal is visible

---

**Symptom**: Modal won't close

**Causes**:
- Close button not found
- Escape key disabled
- JavaScript preventing close
- Confirmation dialog blocking

**Solutions**:
1. Try clicking close button explicitly
2. Try clicking outside modal (if dismissible)
3. Use Escape key: Manually send Escape keypress
4. Check browser console for errors
5. Refresh page if stuck

---

### Table/Grid Issues

**Symptom**: Can't find row in table

**Causes**:
- Data not loaded yet
- Pagination issue
- Filters applied
- Search active

**Solutions**:
1. Wait for table to load: `mcp__chrome-devtools__wait_for` with expected text
2. Clear any active filters/search
3. Navigate through pages to find data
4. Take snapshot to verify table content
5. Check if data is actually in database

---

**Symptom**: Table actions don't work (sort, filter, pagination)

**Causes**:
- JavaScript not loaded
- Event handlers not attached
- API request failing
- State management issue

**Solutions**:
1. Wait for table to fully render
2. Check browser console for errors
3. Verify clicks are registering (console output)
4. Check network tab for API calls
5. Try refreshing page

---

## Performance Issues

**Symptom**: Tests running very slowly

**Causes**:
- Browser CPU throttling enabled
- Network throttling active
- Large page size
- Many concurrent operations

**Solutions**:
1. Disable CPU throttling: `mcp__chrome-devtools__emulate_cpu` with rate 1
2. Disable network throttling: `mcp__chrome-devtools__emulate_network` with "No emulation"
3. Close unused browser tabs
4. Run tests on smaller pages first
5. Reduce snapshot frequency

---

**Symptom**: Page crashes or becomes unresponsive

**Causes**:
- Memory leak
- Infinite loop in JavaScript
- Too many elements in DOM
- Resource exhaustion

**Solutions**:
1. Check browser console for memory warnings
2. Reload page: `mcp__chrome-devtools__navigate_page`
3. Test on fresh browser instance
4. Report issue to development team
5. Use smaller test data sets

---

## Debugging Workflow

### Basic Debugging Steps
1. **Reproduce the issue**: Can you consistently trigger the problem?
2. **Take snapshots**: Compare before/after state
3. **Check console**: Look for JavaScript errors or warnings
4. **Inspect network**: Check for failed API requests
5. **Screenshot evidence**: Capture visual proof of issue
6. **Simplify**: Remove variables to isolate root cause

### When to Report a Bug
- Issue is reproducible
- You have clear steps to reproduce
- You have screenshots/evidence
- Console errors are captured
- Network requests logged (if relevant)

### When to Request Help
- Can't reproduce issue consistently
- Issue only happens in specific browser/device
- Complex interaction patterns involved
- Timing-sensitive problems
- Authentication/permission issues

---

## Best Practices to Avoid Issues

1. **Always take fresh snapshots** before interactions
2. **Wait for page load** before starting tests
3. **Clear state between tests** (logout, clear storage)
4. **Use explicit waits** instead of arbitrary delays
5. **Verify actions completed** before moving to next step
6. **Handle dialogs immediately** when they appear
7. **Take screenshots liberally** for evidence
8. **Check console regularly** for errors
9. **Test in clean browser state** (no extensions interfering)
10. **Document weird behavior** even if tests pass
