# COMMANDS.md - SuperClaude Command Execution Framework

Command execution framework for Claude Code SuperClaude integration.

## Command System Architecture

### Core Command Structure
```yaml
---
command: "/{command-name}"
category: "Primary classification"
purpose: "Operational objective"
wave-enabled: true|false
performance-profile: "optimization|standard|complex"
---
```

### Command Processing Pipeline
1. **Input Parsing**: `$ARGUMENTS` with `@<path>`, `!<command>`, `--<flags>`
2. **Context Resolution**: Auto-persona activation and MCP server selection
3. **Wave Eligibility**: Complexity assessment and wave mode determination
4. **Execution Strategy**: Tool orchestration and resource allocation
5. **Quality Gates**: Validation checkpoints and error handling

### Integration Layers
- **Claude Code**: Native slash command compatibility
- **Persona System**: Auto-activation based on command context
- **MCP Servers**: Context7, Sequential, Magic, Playwright integration
- **Wave System**: Multi-stage orchestration for complex operations

## Wave System Integration

**Wave Orchestration Engine**: Multi-stage command execution with compound intelligence. Auto-activates on complexity ≥0.7 + files >20 + operation_types >2.

**Wave-Enabled Commands**:
- **Tier 1**: `/analyze`, `/build`, `/implement`, `/improve`
- **Tier 2**: `/design`, `/task`

### Development Commands

**`/build $ARGUMENTS`**
```yaml
---
command: "/build"
category: "Development & Deployment"
purpose: "Project builder with framework detection"
wave-enabled: true
performance-profile: "optimization"
---
```
- **Auto-Persona**: Frontend, Backend, Architect, Scribe
- **MCP Integration**: Magic (UI builds), Context7 (patterns), Sequential (logic)
- **Tool Orchestration**: [Read, Grep, Glob, Bash, TodoWrite, Edit, MultiEdit]
- **Arguments**: `[target]`, `@<path>`, `!<command>`, `--<flags>`

**`/implement $ARGUMENTS`**
```yaml
---
command: "/implement"
category: "Development & Implementation"
purpose: "Feature and code implementation with intelligent persona activation"
wave-enabled: true
performance-profile: "standard"
---
```
- **Auto-Persona**: Frontend, Backend, Architect, Security (context-dependent)
- **MCP Integration**: Magic (UI components), Context7 (patterns), Sequential (complex logic)
- **Tool Orchestration**: [Read, Write, Edit, MultiEdit, Bash, Glob, TodoWrite, Task]
- **Arguments**: `[feature-description]`, `--type component|api|service|feature`, `--framework <name>`, `--<flags>`


### Analysis Commands

**`/analyze $ARGUMENTS`**
```yaml
---
command: "/analyze"
category: "Analysis & Investigation"
purpose: "Multi-dimensional code and system analysis"
wave-enabled: true
performance-profile: "complex"
---
```
- **Auto-Persona**: Analyzer, Architect, Security
- **MCP Integration**: Sequential (primary), Context7 (patterns), Magic (UI analysis)
- **Tool Orchestration**: [Read, Grep, Glob, Bash, TodoWrite]
- **Arguments**: `[target]`, `@<path>`, `!<command>`, `--<flags>`

**`/troubleshoot [symptoms] [flags]`** - Problem investigation | Auto-Persona: Analyzer, QA | MCP: Sequential, Playwright

**`/explain [topic] [flags]`** - Educational explanations | Auto-Persona: Mentor, Scribe | MCP: Context7, Sequential


### Quality Commands

**`/improve [target] [flags]`**
```yaml
---
command: "/improve"
category: "Quality & Enhancement"
purpose: "Evidence-based code enhancement"
wave-enabled: true
performance-profile: "optimization"
---
```
- **Auto-Persona**: Refactorer, Performance, Architect, QA
- **MCP Integration**: Sequential (logic), Context7 (patterns), Magic (UI improvements)
- **Tool Orchestration**: [Read, Grep, Glob, Edit, MultiEdit, Bash]
- **Arguments**: `[target]`, `@<path>`, `!<command>`, `--<flags>`


**`/cleanup [target] [flags]`** - Project cleanup and technical debt reduction | Auto-Persona: Refactorer | MCP: Sequential

### Additional Commands

**`/document [target] [flags]`** - Documentation generation | Auto-Persona: Scribe, Mentor | MCP: Context7, Sequential

**`/estimate [target] [flags]`** - Evidence-based estimation | Auto-Persona: Analyzer, Architect | MCP: Sequential, Context7

**`/task [operation] [flags]`** - Long-term project management | Auto-Persona: Architect, Analyzer | MCP: Sequential

**`/workflow $ARGUMENTS`**
```yaml
---
command: "/workflow"
category: "Planning & Orchestration"
purpose: "Analyze PRDs and feature requirements to create comprehensive implementation workflows"
wave-enabled: true
performance-profile: "complex"
---
```
- **Auto-Persona**: Architect, Analyzer, domain-specific experts based on requirements
- **MCP Integration**: Context7 (patterns, best practices), Sequential (complex analysis)
- **Tool Orchestration**: [Read, Grep, Glob, TodoWrite, Write, Task]
- **Arguments**: `[prd-file|feature-description]`, `--strategy systematic|mvp`, `--persona <expert>`, `--output basic|detailed|comprehensive`, `--risks`, `--dependencies`

**`/test [type] [flags]`** - Testing workflows | Auto-Persona: QA | MCP: Playwright, Sequential

**`/git [operation] [flags]`** - Git workflow assistant | Auto-Persona: DevOps, Scribe, QA | MCP: Sequential

**`/design [domain] [flags]`** - Design orchestration | Auto-Persona: Architect, Frontend | MCP: Magic, Sequential, Context7

### Meta & Orchestration Commands

**`/index [query] [flags]`** - Command catalog browsing | Auto-Persona: Mentor, Analyzer | MCP: Sequential

**`/load [path] [flags]`** - Project context loading | Auto-Persona: Analyzer, Architect, Scribe | MCP: All servers

**Iterative Operations** - Use `--loop` flag with improvement commands for iterative refinement

**`/spawn [mode] [flags]`** - Task orchestration | Auto-Persona: Analyzer, Architect, DevOps | MCP: All servers

### Team Coordination Commands

**`/team [member] [action]`** - Software engineering team coordination
```yaml
---
command: "/team"
category: "Team Coordination"
purpose: "Activate specialized team members for software development"
wave-enabled: false
performance-profile: "standard"
---
```
- **Team Members**: pm, lead, backend, frontend, devops, qa, security, performance, data, ml, mobile, dba, ux, platform, docs, accessibility, release, compliance, ba, solutions, observability, api, cost, designer, researcher, analyst, product-analyst, integration, architect, fullstack, growth, sre, technical-writer, enterprise-architect, program-manager, customer-success-engineer, solutions-engineer, growth-engineer, product-designer
- **Auto-Coordination**: Handoffs based on workflow phase and dependencies
- **Integration**: Loads agent context from `~/.claude/agents/[role].md`
- **Workflows**: TDD, specification-driven, handoff protocols

**`/team:pm [action]`** - Product Manager agent | Focus: Requirements, stakeholder communication
**`/team:lead [action]`** - Tech Lead agent | Focus: Architecture, technical leadership  
**`/team:backend [action]`** - Backend Engineer agent | Focus: APIs, databases, server-side
**`/team:frontend [action]`** - Frontend Engineer agent | Focus: UI/UX, components
**`/team:devops [action]`** - DevOps Engineer agent | Focus: Infrastructure, deployment
**`/team:qa [action]`** - QA Engineer agent | Focus: Testing, quality assurance
**`/team:security [action]`** - Security Engineer agent | Focus: Security audits, compliance
**`/team:performance [action]`** - Performance Engineer agent | Focus: Optimization, monitoring
**`/team:data [action]`** - Data Engineer agent | Focus: Data pipelines, ETL, warehousing
**`/team:ml [action]`** - ML/AI Engineer agent | Focus: Machine learning, AI integration
**`/team:mobile [action]`** - Mobile Engineer agent | Focus: iOS/Android, cross-platform
**`/team:dba [action]`** - Database Administrator agent | Focus: Database optimization, reliability
**`/team:ux [action]`** - UX Designer agent | Focus: User experience, design systems
**`/team:platform [action]`** - Infrastructure/Platform Engineer agent | Focus: Developer platforms, Kubernetes
**`/team:docs [action]`** - Documentation Engineer agent | Focus: Technical documentation, API docs
**`/team:accessibility [action]`** - Accessibility Specialist agent | Focus: WCAG compliance, inclusive design
**`/team:release [action]`** - Release Manager agent | Focus: Release coordination, deployment
**`/team:compliance [action]`** - Compliance/Legal Tech agent | Focus: Regulatory compliance, privacy
**`/team:ba [action]`** - Business Analyst agent | Focus: Requirements analysis, process modeling
**`/team:solutions [action]`** - Solutions Architect agent | Focus: End-to-end architecture, integration
**`/team:observability [action]`** - Observability Engineer agent | Focus: Monitoring, tracing, SRE
**`/team:api [action]`** - API Designer agent | Focus: API architecture, developer experience
**`/team:cost [action]`** - Cost Engineer agent | Focus: Cloud cost optimization, FinOps

**`/team:designer [action]`** - Product Designer agent | Focus: Visual design, user flows, design systems
**`/team:researcher [action]`** - UX Researcher agent | Focus: User testing, personas, usability studies
**`/team:analyst [action]`** - Data Analyst agent | Focus: Business intelligence, metrics, user behavior
**`/team:product-analyst [action]`** - Product Analyst agent | Focus: A/B testing, feature performance, conversion
**`/team:integration [action]`** - Integration Engineer agent | Focus: Third-party APIs, middleware, connectivity
**`/team:architect [action]`** - Enterprise Architect agent | Focus: System design, technology strategy, scalability
**`/team:fullstack [action]`** - Full-Stack Engineer agent | Focus: Versatile development, rapid prototyping
**`/team:growth [action]`** - Growth Engineer agent | Focus: Experimentation, conversion optimization, analytics
**`/team:sre [action]`** - Site Reliability Engineer agent | Focus: Uptime, incident response, system reliability
**`/team:technical-writer [action]`** - Technical Writer agent | Focus: User documentation, developer guides
**`/team:enterprise-architect [action]`** - Enterprise Architect agent | Focus: Large-scale design, vendor evaluation
**`/team:program-manager [action]`** - Technical Program Manager agent | Focus: Cross-team coordination, roadmaps
**`/team:customer-success-engineer [action]`** - Customer Success Engineer agent | Focus: Technical onboarding, integration support
**`/team:solutions-engineer [action]`** - Solutions Engineer agent | Focus: Pre-sales technical support, custom implementations
**`/team:growth-engineer [action]`** - Growth Engineer agent | Focus: User acquisition, retention, viral mechanics
**`/team:product-designer [action]`** - Product Designer agent | Focus: User-centered design, conversion optimization

## Command Execution Matrix

### Performance Profiles
```yaml
optimization: "High-performance with caching and parallel execution"
standard: "Balanced performance with moderate resource usage"
complex: "Resource-intensive with comprehensive analysis"
```

### Command Categories
- **Development**: build, implement, design
- **Planning**: workflow, estimate, task
- **Analysis**: analyze, troubleshoot, explain
- **Quality**: improve, cleanup
- **Testing**: test
- **Documentation**: document
- **Version-Control**: git
- **Meta**: index, load, spawn
- **Team Coordination**: team, team:pm, team:lead, team:backend, team:frontend, team:devops, team:qa, team:security, team:performance, team:data, team:ml, team:mobile, team:dba, team:ux, team:platform, team:docs, team:accessibility, team:release, team:compliance, team:ba, team:solutions, team:observability, team:api, team:cost, team:designer, team:researcher, team:analyst, team:product-analyst, team:integration, team:architect, team:fullstack, team:growth, team:sre, team:technical-writer, team:enterprise-architect, team:program-manager, team:customer-success-engineer, team:solutions-engineer, team:growth-engineer, team:product-designer

### Wave-Enabled Commands
7 commands: `/analyze`, `/build`, `/design`, `/implement`, `/improve`, `/task`, `/workflow`

