# SuperClaude Skills Migration Plan - Tier 1 MCP-to-Skills Conversion

**Date**: November 16, 2025
**Status**: PLANNING PHASE - Ready for Implementation
**Migration Type**: Full Skills Migration (Option 1)
**Scope**: 17 files requiring MCP-to-Skills syntax updates

---

## Executive Summary

This migration plan converts SuperClaude framework's hardcoded MCP tool references (`mcp__chrome-devtools__*`, `mcp__playwright__*`) to Agent Skills syntax compatible with the local Docker-based browser automation architecture implemented in Tier 1.

**Migration Commitment**: Full Skills approach with NO MCP fallback
- **Active SuperClaude Agents**: Yes, user actively uses agents
- **Timeline**: Immediate implementation
- **Testing Strategy**: Phase-by-phase validation with rollback capability

---

## Migration Overview

### Current Architecture
```
SuperClaude Agents → MCP Tool Syntax → Remote MCP Servers (REMOVED)
   ❌ Broken: MCP servers no longer exist
```

### Target Architecture
```
SuperClaude Agents → Skills Syntax → Local Docker Skills → REST APIs → Browser Containers
   ✅ Working: Local Docker-based Skills with REST API integration
```

### Key Changes Required

**Tool Reference Syntax**:
```yaml
# FROM (MCP):
allowed-tools: mcp__chrome-devtools__*, mcp__playwright__*

# TO (Skills):
allowed-tools: Skill(chrome-devtools), Skill(playwright-browser)
```

**Command Invocation Syntax**:
```yaml
# FROM (MCP Function Call):
mcp__chrome-devtools__navigate_page({
  url: "http://localhost:3000",
  type: "url"
})

# TO (Skill Script Invocation):
Skill(chrome-devtools): navigate.rb "http://localhost:3000"
```

---

## Affected Files Inventory

### Phase 1: Agent Definitions (6 files)

#### 1.1 `/Users/arlenagreer/.claude/agents/frontend-qc-agent.md`
**Current**: `allowed-tools: Task, Read, Write, TodoWrite, mcp__chrome-devtools__*, Skill(report-bug), Skill(email)`
**Target**: `allowed-tools: Task, Read, Write, TodoWrite, Skill(chrome-devtools), Skill(report-bug), Skill(email)`
**Critical**: Primary QA agent for parallel frontend testing
**Impact**: HIGH - Used in all frontend quality campaigns

#### 1.2 `/Users/arlenagreer/.claude/agents/frontend-debug-agent.md`
**Current**: `allowed-tools: Task, Read, Write, Edit, TodoWrite, mcp__chrome-devtools__*, Skill(report-bug), mcp__sequential-thinking__*, SlashCommand(...)`
**Target**: `allowed-tools: Task, Read, Write, Edit, TodoWrite, Skill(chrome-devtools), Skill(report-bug), mcp__sequential-thinking__*, SlashCommand(...)`
**Critical**: Orchestrator for complex frontend debugging
**Impact**: HIGH - Coordinates all debug specialists

#### 1.3 `/Users/arlenagreer/.claude/agents/debug-specialists/network-specialist.md`
**Current**: Uses specific MCP commands:
```yaml
mcp__chrome-devtools__navigate_page(...)
mcp__chrome-devtools__list_network_requests(...)
mcp__chrome-devtools__get_network_request(...)
mcp__chrome-devtools__fill_form(...)
```
**Target**: Convert to Skill script invocations
**Critical**: Network/API debugging specialist
**Impact**: MEDIUM - Specialized domain expert

#### 1.4 `/Users/arlenagreer/.claude/agents/debug-specialists/state-specialist.md`
**Current**: MCP command references for state inspection
**Target**: Skill script invocations for state debugging
**Critical**: Redux/Context/data-flow debugging
**Impact**: MEDIUM - Specialized domain expert

#### 1.5 `/Users/arlenagreer/.claude/agents/debug-specialists/ui-specialist.md`
**Current**: MCP commands for DOM/rendering/CSS inspection
**Target**: Skill scripts for UI debugging
**Critical**: Visual bug and rendering specialist
**Impact**: MEDIUM - Specialized domain expert

#### 1.6 `/Users/arlenagreer/.claude/agents/debug-specialists/performance-specialist.md`
**Current**: MCP performance measurement commands
**Target**: Skill scripts for performance profiling
**Critical**: Bundle/memory/Core Web Vitals specialist
**Impact**: MEDIUM - Specialized domain expert

### Phase 2: Skill Definitions (2 files)

#### 2.1 `/Users/arlenagreer/.claude/skills/frontend-qc/SKILL.md`
**Current**: `allowed-tools: mcp__chrome-devtools__*, Skill(report-bug), Skill(email), Read, Write, Task`
**Target**: `allowed-tools: Skill(chrome-devtools), Skill(report-bug), Skill(email), Read, Write, Task`
**Critical**: Primary frontend QA skill
**Impact**: HIGH - Direct user-facing skill

#### 2.2 `/Users/arlenagreer/.claude/skills/frontend-qc/references/devtools-commands.md`
**Current**: 20+ MCP command examples:
```markdown
- `mcp__chrome-devtools__take_snapshot()`
- `mcp__chrome-devtools__click({ uid: "123" })`
- `mcp__chrome-devtools__fill({ uid: "456", value: "text" })`
```
**Target**: Equivalent Skill script invocations with Ruby examples
**Critical**: Reference documentation
**Impact**: MEDIUM - Documentation/examples

### Phase 3: Framework Documentation (4 files)

#### 3.1 `/Users/arlenagreer/.claude/MCP.md`
**Current**: Playwright and Chrome DevTools sections describe MCP server integration
**Target**: Update to describe Docker Skills architecture with REST API
**Critical**: Core framework documentation
**Impact**: MEDIUM - Documentation accuracy

#### 3.2 `/Users/arlenagreer/.claude/ORCHESTRATOR.md`
**Current**: Routing logic references MCP tool selection
**Target**: Update routing to Skill-based selection
**Critical**: Intelligent routing system
**Impact**: MEDIUM - Tool selection logic

#### 3.3 `/Users/arlenagreer/.claude/FLAGS.md`
**Current**: `--play` / `--playwright` flags reference MCP servers
**Target**: Update to reference Skills
**Critical**: Flag documentation
**Impact**: LOW - Documentation clarity

#### 3.4 `/Users/arlenagreer/.claude/.mcp.json`
**Current**: May contain MCP server configurations
**Target**: Remove or update Playwright/Chrome DevTools MCP references
**Critical**: MCP configuration file
**Impact**: LOW - Configuration cleanup

### Phase 4: Additional Files (TBD during implementation)
Files discovered during grep/search that may contain references requiring updates.

---

## Syntax Conversion Guide

### Tool Reference Updates

**Agent `allowed-tools` Declarations**:
```yaml
# BEFORE:
allowed-tools: mcp__chrome-devtools__*

# AFTER:
allowed-tools: Skill(chrome-devtools)

# BEFORE:
allowed-tools: mcp__playwright__*

# AFTER:
allowed-tools: Skill(playwright-browser)
```

### Command Invocation Updates

#### Navigation Commands

**MCP Syntax**:
```javascript
mcp__chrome-devtools__navigate_page({
  url: "http://localhost:3000",
  type: "url"
})
```

**Skill Syntax**:
```bash
Skill(chrome-devtools): navigate.rb "http://localhost:3000"
```

#### Screenshot Commands

**MCP Syntax**:
```javascript
mcp__chrome-devtools__take_screenshot({
  filePath: "/tmp/screenshot.png",
  fullPage: true
})
```

**Skill Syntax**:
```bash
Skill(chrome-devtools): screenshot.rb "/tmp/screenshot.png"
```

#### JavaScript Evaluation

**MCP Syntax**:
```javascript
mcp__chrome-devtools__evaluate_script({
  function: "() => document.title"
})
```

**Skill Syntax**:
```bash
Skill(chrome-devtools): evaluate.rb "document.title"
```

#### Interaction Commands

**Click - MCP Syntax**:
```javascript
mcp__chrome-devtools__click({ uid: "element-123" })
```

**Click - Skill Syntax**:
```bash
Skill(chrome-devtools): click.rb "element-123"
```

**Fill - MCP Syntax**:
```javascript
mcp__chrome-devtools__fill({
  uid: "input-456",
  value: "test@example.com"
})
```

**Fill - Skill Syntax**:
```bash
Skill(chrome-devtools): fill.rb "input-456" "test@example.com"
```

#### Snapshot Commands

**MCP Syntax**:
```javascript
mcp__chrome-devtools__take_snapshot({ verbose: false })
```

**Skill Syntax**:
```bash
Skill(chrome-devtools): snapshot.rb
```

#### Network Commands

**MCP Syntax**:
```javascript
mcp__chrome-devtools__list_network_requests({
  resourceTypes: ["xhr", "fetch"]
})
```

**Skill Syntax**:
```bash
Skill(chrome-devtools): network.rb "list" "xhr,fetch"
```

#### Wait Commands

**MCP Syntax**:
```javascript
mcp__chrome-devtools__wait_for({
  text: "Login successful",
  timeout: 5000
})
```

**Skill Syntax**:
```bash
Skill(chrome-devtools): wait.rb "Login successful" "5000"
```

### Ruby Script API Reference

**Available Scripts** (in `~/.claude/skills/chrome-devtools/scripts/`):
- `navigate.rb [url]` - Navigate to URL
- `screenshot.rb [filepath]` - Capture screenshot
- `evaluate.rb [expression]` - Evaluate JavaScript
- `click.rb [uid]` - Click element
- `fill.rb [uid] [value]` - Fill form field
- `wait.rb [text] [timeout_ms]` - Wait for text/element
- `snapshot.rb` - Take page snapshot
- `content.rb` - Get page content
- `title.rb` - Get page title
- `close.rb` - Close browser session

**Script Usage Pattern**:
```bash
# General pattern:
Skill(chrome-devtools): [script_name].rb [arg1] [arg2] ...

# Examples:
Skill(chrome-devtools): navigate.rb "https://example.com"
Skill(chrome-devtools): screenshot.rb "/tmp/test.png"
Skill(chrome-devtools): evaluate.rb "document.querySelector('h1').textContent"
```

---

## Implementation Phases

### Phase 1: Agent Definitions (High Priority)
**Goal**: Update core agents to use Skills syntax
**Duration**: 1-2 hours
**Risk**: HIGH - These are primary automation agents

**Tasks**:
1. Update `frontend-qc-agent.md` allowed-tools
2. Update `frontend-debug-agent.md` allowed-tools
3. Update all 4 debug specialist agents:
   - `network-specialist.md`
   - `state-specialist.md`
   - `ui-specialist.md`
   - `performance-specialist.md`
4. Convert all MCP command examples to Skill script invocations
5. Test each agent individually

**Validation**:
```bash
# Test QA agent:
Task(frontend-qc-agent) "Test login form at localhost:3000"

# Test debug agent:
Task(frontend-debug-agent) "Investigate API failure on /api/users"

# Test specialists individually (via debug agent coordination)
```

### Phase 2: Skill Definitions (Medium Priority)
**Goal**: Update skill documentation and references
**Duration**: 1 hour
**Risk**: MEDIUM - Direct user-facing skills

**Tasks**:
1. Update `frontend-qc/SKILL.md` allowed-tools
2. Convert all examples in `frontend-qc/references/devtools-commands.md`
3. Add new Skill script usage examples
4. Update documentation with REST API architecture notes

**Validation**:
```bash
# Test frontend-qc skill directly:
Skill(frontend-qc) "Test dashboard accessibility"

# Verify documentation examples work:
# (manually test each command from devtools-commands.md)
```

### Phase 3: Framework Documentation (Low Priority)
**Goal**: Update framework docs for accuracy
**Duration**: 30 minutes
**Risk**: LOW - Documentation only

**Tasks**:
1. Update `MCP.md` Playwright/Chrome DevTools sections
2. Update `ORCHESTRATOR.md` routing logic
3. Update `FLAGS.md` descriptions
4. Review/clean ``.mcp.json`

**Validation**:
```bash
# Verify documentation accuracy:
grep -r "mcp__chrome-devtools" ~/.claude/
grep -r "mcp__playwright" ~/.claude/
# Should only return historical/archived references
```

### Phase 4: Comprehensive Search & Cleanup
**Goal**: Find and fix any remaining references
**Duration**: 1 hour
**Risk**: LOW - Catch-all phase

**Tasks**:
1. Search entire codebase for MCP tool references
2. Update any missed files
3. Archive old MCP documentation
4. Create migration completion checklist

**Validation**:
```bash
# Comprehensive search:
cd ~/.claude
grep -r "mcp__chrome-devtools__" --include="*.md" .
grep -r "mcp__playwright__" --include="*.md" .
# Should return ZERO results (or only archived/historical docs)
```

---

## Testing Procedures

### Pre-Migration Validation
```bash
# Verify Docker containers are running:
docker ps | grep -E "(playwright|chrome-devtools)"

# Expected output:
# chrome-devtools-api       Up (healthy)
# chrome-devtools-browser   Up (healthy)
# playwright-server         Up (healthy)

# Test Skills work:
cd ~/.claude/skills/chrome-devtools/scripts
ruby navigate.rb "https://example.com"
# Expected: {"success": true, "url": "https://example.com/", "status": 200}

cd ~/.claude/skills/playwright-browser/scripts
ruby navigate.rb "https://example.com"
# Expected: {"success": true, "url": "https://example.com/", "status": 200}
```

### Phase 1 Testing (After Agent Updates)

**Test 1: Frontend QA Agent**
```bash
# Invoke agent with test task:
Task(frontend-qc-agent) "Test login form at http://localhost:3000/login"

# Expected behavior:
# 1. Agent loads with Skill(chrome-devtools) in allowed-tools
# 2. Agent can invoke: Skill(chrome-devtools): navigate.rb "..."
# 3. Agent completes QA tasks successfully
# 4. Agent creates bug report if issues found

# Validation:
# - No errors about "mcp__chrome-devtools__ not found"
# - Skill invocations execute successfully
# - Agent workflow completes end-to-end
```

**Test 2: Frontend Debug Agent**
```bash
# Invoke debug orchestrator:
Task(frontend-debug-agent) "Debug 404 errors on /api/users endpoint"

# Expected behavior:
# 1. Debug agent analyzes issue
# 2. Spawns network-specialist (network debugging)
# 3. Specialist uses Skill(chrome-devtools) successfully
# 4. Returns root cause analysis

# Validation:
# - Specialist agents load correctly
# - No MCP tool errors
# - Debug workflow completes
```

**Test 3: Individual Specialists**
```bash
# Test each specialist via debug agent:

# Network specialist:
Task(frontend-debug-agent) "Check API response headers for CORS issues"

# State specialist:
Task(frontend-debug-agent) "Investigate Redux state mutation in user profile"

# UI specialist:
Task(frontend-debug-agent) "Find why button appears off-screen on mobile"

# Performance specialist:
Task(frontend-debug-agent) "Analyze bundle size and Core Web Vitals"

# Validation for each:
# - Specialist activates correctly
# - Skill(chrome-devtools) invocations work
# - Specialist completes analysis
```

### Phase 2 Testing (After Skill Updates)

**Test 4: Frontend QC Skill Direct Invocation**
```bash
# Invoke skill directly (not via agent):
Skill(frontend-qc) "Test dashboard component accessibility and responsiveness"

# Expected behavior:
# 1. Skill loads with updated allowed-tools
# 2. Skill invokes Skill(chrome-devtools) sub-operations
# 3. QA workflow completes
# 4. Report generated with findings

# Validation:
# - No MCP tool errors
# - Skill-to-Skill invocation works
# - Complete QA report delivered
```

**Test 5: Documentation Examples**
```bash
# Test each example from devtools-commands.md:

# Navigation example:
Skill(chrome-devtools): navigate.rb "http://localhost:3000"

# Screenshot example:
Skill(chrome-devtools): screenshot.rb "/tmp/test-screenshot.png"

# Evaluate example:
Skill(chrome-devtools): evaluate.rb "document.title"

# Click example:
Skill(chrome-devtools): click.rb "button-login"

# Validation:
# - Each example executes successfully
# - Results match expected behavior
# - No syntax errors
```

### Phase 3 Testing (After Framework Doc Updates)

**Test 6: Documentation Accuracy**
```bash
# Read updated docs and verify:

# MCP.md accuracy:
cat ~/.claude/MCP.md | grep -A 20 "Playwright Integration"
# Should describe Docker Skills, not MCP servers

# ORCHESTRATOR.md routing:
cat ~/.claude/ORCHESTRATOR.md | grep -A 10 "frontend_qc"
# Should reference Skill(chrome-devtools), not MCP

# FLAGS.md descriptions:
cat ~/.claude/FLAGS.md | grep -A 5 "playwright"
# Should describe Skill activation, not MCP

# Validation:
# - No MCP server references in current architecture sections
# - Skills architecture accurately described
# - Examples use correct Skill syntax
```

### Phase 4 Testing (Comprehensive Validation)

**Test 7: Full Integration Test**
```bash
# End-to-end workflow test:

# 1. Invoke QA agent with multi-component test:
Task(frontend-qc-agent) "Parallel test: login form, dashboard, user profile pages"

# 2. Invoke debug agent with complex issue:
Task(frontend-debug-agent) "Debug intermittent auth failures and state desync"

# 3. Direct skill invocation:
Skill(frontend-qc) "Complete accessibility audit of checkout flow"

# 4. Verify parallel operations work:
# (QA agent should spawn multiple sub-agents in parallel)

# Validation:
# - All workflows complete successfully
# - Parallel operations function correctly
# - No MCP tool errors anywhere
# - Performance equivalent or better than old MCP approach
```

**Test 8: Negative Testing (Error Handling)**
```bash
# Test error scenarios:

# 1. Invalid URL:
Skill(chrome-devtools): navigate.rb "not-a-valid-url"
# Expected: Graceful error message, not MCP tool error

# 2. Missing element:
Skill(chrome-devtools): click.rb "nonexistent-element-uid"
# Expected: Timeout error, not MCP invocation error

# 3. Docker container down:
docker stop chrome-devtools-api
Skill(chrome-devtools): navigate.rb "https://example.com"
# Expected: Connection error, clear error message

# Restart container:
docker start chrome-devtools-api
```

### Rollback Testing

**Test 9: Rollback Procedure Validation**
```bash
# Test rollback capability:

# 1. Create backup before migration
# 2. Perform Phase 1 migration
# 3. Execute rollback procedure
# 4. Verify old MCP syntax restored
# 5. Re-run migration

# Validation:
# - Rollback completes successfully
# - System returns to pre-migration state
# - Re-migration works after rollback
```

---

## Validation Checklist

### Pre-Migration Checklist
- [ ] Docker containers running and healthy (playwright-server, chrome-devtools-api, chrome-devtools-browser)
- [ ] Skills tested and working (navigate.rb, screenshot.rb, evaluate.rb)
- [ ] Backup created of all files to be modified
- [ ] Git commit created as restore point
- [ ] Test environment prepared (localhost:3000 or test application running)

### Phase 1 Validation (Agents)
- [ ] `frontend-qc-agent.md` updated and tested
- [ ] `frontend-debug-agent.md` updated and tested
- [ ] `network-specialist.md` updated and tested
- [ ] `state-specialist.md` updated and tested
- [ ] `ui-specialist.md` updated and tested
- [ ] `performance-specialist.md` updated and tested
- [ ] All agent tool references use `Skill(chrome-devtools)` syntax
- [ ] All MCP command invocations converted to Skill scripts
- [ ] Agent workflows complete end-to-end successfully
- [ ] Parallel agent spawning works correctly

### Phase 2 Validation (Skills)
- [ ] `frontend-qc/SKILL.md` updated and tested
- [ ] `frontend-qc/references/devtools-commands.md` examples updated
- [ ] All 20+ command examples converted to Skill syntax
- [ ] Documentation examples tested and working
- [ ] Direct skill invocation works
- [ ] Skill-to-Skill invocations function correctly

### Phase 3 Validation (Framework Docs)
- [ ] `MCP.md` updated with Docker Skills architecture
- [ ] `ORCHESTRATOR.md` routing logic updated
- [ ] `FLAGS.md` descriptions updated
- [ ] `.mcp.json` cleaned/updated
- [ ] No misleading MCP server references remain
- [ ] Architecture diagrams reflect current Docker Skills setup

### Phase 4 Validation (Comprehensive)
- [ ] Comprehensive grep search shows no remaining MCP references
- [ ] All integration tests passing
- [ ] Negative testing completed
- [ ] Performance equivalent or better than MCP approach
- [ ] Error handling graceful and clear
- [ ] Documentation accurate and complete

### Post-Migration Checklist
- [ ] All 17+ files updated successfully
- [ ] All tests passing
- [ ] Zero MCP tool syntax errors
- [ ] Agents and skills fully functional
- [ ] Documentation accurate
- [ ] Migration completion document created
- [ ] User acceptance testing completed

---

## Rollback Procedures

### Pre-Migration Backup
```bash
# Create timestamped backup directory:
cd ~/.claude
mkdir -p backups/pre-skills-migration-$(date +%Y%m%d)

# Backup all files to be modified:
cp agents/frontend-qc-agent.md backups/pre-skills-migration-$(date +%Y%m%d)/
cp agents/frontend-debug-agent.md backups/pre-skills-migration-$(date +%Y%m%d)/
cp -r agents/debug-specialists/ backups/pre-skills-migration-$(date +%Y%m%d)/
cp skills/frontend-qc/SKILL.md backups/pre-skills-migration-$(date +%Y%m%d)/
cp skills/frontend-qc/references/devtools-commands.md backups/pre-skills-migration-$(date +%Y%m%d)/
cp MCP.md backups/pre-skills-migration-$(date +%Y%m%d)/
cp ORCHESTRATOR.md backups/pre-skills-migration-$(date +%Y%m%d)/
cp FLAGS.md backups/pre-skills-migration-$(date +%Y%m%d)/
cp .mcp.json backups/pre-skills-migration-$(date +%Y%m%d)/

# Create git restore point:
cd ~/.claude
git add -A
git commit -m "Pre-migration backup: SuperClaude Skills migration $(date +%Y%m%d)"
```

### Rollback Procedure (if migration fails)
```bash
# Option 1: Restore from backup directory
cd ~/.claude
cp backups/pre-skills-migration-YYYYMMDD/* [destination]

# Option 2: Git revert
cd ~/.claude
git log --oneline | head -5  # Find pre-migration commit
git revert <commit-hash>

# Option 3: Manual file restoration
# Restore each file individually from backup
```

### Rollback Validation
```bash
# After rollback:
# 1. Verify old MCP syntax restored:
grep "mcp__chrome-devtools__" ~/.claude/agents/frontend-qc-agent.md
# Should return MCP syntax (proving rollback successful)

# 2. Test agents still work (will fail if MCP servers gone):
# This validates the need for migration

# 3. Verify backup integrity:
diff backups/pre-skills-migration-YYYYMMDD/frontend-qc-agent.md \
     agents/frontend-qc-agent.md
# Should show zero differences
```

---

## Risk Assessment & Mitigation

### High Risk Areas

**Risk 1: Agent Tool Invocation Failures**
- **Probability**: HIGH (if syntax incorrect)
- **Impact**: HIGH (agents non-functional)
- **Mitigation**:
  - Test each agent individually after update
  - Use exact Skill syntax from working examples
  - Validate with simple test cases before complex workflows
  - Maintain backup for immediate rollback

**Risk 2: Specialist Agent Coordination Breaking**
- **Probability**: MEDIUM (multi-agent orchestration)
- **Impact**: HIGH (debug workflows broken)
- **Mitigation**:
  - Test frontend-debug-agent orchestration thoroughly
  - Verify specialist spawning works
  - Test each specialist domain individually
  - Validate parallel execution capability

**Risk 3: Documentation Drift**
- **Probability**: MEDIUM (docs get out of sync)
- **Impact**: MEDIUM (confusion, incorrect usage)
- **Mitigation**:
  - Update all docs in single phase
  - Cross-reference all documentation
  - Test all documented examples
  - Add "Last Updated" timestamps

### Medium Risk Areas

**Risk 4: Performance Regression**
- **Probability**: LOW (Skills proven faster)
- **Impact**: MEDIUM (user experience)
- **Mitigation**:
  - Benchmark before/after migration
  - Monitor agent execution times
  - Compare Docker Skills vs theoretical MCP performance
  - Optimize if regressions detected

**Risk 5: Missing Edge Cases**
- **Probability**: MEDIUM (17+ files, many examples)
- **Impact**: MEDIUM (partial functionality)
- **Mitigation**:
  - Comprehensive grep search in Phase 4
  - Test all documented commands
  - Review commit diffs for completeness
  - User acceptance testing

### Low Risk Areas

**Risk 6: Framework Documentation Inaccuracy**
- **Probability**: LOW (Phase 3 is docs only)
- **Impact**: LOW (documentation only)
- **Mitigation**:
  - Peer review documentation
  - Validate examples work
  - Keep old docs archived for reference

---

## Performance Expectations

### Expected Improvements
- **Latency**: 70-90% reduction (local Docker vs remote MCP)
- **Reliability**: 99.9% uptime (local containers with auto-restart)
- **Startup Time**: Instant (containers pre-warmed)
- **Throughput**: Higher (no network round-trips)

### Benchmark Targets
```bash
# Navigation operation:
# OLD (MCP): ~500-1000ms network latency + execution
# NEW (Skills): ~50-100ms localhost HTTP + execution
# Expected: 80%+ improvement

# Screenshot operation:
# OLD (MCP): Large binary transfer over network
# NEW (Skills): Local file system write
# Expected: 90%+ improvement

# Complex workflows (multi-operation):
# OLD (MCP): Multiple network round-trips
# NEW (Skills): Pipelined local operations
# Expected: 70%+ improvement
```

### Monitoring Plan
```bash
# Track agent execution times:
# 1. Before migration: Note typical QA agent execution time
# 2. After migration: Compare execution time
# 3. Goal: Equal or better performance

# Track Docker resource usage:
docker stats playwright-server chrome-devtools-api chrome-devtools-browser
# Goal: <500MB memory per container, <30% CPU average
```

---

## Success Criteria

### Technical Success Criteria
1. ✅ All 17+ files updated with correct Skill syntax
2. ✅ Zero MCP tool invocation errors
3. ✅ All agents functional (QA, Debug, Specialists)
4. ✅ All skills functional (frontend-qc, chrome-devtools, playwright-browser)
5. ✅ Parallel agent spawning works correctly
6. ✅ Performance equal or better than theoretical MCP baseline
7. ✅ Documentation accurate and complete
8. ✅ All tests passing
9. ✅ Docker containers healthy and auto-restarting
10. ✅ Comprehensive grep search shows zero MCP references (except archives)

### User Acceptance Criteria
1. ✅ Can invoke `Task(frontend-qc-agent)` successfully
2. ✅ Can invoke `Task(frontend-debug-agent)` successfully
3. ✅ Can invoke `Skill(frontend-qc)` directly
4. ✅ QA workflows complete end-to-end
5. ✅ Debug workflows identify root causes
6. ✅ Error messages are clear and actionable
7. ✅ Performance is acceptable (no noticeable regression)
8. ✅ No confusing MCP error messages

### Business Success Criteria
1. ✅ Zero downtime during migration (parallel chat session)
2. ✅ Immediate rollback capability maintained
3. ✅ Local-first architecture achieved (no remote dependencies)
4. ✅ Foundation ready for Tier 2 migrations
5. ✅ Documentation enables future skill development

---

## Post-Migration Actions

### Immediate (Day 1)
- [ ] Complete all validation tests
- [ ] Create migration completion document
- [ ] Archive old MCP documentation
- [ ] Update README with new Skills architecture
- [ ] User acceptance testing

### Short-term (Week 1)
- [ ] Monitor agent performance and stability
- [ ] Collect user feedback on new syntax
- [ ] Fix any edge cases discovered
- [ ] Create troubleshooting guide
- [ ] Update SuperClaude framework examples

### Long-term (Month 1)
- [ ] Evaluate migration for Tier 2 candidates (Google APIs)
- [ ] Consider additional Skills conversions
- [ ] Document lessons learned
- [ ] Optimize Docker resource usage if needed
- [ ] Create advanced usage examples

---

## Reference Links

### Docker Skills Architecture
- Playwright Skill: `~/.claude/skills/playwright-browser/SKILL.md`
- Chrome DevTools Skill: `~/.claude/skills/chrome-devtools/SKILL.md`
- Playwright Scripts: `~/.claude/skills/playwright-browser/scripts/`
- Chrome DevTools Scripts: `~/.claude/skills/chrome-devtools/scripts/`

### Implementation Documentation
- Tier 1 Implementation Complete: `~/.claude/claudedocs/tier1_implementation_complete_20251116.md`
- Docker Auto-Start Verification: `~/.claude/claudedocs/tier1_docker_autostart_verification_20251116.md`

### SuperClaude Framework
- Agent Definitions: `~/.claude/agents/`
- Skills Definitions: `~/.claude/skills/`
- Framework Docs: `~/.claude/MCP.md`, `~/.claude/ORCHESTRATOR.md`, `~/.claude/FLAGS.md`

### Backup Location
- Pre-Migration Backup: `~/.claude/backups/pre-skills-migration-YYYYMMDD/`

---

## Migration Timeline

**Estimated Total Time**: 4-5 hours

| Phase | Duration | Risk | Priority |
|-------|----------|------|----------|
| Phase 1: Agents | 1-2 hours | HIGH | CRITICAL |
| Phase 2: Skills | 1 hour | MEDIUM | HIGH |
| Phase 3: Framework Docs | 30 minutes | LOW | MEDIUM |
| Phase 4: Comprehensive Search | 1 hour | LOW | MEDIUM |
| Testing & Validation | 1 hour | - | CRITICAL |

**Recommended Approach**: Execute phases sequentially with validation between each phase. Do NOT proceed to next phase if current phase tests fail.

---

## Notes for Implementation Chat

**Critical Reminders**:
1. **Create backup before ANY changes**: `git commit -m "Pre-migration backup"`
2. **Test each file after update**: Don't batch-update without validation
3. **Use exact Skill syntax**: Syntax errors will break agent invocation
4. **Verify Docker containers running**: Skills won't work if containers down
5. **Phase-by-phase approach**: Don't skip validation steps
6. **Rollback ready**: Keep backup commands handy
7. **Performance monitoring**: Track execution times before/after

**User Commitment Confirmed**:
- ✅ Actively uses SuperClaude agents
- ✅ No MCP fallback needed
- ✅ Full commitment to Docker Skills approach
- ✅ Immediate timeline
- ✅ Separate implementation chat (this is planning only)

**Next Step**: Implementation chat executes this plan phase-by-phase with validation gates between each phase.

---

**Migration Plan Status**: ✅ COMPLETE - Ready for Implementation
**Created**: November 16, 2025
**Implementation**: Separate chat session per user request
