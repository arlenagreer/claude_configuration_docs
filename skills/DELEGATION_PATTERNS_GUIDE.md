# Skill→Agent Delegation Patterns Guide

**Purpose**: Unified documentation for skill→agent hybrid architecture patterns, complexity detection, and delegation mechanisms.

**Created**: 2025-10-23
**Based On**: Phase 3 testing results (frontend-qc and frontend-debug validation)

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Delegation Decision Frameworks](#delegation-decision-frameworks)
3. [Configuration Requirements](#configuration-requirements)
4. [Complexity Detection Patterns](#complexity-detection-patterns)
5. [Agent Orchestration](#agent-orchestration)
6. [Troubleshooting Guide](#troubleshooting-guide)
7. [Design Checklist](#design-checklist)

---

## Architecture Overview

### Skill→Agent Hybrid Model

**Progressive Enhancement Pattern**: Skills detect complexity and delegate to agents when appropriate.

```
User Request
    ↓
Skill Execution (Complexity Detection)
    ↓
┌───────────────────────────────┐
│ Complexity Below Threshold?   │
├───────────────────────────────┤
│ YES → Execute in skill mode   │
│  NO → Delegate to agent       │
└───────────────────────────────┘
    ↓
Agent Orchestration (if delegated)
    ↓
Specialist Sub-Agents (parallel/sequential)
    ↓
Results Aggregation
    ↓
Unified Report to User
```

### Key Benefits

1. **Efficiency**: Simple tasks execute quickly in skill mode
2. **Scalability**: Complex tasks leverage agent parallelization
3. **Specialization**: Agents spawn domain-specific specialists
4. **Token Optimization**: Isolated agent contexts prevent context pollution
5. **Quality**: Specialist knowledge applied to complex scenarios

---

## Delegation Decision Frameworks

### Framework 1: Quantity-Based Threshold (frontend-qc)

**Use Case**: Parallel testing of multiple similar components

**Threshold**: Component count **>3**

**Decision Logic**:
```yaml
if (component_count > 3):
  delegate_to: frontend-qc-agent
  strategy: spawn_subagent_per_component
  max_concurrent: 5
else:
  execute_in_skill_mode: coordinated_sequential_testing
```

**Rationale**:
- 1-3 components: Skill handles efficiently with coordinated MCP calls
- 4+ components: Agent parallelization provides significant speedup (3-6x)
- Token efficiency: ~79% reduction through isolated agent contexts

**Example**:
```
User: "Test the Login, Registration, Checkout, and Profile pages"
→ 4 components detected
→ Exceeds threshold (>3)
→ Delegates to frontend-qc-agent
→ Spawns 4 sub-agents (1 per component)
→ Parallel execution with aggregated results
```

### Framework 2: Multi-Factor Indicators (frontend-debug)

**Use Case**: Complex debugging requiring specialized domain knowledge

**Threshold**: **ANY** of 6 escalation indicators met

**Escalation Indicators**:
1. **Low Confidence**: Root cause confidence score **<60%**
2. **Multi-Domain Issue**: Multiple interacting systems involved
3. **Systemic Problem**: Issue affects multiple components or features
4. **Deep Investigation**: Requires analysis across **>5 files**
5. **Specialized Analysis**: User explicitly requests domain-specific investigation
6. **Multiple Issues**: User reports **2+ unrelated problems** to debug

**Decision Logic**:
```yaml
confidence_score = calculate_confidence(evidence)
domains = detect_domains(issue_description)
affected_components = count_affected_components()
files_to_analyze = estimate_file_count()

indicators_met = 0
if confidence_score < 0.6: indicators_met += 1
if len(domains) > 1: indicators_met += 1
if affected_components > 3: indicators_met += 1
if files_to_analyze > 5: indicators_met += 1
if "network analysis" in request or "state debugging" in request: indicators_met += 1
if multiple_unrelated_issues(): indicators_met += 1

if indicators_met > 0:
  delegate_to: frontend-debug-agent
  spawn_specialists: based_on_domain_relevance_scoring
else:
  execute_in_skill_mode: standard_6_phase_workflow
```

**Rationale**:
- ANY indicator = potential complexity requiring specialist knowledge
- Multi-domain issues need coordinated specialist investigation
- Low confidence suggests need for systematic analysis
- Prevents single-skill limitations on complex problems

**Example**:
```
User: "Checkout flow has multiple issues: cart appears empty, payment fails with API errors, form doesn't fit on mobile"
→ Multi-domain detected: state, network, UI
→ Systemic problem: affects entire checkout flow
→ Multiple issues: 3 distinct problems
→ 3 indicators met (ANY threshold)
→ Delegates to frontend-debug-agent
→ Spawns network-specialist, state-specialist, ui-specialist
→ Parallel domain-specific investigation
→ Aggregated findings with cross-domain insights
```

### Framework Comparison

| Aspect | Quantity-Based (frontend-qc) | Multi-Factor (frontend-debug) |
|--------|------------------------------|-------------------------------|
| **Threshold** | Component count >3 | ANY of 6 indicators |
| **Complexity Type** | Scalability | Domain expertise |
| **Agent Strategy** | 1 sub-agent per component | Specialists per domain |
| **Execution Mode** | Parallel | Parallel or sequential |
| **Primary Benefit** | Speed (3-6x) | Specialized knowledge |
| **Token Efficiency** | ~79% reduction | Isolated specialist contexts |
| **Use Case** | QA campaigns | Complex multi-domain debugging |

---

## Configuration Requirements

### Critical: Task Tool Access

**Requirement**: Skills that delegate to agents **MUST** have `Task` tool access.

**Implementation**:

#### Option 1: Explicit allowed-tools (Recommended)
```yaml
---
name: my-skill
description: "Skill that delegates to agents"
allowed-tools: Task, Read, Write, Skill(other-skill), mcp__domain__*
---
```

#### Option 2: No allowed-tools (All Tools)
```yaml
---
name: my-skill
description: "Skill that delegates to agents"
# No allowed-tools line = access to ALL tools including Task
---
```

### Tool Access Patterns

**frontend-qc** (Explicit):
```yaml
allowed-tools: Skill(chrome-devtools), Skill(report-bug), Skill(email), Read, Write, Task
```
- Explicitly lists required tools
- Clear dependencies
- Easier to audit
- **Fixed in Phase 3.1**: Added `, Task` to enable delegation

**frontend-debug** (Permissive):
```yaml
# No allowed-tools line in frontmatter
```
- Access to ALL tools by default
- More flexible
- Already includes Task
- Worked correctly in Phase 3.2 testing

### Recommendation

**For New Skills**:
- Use explicit `allowed-tools` for clarity and security
- Always include `Task` if skill may delegate
- Document why each tool is needed

**Template**:
```yaml
---
name: my-delegating-skill
description: "Skill description"
allowed-tools: Task, Read, Write, Skill(helper-skill), mcp__required_server__*
# Task: Required for agent delegation
# Read/Write: File operations
# Skill(helper-skill): Sub-skill invocation
# mcp__required_server__*: Domain-specific MCP server access
---
```

---

## Complexity Detection Patterns

### Pattern 1: Component Counting

**Used By**: frontend-qc

**Implementation**:
```javascript
function detectComplexity(userRequest) {
  const components = extractComponents(userRequest);
  const componentCount = components.length;

  return {
    shouldDelegate: componentCount > 3,
    strategy: componentCount > 3 ? 'parallel' : 'sequential',
    componentCount: componentCount,
    components: components
  };
}
```

**Extraction Methods**:
- URL pattern matching (`/login.html`, `/dashboard.html`)
- Explicit component names ("Login page", "Registration form")
- File path patterns (`components/login.tsx`)
- User enumeration ("Test A, B, C, and D")

### Pattern 2: Domain Detection

**Used By**: frontend-debug

**Implementation**:
```javascript
function detectDomains(issueDescription) {
  const domains = new Set();

  // Network indicators
  if (/API|404|CORS|timeout|endpoint|fetch/.test(issueDescription)) {
    domains.add('network');
  }

  // State indicators
  if (/state|redux|context|undefined|null|persistence/.test(issueDescription)) {
    domains.add('state');
  }

  // UI indicators
  if (/display|render|CSS|responsive|mobile|layout/.test(issueDescription)) {
    domains.add('ui');
  }

  // Performance indicators
  if (/slow|performance|memory|bundle|loading/.test(issueDescription)) {
    domains.add('performance');
  }

  return Array.from(domains);
}
```

**Domain Keywords**:

| Domain | Keywords |
|--------|----------|
| **Network** | API, 404, 500, CORS, timeout, endpoint, fetch, request, response, auth |
| **State** | state, redux, context, undefined, null, persistence, localStorage, data flow |
| **UI** | display, render, CSS, responsive, mobile, layout, z-index, overflow, flex |
| **Performance** | slow, memory, bundle, loading, Core Web Vitals, FPS, lag, optimization |

### Pattern 3: Escalation Scoring

**Used By**: frontend-debug

**Implementation**:
```javascript
function calculateEscalationScore(context) {
  let score = 0;
  const indicators = [];

  // Indicator 1: Low Confidence
  const confidence = estimateConfidence(context.evidence);
  if (confidence < 0.6) {
    score += 1;
    indicators.push('low_confidence');
  }

  // Indicator 2: Multi-Domain
  const domains = detectDomains(context.description);
  if (domains.length > 1) {
    score += 1;
    indicators.push('multi_domain');
  }

  // Indicator 3: Systemic Problem
  const affectedComponents = analyzeScope(context);
  if (affectedComponents > 3) {
    score += 1;
    indicators.push('systemic');
  }

  // Indicator 4: Deep Investigation
  const estimatedFileCount = estimateFilesToAnalyze(context);
  if (estimatedFileCount > 5) {
    score += 1;
    indicators.push('deep_investigation');
  }

  // Indicator 5: Specialized Analysis Requested
  if (/network analysis|state debugging|performance profiling/.test(context.request)) {
    score += 1;
    indicators.push('specialized_request');
  }

  // Indicator 6: Multiple Unrelated Issues
  const issues = extractIssues(context.description);
  if (issues.length >= 2 && !issuesAreRelated(issues)) {
    score += 1;
    indicators.push('multiple_issues');
  }

  return {
    score: score,
    indicators: indicators,
    shouldDelegate: score > 0, // ANY indicator
    confidence: confidence,
    domains: domains
  };
}
```

---

## Agent Orchestration

### Sub-Agent Spawning Strategies

#### Strategy 1: One Sub-Agent Per Component (frontend-qc)

**Pattern**:
```yaml
agent: frontend-qc-agent
sub_agents:
  - type: frontend-qc-subagent
    component: Login
    url: /components/login.html

  - type: frontend-qc-subagent
    component: Registration
    url: /components/registration.html

  - type: frontend-qc-subagent
    component: Checkout
    url: /components/checkout.html

  - type: frontend-qc-subagent
    component: Profile
    url: /components/profile.html

execution: parallel
max_concurrent: 5
```

**Benefits**:
- True parallelization (4 components tested simultaneously)
- Isolated browser sessions per component
- Independent bug discovery
- Linear time scaling (not multiplicative)

**Time Savings**:
```
Sequential: 4 components × 15 min = 60 min
Parallel: max(15 min) = 15-20 min
Speedup: 3-4x
```

#### Strategy 2: Domain-Specific Specialists (frontend-debug)

**Pattern**:
```yaml
agent: frontend-debug-agent

# Domain relevance scoring first
domain_scores:
  network: 0.7  # API failures, CORS, timeouts
  state: 0.8    # localStorage issues, undefined access
  ui: 0.9       # Responsive design, z-index
  performance: 0.6  # Bundle size, lazy-loading

# Spawn specialists where score >0.6
specialists:
  - type: network-specialist
    domain: network
    focus: [API_endpoints, CORS_errors, authentication, timeouts]

  - type: state-specialist
    domain: state
    focus: [localStorage, Redux, Context_API, data_flow]

  - type: ui-specialist
    domain: ui
    focus: [responsive_design, CSS_issues, accessibility, z-index]

  - type: performance-specialist
    domain: performance
    focus: [bundle_analysis, lazy_loading, Core_Web_Vitals]

execution: parallel
coordination: results_aggregation
```

**Domain Relevance Scoring**:
```javascript
function scoreDomainRelevance(domain, evidence) {
  let score = 0.0;

  const indicators = DOMAIN_INDICATORS[domain];

  for (const indicator of indicators) {
    if (evidenceContains(evidence, indicator.pattern)) {
      score += indicator.weight;
    }
  }

  return Math.min(score, 1.0); // Cap at 1.0
}

const DOMAIN_INDICATORS = {
  network: [
    { pattern: /404|500|API.*error/i, weight: 0.3 },
    { pattern: /CORS/i, weight: 0.2 },
    { pattern: /timeout|slow.*request/i, weight: 0.2 },
    { pattern: /auth.*fail/i, weight: 0.3 }
  ],
  state: [
    { pattern: /undefined|null.*error/i, weight: 0.4 },
    { pattern: /state.*not.*updat/i, weight: 0.3 },
    { pattern: /redux|context.*error/i, weight: 0.3 },
    { pattern: /persist|localStorage/i, weight: 0.3 }
  ],
  // ... other domains
};
```

**Threshold**: Spawn specialist if score **≥0.6**

### Results Aggregation

#### Deduplication Strategy
```javascript
function aggregateResults(specialistFindings) {
  const allBugs = [];
  const bugSignatures = new Set();

  for (const specialist of specialistFindings) {
    for (const bug of specialist.bugs) {
      const signature = generateBugSignature(bug);

      if (!bugSignatures.has(signature)) {
        bugSignatures.add(signature);
        allBugs.push({
          ...bug,
          discoveredBy: specialist.domain,
          severity: calculateSeverity(bug, allBugs)
        });
      }
    }
  }

  return {
    bugs: prioritizeBugs(allBugs),
    systemicIssues: identifySystemicPatterns(allBugs),
    crossDomainInsights: analyzeCrossDomainRelationships(allBugs)
  };
}
```

#### Systemic Issue Detection
```javascript
function identifySystemicPatterns(bugs) {
  const patterns = [];

  // Group bugs by affected files
  const fileGroups = groupBy(bugs, bug => bug.file);

  // Detect files with multiple unrelated bugs
  for (const [file, fileBugs] of Object.entries(fileGroups)) {
    if (fileBugs.length >= 2) {
      patterns.push({
        type: 'hotspot',
        file: file,
        bugCount: fileBugs.length,
        recommendation: 'Consider refactoring this file'
      });
    }
  }

  // Detect cross-cutting concerns
  const domainGroups = groupBy(bugs, bug => bug.domain);
  if (Object.keys(domainGroups).length >= 3) {
    patterns.push({
      type: 'cross_cutting',
      domains: Object.keys(domainGroups),
      recommendation: 'Multi-domain refactoring may be needed'
    });
  }

  return patterns;
}
```

---

## Troubleshooting Guide

### Issue 1: Skill Cannot Invoke Task Tool

**Symptoms**:
- Skill detects complexity correctly
- Delegation decision made
- Error: "Task tool not available in current context"
- Falls back to skill-only execution

**Root Cause**: Missing `Task` in skill's `allowed-tools` configuration

**Diagnosis**:
1. Read skill's SKILL.md frontmatter
2. Check `allowed-tools` line
3. Verify `Task` is included

**Fix**:
```yaml
# Before (BROKEN)
allowed-tools: Skill(chrome-devtools), Skill(report-bug), Read, Write

# After (FIXED)
allowed-tools: Skill(chrome-devtools), Skill(report-bug), Read, Write, Task
```

**Validation**:
- Re-invoke skill with complexity scenario
- Verify Task tool invocation succeeds
- Confirm agent spawns correctly

**Example** (from Phase 3.1):
- frontend-qc detected 4 components (>3 threshold)
- Attempted to delegate to frontend-qc-agent
- Failed: Task tool unavailable
- Fixed: Added `, Task` to allowed-tools line 4
- Result: Agent delegation now works

### Issue 2: Agent Not Spawning Despite Complexity

**Symptoms**:
- Complexity threshold exceeded
- No error messages
- Skill executes in single mode

**Possible Causes**:
1. **Task tool unavailable** (see Issue 1)
2. **Agent not registered** in Claude Code agent system
3. **Incorrect agent name** in Task tool invocation
4. **Agent file missing** or corrupted

**Diagnosis**:
```bash
# Check agent exists
ls -la ~/.claude/agents/frontend-*-agent.md

# Check agent is registered
grep "frontend-.*-agent" ~/.claude/agents/*.md

# Check skill invocation syntax
grep -A 5 "Task.*agent" ~/.claude/skills/*/SKILL.md
```

**Fix Options**:
- Verify agent file exists at correct path
- Check agent name matches exactly in Task invocation
- Ensure agent is properly documented
- Add Task to allowed-tools if missing

### Issue 3: Complexity Detection Not Triggering

**Symptoms**:
- Complex scenario provided
- Skill executes in simple mode
- No delegation attempted

**Diagnosis**:
1. **Check threshold logic**:
   ```javascript
   // Is threshold too high?
   if (componentCount > 10) // Should be >3 for frontend-qc
   ```

2. **Check detection patterns**:
   ```javascript
   // Are keywords missing?
   const components = request.match(/component|page|form/gi);
   ```

3. **Enable debug logging**:
   ```javascript
   console.log('Complexity detection:', {
     componentCount,
     threshold: 3,
     shouldDelegate: componentCount > 3
   });
   ```

**Fix**:
- Adjust threshold to appropriate level
- Expand keyword detection patterns
- Validate extraction logic with test cases

### Issue 4: Sub-Agents Not Spawning Specialists

**Symptoms**:
- Agent spawns successfully
- No domain-specific specialists created
- Generic debugging instead of specialized

**Diagnosis**:
1. **Check domain relevance scores**:
   ```javascript
   // Are scores below threshold?
   console.log('Domain scores:', {
     network: 0.4,  // Below 0.6 threshold - won't spawn
     state: 0.8,    // Above 0.6 - will spawn
   });
   ```

2. **Check domain detection**:
   ```javascript
   // Are domains being detected?
   const domains = detectDomains(issueDescription);
   console.log('Detected domains:', domains);
   ```

**Fix**:
- Lower domain relevance threshold (e.g., 0.5 instead of 0.6)
- Expand domain keyword patterns
- Validate domain detection with test cases
- Check specialist agent files exist

### Issue 5: Performance Not Meeting Expectations

**Symptoms**:
- Parallel execution not faster than sequential
- High token usage despite agent delegation
- Slow specialist spawning

**Diagnosis**:
1. **Check actual parallelization**:
   ```bash
   # Are specialists running sequentially?
   grep -i "waiting for" agent-debug.log
   ```

2. **Check token usage**:
   ```bash
   # Is context being duplicated?
   grep -c "context:" agent-*.log
   ```

3. **Check specialist coordination**:
   ```bash
   # Are specialists blocking each other?
   grep -i "waiting\|blocked" specialist-*.log
   ```

**Fix**:
- Ensure specialists truly run in parallel
- Minimize context duplication
- Optimize specialist coordination
- Use isolated browser sessions (frontend-qc)
- Implement proper result aggregation

---

## Design Checklist

### For Skills That Delegate to Agents

#### Configuration
- [ ] `Task` included in `allowed-tools` (or no restrictions)
- [ ] Required MCP servers specified
- [ ] Helper skills listed (if needed)
- [ ] File operation tools included (Read, Write, Edit)

#### Complexity Detection
- [ ] Clear threshold defined (quantity or multi-factor)
- [ ] Detection algorithm implemented
- [ ] Edge cases handled (0 components, 1 component, etc.)
- [ ] Fallback behavior for detection failures

#### Delegation Logic
- [ ] Decision framework documented
- [ ] Agent name specified correctly
- [ ] Context prepared for agent
- [ ] Fallback plan if delegation fails

#### Testing
- [ ] Test cases for threshold boundary conditions
- [ ] Test cases for successful delegation
- [ ] Test cases for delegation failure scenarios
- [ ] Performance benchmarks established

#### Documentation
- [ ] Delegation patterns documented in SKILL.md
- [ ] Examples provided for common scenarios
- [ ] Troubleshooting guide included
- [ ] Agent coordination explained

### For Agents That Spawn Specialists

#### Specialist Selection
- [ ] Domain relevance scoring algorithm defined
- [ ] Threshold for spawning specialists documented
- [ ] Maximum specialists limit established
- [ ] Fallback for no relevant specialists

#### Orchestration
- [ ] Parallel vs sequential execution determined
- [ ] Resource limits defined (max concurrent)
- [ ] Timeout handling implemented
- [ ] Progress tracking established

#### Results Aggregation
- [ ] Deduplication strategy implemented
- [ ] Cross-domain analysis planned
- [ ] Systemic issue detection designed
- [ ] Unified reporting format defined

#### Error Handling
- [ ] Specialist failure recovery
- [ ] Partial results handling
- [ ] Timeout recovery
- [ ] Resource exhaustion handling

---

## Real-World Examples

### Example 1: frontend-qc Parallel Testing

**Scenario**: Test 4 UI components in a web application

**Input**:
```
User: "Test the Login, Registration, Checkout, and Profile pages at http://localhost:8080"
```

**Complexity Detection**:
```javascript
components = ['Login', 'Registration', 'Checkout', 'Profile']
componentCount = 4
threshold = 3
shouldDelegate = 4 > 3 // TRUE
```

**Delegation**:
```yaml
Tool: Task
Agent: frontend-qc-agent
Context:
  components: 4
  urls:
    - /components/login.html
    - /components/registration.html
    - /components/checkout.html
    - /components/profile.html
  strategy: parallel
  max_concurrent: 5
```

**Agent Orchestration**:
```yaml
Main Agent: frontend-qc-agent
Sub-Agents: 4
  - login-subagent → tests /components/login.html
  - registration-subagent → tests /components/registration.html
  - checkout-subagent → tests /components/checkout.html
  - profile-subagent → tests /components/profile.html

Execution: Parallel (all 4 run simultaneously)
Time: ~15-20 minutes (vs 60 min sequential)
Speedup: 3-4x
```

**Results Aggregation**:
```yaml
Bugs Found:
  - Profile page: Selector typo (CRITICAL)
  - Registration: Weak email validation (MEDIUM)

Test Summary:
  - Total Components: 4
  - Tests Passed: 2 (Login, Checkout)
  - Tests Failed: 1 (Profile)
  - Warnings: 1 (Registration)
  - Duration: 18 minutes
  - Token Efficiency: 79% reduction vs skill-only mode
```

### Example 2: frontend-debug Multi-Domain Investigation

**Scenario**: E-commerce checkout with multiple unrelated bugs

**Input**:
```
User: "Checkout flow has problems: cart appears empty after adding items,
       payment processing fails with API errors, payment form doesn't fit
       on mobile screens, and page loads slowly"
```

**Complexity Detection**:
```javascript
domains = detectDomains(description);
// domains = ['state', 'network', 'ui', 'performance']

issues = extractIssues(description);
// issues = [
//   'cart empty',
//   'payment API fails',
//   'form mobile overflow',
//   'slow loading'
// ]

escalationScore = {
  indicators: [
    'multi_domain',      // 4 domains
    'systemic',          // affects entire checkout
    'multiple_issues',   // 4 unrelated problems
    'deep_investigation' // >5 files expected
  ],
  score: 4,
  shouldDelegate: true // ANY indicator = true
}
```

**Delegation**:
```yaml
Tool: Task
Agent: frontend-debug-agent
Context:
  browser_evidence:
    - Cart appears empty after items added
    - Payment API returns 404 errors
    - CORS errors on shipping calculation
    - Payment form overflow on mobile
    - Slow page load times

  hypothesis:
    - Multiple independent bugs across domains
    - Network: API endpoints misconfigured
    - State: localStorage key mismatch
    - UI: Fixed-width CSS, z-index conflicts
    - Performance: Large bundle, no lazy-loading

  confidence: 0.3
  domains_affected: [network, state, ui, performance]
```

**Domain Relevance Scoring**:
```yaml
Scores:
  network: 0.7
    - API 404 errors (+0.3)
    - CORS errors (+0.2)
    - Request failures (+0.2)

  state: 0.8
    - Cart empty (undefined) (+0.4)
    - Data persistence issues (+0.3)
    - State sync problems (+0.1)

  ui: 0.9
    - Mobile overflow (+0.4)
    - Responsive design issues (+0.4)
    - Visual bugs (+0.1)

  performance: 0.6
    - Slow page loads (+0.4)
    - Large bundle suspected (+0.2)

Threshold: 0.6
Specialists to Spawn: All 4 (all scores ≥0.6)
```

**Specialist Execution**:
```yaml
Parallel Execution: 4 specialists

network-specialist:
  findings:
    - Payment endpoint 404: /api/payment/process doesn't exist
    - CORS error: shipping API cross-origin blocked
    - Request timeout: slow backend response
  severity: CRITICAL
  duration: 8 minutes

state-specialist:
  findings:
    - localStorage key mismatch: writes 'shoppingCart', reads 'cart'
    - Undefined user.preferences access
  severity: HIGH
  duration: 7 minutes

ui-specialist:
  findings:
    - Fixed width form (800px) breaks mobile
    - Z-index conflict: overlay blocks modal
    - Missing ARIA labels on payment form
  severity: MEDIUM
  duration: 9 minutes

performance-specialist:
  findings:
    - Large bundle: 2.5MB (no code splitting)
    - Missing lazy-loading for images
  severity: MEDIUM
  duration: 6 minutes

Total Duration: max(8, 7, 9, 6) = 9 minutes
Sequential Estimate: 8+7+9+6 = 30 minutes
Speedup: 3.3x
```

**Results Aggregation**:
```yaml
Total Bugs: 10
Priority:
  CRITICAL:
    - Payment endpoint 404 (blocks checkout)
  HIGH:
    - localStorage key mismatch (cart data loss)
    - CORS error (shipping calculation fails)
  MEDIUM:
    - Fixed width mobile form
    - Z-index modal blocking
    - Missing ARIA labels
    - Large bundle size
    - Missing lazy-loading
    - Request timeout
    - Undefined preferences

Systemic Issues:
  - API endpoint changes across multiple pages
  - Accessibility gaps throughout checkout flow
  - Performance issues affect entire application

Cross-Domain Insights:
  - Network and state bugs are independent
  - UI and performance issues share root cause (lack of optimization)
  - Checkout flow needs comprehensive refactoring
```

---

## Performance Metrics

### frontend-qc Parallel Testing

| Metric | Skill-Only Mode | Agent-Delegated Mode | Improvement |
|--------|-----------------|----------------------|-------------|
| **Execution Time** (4 components) | ~60 min | ~15-20 min | 3-4x faster |
| **Token Usage** | ~24K tokens | ~5K main + isolated contexts | 79% reduction |
| **Bug Discovery** | Sequential | Parallel | Same quality |
| **Context Pollution** | High (all tests in one context) | Low (isolated per component) | Significant |
| **Scalability** | Linear (4x time for 4x components) | Sub-linear (parallel execution) | Excellent |

### frontend-debug Multi-Domain Debugging

| Metric | Skill-Only Mode | Agent-Delegated Mode | Improvement |
|--------|-----------------|----------------------|-------------|
| **Specialist Knowledge** | Generalist debugging | Domain-specific specialists | Higher quality |
| **Domain Coverage** | Sequential investigation | Parallel domain analysis | Comprehensive |
| **Bug Discovery** | May miss domain-specific issues | Specialists catch domain nuances | More thorough |
| **Cross-Domain Insights** | Limited synthesis | Systematic aggregation | Better analysis |
| **Execution Time** (4 domains) | ~30-40 min | ~9-15 min | 2.5-3.5x faster |

---

## Conclusion

The skill→agent hybrid architecture provides:

1. **Progressive Enhancement**: Simple tasks stay simple, complex tasks get appropriate resources
2. **Specialization**: Domain experts applied when needed
3. **Efficiency**: Token optimization through context isolation
4. **Scalability**: Parallel execution for independent work
5. **Quality**: Specialist knowledge improves outcomes

**Key Learnings from Phase 3**:
- Configuration is critical (`Task` tool access required)
- Complexity detection frameworks should match use case (quantity vs multi-factor)
- Agent orchestration strategies differ by problem type (component parallelization vs domain specialization)
- Testing validates architecture but also discovers configuration issues

**Next Steps**:
- Apply these patterns to additional skills
- Measure real-world performance gains
- Refine complexity thresholds based on usage data
- Expand specialist knowledge bases

---

**Guide Version**: 1.0
**Last Updated**: 2025-10-23
**Based On**: Phase 3 Testing (frontend-qc, frontend-debug)
**Maintained By**: SuperClaude Implementation Team
