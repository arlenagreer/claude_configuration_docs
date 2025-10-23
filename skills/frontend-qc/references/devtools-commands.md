# Chrome DevTools MCP Commands

## Navigation

```javascript
mcp__chrome-devtools__navigate_page({ url: "http://localhost:3000" })
mcp__chrome-devtools__list_pages()  // See all open pages
mcp__chrome-devtools__select_page({ pageIdx: 0 })  // Switch pages
mcp__chrome-devtools__navigate_page_history({ navigate: "back" })
```

## Screenshots

```javascript
mcp__chrome-devtools__take_screenshot({ fullPage: true })
mcp__chrome-devtools__take_screenshot({ uid: "element-id" })  // Element screenshot
mcp__chrome-devtools__take_screenshot({ format: "png", quality: 90 })
```

## Page Inspection

```javascript
mcp__chrome-devtools__take_snapshot()  // Get page structure with UIDs
mcp__chrome-devtools__list_console_messages()  // Console errors/warnings
mcp__chrome-devtools__list_network_requests()  // Network activity
```

## Interaction

```javascript
mcp__chrome-devtools__click({ uid: "button-uid" })
mcp__chrome-devtools__click({ uid: "element-uid", dblClick: true })
mcp__chrome-devtools__fill({ uid: "input-uid", value: "test@example.com" })
mcp__chrome-devtools__hover({ uid: "element-uid" })
mcp__chrome-devtools__wait_for({ text: "Success message", timeout: 5000 })
```

## Form Testing

```javascript
mcp__chrome-devtools__fill_form({
  elements: [
    { uid: "email-input", value: "test@example.com" },
    { uid: "password-input", value: "password123" }
  ]
})
```

## Responsive Testing

```javascript
mcp__chrome-devtools__resize_page({ width: 375, height: 667 })   // Mobile
mcp__chrome-devtools__resize_page({ width: 768, height: 1024 })  // Tablet
mcp__chrome-devtools__resize_page({ width: 1920, height: 1080 }) // Desktop
```

## Dialog Handling

```javascript
mcp__chrome-devtools__handle_dialog({ action: "accept" })
mcp__chrome-devtools__handle_dialog({ action: "dismiss" })
mcp__chrome-devtools__handle_dialog({ action: "accept", promptText: "input text" })
```

## Key Workflow Pattern

1. Navigate to page
2. Take snapshot to get element UIDs
3. Interact with elements using UIDs
4. Re-snapshot after page updates (UIDs change on re-render)
5. Check console and network throughout
