---
name: playwright-browser
description: Browser automation and E2E testing via local Playwright Docker container
category: testing
triggers: [browser, automation, E2E, screenshot, navigate, playwright]
docker_required: true
ruby_required: true
---

# Playwright Browser Automation Skill

## Purpose
Provides browser automation capabilities through a local Playwright Docker container, eliminating the need for remote MCP server connections. Enables web scraping, E2E testing, screenshot capture, and browser interaction automation.

## Capabilities
- **Navigation**: Load URLs with configurable wait conditions
- **Screenshots**: Capture full-page or viewport screenshots
- **Interaction**: Click, fill forms, press keys
- **Evaluation**: Execute JavaScript in page context
- **Testing**: End-to-end test automation

## Requirements

### Docker
- Docker Desktop installed and running
- `agent-network` Docker network created
- Playwright container running

### Ruby
- Ruby ≥2.7
- Gems: `websocket-client-simple`, `json`

### Setup
```bash
# Start Playwright container
cd ~/.claude/skills/playwright-browser/docker
docker-compose up -d

# Verify container is running
docker ps | grep playwright-server

# Check health
curl http://localhost:3000/health
```

## Usage

### Navigation
```bash
# Navigate to URL
~/.claude/skills/playwright-browser/scripts/navigate.rb "https://example.com"
```

### Screenshots
```bash
# Capture screenshot
~/.claude/skills/playwright-browser/scripts/screenshot.rb "https://example.com" /tmp/screenshot.png

# Full-page screenshot
~/.claude/skills/playwright-browser/scripts/screenshot.rb "https://example.com" /tmp/screenshot.png --full-page
```

### JavaScript Evaluation
```bash
# Execute JavaScript
~/.claude/skills/playwright-browser/scripts/evaluate.rb "document.title"

# Get page data
~/.claude/skills/playwright-browser/scripts/evaluate.rb "JSON.stringify({title: document.title, url: location.href})"
```

## Docker Management

### Start Container
```bash
~/.claude/skills/playwright-browser/scripts/start.sh
```

### Stop Container
```bash
~/.claude/skills/playwright-browser/scripts/stop.sh
```

### Restart Container
```bash
~/.claude/skills/playwright-browser/scripts/restart.sh
```

### Check Status
```bash
~/.claude/skills/playwright-browser/scripts/status.sh
```

## Troubleshooting

### Container won't start
**Symptom**: `docker-compose up -d` fails

**Solutions**:
1. Check Docker Desktop is running
2. Verify network exists: `docker network ls | grep agent-network`
3. Check logs: `docker-compose logs`
4. Try recreating: `docker-compose down && docker-compose up -d`

### Connection refused
**Symptom**: WebSocket connection fails

**Solutions**:
1. Verify container is running: `docker ps | grep playwright`
2. Check health: `curl http://localhost:3000/health`
3. Check logs: `docker logs playwright-server`
4. Restart container: `docker-compose restart`

### Slow performance
**Symptom**: Operations take >5 seconds

**Solutions**:
1. Check resource allocation in Docker Desktop settings
2. Increase memory limit in docker-compose.yml
3. Verify no other heavy containers running
4. Check system resources: `docker stats`

### Ruby gem errors
**Symptom**: `LoadError` for websocket gem

**Solutions**:
```bash
gem install websocket-client-simple
gem install json
```

## Performance Notes
- Container startup: ~20-30 seconds
- API response time: <500ms typical
- Memory usage: ~500MB-1GB
- Suitable for development and light automation

## Advanced Configuration

### Custom Playwright version
Edit `docker-compose.yml`:
```yaml
image: mcr.microsoft.com/playwright:v1.41.0-jammy
```

### Resource limits
Edit `docker-compose.yml` deploy section:
```yaml
deploy:
  resources:
    limits:
      memory: 4G
      cpus: '4.0'
```

## See Also
- Chrome DevTools skill for debugging capabilities
- Original research: `~/.claude/claudedocs/research_mcp_to_agent_skill_conversion_20251116.md`
