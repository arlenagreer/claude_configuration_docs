# Form Testing Checklist

## Input Fields

- [ ] All text inputs accept valid input
- [ ] Required field validation works
- [ ] Email format validation (if applicable)
- [ ] Password strength validation (if applicable)
- [ ] Number inputs enforce numeric values
- [ ] Date inputs show proper picker
- [ ] Text length limits enforced
- [ ] Special characters handled correctly

## Dropdowns/Select Elements

- [ ] All options visible and selectable
- [ ] Default selection appropriate
- [ ] Required field validation works
- [ ] Search functionality (if applicable)
- [ ] Multi-select works (if applicable)

## Checkboxes & Radio Buttons

- [ ] Visual state changes on selection
- [ ] Required validation works
- [ ] Group behavior correct (radio exclusivity)
- [ ] Default selections appropriate

## Form Submission

- [ ] Submit with empty form → validation errors shown
- [ ] Submit with invalid data → specific error messages
- [ ] Submit with valid data → success feedback
- [ ] Loading state shown during submission
- [ ] Form disabled during submission
- [ ] Success message clear and accurate
- [ ] Error messages helpful and specific

## Error Handling

- [ ] Validation errors appear inline
- [ ] Error messages are clear and actionable
- [ ] Errors clear when corrected
- [ ] Form focus moves to first error
- [ ] Multiple errors shown simultaneously

## User Experience

- [ ] Tab order is logical
- [ ] Labels associated with inputs
- [ ] Placeholder text helpful
- [ ] Help text available where needed
- [ ] Required fields clearly marked
- [ ] Form can be reset/cleared

## Accessibility

- [ ] Keyboard navigation works
- [ ] ARIA labels present
- [ ] Error announcements for screen readers
- [ ] Focus management proper
- [ ] Color contrast sufficient

## Edge Cases

- [ ] Very long text inputs (>255 chars)
- [ ] Paste operations work correctly
- [ ] Browser autofill compatible
- [ ] Back button doesn't lose data
- [ ] Concurrent submissions prevented
