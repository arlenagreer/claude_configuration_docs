#!/bin/bash
# Google OAuth Authorization Helper
# This script helps with the authorization process

echo "=================================="
echo "Google OAuth Re-authorization"
echo "=================================="
echo ""
echo "This will authorize both:"
echo "  - Google Calendar access"
echo "  - Google Contacts access"
echo ""
echo "Starting authorization flow..."
echo ""

# Run the contacts manager which will trigger OAuth
~/.claude/skills/contacts/scripts/contacts_manager.rb --list
