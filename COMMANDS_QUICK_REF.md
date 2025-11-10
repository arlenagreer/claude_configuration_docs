# Commands Quick Reference

**Full Documentation**: @details/COMMANDS.md (load on-demand)

## Command Format
```
/{command} [target] [--flags]
```

## Core Commands

| Command | Purpose | Key Flags | Wave |
|---------|---------|-----------|------|
| `/analyze` | Multi-domain code analysis | `--focus domain` `--depth quick\|deep` | ✅ |
| `/build` | Project builder with framework detection | `--framework name` | ✅ |
| `/implement` | Feature/code implementation | `--type component\|api\|service` | ✅ |
| `/improve` | Evidence-based enhancement | `--quality\|perf\|security` | ✅ |
| `/design` | Design orchestration | `--domain area` | ✅ |
| `/task` | Long-term project management | `--operation action` | ✅ |
| `/workflow` | PRD → implementation roadmap | `--strategy systematic\|mvp` | ✅ |
| `/troubleshoot` | Problem investigation | `--symptoms` | - |
| `/explain` | Educational explanations | `--detailed` | - |
| `/cleanup` | Technical debt reduction | `--target area` | - |
| `/document` | Documentation generation | `--target area` | - |
| `/estimate` | Evidence-based estimation | `--breakdown` | - |
| `/test` | Testing workflows | `--type unit\|e2e\|integration` | - |
| `/git` | Git workflow assistant | `--operation action` | - |
| `/index` | Command catalog browsing | `--query term` | - |
| `/load` | Project context loading | `--path location` | - |
| `/spawn` | Task orchestration | `--mode type` | - |

## Team Commands

| Command | Role | Focus Area |
|---------|------|------------|
| `/team:pm` | Product Manager | Requirements, stakeholder communication |
| `/team:lead` | Tech Lead | Architecture, technical leadership |
| `/team:backend` | Backend Engineer | APIs, databases, server-side |
| `/team:frontend` | Frontend Engineer | UI/UX, components |
| `/team:devops` | DevOps Engineer | Infrastructure, deployment |
| `/team:qa` | QA Engineer | Testing, quality assurance |
| `/team:security` | Security Engineer | Security audits, compliance |
| `/team:performance` | Performance Engineer | Optimization, monitoring |

**35+ team roles available** - See @details/COMMANDS.md for complete list

## Common Patterns

### Development Workflow
```bash
/analyze src/                    # Assess codebase
/design feature-name            # Plan architecture
/implement "feature description" # Build feature
/test --type integration        # Validate
/git commit                     # Commit changes
```

### Quality Improvement
```bash
/analyze --focus quality        # Identify issues
/improve --quality src/         # Apply improvements
/cleanup src/                   # Remove technical debt
```

### Team Coordination
```bash
/team:pm gather requirements    # PM gathers requirements
/team:lead design system        # Lead designs architecture
/team:backend implement API     # Backend builds service
/team:frontend build UI         # Frontend creates interface
/team:qa validate quality       # QA tests
```

## Auto-Activation Features

**Persona Selection**: Commands auto-activate relevant personas based on keywords and context

**MCP Integration**: Automatic server selection (Context7, Sequential, Magic, Playwright)

**Wave Orchestration**: Complex operations trigger multi-stage execution (complexity >0.7)

## Quick Tips

- **Wave Mode**: Add `--wave-mode` for complex multi-stage operations
- **Parallel Ops**: Use `--delegate` for large-scale operations
- **Validation**: Add `--validate` for pre-execution risk assessment
- **Efficiency**: Use `--uc` for ultracompressed output in resource-constrained scenarios
- **Depth Control**: `--think` (4K) `--think-hard` (10K) `--ultrathink` (32K)
