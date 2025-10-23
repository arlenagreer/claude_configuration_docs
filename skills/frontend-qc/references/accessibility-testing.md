# Accessibility Testing Checklist

## Keyboard Navigation

- [ ] All interactive elements reachable via Tab
- [ ] Tab order is logical and intuitive
- [ ] Shift+Tab goes backward correctly
- [ ] Enter activates buttons/links
- [ ] Space toggles checkboxes
- [ ] Arrow keys work in lists/grids
- [ ] Escape closes modals/menus
- [ ] No keyboard traps

## Focus Management

- [ ] Focus indicator clearly visible
- [ ] Focus contrast meets WCAG standards
- [ ] Focus doesn't disappear
- [ ] Focus order matches visual layout
- [ ] Skip navigation link available
- [ ] Focus moves to modals when opened
- [ ] Focus returns on modal close

## Screen Reader Compatibility

- [ ] ARIA labels on interactive elements
- [ ] Landmark regions defined (main, nav, etc.)
- [ ] Headings hierarchy correct (h1→h2→h3)
- [ ] Form labels associated with inputs
- [ ] Alt text on images
- [ ] Error announcements clear
- [ ] Dynamic content announced
- [ ] State changes announced

## Visual Accessibility

- [ ] Color contrast ≥4.5:1 for normal text
- [ ] Color contrast ≥3:1 for large text
- [ ] No color-only information
- [ ] Text resizable to 200% without breaking
- [ ] UI works with browser zoom
- [ ] Icons have text alternatives
- [ ] Focus visible without color alone

## Motion & Animation

- [ ] Respects prefers-reduced-motion
- [ ] Animations can be paused
- [ ] No auto-playing videos
- [ ] No flashing content (seizure risk)

## Forms Accessibility

- [ ] Required fields indicated
- [ ] Error messages descriptive
- [ ] Errors associated with fields
- [ ] Help text available
- [ ] Fieldsets for grouped inputs
- [ ] Autocomplete attributes present

## Links & Buttons

- [ ] Link purpose clear from text
- [ ] "Click here" avoided
- [ ] Buttons vs links used correctly
- [ ] Disabled state announced
- [ ] Link targets indicated (_blank)

## Tables

- [ ] Table headers (th) defined
- [ ] Complex tables have scope attributes
- [ ] Caption or aria-label present
- [ ] Data relationships clear

## Testing Tools

**Quick checks:**
- Browser DevTools accessibility inspector
- Keyboard-only navigation
- Zoom to 200%
- Screen reader (VoiceOver on Mac, NVDA on Windows)

**Automated checks:**
- axe DevTools browser extension
- Lighthouse accessibility audit
- WAVE browser extension
