# SuperClaude Framework Reference

Complete reference for crafting optimal SuperClaude prompts using commands, flags, personas, MCP servers, and orchestration patterns.

## Quick Reference: Command Categories

### Development Commands
- `/sc:build [target] [flags]` - Project builder with framework detection (wave-enabled)
- `/sc:implement [feature] [flags]` - Feature and code implementation (wave-enabled)
- `/sc:design [domain] [flags]` - Design orchestration

### Analysis Commands
- `/sc:analyze [target] [flags]` - Multi-dimensional code and system analysis (wave-enabled)
- `/sc:troubleshoot [symptoms] [flags]` - Problem investigation
- `/sc:explain [topic] [flags]` - Educational explanations

### Quality Commands
- `/sc:improve [target] [flags]` - Evidence-based code enhancement (wave-enabled)
- `/sc:cleanup [target] [flags]` - Technical debt reduction

### Planning & Orchestration
- `/sc:workflow [prd-file|feature-description] [flags]` - PRD analysis to implementation workflow (wave-enabled)
- `/sc:estimate [target] [flags]` - Evidence-based estimation
- `/sc:task [operation] [flags]` - Long-term project management (wave-enabled)
- `/sc:spawn [mode] [flags]` - Task orchestration

### Testing & Documentation
- `/sc:test [type] [flags]` - Testing workflows
- `/sc:document [target] [flags]` - Documentation generation

### Meta Commands
- `/sc:git [operation] [flags]` - Git workflow assistant
- `/sc:load [path] [flags]` - Project context loading
- `/sc:index [query] [flags]` - Command catalog browsing

## Essential Flags

### Mode Activation
- `--brainstorm` - Collaborative discovery for vague requirements
- `--introspect` - Expose thinking process and meta-cognition
- `--task-manage` - Multi-step orchestration (>3 steps, >2 dirs OR >3 files)
- `--orchestrate` - Optimize tool selection for multi-tool operations
- `--token-efficient` / `--uc` - Symbol-enhanced communication (30-50% token reduction)

### MCP Server Control
- `--c7` / `--context7` - Library docs, framework patterns, best practices
- `--seq` / `--sequential` - Complex debugging, multi-step reasoning
- `--magic` - UI component generation, design systems
- `--play` / `--playwright` - Browser testing, E2E scenarios
- `--all-mcp` - Enable all MCP servers (max complexity)
- `--no-mcp` - Native tools only (performance priority)

### Analysis Depth
- `--think` - Standard analysis (~4K tokens), enables Sequential
- `--think-hard` - Deep analysis (~10K tokens), Sequential + Context7
- `--ultrathink` - Maximum depth (~32K tokens), all MCP servers

### Execution Control
- `--delegate [auto|files|folders]` - Sub-agent parallel processing (>7 dirs OR >50 files)
- `--concurrency [n]` - Control max concurrent operations (1-15)
- `--loop` - Iterative improvement cycles
- `--iterations [n]` - Set improvement cycle count (1-10)
- `--validate` - Pre-execution risk assessment (risk >0.7)
- `--safe-mode` - Maximum validation, conservative execution

### Output Optimization
- `--scope [file|module|project|system]` - Define operational scope
- `--focus [performance|security|quality|architecture|accessibility|testing]` - Target specific domain

### Flag Priority Rules
1. **Safety First**: --safe-mode > --validate > optimization flags
2. **Explicit Override**: User flags > auto-detection
3. **Depth Hierarchy**: --ultrathink > --think-hard > --think
4. **MCP Control**: --no-mcp overrides all individual MCP flags
5. **Scope Precedence**: system > project > module > file

## Personas (use --persona-[name])

### Technical Specialists
- **architect** - Systems design, long-term thinking, scalability (MCP: Sequential, Context7)
- **frontend** - UI/UX, accessibility, performance (MCP: Magic, Playwright)
- **backend** - Reliability, API design, data integrity (MCP: Context7, Sequential)
- **security** - Threat modeling, compliance, vulnerabilities (MCP: Sequential, Context7)
- **performance** - Optimization, bottleneck elimination (MCP: Playwright, Sequential)

### Process & Quality Experts
- **analyzer** - Root cause analysis, evidence-based investigation (MCP: Sequential, Context7)
- **qa** - Quality assurance, testing, edge cases (MCP: Playwright, Sequential)
- **refactorer** - Code quality, technical debt management (MCP: Sequential, Context7)
- **devops** - Infrastructure, deployment automation (MCP: Sequential, Context7)

### Knowledge & Communication
- **mentor** - Educational guidance, knowledge transfer (MCP: Context7, Sequential)
- **scribe** - Professional documentation, localization (MCP: Context7, Sequential)

### Auto-Activation Keywords
- **architect**: "architecture", "design", "scalability"
- **frontend**: "component", "responsive", "accessibility"
- **backend**: "API", "database", "service", "reliability"
- **security**: "vulnerability", "threat", "compliance"
- **performance**: "optimize", "performance", "bottleneck"
- **analyzer**: "analyze", "investigate", "root cause"
- **qa**: "test", "quality", "validation"
- **refactorer**: "refactor", "cleanup", "technical debt"
- **devops**: "deploy", "infrastructure", "automation"
- **mentor**: "explain", "learn", "understand"
- **scribe**: "document", "write", "guide"

## MCP Server Integration

**Note on MCP Server Support**: SuperClaude supports 9 MCP servers, but only 4 are officially documented in MCP.md (Context7, Sequential, Magic, Playwright). The remaining servers (Serena, Tavily, Chrome DevTools, Morphllm, Puppeteer) are functional and available but not yet covered in the official MCP documentation.

### Context7 (Documentation & Patterns)
**Purpose**: Official library docs, code examples, best practices
**Use For**: Framework patterns, library documentation, localization standards
**Commands**: /sc:build, /sc:analyze, /sc:improve, /sc:design, /sc:document, /sc:explain, /sc:git
**Activation**: Library imports, framework questions, scribe persona

### Sequential (Complex Analysis)
**Purpose**: Multi-step problem solving, architectural analysis, systematic debugging
**Use For**: Root cause analysis, performance bottlenecks, architecture review, security threat modeling
**Commands**: /sc:analyze, /sc:troubleshoot, /sc:workflow, /sc:task, /sc:estimate
**Activation**: Complex debugging, system design, --think flags

### Magic (UI Components)
**Purpose**: Modern UI component generation, design system integration
**Use For**: Buttons, forms, modals, layout components, responsive design
**Commands**: /sc:build, /sc:implement, /sc:design
**Activation**: UI component requests, design system queries, frontend persona

### Playwright (Browser Testing)
**Purpose**: Cross-browser E2E testing, performance monitoring, automation
**Use For**: User workflows, visual testing, performance metrics, accessibility testing
**Commands**: /sc:test, /sc:improve --perf, /sc:troubleshoot
**Activation**: Testing workflows, performance monitoring, QA persona

### Serena (Symbolic Code Operations)
**Purpose**: Semantic code analysis, symbol operations, project memory, large codebase navigation
**Use For**: Find symbol, symbol references, code structure analysis, session persistence
**Commands**: /sc:analyze, /sc:improve, /sc:implement
**Activation**: Large codebase work, symbol operations, cross-session context

### Tavily (Web Search & Research)
**Purpose**: Real-time web search, current information, research capabilities
**Use For**: Latest documentation, current best practices, technology research, market data
**Commands**: /sc:research, /sc:analyze, /sc:explain, /sc:document
**Activation**: Current information needs, web research, latest trends

### Chrome DevTools (Browser Debugging)
**Purpose**: Browser automation, debugging, performance analysis, network inspection
**Use For**: Frontend debugging, network issues, performance profiling, DOM inspection
**Commands**: /sc:troubleshoot, /sc:test, /sc:analyze --focus performance
**Activation**: Frontend debugging, browser-specific issues, performance investigation

### Morphllm (Pattern-Based Transformations)
**Purpose**: Bulk code transformations, pattern-based edits, style enforcement across multiple files
**Use For**: Codebase-wide refactoring, style consistency, pattern application
**Commands**: /sc:improve, /sc:cleanup
**Activation**: Multi-file transformations, style enforcement, bulk updates

### Puppeteer (Browser Automation)
**Purpose**: Headless browser automation, web scraping, automated testing alternative
**Use For**: Browser automation, screenshot capture, PDF generation, web scraping
**Commands**: /sc:test, /sc:build, /sc:implement
**Activation**: Browser automation needs, alternative to Playwright

## Wave Orchestration System

### Wave-Enabled Commands
**Tier 1**: `/sc:analyze`, `/sc:build`, `/sc:implement`, `/sc:improve`, `/sc:workflow` (primary wave support)
**Tier 2**: `/sc:design`, `/sc:task` (secondary wave support)

### Wave Activation
**Automatic**: complexity ≥0.7 + files >20 + operation_types >2
**Explicit**: `--wave-mode`, `--force-waves`
**Override**: `--single-wave` (disables), `--wave-dry-run` (simulation)

### Wave Strategies
- `--wave-strategy progressive` - Incremental enhancement
- `--wave-strategy systematic` - Methodical analysis
- `--wave-strategy adaptive` - Dynamic configuration
- `--wave-strategy enterprise` - Large-scale operations

### Wave Use Cases
- Comprehensive system improvements (complexity >0.8, files >20, types >2)
- Enterprise security audits (multi-domain, critical quality)
- Large-scale refactoring (structural changes, high complexity)
- Legacy system modernization (files >100, complexity >0.7)

## Orchestration Patterns

### Complexity Detection
- **Simple**: Single file, basic CRUD, <3 steps (5K tokens, <5 min)
- **Moderate**: Multi-file, analysis tasks, 3-10 steps (15K tokens, 5-30 min)
- **Complex**: System-wide, architectural, >10 steps (30K+ tokens, >30 min)

### Domain Identification Keywords
- **Frontend**: UI, component, React, Vue, CSS, responsive, accessibility
- **Backend**: API, database, server, endpoint, authentication, performance
- **Infrastructure**: deploy, Docker, CI/CD, monitoring, scaling
- **Security**: vulnerability, authentication, encryption, audit
- **Documentation**: document, README, wiki, guide, manual, commit

### Operation Type Classification
- **Analysis**: analyze, review, explain, understand, investigate
- **Creation**: create, build, implement, generate, design
- **Implementation**: implement, develop, code, construct, realize
- **Modification**: update, refactor, improve, optimize, fix
- **Debugging**: debug, fix, troubleshoot, resolve, investigate
- **Iterative**: improve, refine, enhance, correct, polish, iterate

### Auto-Flag Assignment
- Directory count >7 → `--delegate --parallel-dirs`
- Files >50 + complexity >0.6 → `--delegate --sub-agents`
- Focus areas >2 → `--multi-agent --parallel-focus`
- High complexity + critical quality → `--wave-mode --wave-validation`
- Multiple operation types → `--wave-mode --adaptive-waves`

## Prompt Optimization Strategies

### Parallel Execution Opportunities
**Identify when to batch operations**:
- Independent Read operations → Batch in single message
- Multiple file searches → Parallel Grep/Glob calls
- Multi-file edits → Use MultiEdit instead of sequential Edits
- Analysis across directories → Use --delegate with parallel processing

### Tool Selection Matrix
- **Multi-file edits** → MultiEdit > individual Edits
- **Complex analysis** → Task agent > native reasoning
- **Code search** → Grep tool > bash grep
- **UI components** → Magic MCP > manual coding
- **Documentation** → Context7 MCP > web search
- **Browser testing** → Playwright MCP > unit tests

### Resource Optimization
**Token Management**:
- Green Zone (0-60%): Full operations
- Yellow Zone (60-75%): Suggest --uc mode
- Orange Zone (75-85%): Warning, defer non-critical ops
- Red Zone (85-95%): Force efficiency modes
- Critical Zone (95%+): Emergency protocols

### Persona + MCP + Command Combinations

**Security Analysis**:
```
/sc:analyze [target] --persona security --seq --ultrathink --focus security --validate
```

**Frontend Performance Optimization**:
```
/sc:improve [component] --persona frontend --persona performance --magic --play --focus performance
```

**System Architecture Review**:
```
/sc:analyze @codebase --persona architect --seq --think-hard --scope system --dependencies
```

**Complex Multi-Domain Implementation**:
```
/sc:implement [feature] --persona architect --seq --c7 --magic --delegate auto --validate
```

**Iterative Code Quality Improvement**:
```
/sc:improve [target] --persona refactorer --loop --iterations 3 --focus quality --validate
```

**Comprehensive Enterprise Audit**:
```
/sc:analyze @project --wave-mode --wave-strategy enterprise --persona security --persona performance --ultrathink --validate
```

## Best Practices for Prompt Crafting

### 1. Start with Domain Analysis
Identify the primary domain (frontend, backend, security, etc.) to select the right persona and MCP servers.

### 2. Assess Complexity
- Simple (1-2 files, basic task) → Standard command, minimal flags
- Moderate (3-10 files, analysis needed) → Add --think, relevant persona
- Complex (>10 files, system-wide) → Add --delegate, --wave-mode, multiple personas

### 3. Leverage Parallelization
Identify independent operations and use batch operations, --delegate, or --concurrency flags.

### 4. Choose Appropriate Depth
- Standard work → No depth flags
- Important analysis → --think
- Critical decisions → --think-hard
- System redesign → --ultrathink

### 5. Add Safety for Production
For production environments or risky operations, always add:
- `--validate` (pre-execution risk assessment)
- `--safe-mode` (maximum validation)

### 6. Optimize for Token Efficiency
When context is high or operation is large:
- Add `--uc` flag for compressed output
- Use `--scope` to limit analysis boundaries
- Leverage `--focus` to target specific domains

### 7. Enable Iterative Workflows
For improvement and refinement tasks:
- Add `--loop` for automatic iteration cycles
- Specify `--iterations [n]` for controlled refinement
- Combine with refactorer persona for code quality

### 8. Wave Mode for Large Operations
When dealing with:
- Files >20 and complexity >0.7
- Multiple operation types
- Enterprise-scale changes
→ Use `--wave-mode` with appropriate strategy

## Common Prompt Patterns

### Security Audit Pattern
```
/sc:analyze [target] --persona security --seq --ultrathink --focus security --risks --validate
```
**Why**: Security persona + Sequential for threat modeling + ultrathink for comprehensive coverage + validate for safety

### Performance Investigation Pattern
```
/sc:troubleshoot [symptoms] --persona performance --play --think-hard --focus performance
```
**Why**: Performance persona + Playwright for metrics + think-hard for deep analysis

### Feature Implementation Pattern
```
/sc:implement [feature-description] --persona [domain] --c7 --seq --magic --validate
```
**Why**: Domain persona + Context7 for patterns + Sequential for logic + Magic for UI + validate for safety

### Code Quality Improvement Pattern
```
/sc:improve [target] --persona refactorer --loop --iterations 3 --focus quality --uc
```
**Why**: Refactorer persona + loop for iterative refinement + focus quality + uc for efficiency

### Large Codebase Analysis Pattern
```
/sc:analyze @codebase --delegate auto --think-hard --persona analyzer --scope system --uc
```
**Why**: Auto-delegation for scale + think-hard for depth + analyzer persona + system scope + uc for efficiency

### Workflow Planning Pattern
```
/sc:workflow [prd-file] --strategy systematic --persona architect --c7 --seq --risks --dependencies --timeline
```
**Why**: Systematic strategy for completeness + architect persona + Context7 for patterns + Sequential for planning + comprehensive flags

### Multi-Domain Development Pattern
```
/sc:implement [feature] --persona frontend --persona backend --magic --c7 --delegate auto --validate
```
**Why**: Multiple personas for full-stack + Magic for UI + Context7 for patterns + delegation for parallelization + validate for safety
