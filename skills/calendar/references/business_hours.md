# Business Hours Guide

## Default Business Hours

**Standard Configuration**:
- Start: 9:00 AM
- End: 5:00 PM
- Days: Monday - Friday
- Timezone: America/Chicago (default)

## Customizing Business Hours

### Via Command Line Flags

```bash
scripts/calendar_manager.rb --operation find_free \
  --time-min "2024-11-01T00:00:00" \
  --time-max "2024-11-08T23:59:59" \
  --business-start 8 \
  --business-end 18
```

**Parameters**:
- `--business-start`: Hour (0-23) when business day starts
- `--business-end`: Hour (0-23) when business day ends
- Both use 24-hour format

### Common Business Hour Configurations

| Type | Start | End | Use Case |
|------|-------|-----|----------|
| Standard | 9 AM | 5 PM | Traditional office hours |
| Early Bird | 7 AM | 3 PM | Early start preference |
| Standard Extended | 8 AM | 6 PM | Longer workday |
| Tech Industry | 10 AM | 6 PM | Later start, common in tech |
| International | 6 AM | 8 PM | Covering multiple timezones |
| Flexible | 8 AM | 8 PM | Find any reasonable time |

## Finding Optimal Meeting Times

### 1. Single Timezone Scheduling

**Within Same Timezone**:
```bash
# Find 1-hour slots during standard business hours
scripts/calendar_manager.rb --operation find_free \
  --time-min "2024-11-04T00:00:00" \
  --time-max "2024-11-08T23:59:59" \
  --duration 3600 \
  --business-start 9 \
  --business-end 17
```

**Best Practices**:
- Avoid scheduling before 9 AM or after 5 PM
- Consider lunch hour (12 PM - 1 PM) preferences
- Check for existing meeting density

### 2. Multi-Timezone Scheduling

**US Coast-to-Coast** (Eastern + Pacific):
```bash
# Find overlap: 12 PM - 4 PM EST / 9 AM - 1 PM PST
# In Central time: 11 AM - 3 PM CST
scripts/calendar_manager.rb --operation find_free \
  --time-min "2024-11-04T11:00:00" \
  --time-max "2024-11-04T15:00:00" \
  --duration 3600
```

**Chicago + London**:
```bash
# Morning Chicago = Afternoon London
# 9 AM - 11 AM CST = 3 PM - 5 PM GMT
scripts/calendar_manager.rb --operation find_free \
  --time-min "2024-11-04T09:00:00" \
  --time-max "2024-11-04T11:00:00" \
  --duration 3600
```

### 3. Preferred Meeting Times

**Early Morning** (8 AM - 10 AM):
- ✅ Pros: Fresh minds, fewer distractions
- ❌ Cons: May conflict with commutes, not everyone is a morning person

**Mid-Morning** (10 AM - 12 PM):
- ✅ Pros: Everyone settled in, productive time
- ❌ Cons: Often heavily booked

**Early Afternoon** (1 PM - 3 PM):
- ✅ Pros: Post-lunch, good for collaboration
- ❌ Cons: Post-lunch energy dip for some

**Late Afternoon** (3 PM - 5 PM):
- ✅ Pros: Can serve as end-of-day checkpoint
- ❌ Cons: Energy waning, may run over into personal time

**Avoid**:
- 12 PM - 1 PM (lunch hour)
- First 30 min of business day (people settling in)
- Last 30 min of business day (people wrapping up)

## Blocking Focus Time

### Strategy 1: Morning Focus Blocks

**Philosophy**: Protect creative/deep work time in the morning

```bash
# Block 9 AM - 11 AM for focus work
scripts/calendar_manager.rb --operation create \
  --summary "Focus Time - Deep Work" \
  --description "Protected time for concentrated work" \
  --start-time "2024-11-04T09:00:00" \
  --end-time "2024-11-04T11:00:00"
```

**Benefits**:
- Peak cognitive performance
- Fewer interruptions
- Sets productive tone for day

### Strategy 2: Afternoon Focus Blocks

**Philosophy**: After meetings, dedicate time to execution

```bash
# Block 2 PM - 4 PM for focused implementation
scripts/calendar_manager.rb --operation create \
  --summary "Focus Time - Implementation" \
  --description "Blocked time for project work" \
  --start-time "2024-11-04T14:00:00" \
  --end-time "2024-11-04T16:00:00"
```

**Benefits**:
- Action on morning decisions
- Less email/Slack activity
- Buffer before end of day

### Strategy 3: Full-Day Deep Work

**Philosophy**: Entire day dedicated to major project

```bash
# Block full business day (with breaks)
scripts/calendar_manager.rb --operation create \
  --summary "Deep Work Day - Database Migration" \
  --description "Full day blocked for concentrated project work" \
  --start-time "2024-11-05T09:00:00" \
  --end-time "2024-11-05T17:00:00"
```

**When to Use**:
- Major project milestones
- Complex problem-solving needed
- Deadline-driven work
- Recovery after heavily meeting-packed week

### Focus Time Best Practices

1. **Mark as Busy**: Set calendar status to "Busy" not "Free"
2. **Descriptive Titles**: "Focus Time - [Specific Project]"
3. **Recurring Blocks**: Set up weekly recurring focus time
4. **Respect Your Own Blocks**: Treat them as seriously as external meetings
5. **Communicate**: Let team know about regular focus blocks

## Time Slot Duration Guidelines

| Meeting Type | Recommended Duration | Use Case |
|--------------|---------------------|----------|
| Quick Sync | 15 minutes | Status updates, quick questions |
| Standard Meeting | 30 minutes | Most 1:1s, small team discussions |
| Deep Discussion | 1 hour | Project planning, problem solving |
| Workshop/Brainstorm | 2 hours | Collaborative design, team building |
| Training/Presentation | 2-3 hours | Learning sessions, comprehensive reviews |
| Focus Work | 2-4 hours | Deep work on complex problems |

## Calendar Health Best Practices

### 1. Meeting-Free Time Ratios

**Healthy Calendar Balance**:
- 40-50% meetings
- 40-50% focus time
- 10-20% buffer/break time

**Warning Signs**:
- ❌ >70% meetings = Not enough execution time
- ❌ Back-to-back meetings all day = Burnout risk
- ❌ No focus blocks = Reactive mode only

### 2. Buffer Time

**Between Meetings**:
```bash
# Leave 5-10 minute buffers between meetings
# If meeting ends at 11:00, next starts at 11:10
scripts/calendar_manager.rb --operation create \
  --summary "Next Meeting" \
  --start-time "2024-11-04T11:10:00" \
  --end-time "2024-11-04T12:00:00"
```

**Benefits**:
- Bathroom breaks
- Mental transition
- Action items capture
- Travel time between rooms

### 3. No-Meeting Days

**Strategy**: Designate one day per week with minimal/no meetings

```bash
# Block entire Wednesday for focus
scripts/calendar_manager.rb --operation create \
  --summary "No-Meeting Day - Focus Work" \
  --description "Protected day for deep work and project progress" \
  --start-time "2024-11-06T09:00:00" \
  --end-time "2024-11-06T17:00:00"
```

**Common Choices**:
- Wednesday (mid-week balance)
- Friday (wrap up week's work)
- Monday (set intentions for week)

## Finding Free Time: Advanced Techniques

### 1. Next Available Slot

```bash
# Find soonest 1-hour slot this week
scripts/calendar_manager.rb --operation find_free \
  --time-min "$(date -u +%Y-%m-%dT%H:%M:%S)" \
  --time-max "$(date -u -v+7d +%Y-%m-%dT%H:%M:%S)" \
  --duration 3600 \
  --max-results 1
```

### 2. Specific Day Pattern

```bash
# Find Tuesday/Thursday slots only
# (Requires filtering results by day of week)
scripts/calendar_manager.rb --operation find_free \
  --time-min "2024-11-05T00:00:00" \
  --time-max "2024-11-30T23:59:59" \
  --duration 3600
# Then filter for Tuesday/Thursday in results
```

### 3. Long Duration Blocks

```bash
# Find 3-hour blocks for deep work
scripts/calendar_manager.rb --operation find_free \
  --time-min "2024-11-04T00:00:00" \
  --time-max "2024-11-15T23:59:59" \
  --duration 10800 \
  --business-start 9 \
  --business-end 17
```

### 4. Multiple Short Slots

```bash
# Find several 30-minute slots
scripts/calendar_manager.rb --operation find_free \
  --time-min "2024-11-04T00:00:00" \
  --time-max "2024-11-08T23:59:59" \
  --duration 1800 \
  --max-results 10
```

## Time Management Strategies

### 1. Themed Days

Designate days for specific types of work:
- **Monday**: Planning, team meetings
- **Tuesday/Thursday**: External meetings, client calls
- **Wednesday**: Focus day, deep work
- **Friday**: Wrap-up, 1:1s, retrospectives

### 2. Time Blocking

Proactively block time for different activities:
```bash
# Morning: Deep work
# Afternoon: Meetings
# End of day: Email/admin

# Example blocks
scripts/calendar_manager.rb --operation create \
  --summary "Deep Work Block" \
  --start-time "2024-11-04T09:00:00" \
  --end-time "2024-11-04T12:00:00"
```

### 3. Meeting Stacking

Group meetings together to preserve focus blocks:
- ✅ 10-11 AM, 11-12 PM, 1-2 PM (stacked)
- ❌ 10-11 AM, 2-3 PM, 4-5 PM (fragmented)

## Quick Reference

**Find next free slot**:
```bash
scripts/calendar_manager.rb --operation find_free \
  --time-min "[TODAY]" --time-max "[WEEK_END]"
```

**Block focus time**:
```bash
scripts/calendar_manager.rb --operation create \
  --summary "Focus Time" \
  --start-time "[DATE]T09:00:00" \
  --end-time "[DATE]T11:00:00"
```

**Custom business hours**:
```bash
# Add --business-start 8 --business-end 18 to any find_free command
```

## Resources

- [Cal Newport's "Deep Work"](https://www.calnewport.com/books/deep-work/)
- [Maker's Schedule, Manager's Schedule](http://www.paulgraham.com/makersschedule.html)
- [Time Blocking Method](https://todoist.com/productivity-methods/time-blocking)
