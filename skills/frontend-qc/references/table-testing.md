# Table/Grid Testing Checklist

## Data Display

- [ ] All columns render correctly
- [ ] Data aligns properly (left/right/center)
- [ ] Empty state displays when no data
- [ ] Loading state shows during fetch
- [ ] Long text truncates or wraps appropriately
- [ ] Dates/numbers formatted correctly

## Sorting

- [ ] Each sortable column has indicator
- [ ] Click column header to sort ascending
- [ ] Second click sorts descending
- [ ] Third click removes sort
- [ ] Sort state persists during pagination
- [ ] Multiple column sorting (if applicable)

## Pagination

- [ ] Page numbers display correctly
- [ ] Next/Previous buttons work
- [ ] First/Last page buttons work (if present)
- [ ] Current page highlighted
- [ ] Disabled state on first/last page
- [ ] Page size selector works (if applicable)
- [ ] Total count accurate

## Search/Filtering

- [ ] Search input responsive to typing
- [ ] Results filter in real-time or on submit
- [ ] No results state shown appropriately
- [ ] Clear search button works
- [ ] Filter persistence during actions
- [ ] Multiple filters work together
- [ ] Advanced filters work (if present)

## Row Selection

- [ ] Single row selection works
- [ ] Multi-row selection works (if applicable)
- [ ] Select all checkbox works
- [ ] Selection count displayed
- [ ] Selection cleared appropriately
- [ ] Selected state visually clear

## Bulk Actions

- [ ] Bulk action menu appears when rows selected
- [ ] Actions apply to all selected rows
- [ ] Confirmation prompt for destructive actions
- [ ] Progress indicator for bulk operations
- [ ] Success/failure feedback clear
- [ ] Selection cleared after action

## Interactive Elements

- [ ] Row click actions work (if applicable)
- [ ] Expand/collapse rows work (if applicable)
- [ ] Inline editing works (if applicable)
- [ ] Action buttons in rows work
- [ ] Context menus work (if applicable)

## Performance

- [ ] Large datasets (100+ rows) render smoothly
- [ ] Sorting is fast (<500ms)
- [ ] Filtering is responsive
- [ ] Scrolling is smooth
- [ ] No memory leaks during interaction

## Accessibility

- [ ] Keyboard navigation works (arrow keys)
- [ ] Tab order logical
- [ ] Row selection via keyboard
- [ ] Screen reader announces row count
- [ ] Column headers properly labeled

## Responsive Behavior

- [ ] Mobile view shows appropriate columns
- [ ] Horizontal scrolling works (if needed)
- [ ] Actions accessible on mobile
- [ ] Touch gestures work on mobile
