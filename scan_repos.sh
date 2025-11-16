#!/bin/bash

# Scan all repositories for Dependabot alerts
# Output: JSON file with all security alerts

REPOS=(
  "claude_configuration_docs"
  "sastamps"
  "american_laboratory_trading"
  "labdeskinc"
  "bryan_mobile_app"
  "athelytix"
  "mcp_servers"
  "quality-automation"
  "claude_dispatcher"
  "ellerton-adsense-api"
  "ddswebclient"
)

echo "{"
echo '  "scan_date": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",'
echo '  "repositories": ['

first_repo=true

for repo in "${REPOS[@]}"; do
  if [ "$first_repo" = false ]; then
    echo "    ,"
  fi
  first_repo=false

  echo "    {"
  echo "      \"name\": \"$repo\","

  # Get alerts
  alerts=$(gh api "repos/arlenagreer/$repo/dependabot/alerts" 2>/dev/null)

  if [ $? -eq 0 ]; then
    echo "      \"alerts\": $alerts"
  else
    echo "      \"alerts\": [],"
    echo "      \"error\": \"Failed to access repository\""
  fi

  echo -n "    }"
done

echo ""
echo "  ]"
echo "}"
