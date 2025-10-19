# Chrome DevTools MCP - Quick Reference

## Navigation Tools

### navigate_page(url, timeout?)
Navigate to a URL. Waits for page load.

```javascript
navigate_page("https://example.com")
navigate_page("https://example.com", 30000) // with timeout
```

### navigate_page_history(direction, timeout?)
Go back or forward in browser history.

```javascript
navigate_page_history("back")
navigate_page_history("forward")
```

---

## State Capture Tools

### take_snapshot()
Get text representation of page accessibility tree. Essential for understanding page structure.

```javascript
take_snapshot()
// Returns: structured text with element roles, names, UIDs
```

**When to use**: Always capture snapshot before interaction to identify element UIDs.

### take_screenshot(format?, fullPage?, filename?)
Capture visual state of page.

```javascript
take_screenshot("png", false) // viewport only
take_screenshot("png", true)  // full page scroll
take_screenshot("png", true, "before-fix.png") // with filename
```

**Formats**: "png" | "jpeg" | "webp"

### list_console_messages(onlyErrors?)
Get all console logs, warnings, errors.

```javascript
list_console_messages()        // all messages
list_console_messages(true)    // errors only
```

**Returns**: Array of {type, message, timestamp, source}

### list_network_requests(resourceTypes?, pageIdx?, pageSize?)
Get network activity since page load.

```javascript
list_network_requests()                          // all requests
list_network_requests(["xhr", "fetch"])         // API calls only
list_network_requests(["document", "script"])   // page resources
```

**Resource Types**: "document", "stylesheet", "image", "media", "font", "script", "xhr", "fetch", "websocket"

### get_network_request(url)
Get detailed info for specific request.

```javascript
get_network_request("https://api.example.com/users")
// Returns: headers, payload, response, timing, status
```

---

## Interaction Tools

### click(element, uid, button?, doubleClick?)
Click an element (from snapshot).

```javascript
click("Login button", "uid-123")
click("Menu item", "uid-456", "right")      // right-click
click("Toggle", "uid-789", "left", true)    // double-click
```

**Buttons**: "left" | "right" | "middle"

### fill(element, uid, value)
Fill input, textarea, or select.

```javascript
fill("Email input", "uid-123", "admin@example.com")
fill("Password", "uid-456", "SecurePass123!")
fill("Dropdown", "uid-789", "Option 2")
```

### fill_form(elements)
Fill multiple fields at once.

```javascript
fill_form([
  {uid: "uid-123", value: "admin@example.com"},
  {uid: "uid-456", value: "SecurePass123!"}
])
```

### hover(element, uid)
Hover over element (triggers hover states).

```javascript
hover("Menu item", "uid-123")
```

### drag(startElement, startUid, endElement, endUid)
Drag and drop.

```javascript
drag("Task card", "uid-123", "Done column", "uid-456")
```

### upload_file(element, uid, filePath)
Upload file through file input.

```javascript
upload_file("File input", "uid-123", "/Users/user/documents/file.pdf")
```

---

## Advanced Analysis

### evaluate_script(function, args?)
Execute JavaScript in page context.

```javascript
evaluate_script("() => document.title")
evaluate_script("() => localStorage.getItem('token')")
evaluate_script("(el) => el.innerText", [{uid: "uid-123"}])
```

**Returns**: JSON-serializable result

### performance_start_trace(reload?, autoStop?)
Start performance recording.

```javascript
performance_start_trace(true, false)   // reload page and keep recording
performance_start_trace(false, true)   // current page, auto-stop
```

### performance_stop_trace()
Stop recording and get analysis.

```javascript
performance_stop_trace()
// Returns: Core Web Vitals, performance insights, bottlenecks
```

### performance_analyze_insight(insightName)
Get detailed info on specific performance insight.

```javascript
performance_analyze_insight("LCPBreakdown")
performance_analyze_insight("DocumentLatency")
```

**Common Insights**: "LCPBreakdown", "DocumentLatency", "RenderBlocking", "SlowCSSSelector"

---

## Emulation & Testing

### emulate_network(throttlingOption)
Simulate network conditions.

```javascript
emulate_network("No emulation")
emulate_network("Offline")
emulate_network("Slow 3G")
emulate_network("Fast 3G")
emulate_network("Slow 4G")
emulate_network("Fast 4G")
```

### emulate_cpu(throttlingRate)
Simulate CPU slowdown (1-20x).

```javascript
emulate_cpu(1)   // no throttling
emulate_cpu(4)   // 4x slower
emulate_cpu(20)  // 20x slower
```

### resize_page(width, height)
Change viewport size.

```javascript
resize_page(375, 667)  // iPhone SE
resize_page(1920, 1080) // Desktop
```

---

## Tab/Page Management

### list_pages()
Get all open tabs/pages.

```javascript
list_pages()
// Returns: [{index, title, url, selected}, ...]
```

### select_page(pageIdx)
Switch to different tab.

```javascript
select_page(0)  // switch to first tab
select_page(1)  // switch to second tab
```

### new_page(url, timeout?)
Open new tab.

```javascript
new_page("https://example.com")
```

### close_page(pageIdx?)
Close tab.

```javascript
close_page(1)   // close specific tab
close_page()    // close current tab
```

---

## Dialog Handling

### handle_dialog(action, promptText?)
Handle alert/confirm/prompt dialogs.

```javascript
handle_dialog("accept")
handle_dialog("dismiss")
handle_dialog("accept", "User input for prompt")
```

---

## Wait Operations

### wait_for(text, timeout?)
Wait for text to appear on page.

```javascript
wait_for("Welcome back!", 5000)
wait_for("Loading...", 10000)
```

---

## Investigation Workflow Patterns

### Pattern 1: Reproduce Issue
```javascript
1. take_snapshot()              // Get baseline state
2. take_screenshot()            // Visual baseline
3. click("Button", "uid-123")   // Interact
4. wait_for("Error message")    // Wait for symptom
5. list_console_messages(true)  // Check errors
6. list_network_requests()      // Check failed requests
```

### Pattern 2: Form Debugging
```javascript
1. take_snapshot()
2. fill_form([...])
3. click("Submit", "uid-456")
4. list_console_messages()
5. list_network_requests(["xhr", "fetch"])
6. take_screenshot("after-submit.png")
```

### Pattern 3: Performance Investigation
```javascript
1. performance_start_trace(true, false)
2. wait_for("Page loaded")
3. performance_stop_trace()
4. performance_analyze_insight("LCPBreakdown")
```

### Pattern 4: State Inspection
```javascript
1. evaluate_script("() => JSON.stringify(localStorage)")
2. evaluate_script("() => document.cookie")
3. evaluate_script("() => window.__STATE__")  // App-specific
```

---

## Common Gotchas

1. **Always take_snapshot() before interaction** - UIDs come from snapshot
2. **UIDs are ephemeral** - Re-take snapshot after page changes
3. **Network requests** - Cleared on navigation, capture before navigating
4. **Console messages** - Persist across navigations until browser restart
5. **Dialogs block execution** - Handle immediately with handle_dialog()
6. **Screenshots** - Use fullPage=true for scrollable content
7. **evaluate_script** - Results must be JSON-serializable

---

## Resource Type Reference

| Type | Description | Use Case |
|------|-------------|----------|
| document | HTML pages | Page load analysis |
| stylesheet | CSS files | Style debugging |
| script | JavaScript files | Script loading issues |
| xhr | XMLHttpRequest | API calls (legacy) |
| fetch | Fetch API | API calls (modern) |
| image | Images | Asset loading |
| font | Web fonts | Font loading |
| websocket | WebSocket | Real-time features |
| media | Audio/Video | Media debugging |

---

## Error Codes Reference

| Status | Meaning | Common Cause |
|--------|---------|--------------|
| 200 | OK | Successful request |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Invalid payload |
| 401 | Unauthorized | Missing/invalid auth |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Wrong endpoint |
| 500 | Server Error | Backend error |
| 502 | Bad Gateway | Backend down |
| 503 | Service Unavailable | Server overload |

---

## Best Practices

✅ **DO**:
- Take snapshot before every interaction
- Capture console messages immediately after issue occurs
- Screenshot before and after for visual comparison
- Use specific resource type filters for network analysis
- Check both console AND network for complete picture

❌ **DON'T**:
- Reuse old UIDs after page updates
- Navigate away before capturing network requests
- Forget to handle dialogs (blocks execution)
- Skip error checking in console/network
- Assume issue is fixed without empirical verification
