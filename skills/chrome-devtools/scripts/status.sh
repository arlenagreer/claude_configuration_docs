#!/bin/bash
echo "=== Chrome DevTools Container Status ==="
docker ps -a | grep chrome-devtools
echo ""
echo "=== CDP Endpoint Check ==="
curl -s http://localhost:9222/json/version || echo "CDP endpoint check failed"
echo ""
echo "=== Container Logs (last 20 lines) ==="
docker logs --tail 20 chrome-devtools-server 2>&1
