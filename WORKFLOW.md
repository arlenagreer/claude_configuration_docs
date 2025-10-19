# WORKFLOW.md - SuperClaude /workflow Command Reference

## Overview

The `/workflow` command analyzes Product Requirement Documents (PRDs) and feature requirements to create comprehensive, step-by-step implementation workflows. It transforms high-level requirements into actionable development roadmaps with expert guidance.

## Command Structure

```bash
/workflow [target] [--strategy] [--persona] [--output] [--flags]
```

## Core Purpose

- **Analyze PRDs**: Process product requirement documents to extract implementation requirements
- **Create Roadmaps**: Generate comprehensive implementation roadmaps with phases and milestones
- **Expert Guidance**: Auto-activate relevant personas for domain-specific best practices
- **Risk Assessment**: Identify potential challenges and mitigation strategies
- **Dependency Mapping**: Visualize and manage project interdependencies

## When to Use

1. **Starting New Features**: Transform PRDs or specifications into actionable plans
2. **Complex Planning**: Break down complex features with multiple dependencies
3. **Implementation Strategy**: Get expert guidance on best implementation approaches
4. **Risk Management**: Identify and plan for potential implementation challenges
5. **Team Coordination**: Create shared understanding of implementation approach

## Command Arguments

### Primary Target
- `[prd-file]` - Path to PRD document (markdown, text, or other formats)
- `[feature-description]` - Text description of feature requirements
- `[specification-url]` - URL to online specification document

### Strategy Flags
- `--strategy systematic` - Comprehensive, methodical approach with all details
- `--strategy mvp` - Minimum viable product approach, focusing on core features
- `--strategy iterative` - Incremental delivery with multiple phases
- `--strategy agile` - Sprint-based planning with user stories

### Persona Activation
- `--persona architect` - System design and architecture focus
- `--persona security` - Security-first implementation planning
- `--persona frontend` - UI/UX focused workflow
- `--persona backend` - Server-side and API planning
- `--persona fullstack` - End-to-end implementation approach

### Output Control
- `--output basic` - Essential workflow steps only
- `--output detailed` - Comprehensive steps with explanations
- `--output comprehensive` - Full documentation with examples and alternatives

### Analysis Flags
- `--risks` - Include comprehensive risk assessment and mitigation
- `--dependencies` - Map all project dependencies and relationships
- `--timeline` - Generate estimated timelines for each phase
- `--resources` - Identify required resources and tools
- `--testing` - Include test strategy and validation steps

### MCP Integration
- `--c7` / `--context7` - Activate Context7 for pattern analysis and best practices
- `--seq` / `--sequential` - Enable Sequential for complex multi-step analysis
- `--magic` - Include Magic for UI component recommendations

### Wave Orchestration
- `--wave-mode` - Enable wave orchestration for complex workflows
- `--wave-strategy progressive` - Incremental enhancement approach
- `--wave-strategy systematic` - Methodical comprehensive analysis

## Usage Examples

### Basic Usage
```bash
# Simple workflow from feature description
/workflow "user authentication system"

# Workflow from PRD file
/workflow docs/feature-100-prd.md
```

### With Strategy
```bash
# MVP approach for quick delivery
/workflow payment-api --strategy mvp

# Systematic approach for critical features
/workflow security-system --strategy systematic --risks
```

### With Persona and Detail
```bash
# Security-focused workflow with detailed output
/workflow "user authentication" --persona security --output detailed

# Frontend workflow with UI components
/workflow dashboard-feature --persona frontend --magic --output comprehensive
```

### Complex Analysis
```bash
# Full analysis with all enhancements
/workflow enterprise-api.md --strategy systematic --c7 --sequential --risks --dependencies --timeline

# Agile workflow with testing strategy
/workflow user-stories.md --strategy agile --testing --resources
```

### Team Coordination
```bash
# Multi-team workflow planning
/workflow platform-migration --persona architect --output comprehensive --dependencies

# Cross-functional feature planning
/workflow checkout-flow --strategy iterative --risks --timeline
```

## Output Structure

The `/workflow` command generates:

### 1. Implementation Roadmap
```
Phase 1: Foundation (Week 1-2)
  ├── Database schema design
  ├── API structure planning
  └── Security architecture

Phase 2: Core Development (Week 3-4)
  ├── Authentication implementation
  ├── API endpoints
  └── Basic UI components

Phase 3: Integration (Week 5)
  ├── Frontend-backend integration
  ├── Third-party services
  └── Testing implementation
```

### 2. Task Organization
```
Epic: User Authentication System
  Story 1: Database and Models
    Task 1.1: Design user schema
    Task 1.2: Create migration scripts
    Task 1.3: Implement models
  
  Story 2: Authentication Logic
    Task 2.1: JWT implementation
    Task 2.2: Password hashing
    Task 2.3: Session management
```

### 3. Risk Assessment
```
High Risk:
  - Third-party API reliability
  - Mitigation: Implement fallback mechanisms

Medium Risk:
  - Performance at scale
  - Mitigation: Load testing and optimization

Low Risk:
  - Browser compatibility
  - Mitigation: Progressive enhancement
```

### 4. Dependency Map
```
Frontend Components
  └── depends on → API Contracts
      └── depends on → Database Schema
          └── depends on → Infrastructure Setup
```

### 5. Best Practices
```
Security:
  - Use bcrypt for password hashing
  - Implement rate limiting
  - Add CSRF protection

Performance:
  - Implement caching strategy
  - Use database indexing
  - Optimize API responses
```

## Integration with Other Commands

### Workflow → Implementation
```bash
# Generate workflow
/workflow feature.prd --output detailed

# Then implement
/implement --from-workflow --phase 1
```

### Workflow → Task Management
```bash
# Create workflow
/workflow project.md --strategy agile

# Convert to tasks
/task create --from-workflow --auto-assign
```

### Workflow → Estimation
```bash
# Generate workflow with timeline
/workflow feature.prd --timeline

# Get detailed estimates
/estimate --from-workflow --breakdown
```

## Auto-Activation Features

### Smart Persona Selection
The command automatically activates relevant personas based on:
- **Keywords**: "authentication" → security persona
- **File patterns**: "*.ui.prd" → frontend persona
- **Requirements**: "API design" → backend persona

### Wave Orchestration
As a wave-enabled command, `/workflow` supports:
- **Progressive Enhancement**: Iterative workflow refinement
- **Systematic Analysis**: Comprehensive multi-phase planning
- **Adaptive Strategy**: Dynamic adjustment based on complexity

### MCP Server Coordination
- **Context7**: Fetches best practices and patterns
- **Sequential**: Performs complex requirement analysis
- **Magic**: Suggests UI components for frontend workflows

## Advanced Features

### Checkpoint System
```bash
# Create workflow with checkpoints
/workflow feature.prd --checkpoints

# Navigate to specific checkpoint
/workflow --resume checkpoint-2
```

### Parallel Workflows
```bash
# Generate parallel team workflows
/workflow platform.prd --parallel-teams frontend,backend,devops
```

### Template Usage
```bash
# Use predefined workflow template
/workflow feature.prd --template microservice

# Available templates:
# - microservice
# - spa (single-page app)
# - api
# - migration
# - integration
```

## Best Practices

1. **Start with Clear Requirements**: Better PRDs lead to better workflows
2. **Choose Appropriate Strategy**: MVP for experiments, systematic for critical features
3. **Include Risk Assessment**: Always use `--risks` for complex features
4. **Map Dependencies Early**: Use `--dependencies` to prevent blockers
5. **Iterate and Refine**: Workflows can be updated as requirements evolve

## Common Patterns

### Feature Development
```bash
/workflow feature.prd --strategy iterative --timeline --testing
```

### System Migration
```bash
/workflow migration-plan.md --strategy systematic --risks --dependencies --checkpoints
```

### API Design
```bash
/workflow api-spec.yaml --persona backend --c7 --output comprehensive
```

### UI Implementation
```bash
/workflow ui-mockups.md --persona frontend --magic --strategy mvp
```

## Troubleshooting

### Issue: Workflow too generic
**Solution**: Add more specific flags like `--persona` and `--output detailed`

### Issue: Missing dependencies
**Solution**: Use `--dependencies` flag to ensure complete mapping

### Issue: Unclear timeline
**Solution**: Add `--timeline` and `--resources` flags for better planning

### Issue: No risk mitigation
**Solution**: Always include `--risks` for production features

## Performance Considerations

- **Token Usage**: Comprehensive workflows use more tokens; use `--output basic` for efficiency
- **Processing Time**: Complex analysis with `--sequential` may take longer
- **Caching**: Workflows are cached for session reuse

## Version History

- **v3.0**: Added wave orchestration support
- **v2.5**: Enhanced MCP integration
- **v2.0**: Added multiple strategy options
- **v1.0**: Initial workflow command implementation

---

*The `/workflow` command is your strategic planning assistant, bridging the gap between requirements and implementation.*