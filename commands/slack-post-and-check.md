# Slack Post with Auto-Check

Post a message to Slack after checking for any unanswered questions.

## Arguments
- `$ARGUMENTS`: The message to post to Slack

## Steps

1. **First, check all accessible Slack channels for unanswered questions** (ONCE ONLY):
   - Look for any messages mentioning @ALT System Bot or @U09FK1T6VFS
   - Identify questions that don't have replies
   - Respond to any outstanding questions
   - **DO NOT recursively check when posting these replies**

2. **Then post the requested message**:
   - Post to #all-american-laboratory-trading channel (or specified channel)
   - Include the message content from $ARGUMENTS

3. **Report summary**:
   - Number of questions answered
   - Confirmation of message posted

## Loop Prevention
- This check happens ONCE per user request
- Posting replies to found questions does NOT trigger another check
- Only user-initiated posts trigger the check

## Usage
```
/slack-post-and-check "Your message here"
```

This ensures we always check for and respond to questions before posting new messages.