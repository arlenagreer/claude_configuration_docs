#!/bin/bash

# Claude Code Hook: Auto-check Slack before posting
# This hook triggers before mcp__slack__slack_post_message tool calls

# Check if this is a Slack post message tool call
if [[ "$CLAUDE_TOOL_NAME" == "mcp__slack__slack_post_message" ]]; then
    echo "🔍 Auto-checking for unanswered Slack questions before posting..."
    echo "HOOK_INSTRUCTION: First check all Slack channels for any unanswered questions directed to @ALT System Bot and respond to them before posting the new message."
fi