#!/bin/bash
echo "=== Playwright Container Status ==="
docker ps -a | grep playwright
echo ""
echo "=== Health Check ==="
curl -s http://localhost:3000/health || echo "Health check failed"
echo ""
echo "=== Container Logs (last 20 lines) ==="
docker logs --tail 20 playwright-server 2>&1
