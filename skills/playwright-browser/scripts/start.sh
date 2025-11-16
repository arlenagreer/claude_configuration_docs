#!/bin/bash
# ~/.claude/skills/playwright-browser/scripts/start.sh
cd ~/.claude/skills/playwright-browser/docker
docker-compose up -d
echo "Playwright container started. Waiting for health check..."
sleep 5
docker ps | grep playwright
