# SuperClaude Prompt Generator Skill

**Version**: 1.0.0
**Category**: Productivity
**Author**: SuperClaude Framework

## Overview

The SuperClaude Prompt Generator is an expert prompt engineering skill that analyzes your needs and crafts optimal SuperClaude prompts using the full framework capabilities including commands, flags, personas, MCP servers, wave orchestration, and parallel execution patterns.

## What This Skill Does

Given a description of what you need to accomplish, this skill will:

1. **Analyze** your request to understand:
   - Primary domain (frontend, backend, security, etc.)
   - Operation type (analysis, implementation, debugging, etc.)
   - Complexity level (simple, moderate, complex)
   - Scope (file, module, project, system)
   - Special requirements (security, performance, testing)

2. **Design** an optimal prompt by selecting:
   - The right SuperClaude command (`/build`, `/implement`, `/analyze`, etc.)
   - Appropriate behavioral flags (`--think`, `--validate`, `--delegate`, etc.)
   - Relevant personas (`--persona-security`, `--persona-frontend`, etc.)
   - Necessary MCP servers (Context7, Sequential, Magic, Playwright)
   - Orchestration strategies (parallel execution, wave mode, delegation)

3. **Explain** the reasoning behind each choice:
   - Why this command was selected
   - How each flag contributes to the best result
   - Why specific personas were activated
   - How MCP servers enhance the solution
   - What orchestration patterns were applied

4. **Output** a complete, ready-to-use SuperClaude prompt with comprehensive analysis

## How to Use

Simply invoke the skill and describe what you need:

```
@superclaude-prompt-creator "I need to add authentication to my web application"
```

```
@superclaude-prompt-creator "Optimize the performance of my React dashboard"
```

```
@superclaude-prompt-creator "Analyze security vulnerabilities in the API layer"
```

The skill will generate an optimal SuperClaude prompt tailored to your specific need.

## What's Included

### SKILL.md
The main skill file containing:
- Complete prompt engineering workflow
- SuperClaude facility selection logic
- Optimization patterns and best practices
- Detailed example usage
- Output format specifications

### references/superclaude-reference.md
Comprehensive SuperClaude framework reference including:
- All commands categorized by function
- Essential flags organized by type
- 11 specialized personas with auto-activation keywords
- MCP server integration details
- Wave orchestration system
- Orchestration patterns
- Common prompt patterns with examples

## Key Features

- **Framework-Complete**: Uses all SuperClaude facilities (commands, flags, personas, MCP servers)
- **Intelligent Selection**: Analyzes complexity and context to choose optimal combinations
- **Parallel-First**: Identifies and leverages parallelization opportunities
- **Evidence-Based**: Every selection is justified with clear reasoning
- **Best Practices**: Ensures framework compliance and optimal patterns

## Example Output

For the request "I need to add authentication to my web application", the skill generates:

**Prompt**:
```
/implement "user authentication system" --persona-security --persona-backend --seq --c7 --validate --output detailed --testing
```

**Analysis**:
- Domain: Security + Backend (multi-domain)
- Complexity: Complex (security-critical)
- Command: `/implement` (feature creation)
- Personas: Security (primary), Backend (supporting)
- MCP Servers: Sequential (auth flow analysis), Context7 (patterns)
- Flags: `--validate` (risk assessment), `--testing` (validation strategy)

**Why Optimal**:
1. Security-first approach with security persona as primary decision-maker
2. Backend expertise for API and database implementation
3. Context7 provides proven authentication patterns
4. Sequential enables proper auth flow design
5. Validation ensures pre-execution security review
6. Testing flag ensures comprehensive validation strategy

## Technical Details

- **Self-Contained**: All documentation bundled in references/
- **Progressive Disclosure**: Metadata → SKILL.md → bundled resources
- **Framework Compliant**: Follows all SuperClaude principles and patterns
- **Token Efficient**: Uses SuperClaude's token efficiency mode when needed

## Maintenance

To keep this skill up-to-date with the latest SuperClaude framework:

1. Check for updates in global `.claude` documentation:
   - `/Users/arlenagreer/.claude/COMMANDS.md`
   - `/Users/arlenagreer/.claude/FLAGS.md`
   - `/Users/arlenagreer/.claude/PERSONAS.md`
   - `/Users/arlenagreer/.claude/MCP.md`

2. Update `references/superclaude-reference.md` if needed

3. Revise SKILL.md workflow if new patterns emerge

## License

Part of the SuperClaude Framework.

---

**Ready to craft optimal SuperClaude prompts!**
