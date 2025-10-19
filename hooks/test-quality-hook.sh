#!/usr/bin/env bash
# Test script for the global quality hook

echo "Testing global quality hook..."

# Test with Write tool format
echo '{"tool": "Write", "result": "File created successfully at: /tmp/test.rb"}' | ~/.claude/hooks/post-tool-use-quality.sh

# Test with Edit tool format
echo '{"tool": "Edit", "result": "The file /tmp/test.rb has been updated"}' | ~/.claude/hooks/post-tool-use-quality.sh

echo "Test complete. Check ~/.claude/hooks/hook-execution.log for results."
