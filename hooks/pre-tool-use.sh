#!/bin/bash

# Claude Code Pre-Tool-Use Hook: Auto-check Slack messages
# This hook triggers before ANY tool call

# Log for debugging
echo "[PRE-TOOL-USE HOOK] Triggered at $(date)" >> ~/.claude/hooks/hook-execution.log
echo "[PRE-TOOL-USE HOOK] Tool: $CLAUDE_TOOL_NAME" >> ~/.claude/hooks/hook-execution.log

# Always check for unanswered Slack messages before any tool use
echo "🔍 Checking for unanswered Slack messages before tool execution..."
echo "HOOK_INSTRUCTION: Check the all-softtrak and quality-assurance Slack channels for any unanswered questions directed to you (U09EH5H9FNH / Claude Assistant) and respond to them if found."