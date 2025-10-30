# Google Contacts API Field Reference

Comprehensive documentation of all available contact fields in the Google People API v1.

## Field Categories

### Names

Primary identifier for contacts.

```json
{
  "name": {
    "given_name": "John",
    "family_name": "Doe",
    "middle_name": "Michael",
    "display_name": "John Doe",
    "prefix": "Dr.",
    "suffix": "Jr."
  }
}
```

**Fields**:
- `given_name` - First name
- `family_name` - Last name / surname
- `middle_name` - Middle name
- `display_name` - Full name for display
- `prefix` - Title (Dr., Mr., Ms., etc.)
- `suffix` - Suffix (Jr., Sr., III, etc.)

### Email Addresses

Contact email addresses with type classification.

```json
{
  "emails": [
    {"value": "john@work.com", "type": "work"},
    {"value": "john@personal.com", "type": "home"},
    {"value": "john@other.com", "type": "other"}
  ]
}
```

**Types**:
- `work` - Work/business email
- `home` - Personal email
- `other` - Other email address

### Phone Numbers

Contact phone numbers with type classification.

```json
{
  "phones": [
    {"value": "+1-555-1234", "type": "mobile"},
    {"value": "+1-555-5678", "type": "work"},
    {"value": "+1-555-9999", "type": "home"}
  ]
}
```

**Types**:
- `mobile` - Mobile/cell phone
- `work` - Work phone
- `home` - Home phone
- `main` - Main phone number
- `work_mobile` - Work mobile
- `home_fax` - Home fax
- `work_fax` - Work fax
- `other_fax` - Other fax
- `pager` - Pager
- `other` - Other phone

### Organizations

Employment and organization information.

```json
{
  "organization": {
    "name": "Acme Corporation",
    "title": "Senior Software Engineer",
    "department": "Engineering",
    "job_description": "Full-stack development",
    "symbol": "ACME",
    "domain": "acme.com",
    "location": "San Francisco, CA"
  }
}
```

**Fields**:
- `name` - Company/organization name
- `title` - Job title/position
- `department` - Department name
- `job_description` - Job description
- `symbol` - Stock symbol (if public company)
- `domain` - Company domain
- `location` - Office location

### Addresses

Physical addresses with type classification.

```json
{
  "addresses": [
    {
      "street": "123 Main Street",
      "city": "Springfield",
      "state": "Illinois",
      "zip": "62701",
      "country": "United States",
      "type": "home",
      "country_code": "US",
      "postal_code": "62701",
      "region": "IL",
      "street_address": "123 Main Street",
      "extended_address": "Apt 4B"
    }
  ]
}
```

**Fields**:
- `street` / `street_address` - Street address
- `extended_address` - Apartment, suite, etc.
- `city` - City name
- `state` / `region` - State/province
- `zip` / `postal_code` - ZIP/postal code
- `country` - Country name
- `country_code` - ISO country code
- `type` - Address type

**Types**:
- `home` - Home address
- `work` - Work address
- `other` - Other address

### Birthdays

Birthday information.

```json
{
  "birthday": {
    "year": 1990,
    "month": 5,
    "day": 15
  }
}
```

**Fields**:
- `year` - Birth year (optional, for privacy)
- `month` - Birth month (1-12)
- `day` - Birth day (1-31)

**Note**: Year can be omitted if contact prefers privacy.

### Biographies / Notes

Free-form text notes about the contact.

```json
{
  "notes": "Met at tech conference 2024. Interested in AI/ML collaboration."
}
```

Single text field for any additional information.

### URLs

Website URLs associated with contact.

```json
{
  "urls": [
    {"value": "https://linkedin.com/in/johndoe", "type": "profile"},
    {"value": "https://johndoe.com", "type": "home_page"},
    {"value": "https://github.com/johndoe", "type": "other"}
  ]
}
```

**Types**:
- `home_page` - Personal website
- `work` - Work website
- `profile` - Social profile
- `blog` - Blog URL
- `other` - Other URL

### Relations

Relationships to other people.

```json
{
  "relations": [
    {"person": "Jane Doe", "type": "spouse"},
    {"person": "Bob Smith", "type": "manager"},
    {"person": "Alice Johnson", "type": "assistant"}
  ]
}
```

**Types**:
- `spouse` - Spouse/partner
- `child` - Child
- `mother` / `father` - Parents
- `parent` - Generic parent
- `brother` / `sister` - Siblings
- `friend` - Friend
- `relative` - Other relative
- `manager` - Manager/boss
- `assistant` - Assistant
- `referred_by` - Referral source
- `partner` - Business partner

### Events

Important dates associated with contact.

```json
{
  "events": [
    {
      "date": {"year": 2020, "month": 6, "day": 15},
      "type": "anniversary"
    }
  ]
}
```

**Types**:
- `anniversary` - Anniversary
- `other` - Other important date

### IM Addresses

Instant messaging handles.

```json
{
  "im_clients": [
    {"username": "johndoe", "protocol": "skype"},
    {"username": "johndoe", "protocol": "aim"}
  ]
}
```

**Protocols**:
- `aim` - AOL Instant Messenger
- `msn` - MSN Messenger
- `yahoo` - Yahoo Messenger
- `skype` - Skype
- `qq` - QQ
- `google_talk` - Google Talk
- `icq` - ICQ
- `jabber` - Jabber

### Interests

Contact interests and hobbies.

```json
{
  "interests": [
    "Photography",
    "Machine Learning",
    "Rock Climbing"
  ]
}
```

Array of text strings describing interests.

### Memberships

Group memberships.

```json
{
  "memberships": [
    {"contact_group_membership": {"contact_group_resource_name": "contactGroups/myContacts"}},
    {"contact_group_membership": {"contact_group_resource_name": "contactGroups/family"}}
  ]
}
```

Assigns contacts to groups for organization.

## Update Mask Reference

When updating contacts, specify which fields to modify using the update mask parameter.

### Common Update Masks

- `names` - Update name fields
- `emailAddresses` - Update email addresses
- `phoneNumbers` - Update phone numbers
- `organizations` - Update organization info
- `birthdays` - Update birthday
- `addresses` - Update physical addresses
- `biographies` - Update notes/biography
- `urls` - Update URLs
- `relations` - Update relationships
- `events` - Update events
- `imClients` - Update IM addresses
- `interests` - Update interests

### Multiple Field Updates

Combine masks with commas:

```bash
--update-mask "phoneNumbers,emailAddresses,organizations"
```

## Data Type Constraints

### Phone Number Formats

- Accepts various formats: `555-1234`, `(555) 123-4567`, `+1-555-123-4567`
- Google normalizes formats automatically
- International format recommended: `+[country code]-[number]`

### Email Validation

- Must be valid email format: `user@domain.com`
- Google validates email syntax automatically
- Multiple emails per contact supported

### Date Formats

- Month: 1-12
- Day: 1-31 (validated against month)
- Year: Optional, 4-digit format

### Required Fields

Minimal contact requires:
- At least one name field (`given_name`, `family_name`, or `display_name`)

All other fields are optional.

## Best Practices

### Field Selection

1. **Always include display_name**: Most user-friendly identifier
2. **Separate given_name and family_name**: Better for sorting and searching
3. **Use appropriate types**: Helps with organization and filtering
4. **Include multiple contact methods**: Increases reachability

### Data Quality

1. **Normalize phone numbers**: Use international format when possible
2. **Validate emails**: Ensure correct syntax before creating
3. **Complete addresses**: Include all available address components
4. **Consistent organization names**: Use official company names

### Privacy Considerations

1. **Birthday year optional**: Many users prefer not to share birth year
2. **Minimal required data**: Only collect what's necessary
3. **Notes field sensitivity**: Avoid storing sensitive information in notes
4. **Update permissions**: Respect contact preferences for data updates

## API Limitations

### Rate Limits

- **Quota**: Google Contacts API has daily quotas
- **Batch size**: Recommended max 100 contacts per batch operation
- **Pagination**: Use page tokens for large contact lists

### Field Limits

- **Email addresses**: Unlimited per contact
- **Phone numbers**: Unlimited per contact
- **Addresses**: Unlimited per contact
- **Organizations**: Multiple supported
- **Notes length**: Very large (practical limit ~32KB)

### Search Limitations

- **Search scope**: Name, email, phone fields
- **Partial matching**: Supported for name searches
- **Case sensitivity**: Case-insensitive search
- **Special characters**: Handle with care in JSON

## Resource Name Format

All contacts have a unique resource name:

```
people/c1234567890
```

- Prefix: Always `people/`
- ID: Unique identifier (alphanumeric)
- Immutable: Resource name doesn't change
- Required: For get/update/delete operations

## Response Field Metadata

Contact responses include metadata:

```json
{
  "resource_name": "people/c1234567890",
  "etag": "%Abc123...",
  "metadata": {
    "sources": [...],
    "object_type": "PERSON"
  }
}
```

- `resource_name`: Unique identifier
- `etag`: Entity tag for concurrency control
- `metadata`: Source and type information
