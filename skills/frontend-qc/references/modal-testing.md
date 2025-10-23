# Modal/Dialog Testing Checklist

## Opening/Closing

- [ ] Modal opens with trigger action
- [ ] Modal appears centered on screen
- [ ] Background overlay appears
- [ ] Page scroll disabled when modal open
- [ ] Close button works
- [ ] Escape key closes modal
- [ ] Click outside closes modal (if applicable)
- [ ] Modal closes after successful action

## Content Display

- [ ] Title/header displays correctly
- [ ] Content renders completely
- [ ] Scrollable if content exceeds viewport
- [ ] Loading states shown (if applicable)
- [ ] Images/media load correctly
- [ ] Dynamic content updates properly

## Form Modals

- [ ] All form elements functional
- [ ] Validation works correctly
- [ ] Submit button behavior correct
- [ ] Cancel button returns to previous state
- [ ] Form data persists if modal reopened
- [ ] Success feedback clear
- [ ] Error handling works

## Focus Management

- [ ] Focus moves to modal on open
- [ ] Focus trapped within modal
- [ ] Tab order logical within modal
- [ ] Focus returns to trigger on close
- [ ] First focusable element receives focus

## Confirmation Dialogs

- [ ] Message clear and specific
- [ ] Confirm/Cancel buttons distinct
- [ ] Destructive actions clearly labeled
- [ ] Keyboard shortcuts work (Enter/Escape)
- [ ] Default button appropriate

## Nested Modals

- [ ] Second modal opens correctly
- [ ] Both modals display properly
- [ ] Closing sequence correct
- [ ] Focus management works
- [ ] Background interactions blocked

## Accessibility

- [ ] ARIA role="dialog" present
- [ ] aria-modal="true" set
- [ ] Descriptive aria-label or aria-labelledby
- [ ] Screen reader announces modal
- [ ] Keyboard navigation complete

## Responsive Behavior

- [ ] Mobile view displays correctly
- [ ] Full-screen on small viewports (if needed)
- [ ] Touch interactions work
- [ ] Scrolling works on mobile

## Edge Cases

- [ ] Multiple rapid opens/closes handled
- [ ] Browser back button doesn't break state
- [ ] Page refresh doesn't show modal
- [ ] Modal over modal scenarios work
- [ ] Long content doesn't break layout
