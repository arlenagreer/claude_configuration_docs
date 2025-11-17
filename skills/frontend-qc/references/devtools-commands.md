# Chrome DevTools Skill Commands

## Navigation

```bash
Skill(chrome-devtools): navigate.rb "http://localhost:3000"
Skill(chrome-devtools): list.rb "pages"  # See all open pages
Skill(chrome-devtools): select.rb "0"  # Switch to page index 0
Skill(chrome-devtools): navigate.rb "back"  # Navigate back
```

## Screenshots

```bash
Skill(chrome-devtools): screenshot.rb "--full-page"
Skill(chrome-devtools): screenshot.rb "--element element-id"
Skill(chrome-devtools): screenshot.rb "--format png --quality 90"
```

## Page Inspection

```bash
Skill(chrome-devtools): snapshot.rb  # Get page structure with UIDs
Skill(chrome-devtools): console.rb "list"  # Console errors/warnings
Skill(chrome-devtools): network.rb "list"  # Network activity
```

## Interaction

```bash
Skill(chrome-devtools): click.rb "button-uid"
Skill(chrome-devtools): click.rb "element-uid" "--double"
Skill(chrome-devtools): fill.rb "input-uid" "test@example.com"
Skill(chrome-devtools): hover.rb "element-uid"
Skill(chrome-devtools): wait.rb "Success message" "5000"  # Wait for text with timeout
```

## Form Testing

```bash
# Fill multiple form fields sequentially
Skill(chrome-devtools): fill.rb "email-input" "test@example.com"
Skill(chrome-devtools): fill.rb "password-input" "password123"
Skill(chrome-devtools): click.rb "submit-button"
```

## Responsive Testing

```bash
Skill(chrome-devtools): resize.rb "375" "667"    # Mobile
Skill(chrome-devtools): resize.rb "768" "1024"   # Tablet
Skill(chrome-devtools): resize.rb "1920" "1080"  # Desktop
```

## Dialog Handling

```bash
Skill(chrome-devtools): dialog.rb "accept"
Skill(chrome-devtools): dialog.rb "dismiss"
Skill(chrome-devtools): dialog.rb "accept" "input text"  # With prompt text
```

## Key Workflow Pattern

1. Navigate to page
2. Take snapshot to get element UIDs
3. Interact with elements using UIDs
4. Re-snapshot after page updates (UIDs change on re-render)
5. Check console and network throughout
