# Software Engineering Team Configuration

## Team Overview

This team implements a complete software development lifecycle with test-driven development and specification-driven approaches. Each agent specializes in their domain while maintaining seamless collaboration.

## Team Members

- **Product Manager** (`/team:pm`) - Requirements, stakeholder communication, feature prioritization
- **Tech Lead** (`/team:lead`) - Technical direction, system design, team coordination
- **Backend Engineer** (`/team:backend`) - APIs, databases, server-side logic
- **Frontend Engineer** (`/team:frontend`) - UI/UX, client-side development
- **DevOps Engineer** (`/team:devops`) - Infrastructure, CI/CD, deployment
- **QA Engineer** (`/team:qa`) - Test strategy, automation, quality gates
- **Security Engineer** (`/team:security`) - Security audits, compliance, threat modeling
- **Performance Engineer** (`/team:performance`) - Optimization, monitoring, scalability

## Coordination Protocols

### Auto-Handoff Triggers

**Requirements → Design**
- PM completes requirements → Auto-notify Tech Lead
- Keywords: "requirements complete", "stakeholder approval", "ready for design"

**Design → Implementation**
- Tech Lead completes architecture → Auto-notify Backend/Frontend
- Keywords: "architecture approved", "ready for implementation", "design complete"

**Implementation → Testing**
- Engineers complete features → Auto-notify QA
- Keywords: "implementation complete", "ready for testing", "feature done"

**Testing → Deployment**
- QA approves → Auto-notify DevOps
- Keywords: "tests passing", "ready for deployment", "QA approved"

### Shared Context Standards

**All agents maintain:**
- Project context through `.claude/project-context.md`
- Decision log in `.claude/decisions/`
- Test results in `.claude/test-reports/`
- Architecture documentation in `.claude/architecture/`

### Conflict Resolution

1. **Technical Conflicts**: Escalate to Tech Lead
2. **Resource Conflicts**: Escalate to PM
3. **Security Conflicts**: Security Engineer has veto power
4. **Performance Conflicts**: Performance Engineer provides guidance

### Communication Protocols

**Status Updates**: Each agent provides status in standardized format:
```markdown
## [Role] Status Update
- **Current Task**: [description]
- **Progress**: [percentage]
- **Blockers**: [list any blockers]
- **Next Steps**: [immediate next actions]
- **Handoffs**: [who needs what when]
```

**Decision Documentation**: All major decisions logged with:
```markdown
## Decision: [Title]
- **Date**: [YYYY-MM-DD]
- **Participants**: [roles involved]
- **Context**: [why decision needed]
- **Options**: [alternatives considered]
- **Decision**: [what was decided]
- **Rationale**: [why this option]
- **Impact**: [who/what affected]
```

## Tool Usage Standards

### Shared Tool Priorities
1. **Read** before **Write** - Always understand before modifying
2. **Grep** for discovery - Find patterns before implementing
3. **Sequential** for complex analysis - Use for multi-step reasoning
4. **Context7** for frameworks - Leverage official documentation
5. **Magic** for UI components - Use for modern component generation
6. **Playwright** for testing - E2E and performance validation

### Testing Framework Detection
```yaml
JavaScript/TypeScript:
  - Check package.json for existing test framework
  - Priority: Vitest > Jest > Mocha > Jasmine
  - Default: Vitest for new projects

Python:
  - Check requirements.txt/pyproject.toml
  - Priority: pytest > unittest > nose
  - Default: pytest for new projects

Java:
  - Check pom.xml/build.gradle
  - Priority: JUnit 5 > TestNG > JUnit 4
  - Default: JUnit 5 for new projects

C#:
  - Check .csproj files
  - Priority: xUnit > MSTest > NUnit
  - Default: xUnit for new projects

Go:
  - Built-in testing package
  - Additional: Testify, Ginkgo for BDD

Ruby:
  - Check Gemfile
  - Priority: RSpec > Minitest
  - Default: RSpec for new projects
```

## Quality Gates

### Code Quality Standards
- **Test Coverage**: Minimum 80% for critical paths
- **Code Review**: Mandatory for all changes
- **Documentation**: All public APIs documented
- **Security Scan**: Automated security checks on all commits
- **Performance**: No regressions in key metrics

### Definition of Done
- [ ] Requirements clearly defined and approved
- [ ] Architecture designed and documented
- [ ] Tests written before implementation (TDD)
- [ ] Implementation complete and working
- [ ] Code reviewed by appropriate team member
- [ ] All tests passing (unit, integration, E2E)
- [ ] Security scan passed
- [ ] Performance benchmarks met
- [ ] Documentation updated
- [ ] Deployment successful
- [ ] Monitoring and alerting configured

## Emergency Protocols

### Production Issues
1. **Security Engineer** - Immediate escalation for security issues
2. **DevOps Engineer** - Infrastructure and deployment issues
3. **Performance Engineer** - Performance degradation
4. **Tech Lead** - Coordination and decision making
5. **PM** - Stakeholder communication

### Rollback Procedures
1. DevOps executes technical rollback
2. QA validates rollback success
3. Security verifies no security implications
4. PM communicates to stakeholders
5. Tech Lead coordinates post-mortem

## Continuous Improvement

### Learning Integration
- **Retrospectives**: After each major feature/sprint
- **Knowledge Sharing**: Cross-training between roles
- **Best Practices**: Regular updates to team protocols
- **Tool Evolution**: Evaluate and adopt new tools/techniques