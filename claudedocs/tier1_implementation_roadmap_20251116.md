# Tier 1 MCP-to-Agent-Skill Implementation Roadmap
**Playwright & Chrome DevTools Docker Conversion**

Generated: 2025-11-16
Status: Planning Complete
Estimated Duration: 6 weeks
Priority: Tier 1 (High ROI)

---

## Executive Summary

### Objectives
Replace Playwright and Chrome DevTools MCP servers with Docker-containerized Agent Skills that provide:
- **Local execution**: No remote MCP server dependencies
- **API-based access**: Claude Code → Ruby CLI → Docker API → Service
- **Persistent containers**: Faster startup, cross-session reliability
- **Simplified management**: Single `docker-compose up` command

### Timeline Overview
- **Phase 1**: Environment Setup (Week 1)
- **Phase 2**: Playwright Implementation (Weeks 2-3)
- **Phase 3**: Chrome DevTools Implementation (Weeks 4-5)
- **Phase 4**: Integration & Validation (Week 6)

### Success Criteria
- ✅ Both services running in isolated Docker containers
- ✅ API response time <500ms (95th percentile)
- ✅ Container startup <30 seconds
- ✅ Memory usage <2GB total
- ✅ 99%+ reliability during development sessions
- ✅ Complete MCP feature parity
- ✅ Agent Skills functional in Claude Code

### Quick Reference
| Phase | Duration | Key Deliverables |
|-------|----------|-----------------|
| 1: Environment Setup | Week 1 | Docker network, dependencies |
| 2: Playwright | Weeks 2-3 | Container, Ruby CLI, Agent Skill |
| 3: Chrome DevTools | Weeks 4-5 | Container, Ruby CLI, Agent Skill |
| 4: Integration | Week 6 | Testing, validation, documentation |

---

## Phase 1: Environment Setup (Week 1)

### Objectives
- Install and configure Docker environment
- Create shared network infrastructure
- Install Ruby dependencies
- Verify baseline functionality

### Tasks

#### 1.1: Install Docker Desktop
- [ ] **Task 1.1.1**: Download Docker Desktop for macOS
  - URL: https://www.docker.com/products/docker-desktop
  - Version: Latest stable (≥4.25.0)
  - Verification: `docker --version`

- [ ] **Task 1.1.2**: Configure Docker Desktop resources
  - Memory: ≥4GB (Settings → Resources → Memory)
  - CPU: ≥2 cores (Settings → Resources → CPUs)
  - Disk: ≥20GB available
  - Verification: Check Settings → Resources panel

- [ ] **Task 1.1.3**: Verify Docker Compose installation
  - Command: `docker-compose --version`
  - Expected: v2.x or higher
  - Alternative: `docker compose version` (plugin syntax)

#### 1.2: Create Docker Network
- [ ] **Task 1.2.1**: Create agent-network bridge network
  ```bash
  docker network create \
    --driver bridge \
    --subnet 172.28.0.0/16 \
    --ip-range 172.28.5.0/24 \
    --gateway 172.28.5.254 \
    agent-network
  ```

- [ ] **Task 1.2.2**: Verify network configuration
  ```bash
  docker network inspect agent-network
  ```
  - Verify: Subnet, gateway, driver type
  - Expected: JSON output with network details

#### 1.3: Install Ruby Dependencies
- [ ] **Task 1.3.1**: Verify Ruby installation
  - Command: `ruby --version`
  - Required: Ruby ≥2.7
  - macOS default: Should be present

- [ ] **Task 1.3.2**: Install required gems
  ```bash
  gem install websocket-client-simple
  gem install json
  gem install net-http
  ```

- [ ] **Task 1.3.3**: Create skills directory structure
  ```bash
  mkdir -p ~/.claude/skills/playwright-browser/{scripts,tests}
  mkdir -p ~/.claude/skills/chrome-devtools/{scripts,tests}
  ```

#### 1.4: Prepare Directory Structure
- [ ] **Task 1.4.1**: Create Playwright skill directories
  ```bash
  cd ~/.claude/skills/playwright-browser
  mkdir -p scripts tests docker
  ```

- [ ] **Task 1.4.2**: Create Chrome DevTools skill directories
  ```bash
  cd ~/.claude/skills/chrome-devtools
  mkdir -p scripts tests docker
  ```

### Validation Criteria
- [ ] Docker Desktop running and accessible
- [ ] `agent-network` network created and inspectable
- [ ] Ruby and required gems installed
- [ ] Directory structure created
- [ ] No errors in any installation step

### Estimated Time
- Installation: 2-3 hours
- Configuration: 1 hour
- Verification: 30 minutes
- **Total**: 4-5 hours

---

## Phase 2: Playwright Implementation (Weeks 2-3)

### Objectives
- Deploy Playwright in Docker container
- Develop Ruby CLI client
- Create Agent Skill integration
- Validate browser automation capabilities

### 2.1: Docker Container Setup

#### 2.1.1: Create Docker Compose Configuration
- [ ] **Task 2.1.1.1**: Create docker-compose.yml
  - Location: `~/.claude/skills/playwright-browser/docker/docker-compose.yml`
  - See **Appendix A.1** for complete configuration

- [ ] **Task 2.1.1.2**: Create .env file for configuration
  ```bash
  # ~/.claude/skills/playwright-browser/docker/.env
  PLAYWRIGHT_PORT=3000
  PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
  ```

#### 2.1.2: Deploy Playwright Container
- [ ] **Task 2.1.2.1**: Pull Playwright Docker image
  ```bash
  cd ~/.claude/skills/playwright-browser/docker
  docker-compose pull
  ```

- [ ] **Task 2.1.2.2**: Start Playwright container
  ```bash
  docker-compose up -d
  ```
  - Expected: Container starts successfully
  - Verification: `docker ps | grep playwright`

- [ ] **Task 2.1.2.3**: Verify health check
  ```bash
  docker inspect playwright-server | grep Health
  ```
  - Expected: "healthy" status after 30s

#### 2.1.3: Test Container Connectivity
- [ ] **Task 2.1.3.1**: Test HTTP endpoint
  ```bash
  curl -v http://localhost:3000/health
  ```
  - Expected: 200 OK response

- [ ] **Task 2.1.3.2**: Test WebSocket endpoint
  ```bash
  # Use wscat or websocat tool
  wscat -c ws://localhost:3000/
  ```
  - Expected: WebSocket connection established

### 2.2: Ruby CLI Development

#### 2.2.1: Create Base Client Class
- [ ] **Task 2.2.1.1**: Create playwright_client.rb
  - Location: `~/.claude/skills/playwright-browser/scripts/playwright_client.rb`
  - See **Appendix B.1** for complete implementation
  - Features:
    - WebSocket connection management
    - Command serialization/deserialization
    - Error handling with retries
    - Timeout management

- [ ] **Task 2.2.1.2**: Implement connection pooling
  - Reuse WebSocket connections
  - Handle reconnection on failure
  - Max pool size: 5 connections

#### 2.2.2: Implement Core Operations
- [ ] **Task 2.2.2.1**: Navigation operations
  ```ruby
  def navigate(url, wait_until: 'load', timeout: 30000)
    send_command('page.goto', {
      url: url,
      waitUntil: wait_until,
      timeout: timeout
    })
  end
  ```

- [ ] **Task 2.2.2.2**: Screenshot operations
  ```ruby
  def screenshot(path: nil, full_page: false, type: 'png')
    send_command('page.screenshot', {
      path: path,
      fullPage: full_page,
      type: type
    })
  end
  ```

- [ ] **Task 2.2.2.3**: Interaction operations
  - `click(selector)`
  - `fill(selector, value)`
  - `press(selector, key)`

- [ ] **Task 2.2.2.4**: Evaluation operations
  ```ruby
  def evaluate(script)
    send_command('page.evaluate', { expression: script })
  end
  ```

#### 2.2.3: Create CLI Wrapper Scripts
- [ ] **Task 2.2.3.1**: Create navigate.rb
  ```ruby
  #!/usr/bin/env ruby
  # ~/.claude/skills/playwright-browser/scripts/navigate.rb
  require_relative 'playwright_client'

  url = ARGV[0] || abort("Usage: navigate.rb <url>")
  client = PlaywrightClient.new
  result = client.navigate(url)
  puts JSON.pretty_generate(result)
  ```

- [ ] **Task 2.2.3.2**: Create screenshot.rb
- [ ] **Task 2.2.3.3**: Create click.rb
- [ ] **Task 2.2.3.4**: Create evaluate.rb
- [ ] **Task 2.2.3.5**: Make all scripts executable
  ```bash
  chmod +x ~/.claude/skills/playwright-browser/scripts/*.rb
  ```

#### 2.2.4: Error Handling & Logging
- [ ] **Task 2.2.4.1**: Implement retry logic
  - Max retries: 3
  - Backoff: Exponential (1s, 2s, 4s)
  - Retry on: Connection errors, timeouts

- [ ] **Task 2.2.4.2**: Add logging
  - Log file: `~/.claude/skills/playwright-browser/logs/playwright.log`
  - Log level: INFO (configurable)
  - Include: Timestamps, command, response time

### 2.3: Agent Skill Integration

#### 2.3.1: Create SKILL.md
- [ ] **Task 2.3.1.1**: Create SKILL.md file
  - Location: `~/.claude/skills/playwright-browser/SKILL.md`
  - See **Appendix C.1** for complete template
  - Sections:
    - Metadata (name, description, triggers)
    - Purpose and capabilities
    - Requirements
    - Usage examples
    - Docker management
    - Troubleshooting

#### 2.3.2: Document Usage Patterns
- [ ] **Task 2.3.2.1**: Add navigation examples
  ```bash
  # Navigate to URL
  ~/.claude/skills/playwright-browser/scripts/navigate.rb "https://example.com"
  ```

- [ ] **Task 2.3.2.2**: Add screenshot examples
- [ ] **Task 2.3.2.3**: Add interaction examples
- [ ] **Task 2.3.2.4**: Add evaluation examples

#### 2.3.3: Create Management Scripts
- [ ] **Task 2.3.3.1**: Create start.sh
  ```bash
  #!/bin/bash
  # ~/.claude/skills/playwright-browser/scripts/start.sh
  cd ~/.claude/skills/playwright-browser/docker
  docker-compose up -d
  echo "Playwright container started. Waiting for health check..."
  sleep 5
  docker ps | grep playwright
  ```

- [ ] **Task 2.3.3.2**: Create stop.sh
- [ ] **Task 2.3.3.3**: Create restart.sh
- [ ] **Task 2.3.3.4**: Create status.sh
- [ ] **Task 2.3.3.5**: Make all management scripts executable

### 2.4: Testing & Validation

#### 2.4.1: Unit Tests
- [ ] **Task 2.4.1.1**: Create test_playwright_client.rb
  - Location: `~/.claude/skills/playwright-browser/tests/test_playwright_client.rb`
  - Tests:
    - Connection establishment
    - Command serialization
    - Error handling
    - Retry logic

- [ ] **Task 2.4.1.2**: Run unit tests
  ```bash
  ruby ~/.claude/skills/playwright-browser/tests/test_playwright_client.rb
  ```

#### 2.4.2: Integration Tests
- [ ] **Task 2.4.2.1**: Test navigation
  - Navigate to google.com
  - Verify page load
  - Check response time <500ms

- [ ] **Task 2.4.2.2**: Test screenshot
  - Take full-page screenshot
  - Verify file created
  - Check file size >0

- [ ] **Task 2.4.2.3**: Test interaction
  - Fill form field
  - Click button
  - Verify action completed

- [ ] **Task 2.4.2.4**: Test evaluation
  - Execute JavaScript
  - Capture return value
  - Verify correctness

#### 2.4.3: Performance Testing
- [ ] **Task 2.4.3.1**: Measure operation latency
  - Run 50 navigation operations
  - Calculate: avg, p50, p95, p99
  - Target: p95 <500ms

- [ ] **Task 2.4.3.2**: Measure memory usage
  ```bash
  docker stats playwright-server --no-stream
  ```
  - Target: <1GB memory

- [ ] **Task 2.4.3.3**: Measure startup time
  - Stop container
  - Start and measure time to healthy
  - Target: <30 seconds

#### 2.4.4: Error Recovery Testing
- [ ] **Task 2.4.4.1**: Test connection retry
  - Stop container mid-operation
  - Verify retry logic triggers
  - Confirm graceful failure

- [ ] **Task 2.4.4.2**: Test timeout handling
  - Send command with short timeout
  - Verify timeout error returned
  - Confirm no resource leak

- [ ] **Task 2.4.4.3**: Test invalid commands
  - Send malformed command
  - Verify error response
  - Confirm client stability

### Validation Criteria
- [ ] Docker container running and healthy
- [ ] All Ruby CLI scripts functional
- [ ] SKILL.md complete and accurate
- [ ] Unit tests passing (100%)
- [ ] Integration tests passing (100%)
- [ ] Performance benchmarks met
- [ ] Error recovery working correctly
- [ ] Documentation verified through manual testing

### Estimated Time
- Docker setup: 4 hours
- Ruby client development: 12 hours
- CLI wrapper scripts: 4 hours
- SKILL.md creation: 2 hours
- Testing: 8 hours
- **Total**: 30 hours (2 weeks part-time)

---

## Phase 3: Chrome DevTools Implementation (Weeks 4-5)

### Objectives
- Deploy Chrome with DevTools Protocol in Docker
- Develop Ruby CDP client
- Create Agent Skill integration
- Validate debugging capabilities

### 3.1: Docker Container Setup

#### 3.1.1: Create Docker Compose Configuration
- [ ] **Task 3.1.1.1**: Create docker-compose.yml
  - Location: `~/.claude/skills/chrome-devtools/docker/docker-compose.yml`
  - See **Appendix A.2** for complete configuration

- [ ] **Task 3.1.1.2**: Create .env file
  ```bash
  # ~/.claude/skills/chrome-devtools/docker/.env
  CDP_PORT=9222
  VNC_PORT=5900
  ```

#### 3.1.2: Deploy Chrome DevTools Container
- [ ] **Task 3.1.2.1**: Pull Chrome Docker image
  ```bash
  cd ~/.claude/skills/chrome-devtools/docker
  docker-compose pull
  ```

- [ ] **Task 3.1.2.2**: Start Chrome container
  ```bash
  docker-compose up -d
  ```
  - Expected: Container starts successfully
  - Verification: `docker ps | grep chrome-devtools`

- [ ] **Task 3.1.2.3**: Verify health check
  ```bash
  curl -s http://localhost:9222/json/version
  ```
  - Expected: JSON with browser version

#### 3.1.3: Test Container Connectivity
- [ ] **Task 3.1.3.1**: Test HTTP endpoint
  ```bash
  curl http://localhost:9222/json
  ```
  - Expected: Array of open pages/targets

- [ ] **Task 3.1.3.2**: Test WebSocket endpoint
  ```bash
  # Get WebSocket URL from /json
  curl -s http://localhost:9222/json | jq '.[0].webSocketDebuggerUrl'
  # Connect with wscat
  wscat -c "ws://localhost:9222/devtools/page/[PAGE_ID]"
  ```
  - Expected: WebSocket connection established

### 3.2: Ruby CLI Development

#### 3.2.1: Create CDP Client Class
- [ ] **Task 3.2.1.1**: Create cdp_client.rb
  - Location: `~/.claude/skills/chrome-devtools/scripts/cdp_client.rb`
  - See **Appendix B.2** for complete implementation
  - Features:
    - CDP protocol handling
    - Event subscription
    - Target management (tabs/pages)
    - Session management

- [ ] **Task 3.2.1.2**: Implement CDP message handling
  - Request ID tracking
  - Response correlation
  - Event dispatching
  - Error handling

#### 3.2.2: Implement Core CDP Domains
- [ ] **Task 3.2.2.1**: Page domain
  ```ruby
  # Page.navigate, Page.reload, Page.captureScreenshot
  def page_navigate(url)
    send_command('Page.navigate', { url: url })
  end

  def page_screenshot(format: 'png')
    send_command('Page.captureScreenshot', { format: format })
  end
  ```

- [ ] **Task 3.2.2.2**: Runtime domain
  ```ruby
  # Runtime.evaluate, Runtime.callFunctionOn
  def runtime_evaluate(expression)
    send_command('Runtime.evaluate', {
      expression: expression,
      returnByValue: true
    })
  end
  ```

- [ ] **Task 3.2.2.3**: Network domain
  ```ruby
  # Network.enable, Network.setCacheDisabled
  def network_enable
    send_command('Network.enable')
  end

  def network_get_response_body(request_id)
    send_command('Network.getResponseBody', {
      requestId: request_id
    })
  end
  ```

- [ ] **Task 3.2.2.4**: DOM domain
  ```ruby
  # DOM.getDocument, DOM.querySelector
  def dom_query_selector(selector)
    doc = send_command('DOM.getDocument')
    send_command('DOM.querySelector', {
      nodeId: doc['root']['nodeId'],
      selector: selector
    })
  end
  ```

#### 3.2.3: Implement Event Subscription
- [ ] **Task 3.2.3.1**: Event listener infrastructure
  ```ruby
  def on_event(method, &block)
    @event_handlers[method] = block
  end

  def handle_event(message)
    handler = @event_handlers[message['method']]
    handler.call(message['params']) if handler
  end
  ```

- [ ] **Task 3.2.3.2**: Common event handlers
  - `Network.requestWillBeSent`
  - `Network.responseReceived`
  - `Page.loadEventFired`
  - `Console.messageAdded`

#### 3.2.4: Create CLI Wrapper Scripts
- [ ] **Task 3.2.4.1**: Create navigate.rb
  ```ruby
  #!/usr/bin/env ruby
  require_relative 'cdp_client'

  url = ARGV[0] || abort("Usage: navigate.rb <url>")
  client = CDPClient.new
  client.page_enable
  result = client.page_navigate(url)
  puts JSON.pretty_generate(result)
  ```

- [ ] **Task 3.2.4.2**: Create evaluate.rb
- [ ] **Task 3.2.4.3**: Create screenshot.rb
- [ ] **Task 3.2.4.4**: Create network_capture.rb
- [ ] **Task 3.2.4.5**: Create console_log.rb
- [ ] **Task 3.2.4.6**: Make all scripts executable

### 3.3: Agent Skill Integration

#### 3.3.1: Create SKILL.md
- [ ] **Task 3.3.1.1**: Create SKILL.md file
  - Location: `~/.claude/skills/chrome-devtools/SKILL.md`
  - See **Appendix C.2** for complete template
  - Sections:
    - Metadata (name, description, triggers)
    - Purpose and CDP capabilities
    - Requirements
    - Usage examples
    - Docker management
    - Troubleshooting

#### 3.3.2: Document Usage Patterns
- [ ] **Task 3.3.2.1**: Add page control examples
- [ ] **Task 3.3.2.2**: Add debugging examples
- [ ] **Task 3.3.2.3**: Add network analysis examples
- [ ] **Task 3.3.2.4**: Add performance profiling examples

#### 3.3.3: Create Management Scripts
- [ ] **Task 3.3.3.1**: Create start.sh
- [ ] **Task 3.3.3.2**: Create stop.sh
- [ ] **Task 3.3.3.3**: Create restart.sh
- [ ] **Task 3.3.3.4**: Create status.sh
- [ ] **Task 3.3.3.5**: Create vnc_url.sh (for visual debugging)
  ```bash
  #!/bin/bash
  echo "VNC viewer: vnc://localhost:5900"
  echo "Password: secret"
  ```

### 3.4: Testing & Validation

#### 3.4.1: Unit Tests
- [ ] **Task 3.4.1.1**: Create test_cdp_client.rb
  - CDP message formatting
  - Response parsing
  - Event handling
  - Error cases

- [ ] **Task 3.4.1.2**: Run unit tests

#### 3.4.2: Integration Tests
- [ ] **Task 3.4.2.1**: Test page navigation
  - Navigate to URL
  - Wait for load event
  - Verify success

- [ ] **Task 3.4.2.2**: Test JavaScript evaluation
  - Execute script
  - Capture return value
  - Verify correctness

- [ ] **Task 3.4.2.3**: Test network monitoring
  - Enable network domain
  - Navigate to page
  - Capture requests
  - Verify request data

- [ ] **Task 3.4.2.4**: Test DOM manipulation
  - Query selector
  - Get element attributes
  - Modify element
  - Verify changes

#### 3.4.3: Performance Testing
- [ ] **Task 3.4.3.1**: Measure CDP command latency
  - 50 operations
  - Calculate percentiles
  - Target: p95 <500ms

- [ ] **Task 3.4.3.2**: Measure container resources
  - Memory usage
  - CPU usage
  - Target: <1GB memory, <50% CPU

#### 3.4.4: Multi-Tab Testing
- [ ] **Task 3.4.4.1**: Create multiple targets
  ```ruby
  client.target_create_target(url: 'https://example.com')
  ```

- [ ] **Task 3.4.4.2**: Switch between targets
- [ ] **Task 3.4.4.3**: Close targets
- [ ] **Task 3.4.4.4**: Verify isolation

### Validation Criteria
- [ ] Docker container running and healthy
- [ ] All CDP domains functional
- [ ] Ruby CLI scripts working
- [ ] Event subscription operational
- [ ] SKILL.md complete
- [ ] All tests passing
- [ ] Performance benchmarks met
- [ ] Multi-tab support verified

### Estimated Time
- Docker setup: 3 hours
- CDP client development: 10 hours
- Event handling: 4 hours
- CLI wrapper scripts: 4 hours
- SKILL.md creation: 2 hours
- Testing: 7 hours
- **Total**: 30 hours (2 weeks part-time)

---

## Phase 4: Integration & Validation (Week 6)

### Objectives
- Integrate both skills in Claude Code
- Test cross-skill operations
- Validate production readiness
- Complete documentation
- Create migration guide

### 4.1: Claude Code Integration

#### 4.1.1: Register Agent Skills
- [ ] **Task 4.1.1.1**: Verify skill directory structure
  ```bash
  ls -la ~/.claude/skills/playwright-browser/SKILL.md
  ls -la ~/.claude/skills/chrome-devtools/SKILL.md
  ```

- [ ] **Task 4.1.1.2**: Test skill invocation in Claude Code
  - Invoke: `@~/.claude/skills/playwright-browser/SKILL.md`
  - Invoke: `@~/.claude/skills/chrome-devtools/SKILL.md`
  - Verify: Skills load without errors

#### 4.1.2: Test Skill Operations
- [ ] **Task 4.1.2.1**: Test Playwright skill
  - Request: Navigate to example.com
  - Request: Take screenshot
  - Request: Click element
  - Verify: All operations successful

- [ ] **Task 4.1.2.2**: Test Chrome DevTools skill
  - Request: Navigate to example.com
  - Request: Evaluate JavaScript
  - Request: Capture network traffic
  - Verify: All operations successful

### 4.2: Cross-Skill Operations

#### 4.2.1: Playwright + Chrome DevTools Workflows
- [ ] **Task 4.2.1.1**: Test combined automation
  - Playwright: Navigate to page
  - Chrome DevTools: Monitor network
  - Playwright: Interact with elements
  - Chrome DevTools: Capture console logs

- [ ] **Task 4.2.1.2**: Test debugging workflow
  - Playwright: Reproduce issue
  - Chrome DevTools: Analyze DOM
  - Chrome DevTools: Check performance
  - Verify: Complementary capabilities

#### 4.2.2: Resource Sharing Tests
- [ ] **Task 4.2.2.1**: Test concurrent execution
  - Start both containers
  - Run operations simultaneously
  - Monitor resource usage
  - Verify: <2GB total memory

- [ ] **Task 4.2.2.2**: Test network isolation
  - Verify containers on agent-network
  - Test container-to-container communication (if needed)
  - Verify no port conflicts

### 4.3: Production Readiness Validation

#### 4.3.1: Reliability Testing
- [ ] **Task 4.3.1.1**: 24-hour uptime test
  - Start both containers
  - Run periodic operations (every 30 min)
  - Monitor health checks
  - Target: 99%+ uptime

- [ ] **Task 4.3.1.2**: Failure recovery test
  - Kill container mid-operation
  - Verify auto-restart (if configured)
  - Test manual restart
  - Verify no data corruption

#### 4.3.2: Performance Validation
- [ ] **Task 4.3.2.1**: Load testing
  - 100 sequential operations (each skill)
  - Measure: avg, p50, p95, p99
  - Verify: p95 <500ms

- [ ] **Task 4.3.2.2**: Resource monitoring
  ```bash
  docker stats --no-stream
  ```
  - Verify: Memory <2GB total
  - Verify: CPU <50% average

#### 4.3.3: Security Validation
- [ ] **Task 4.3.3.1**: Review container security
  - Non-root users configured
  - Resource limits applied
  - No unnecessary ports exposed
  - Read-only file systems where applicable

- [ ] **Task 4.3.3.2**: Test network isolation
  - Verify containers isolated from host network (except exposed ports)
  - Test agent-network communication
  - Verify no unintended network access

### 4.4: Documentation Completion

#### 4.4.1: Update SKILL.md Files
- [ ] **Task 4.4.1.1**: Add troubleshooting section
  - Common errors and solutions
  - Debug commands
  - Log locations

- [ ] **Task 4.4.1.2**: Add examples section
  - Real-world use cases
  - Code snippets
  - Expected outputs

#### 4.4.2: Create Migration Guide
- [ ] **Task 4.4.2.1**: Create MIGRATION.md
  - Location: `~/.claude/claudedocs/mcp_to_docker_migration.md`
  - Content:
    - Why migrate from MCP to Docker
    - Step-by-step migration process
    - Comparison table (before/after)
    - Rollback procedures

- [ ] **Task 4.4.2.2**: Document MCP removal (optional)
  - How to disable MCP servers
  - Backup MCP configurations
  - Clean uninstall steps

#### 4.4.3: Create Troubleshooting Guide
- [ ] **Task 4.4.3.1**: Create TROUBLESHOOTING.md
  - Common issues:
    - Container won't start
    - WebSocket connection failed
    - Ruby gem issues
    - Performance degradation
  - Diagnostic commands
  - Solutions and workarounds

### 4.5: Final Validation Checklist

#### 4.5.1: Functional Validation
- [ ] **All Playwright operations working**
  - Navigate, screenshot, click, fill, evaluate
- [ ] **All Chrome DevTools operations working**
  - Page control, runtime evaluation, network monitoring, DOM queries
- [ ] **Both containers start automatically**
  - Docker Compose restart policy working
- [ ] **Health checks passing**
  - Playwright health endpoint responding
  - Chrome DevTools /json endpoint responding
- [ ] **Error handling working**
  - Retry logic functional
  - Timeout handling correct
  - Graceful failures

#### 4.5.2: Performance Validation
- [ ] **API response time <500ms (p95)**
- [ ] **Container startup <30 seconds**
- [ ] **Memory usage <2GB total**
- [ ] **CPU usage <50% average**
- [ ] **99%+ uptime over 24 hours**

#### 4.5.3: Documentation Validation
- [ ] **SKILL.md files complete**
  - All sections filled out
  - Examples tested and verified
  - Troubleshooting accurate
- [ ] **Migration guide complete**
  - Clear step-by-step instructions
  - Tested by following guide
- [ ] **Troubleshooting guide complete**
  - Covers common issues
  - Solutions verified

#### 4.5.4: Integration Validation
- [ ] **Skills work in Claude Code**
  - Invocation successful
  - Operations execute correctly
  - Results returned properly
- [ ] **Cross-session persistence**
  - Containers survive Claude Code restarts
  - State maintained across sessions
- [ ] **No MCP dependency**
  - Skills work without MCP servers running
  - Complete local execution

### Validation Criteria
- [ ] All functional tests passing
- [ ] All performance benchmarks met
- [ ] All documentation complete and verified
- [ ] Skills registered and operational in Claude Code
- [ ] 24-hour stability test passed
- [ ] Migration guide tested and accurate

### Estimated Time
- Integration: 4 hours
- Testing: 8 hours
- Documentation: 6 hours
- Validation: 4 hours
- **Total**: 22 hours (1 week part-time)

---

## Appendices

### Appendix A: Docker Compose Configurations

#### A.1: Playwright Docker Compose

**File**: `~/.claude/skills/playwright-browser/docker/docker-compose.yml`

```yaml
version: '3.8'

services:
  playwright:
    image: mcr.microsoft.com/playwright:v1.40.0-jammy
    container_name: playwright-server
    hostname: playwright

    ports:
      - "${PLAYWRIGHT_PORT:-3000}:3000"

    environment:
      - PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
      - NODE_ENV=production

    command: npx playwright run-server --port 3000 --host 0.0.0.0

    volumes:
      - playwright-cache:/ms-playwright
      - playwright-downloads:/downloads

    networks:
      - agent-network

    restart: unless-stopped

    # Security options
    security_opt:
      - no-new-privileges:true

    # Resource limits
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 512M

    # Health check
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

    # IPC mode for better browser performance
    ipc: host

    # Logging
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

volumes:
  playwright-cache:
    driver: local
  playwright-downloads:
    driver: local

networks:
  agent-network:
    external: true
```

**Environment File**: `.env`
```bash
PLAYWRIGHT_PORT=3000
PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
```

#### A.2: Chrome DevTools Docker Compose

**File**: `~/.claude/skills/chrome-devtools/docker/docker-compose.yml`

```yaml
version: '3.8'

services:
  chrome:
    image: browserless/chrome:latest
    container_name: chrome-devtools-server
    hostname: chrome-devtools

    ports:
      - "${CDP_PORT:-9222}:3000"
      - "${VNC_PORT:-5900}:5900"

    environment:
      - CONNECTION_TIMEOUT=600000
      - MAX_CONCURRENT_SESSIONS=5
      - PREBOOT_CHROME=true
      - DEMO_MODE=false
      - ENABLE_DEBUGGER=true
      - CHROME_REFRESH_TIME=0
      - DEFAULT_HEADLESS=true
      - DEFAULT_LAUNCH_ARGS=["--no-sandbox","--disable-dev-shm-usage"]

    volumes:
      - chrome-data:/data
      - chrome-downloads:/downloads

    networks:
      - agent-network

    restart: unless-stopped

    # Security options
    security_opt:
      - no-new-privileges:true
    cap_add:
      - SYS_ADMIN

    # Resource limits
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 512M

    # Health check
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/json/version"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

    # Shared memory for Chrome
    shm_size: 2gb

    # Logging
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

volumes:
  chrome-data:
    driver: local
  chrome-downloads:
    driver: local

networks:
  agent-network:
    external: true
```

**Environment File**: `.env`
```bash
CDP_PORT=9222
VNC_PORT=5900
```

### Appendix B: Ruby Implementation Examples

#### B.1: Playwright Client Implementation

**File**: `~/.claude/skills/playwright-browser/scripts/playwright_client.rb`

```ruby
#!/usr/bin/env ruby

require 'websocket-client-simple'
require 'json'
require 'logger'

class PlaywrightClient
  attr_reader :logger

  DEFAULT_TIMEOUT = 30000 # 30 seconds
  MAX_RETRIES = 3
  RETRY_DELAY = 1 # seconds

  def initialize(host: 'localhost', port: 3000, logger: nil)
    @host = host
    @port = port
    @logger = logger || Logger.new(STDOUT)
    @logger.level = Logger::INFO
    @ws = nil
    @request_id = 0
    @pending_requests = {}
    @connected = false

    connect
  end

  def connect
    @logger.info("Connecting to Playwright server at ws://#{@host}:#{@port}")

    @ws = WebSocket::Client::Simple.connect("ws://#{@host}:#{@port}/")

    @ws.on :message do |msg|
      handle_message(msg.data)
    end

    @ws.on :open do
      @logger.info("WebSocket connection established")
      @connected = true
    end

    @ws.on :close do |e|
      @logger.warn("WebSocket connection closed: #{e}")
      @connected = false
    end

    @ws.on :error do |e|
      @logger.error("WebSocket error: #{e}")
      @connected = false
    end

    # Wait for connection
    sleep 1 until @connected

  rescue => e
    @logger.error("Failed to connect: #{e.message}")
    raise ConnectionError, "Could not connect to Playwright server: #{e.message}"
  end

  def navigate(url, wait_until: 'load', timeout: DEFAULT_TIMEOUT)
    send_command('page.goto', {
      url: url,
      waitUntil: wait_until,
      timeout: timeout
    })
  end

  def screenshot(path: nil, full_page: false, type: 'png')
    result = send_command('page.screenshot', {
      path: path,
      fullPage: full_page,
      type: type
    })

    # Return base64 image if no path specified
    path.nil? ? result['buffer'] : result
  end

  def click(selector, timeout: DEFAULT_TIMEOUT)
    send_command('page.click', {
      selector: selector,
      timeout: timeout
    })
  end

  def fill(selector, value, timeout: DEFAULT_TIMEOUT)
    send_command('page.fill', {
      selector: selector,
      value: value,
      timeout: timeout
    })
  end

  def evaluate(expression)
    send_command('page.evaluate', {
      expression: expression
    })
  end

  def close
    @ws.close if @ws
    @connected = false
    @logger.info("Connection closed")
  end

  private

  def send_command(method, params = {}, retry_count = 0)
    raise ConnectionError, "Not connected" unless @connected

    @request_id += 1
    request = {
      id: @request_id,
      method: method,
      params: params
    }

    @logger.debug("Sending command: #{method}")
    @ws.send(JSON.generate(request))

    # Wait for response
    response = wait_for_response(@request_id)

    if response['error']
      raise CommandError, "Command failed: #{response['error']['message']}"
    end

    response['result']

  rescue => e
    if retry_count < MAX_RETRIES
      @logger.warn("Command failed, retrying (#{retry_count + 1}/#{MAX_RETRIES}): #{e.message}")
      sleep RETRY_DELAY * (2 ** retry_count) # Exponential backoff
      send_command(method, params, retry_count + 1)
    else
      @logger.error("Command failed after #{MAX_RETRIES} retries: #{e.message}")
      raise
    end
  end

  def handle_message(data)
    message = JSON.parse(data)

    if message['id']
      # Response to a command
      @pending_requests[message['id']] = message
    else
      # Event (not currently handled, but could be)
      @logger.debug("Event received: #{message['method']}")
    end

  rescue JSON::ParserError => e
    @logger.error("Failed to parse message: #{e.message}")
  end

  def wait_for_response(request_id, timeout = DEFAULT_TIMEOUT)
    start_time = Time.now

    loop do
      if @pending_requests[request_id]
        return @pending_requests.delete(request_id)
      end

      if (Time.now - start_time) * 1000 > timeout
        raise TimeoutError, "Request #{request_id} timed out after #{timeout}ms"
      end

      sleep 0.01 # Poll every 10ms
    end
  end

  class ConnectionError < StandardError; end
  class CommandError < StandardError; end
  class TimeoutError < StandardError; end
end

# Example usage (for testing)
if __FILE__ == $0
  client = PlaywrightClient.new

  puts "Navigating to example.com..."
  client.navigate('https://example.com')

  puts "Taking screenshot..."
  client.screenshot(path: '/tmp/example.png', full_page: true)

  puts "Evaluating JavaScript..."
  title = client.evaluate('document.title')
  puts "Page title: #{title}"

  client.close
end
```

#### B.2: Chrome DevTools Protocol Client Implementation

**File**: `~/.claude/skills/chrome-devtools/scripts/cdp_client.rb`

```ruby
#!/usr/bin/env ruby

require 'websocket-client-simple'
require 'json'
require 'net/http'
require 'logger'

class CDPClient
  attr_reader :logger

  DEFAULT_TIMEOUT = 30000
  MAX_RETRIES = 3
  RETRY_DELAY = 1

  def initialize(host: 'localhost', port: 9222, logger: nil)
    @host = host
    @port = port
    @logger = logger || Logger.new(STDOUT)
    @logger.level = Logger::INFO
    @ws = nil
    @request_id = 0
    @pending_requests = {}
    @event_handlers = {}
    @connected = false
    @target_id = nil

    # Get WebSocket debugger URL
    @ws_url = get_websocket_url
    connect
  end

  def connect
    @logger.info("Connecting to Chrome DevTools at #{@ws_url}")

    @ws = WebSocket::Client::Simple.connect(@ws_url)

    @ws.on :message do |msg|
      handle_message(msg.data)
    end

    @ws.on :open do
      @logger.info("CDP connection established")
      @connected = true
    end

    @ws.on :close do |e|
      @logger.warn("CDP connection closed: #{e}")
      @connected = false
    end

    @ws.on :error do |e|
      @logger.error("CDP error: #{e}")
      @connected = false
    end

    sleep 1 until @connected

  rescue => e
    @logger.error("Failed to connect: #{e.message}")
    raise ConnectionError, "Could not connect to Chrome DevTools: #{e.message}"
  end

  # Page domain methods
  def page_enable
    send_command('Page.enable')
  end

  def page_navigate(url)
    send_command('Page.navigate', { url: url })
  end

  def page_reload(ignore_cache: false)
    send_command('Page.reload', { ignoreCache: ignore_cache })
  end

  def page_screenshot(format: 'png', quality: nil)
    params = { format: format }
    params[:quality] = quality if format == 'jpeg' && quality
    send_command('Page.captureScreenshot', params)
  end

  # Runtime domain methods
  def runtime_enable
    send_command('Runtime.enable')
  end

  def runtime_evaluate(expression, return_by_value: true)
    send_command('Runtime.evaluate', {
      expression: expression,
      returnByValue: return_by_value
    })
  end

  # Network domain methods
  def network_enable
    send_command('Network.enable')
  end

  def network_disable
    send_command('Network.disable')
  end

  def network_set_cache_disabled(disabled: true)
    send_command('Network.setCacheDisabled', { cacheDisabled: disabled })
  end

  # DOM domain methods
  def dom_enable
    send_command('DOM.enable')
  end

  def dom_get_document
    send_command('DOM.getDocument')
  end

  def dom_query_selector(node_id, selector)
    send_command('DOM.querySelector', {
      nodeId: node_id,
      selector: selector
    })
  end

  # Event subscription
  def on_event(method, &block)
    @event_handlers[method] = block
    @logger.debug("Registered event handler for: #{method}")
  end

  def close
    @ws.close if @ws
    @connected = false
    @logger.info("CDP connection closed")
  end

  private

  def get_websocket_url
    uri = URI("http://#{@host}:#{@port}/json")
    response = Net::HTTP.get(uri)
    targets = JSON.parse(response)

    # Get first page target
    page = targets.find { |t| t['type'] == 'page' }

    raise ConnectionError, "No page targets available" unless page

    @target_id = page['id']
    page['webSocketDebuggerUrl']

  rescue => e
    raise ConnectionError, "Failed to get WebSocket URL: #{e.message}"
  end

  def send_command(method, params = {}, retry_count = 0)
    raise ConnectionError, "Not connected" unless @connected

    @request_id += 1
    request = {
      id: @request_id,
      method: method,
      params: params
    }

    @logger.debug("Sending CDP command: #{method}")
    @ws.send(JSON.generate(request))

    response = wait_for_response(@request_id)

    if response['error']
      raise CommandError, "CDP command failed: #{response['error']['message']}"
    end

    response['result']

  rescue => e
    if retry_count < MAX_RETRIES
      @logger.warn("Command failed, retrying (#{retry_count + 1}/#{MAX_RETRIES}): #{e.message}")
      sleep RETRY_DELAY * (2 ** retry_count)
      send_command(method, params, retry_count + 1)
    else
      @logger.error("Command failed after #{MAX_RETRIES} retries: #{e.message}")
      raise
    end
  end

  def handle_message(data)
    message = JSON.parse(data)

    if message['id']
      # Response to a command
      @pending_requests[message['id']] = message
    elsif message['method']
      # Event
      @logger.debug("CDP event: #{message['method']}")
      handle_event(message)
    end

  rescue JSON::ParserError => e
    @logger.error("Failed to parse CDP message: #{e.message}")
  end

  def handle_event(message)
    handler = @event_handlers[message['method']]
    handler.call(message['params']) if handler
  end

  def wait_for_response(request_id, timeout = DEFAULT_TIMEOUT)
    start_time = Time.now

    loop do
      if @pending_requests[request_id]
        return @pending_requests.delete(request_id)
      end

      if (Time.now - start_time) * 1000 > timeout
        raise TimeoutError, "Request #{request_id} timed out after #{timeout}ms"
      end

      sleep 0.01
    end
  end

  class ConnectionError < StandardError; end
  class CommandError < StandardError; end
  class TimeoutError < StandardError; end
end

# Example usage
if __FILE__ == $0
  client = CDPClient.new

  # Enable domains
  client.page_enable
  client.runtime_enable
  client.network_enable

  # Subscribe to network events
  client.on_event('Network.requestWillBeSent') do |params|
    puts "Request: #{params['request']['url']}"
  end

  # Navigate
  puts "Navigating to example.com..."
  client.page_navigate('https://example.com')

  sleep 2 # Wait for page load

  # Evaluate JavaScript
  puts "Evaluating JavaScript..."
  result = client.runtime_evaluate('document.title')
  puts "Page title: #{result['result']['value']}"

  # Take screenshot
  puts "Taking screenshot..."
  screenshot = client.page_screenshot
  puts "Screenshot captured (#{screenshot['data'].length} bytes)"

  client.close
end
```

### Appendix C: SKILL.md Templates

#### C.1: Playwright Agent Skill Template

**File**: `~/.claude/skills/playwright-browser/SKILL.md`

```markdown
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

# Navigate with specific wait condition
~/.claude/skills/playwright-browser/scripts/navigate.rb "https://example.com" --wait-until networkidle
```

### Screenshots
```bash
# Capture screenshot
~/.claude/skills/playwright-browser/scripts/screenshot.rb "https://example.com" /tmp/screenshot.png

# Full-page screenshot
~/.claude/skills/playwright-browser/scripts/screenshot.rb "https://example.com" /tmp/screenshot.png --full-page
```

### Interaction
```bash
# Click element
~/.claude/skills/playwright-browser/scripts/click.rb "#submit-button"

# Fill form
~/.claude/skills/playwright-browser/scripts/fill.rb "#email" "user@example.com"
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
```

#### C.2: Chrome DevTools Agent Skill Template

**File**: `~/.claude/skills/chrome-devtools/SKILL.md`

```markdown
---
name: chrome-devtools
description: Chrome debugging and inspection via local CDP Docker container
category: debugging
triggers: [debug, inspect, devtools, performance, network, chrome, CDP]
docker_required: true
ruby_required: true
---

# Chrome DevTools Protocol Skill

## Purpose
Provides Chrome DevTools Protocol (CDP) access through a local Docker container, enabling browser debugging, network inspection, performance profiling, and DOM manipulation without remote MCP dependencies.

## Capabilities
- **Page Control**: Navigate, reload, screenshot
- **JavaScript Execution**: Evaluate scripts in browser context
- **Network Monitoring**: Capture requests, responses, timing
- **DOM Inspection**: Query and manipulate DOM elements
- **Performance**: Profiling, metrics, Core Web Vitals
- **Console**: Capture console logs and errors

## Requirements

### Docker
- Docker Desktop installed and running
- `agent-network` Docker network created
- Chrome DevTools container running

### Ruby
- Ruby ≥2.7
- Gems: `websocket-client-simple`, `json`, `net-http`

### Setup
```bash
# Start Chrome DevTools container
cd ~/.claude/skills/chrome-devtools/docker
docker-compose up -d

# Verify container is running
docker ps | grep chrome-devtools-server

# Check CDP endpoint
curl http://localhost:9222/json/version
```

## Usage

### Page Navigation
```bash
# Navigate to URL
~/.claude/skills/chrome-devtools/scripts/navigate.rb "https://example.com"

# Reload page
~/.claude/skills/chrome-devtools/scripts/reload.rb
```

### JavaScript Evaluation
```bash
# Execute JavaScript
~/.claude/skills/chrome-devtools/scripts/evaluate.rb "document.title"

# Get complex data
~/.claude/skills/chrome-devtools/scripts/evaluate.rb "Array.from(document.querySelectorAll('a')).map(a => a.href)"
```

### Network Monitoring
```bash
# Capture network traffic
~/.claude/skills/chrome-devtools/scripts/network_capture.rb "https://example.com" 5

# Arguments: URL, duration (seconds)
```

### Screenshots
```bash
# Capture screenshot
~/.claude/skills/chrome-devtools/scripts/screenshot.rb /tmp/screenshot.png

# JPEG with quality
~/.claude/skills/chrome-devtools/scripts/screenshot.rb /tmp/screenshot.jpg --format jpeg --quality 80
```

### Console Logs
```bash
# Monitor console output
~/.claude/skills/chrome-devtools/scripts/console_log.rb "https://example.com" 10

# Arguments: URL, duration (seconds)
```

## Docker Management

### Start Container
```bash
~/.claude/skills/chrome-devtools/scripts/start.sh
```

### Stop Container
```bash
~/.claude/skills/chrome-devtools/scripts/stop.sh
```

### Restart Container
```bash
~/.claude/skills/chrome-devtools/scripts/restart.sh
```

### Check Status
```bash
~/.claude/skills/chrome-devtools/scripts/status.sh
```

### VNC Access (Visual Debugging)
```bash
# Get VNC connection details
~/.claude/skills/chrome-devtools/scripts/vnc_url.sh

# Connect with VNC viewer to: vnc://localhost:5900
# Password: secret
```

## Troubleshooting

### Container won't start
**Symptom**: `docker-compose up -d` fails

**Solutions**:
1. Check Docker Desktop is running
2. Verify SHM size setting (Chrome needs shared memory)
3. Check logs: `docker-compose logs`
4. Try with increased shm_size in docker-compose.yml

### CDP connection failed
**Symptom**: Can't connect to WebSocket

**Solutions**:
1. Verify container is running: `docker ps | grep chrome`
2. Check CDP endpoint: `curl http://localhost:9222/json`
3. Verify port not in use: `lsof -i :9222`
4. Check container logs: `docker logs chrome-devtools-server`

### Browser crashed
**Symptom**: CDP commands fail with "Target closed"

**Solutions**:
1. Restart container: `docker-compose restart`
2. Check memory limits (Chrome needs ≥1GB)
3. Review crash logs: `docker logs chrome-devtools-server`

### VNC not working
**Symptom**: Can't connect to VNC

**Solutions**:
1. Verify VNC port exposed: `docker port chrome-devtools-server`
2. Check firewall settings
3. Use different VNC viewer
4. Restart container: `docker-compose restart`

## Performance Notes
- Container startup: ~15-20 seconds
- CDP response time: <200ms typical
- Memory usage: ~800MB-1.5GB
- Supports up to 5 concurrent sessions (configurable)

## Advanced Configuration

### Headless vs Headed Mode
Edit `docker-compose.yml` environment:
```yaml
environment:
  - DEFAULT_HEADLESS=false  # Enable headed mode for VNC
```

### Session Limits
```yaml
environment:
  - MAX_CONCURRENT_SESSIONS=10
```

### Preboot Optimization
```yaml
environment:
  - PREBOOT_CHROME=true  # Faster first connection
```

## CDP Domains Reference

### Commonly Used Domains
- **Page**: Navigation, lifecycle, resources
- **Runtime**: JavaScript evaluation, console
- **Network**: Request/response monitoring
- **DOM**: Document structure, queries
- **Performance**: Metrics, profiling
- **Debugger**: Breakpoints, stepping
- **Profiler**: CPU/Memory profiling

### Event Subscription Example
```ruby
require_relative 'cdp_client'

client = CDPClient.new
client.network_enable

client.on_event('Network.requestWillBeSent') do |params|
  puts "Request: #{params['request']['url']}"
end

client.page_navigate('https://example.com')
sleep 5 # Capture traffic
```

## See Also
- Playwright skill for browser automation
- CDP Protocol documentation: https://chromedevtools.github.io/devtools-protocol/
- Original research: `~/.claude/claudedocs/research_mcp_to_agent_skill_conversion_20251116.md`
```

### Appendix D: Troubleshooting Guide

**File**: `~/.claude/claudedocs/docker_skills_troubleshooting.md`

```markdown
# Docker Agent Skills Troubleshooting Guide

## Common Issues

### Docker Desktop Issues

#### Docker Desktop not running
**Symptoms**:
- `Cannot connect to the Docker daemon`
- `docker: command not found`

**Solutions**:
1. Open Docker Desktop application
2. Wait for Docker to start (check menu bar icon)
3. Verify: `docker --version`
4. If issues persist, restart Docker Desktop

#### Insufficient resources
**Symptoms**:
- Container starts but crashes
- Poor performance
- Out of memory errors

**Solutions**:
1. Open Docker Desktop → Settings → Resources
2. Increase Memory to ≥4GB
3. Increase CPUs to ≥2 cores
4. Increase Disk space to ≥20GB
5. Apply & Restart

### Network Issues

#### agent-network doesn't exist
**Symptoms**:
- `network agent-network not found`

**Solution**:
```bash
docker network create \
  --driver bridge \
  --subnet 172.28.0.0/16 \
  agent-network
```

#### Port already in use
**Symptoms**:
- `port is already allocated`

**Solutions**:
1. Check what's using the port:
   ```bash
   lsof -i :3000  # Playwright
   lsof -i :9222  # Chrome DevTools
   ```
2. Stop conflicting process or change port in `.env` file

### Container Issues

#### Container won't start
**Symptoms**:
- `docker-compose up` fails immediately
- Container status: `Exited`

**Solutions**:
1. Check logs:
   ```bash
   docker-compose logs
   docker logs [container-name]
   ```
2. Verify image pulled successfully:
   ```bash
   docker images | grep playwright
   docker images | grep browserless
   ```
3. Try recreating:
   ```bash
   docker-compose down -v
   docker-compose up -d
   ```

#### Health check failing
**Symptoms**:
- Container running but health check fails
- `Health: unhealthy`

**Solutions**:
1. Check health check logs:
   ```bash
   docker inspect [container-name] | grep -A 20 Health
   ```
2. Test endpoint manually:
   ```bash
   # Playwright
   curl http://localhost:3000/health

   # Chrome DevTools
   curl http://localhost:9222/json/version
   ```
3. Increase health check timeout in docker-compose.yml

### Ruby Script Issues

#### Gem not found
**Symptoms**:
- `LoadError: cannot load such file -- websocket-client-simple`

**Solution**:
```bash
gem install websocket-client-simple json
```

#### Permission denied
**Symptoms**:
- `Permission denied` when running scripts

**Solution**:
```bash
chmod +x ~/.claude/skills/*/scripts/*.rb
```

#### Connection refused
**Symptoms**:
- Ruby script can't connect to container

**Solutions**:
1. Verify container is running:
   ```bash
   docker ps | grep playwright
   docker ps | grep chrome
   ```
2. Check container logs for errors
3. Test endpoint with curl (see above)
4. Verify correct port in script

### Performance Issues

#### Slow operations
**Symptoms**:
- Commands take >5 seconds
- Timeouts

**Solutions**:
1. Check container resources:
   ```bash
   docker stats --no-stream
   ```
2. Increase resource limits in docker-compose.yml
3. Reduce concurrent operations
4. Check system load: `top` or Activity Monitor

#### High memory usage
**Symptoms**:
- Container using >2GB memory
- System becoming slow

**Solutions**:
1. Restart container:
   ```bash
   docker-compose restart
   ```
2. Review resource limits in docker-compose.yml
3. Reduce MAX_CONCURRENT_SESSIONS (Chrome DevTools)
4. Close unused browser tabs/contexts

### Playwright-Specific Issues

#### Browser not launching
**Symptoms**:
- Timeout waiting for browser
- `browserType.launch: Executable doesn't exist`

**Solutions**:
1. Verify Playwright image includes browsers:
   ```bash
   docker exec playwright-server npx playwright --version
   ```
2. Check PLAYWRIGHT_BROWSERS_PATH environment variable
3. Try different Playwright image version

#### Screenshot failed
**Symptoms**:
- Screenshot command returns error
- Empty/corrupted image file

**Solutions**:
1. Verify page loaded completely
2. Check screenshot path is writable
3. Try viewport screenshot instead of full-page
4. Increase timeout

### Chrome DevTools-Specific Issues

#### CDP connection closed
**Symptoms**:
- `Target closed`
- Connection drops mid-operation

**Solutions**:
1. Check Chrome didn't crash:
   ```bash
   docker logs chrome-devtools-server
   ```
2. Verify shared memory size (shm_size in docker-compose.yml)
3. Reduce concurrent sessions
4. Restart container

#### VNC not accessible
**Symptoms**:
- Can't connect via VNC viewer

**Solutions**:
1. Verify VNC port exposed:
   ```bash
   docker port chrome-devtools-server
   ```
2. Check DEFAULT_HEADLESS=false in environment
3. Try different VNC client
4. Check firewall settings

## Diagnostic Commands

### Container Status
```bash
# List running containers
docker ps

# Check specific container
docker ps -a | grep [container-name]

# Container logs
docker logs [container-name]

# Follow logs in real-time
docker logs -f [container-name]

# Inspect container
docker inspect [container-name]
```

### Network Diagnostics
```bash
# List networks
docker network ls

# Inspect agent-network
docker network inspect agent-network

# Check port bindings
docker port [container-name]

# Test connectivity
curl -v http://localhost:3000/health  # Playwright
curl -v http://localhost:9222/json    # Chrome DevTools
```

### Resource Monitoring
```bash
# Real-time stats
docker stats

# One-time snapshot
docker stats --no-stream

# Specific container
docker stats [container-name] --no-stream
```

### Ruby Diagnostics
```bash
# Check Ruby version
ruby --version

# List installed gems
gem list

# Install missing gems
gem install websocket-client-simple json

# Test script syntax
ruby -c [script-path]
```

## Recovery Procedures

### Complete Reset
If all else fails, complete reset:

```bash
# Stop and remove containers
cd ~/.claude/skills/playwright-browser/docker
docker-compose down -v
cd ~/.claude/skills/chrome-devtools/docker
docker-compose down -v

# Remove network
docker network rm agent-network

# Recreate network
docker network create --driver bridge agent-network

# Pull fresh images
docker pull mcr.microsoft.com/playwright:v1.40.0-jammy
docker pull browserless/chrome:latest

# Start containers
cd ~/.claude/skills/playwright-browser/docker
docker-compose up -d
cd ~/.claude/skills/chrome-devtools/docker
docker-compose up -d

# Verify health
docker ps
curl http://localhost:3000/health
curl http://localhost:9222/json/version
```

### Logs Collection
For reporting issues:

```bash
# Create diagnostics bundle
mkdir -p /tmp/docker-skills-diagnostics

# Collect Docker info
docker version > /tmp/docker-skills-diagnostics/docker-version.txt
docker info > /tmp/docker-skills-diagnostics/docker-info.txt

# Collect container logs
docker logs playwright-server > /tmp/docker-skills-diagnostics/playwright.log 2>&1
docker logs chrome-devtools-server > /tmp/docker-skills-diagnostics/chrome.log 2>&1

# Collect container inspection
docker inspect playwright-server > /tmp/docker-skills-diagnostics/playwright-inspect.json
docker inspect chrome-devtools-server > /tmp/docker-skills-diagnostics/chrome-inspect.json

# Collect network info
docker network inspect agent-network > /tmp/docker-skills-diagnostics/network.json

# Collect system info
docker stats --no-stream > /tmp/docker-skills-diagnostics/stats.txt

echo "Diagnostics collected in /tmp/docker-skills-diagnostics/"
```

## Getting Help

### Before Asking for Help
1. Check this troubleshooting guide
2. Review container logs
3. Verify all requirements met (Docker, Ruby, gems)
4. Try complete reset procedure
5. Collect diagnostics bundle

### Information to Include
- Docker version: `docker --version`
- Ruby version: `ruby --version`
- Container logs
- Error messages (complete, not truncated)
- Steps to reproduce
- Expected vs actual behavior

### Resources
- Original research: `~/.claude/claudedocs/research_mcp_to_agent_skill_conversion_20251116.md`
- Playwright docs: https://playwright.dev/
- Chrome DevTools Protocol: https://chromedevtools.github.io/devtools-protocol/
- Docker docs: https://docs.docker.com/
```

---

## Progress Tracking

Use this section to track your progress across sessions. Mark completed tasks with an `x`:

### Quick Status
- [ ] Phase 1 Complete (Environment Setup)
- [ ] Phase 2 Complete (Playwright)
- [ ] Phase 3 Complete (Chrome DevTools)
- [ ] Phase 4 Complete (Integration & Validation)

### Current Phase
**Phase**: ___________
**Week**: ___________
**Last Updated**: ___________

### Notes
```
Add session notes here:
-
-
-
```

### Blockers
```
Document any blockers or issues:
-
-
```

---

## Next Steps

After completing this roadmap:

1. **Monitor Performance**: Track actual vs expected performance over 1-2 weeks
2. **Optimize**: Tune resource limits based on real usage patterns
3. **Expand**: Consider Tier 2 implementations (SearXNG, Zeal Docsets)
4. **Document**: Create user guide for team members
5. **Migrate Others**: Apply learnings to other potential conversions

## References

- **Original Research**: `/Users/arlenagreer/.claude/claudedocs/research_mcp_to_agent_skill_conversion_20251116.md`
- **Docker Documentation**: https://docs.docker.com/
- **Playwright Documentation**: https://playwright.dev/
- **Chrome DevTools Protocol**: https://chromedevtools.github.io/devtools-protocol/
- **Ruby WebSocket**: https://github.com/imanel/websocket-ruby

---

**Document Status**: Planning Complete
**Generated**: 2025-11-16
**Last Updated**: 2025-11-16
**Version**: 1.0
