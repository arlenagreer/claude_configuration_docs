# Timezone Guide

## Common US Timezones

| Timezone | Code | UTC Offset (Standard) | UTC Offset (DST) |
|----------|------|----------------------|------------------|
| Eastern | America/New_York | UTC-5 | UTC-4 |
| Central | America/Chicago | UTC-6 | UTC-5 |
| Mountain | America/Denver | UTC-7 | UTC-6 |
| Pacific | America/Los_Angeles | UTC-8 | UTC-7 |
| Alaska | America/Anchorage | UTC-9 | UTC-8 |
| Hawaii | Pacific/Honolulu | UTC-10 | No DST |

## International Timezones (Common)

| Region | Timezone | Code | UTC Offset |
|--------|----------|------|------------|
| UK | GMT/BST | Europe/London | UTC+0 / UTC+1 |
| Central Europe | CET/CEST | Europe/Paris | UTC+1 / UTC+2 |
| India | IST | Asia/Kolkata | UTC+5:30 |
| China | CST | Asia/Shanghai | UTC+8 |
| Japan | JST | Asia/Tokyo | UTC+9 |
| Australia (Sydney) | AEST/AEDT | Australia/Sydney | UTC+10 / UTC+11 |

## Daylight Saving Time (DST)

### US DST Rules
- **Starts**: Second Sunday in March at 2:00 AM local time
- **Ends**: First Sunday in November at 2:00 AM local time
- **Not Observed**: Hawaii, most of Arizona

### Impact on Scheduling
- Spring forward: Meetings scheduled during "lost hour" (2:00-3:00 AM) may be adjusted
- Fall back: Meetings during duplicated hour need clarification
- Always specify timezone when scheduling across DST transitions

## Timezone Conversion Examples

### Example 1: Chicago to New York
```
Chicago (Central): 2:00 PM CST
New York (Eastern): 3:00 PM EST
Difference: +1 hour
```

### Example 2: Chicago to London
```
Chicago (Central): 9:00 AM CST (Winter)
London (GMT): 3:00 PM GMT
Difference: +6 hours
```

### Example 3: Chicago to Tokyo
```
Chicago (Central): 5:00 PM CST
Tokyo (JST): 10:00 AM JST (next day)
Difference: +15 hours
```

## Best Practices for Timezone Handling

### 1. Always Specify Timezone
```bash
# Good: Explicit timezone
--start-time "2024-10-31T15:00:00" --timezone "America/Chicago"

# Risky: Assumes default timezone
--start-time "2024-10-31T15:00:00"
```

### 2. Use IANA Timezone Database Codes
- ✅ Good: `America/Chicago`, `Europe/London`, `Asia/Tokyo`
- ❌ Bad: `CST`, `GMT`, `JST` (ambiguous, no DST info)

### 3. Consider Attendee Timezones
When scheduling with international attendees:
1. Note each attendee's timezone
2. Find overlap in working hours
3. Specify event in primary user's timezone
4. Calendar automatically converts for attendees

### 4. DST Transition Periods
During first week of March and November:
- Double-check meeting times
- Verify calendar auto-adjusts correctly
- Send confirmation to attendees

## Working Hours by Timezone

### Typical Business Hours (9 AM - 5 PM)

| Location | Timezone | Local Time | Chicago Equivalent |
|----------|----------|------------|-------------------|
| New York | America/New_York | 9 AM - 5 PM EST | 8 AM - 4 PM CST |
| Chicago | America/Chicago | 9 AM - 5 PM CST | 9 AM - 5 PM CST |
| Los Angeles | America/Los_Angeles | 9 AM - 5 PM PST | 11 AM - 7 PM CST |
| London | Europe/London | 9 AM - 5 PM GMT | 3 AM - 11 AM CST |
| Tokyo | Asia/Tokyo | 9 AM - 5 PM JST | 7 PM - 3 AM CST |

### Finding Overlap

**US East Coast + Chicago + West Coast**:
- Overlap: 11 AM - 4 PM CST (10 AM - 3 PM PST, 12 PM - 5 PM EST)
- Best meeting time: 1 PM CST / 12 PM PST / 2 PM EST

**Chicago + London**:
- Overlap: 9 AM - 11 AM CST (3 PM - 5 PM GMT)
- Best meeting time: 10 AM CST / 4 PM GMT

**Chicago + Tokyo**:
- No normal business hours overlap
- Options:
  - Early morning Chicago (7 AM CST = 10 PM JST previous day)
  - Late evening Chicago (9 PM CST = 12 PM JST next day)

## Timezone Detection

### Automatic Detection
The calendar script uses `America/Chicago` as default but allows override:

```bash
# Explicitly set timezone for event
scripts/calendar_manager.rb --operation create \
  --summary "Meeting" \
  --start-time "2024-10-31T15:00:00" \
  --timezone "America/Los_Angeles"
```

### User Travel Considerations
When user is traveling:
1. Check current timezone from system
2. Ask user if they want events in local or home timezone
3. Calendar can show events in any timezone

## Common Timezone Pitfalls

### 1. Ambiguous Abbreviations
```
CST could mean:
- Central Standard Time (UTC-6)
- China Standard Time (UTC+8)
- Cuba Standard Time (UTC-5)

Always use IANA codes: America/Chicago, Asia/Shanghai, America/Havana
```

### 2. All-Day Events
- All-day events don't have timezone
- Display differently based on viewer's timezone
- Be clear when creating: "all-day in what timezone?"

### 3. Recurring Events Across DST
- Meetings may shift by 1 hour relative to other timezones
- Example: Weekly 2 PM CST meeting becomes 3 PM CET after DST change
- Best to review recurring events during DST transitions

## Quick Reference Commands

**Create event with specific timezone**:
```bash
scripts/calendar_manager.rb --operation create \
  --summary "Meeting" \
  --start-time "2024-10-31T15:00:00" \
  --timezone "America/New_York"
```

**List events (returns times in original timezone)**:
```bash
scripts/calendar_manager.rb --operation list
```

**Find free time in specific timezone**:
```bash
scripts/calendar_manager.rb --operation find_free \
  --time-min "2024-11-01T00:00:00" \
  --time-max "2024-11-08T23:59:59" \
  --timezone "America/Los_Angeles"
```

## Resources

- [IANA Timezone Database](https://www.iana.org/time-zones)
- [Time Zone Converter](https://www.timeanddate.com/worldclock/converter.html)
- [DST Information](https://www.timeanddate.com/time/dst/)
