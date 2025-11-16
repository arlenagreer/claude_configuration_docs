#!/bin/bash
cd ~/.claude/skills/chrome-devtools/docker
docker-compose up -d
echo "Chrome DevTools container started. Waiting for health check..."
sleep 5
docker ps | grep chrome-devtools
