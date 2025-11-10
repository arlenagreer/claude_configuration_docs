# Phone Number Formats Reference

## Supported Input Formats

The text-message skill accepts phone numbers in various formats and automatically normalizes them for use with Apple Messages app.

### US/Canada Phone Numbers

**Standard Formats** (all equivalent):
```
5551234567
555-123-4567
(555) 123-4567
555.123.4567
1-555-123-4567
+1-555-123-4567
+15551234567
```

**Normalization Rules**:
- 10 digits → Add +1 prefix (US/Canada)
- 11 digits starting with 1 → Add + prefix
- Already has + prefix → Keep as-is
- Spaces, dashes, dots, parentheses → Removed during processing

### International Numbers

**E.164 Format** (preferred):
```
+44 20 7123 4567  (UK)
+81 3 1234 5678   (Japan)
+61 2 1234 5678   (Australia)
+49 30 12345678   (Germany)
```

**Normalization**:
- Keep + prefix
- Remove all spaces and special characters
- Result: +442071234567, +81312345678, etc.

## Output Format

All phone numbers are normalized to E.164 format before sending:

**Format**: `+[country code][area code][local number]`

**Examples**:
- Input: `(555) 123-4567` → Output: `+15551234567`
- Input: `555-123-4567` → Output: `+15551234567`
- Input: `+44 20 7123 4567` → Output: `+442071234567`

## Validation Rules

**Minimum Requirements**:
- At least 10 digits (after removing non-digit characters)
- Valid characters: 0-9, +, -, ., (, ), spaces

**Invalid Formats**:
- Less than 10 digits: `123-4567` ❌
- Non-numeric characters: `abc-defg` ❌
- Empty string: `` ❌

## Messages App Compatibility

The Apple Messages app handles both:
- **iMessage**: Sent over internet to Apple devices (blue bubbles)
- **SMS**: Sent via cellular network to any phone (green bubbles)

**Automatic Detection**:
- Messages app determines delivery method based on recipient
- iMessage used if recipient has Apple ID registered with that number
- SMS used for all other cases

**Number Format Notes**:
- Messages app accepts E.164 format (+15551234567)
- Also accepts local format (5551234567) for US numbers
- International numbers should always use + prefix

## Best Practices

1. **Use + Prefix**: Always include country code with + for international numbers
2. **Normalize Early**: Normalize phone numbers before validation
3. **Store E.164**: When storing phone numbers, use E.164 format
4. **Display Friendly**: Format for display (555) 123-4567 but send as +15551234567
5. **Validate Before Send**: Always validate phone number format before attempting to send

## Common Issues

### Issue: "Invalid phone number format"
**Cause**: Less than 10 digits or invalid characters
**Solution**: Ensure phone number has at least 10 digits

### Issue: Message sent but not delivered
**Cause**: Phone number valid but recipient unreachable
**Solution**: Check with user that phone number is correct

### Issue: International number fails
**Cause**: Missing + prefix or incorrect country code
**Solution**: Add + prefix and verify country code

## Phone Number Storage

When extracting phone numbers from Google Contacts:

```json
{
  "phones": [
    {
      "value": "555-123-4567",
      "type": "mobile"
    },
    {
      "value": "(555) 987-6543",
      "type": "home"
    }
  ]
}
```

**Processing**:
1. Prioritize "mobile" type for text messaging
2. Fall back to first phone number if no mobile
3. Normalize format before sending
4. Validate before proceeding

## Future Enhancements

Potential improvements for phone number handling:

- **Libphonenumber Integration**: Use Google's libphonenumber for robust parsing
- **Carrier Detection**: Identify carrier for SMS routing
- **Number Validation API**: Verify numbers are active/deliverable
- **Country Code Detection**: Auto-detect country from user's locale
- **Contact Sync**: Cache normalized numbers from contacts

---

*This reference ensures reliable phone number handling across all input formats and regions.*
