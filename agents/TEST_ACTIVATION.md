# Team Agent Activation Test Guide

This document demonstrates how the software engineering team agents are activated and coordinated.

## Activation Methods

### 1. Direct Team Member Commands
Use slash commands to activate specific team members:

```bash
/team:pm requirements          # Product Manager gathers requirements
/team:lead architecture        # Tech Lead designs system architecture  
/team:backend api             # Backend Engineer implements API
/team:frontend component      # Frontend Engineer builds UI component
/team:qa test                # QA Engineer executes testing
/team:security audit         # Security Engineer performs audit
/team:performance optimize   # Performance Engineer optimizes system
/team:devops deploy          # DevOps Engineer handles deployment
```

### 2. Team Coordination Command
Use the main team command for coordination:

```bash
/team standup               # Daily team coordination
/team planning             # Sprint planning session
/team retrospective        # Team improvement discussion
```

### 3. Auto-Activation Based on Keywords
The system automatically activates team members based on task context:

- "gather requirements" → PM agent activation
- "design system architecture" → Tech Lead agent
- "implement API endpoint" → Backend agent
- "build user interface" → Frontend agent
- "setup deployment pipeline" → DevOps agent
- "validate quality" → QA agent
- "security review" → Security agent
- "performance analysis" → Performance agent

### 4. Workflow-Based Activation
Team members activate in sequence based on development workflow:

1. **Requirements Phase**: PM agent activates automatically
2. **Design Phase**: Tech Lead agent takes over from PM
3. **Implementation Phase**: Backend/Frontend agents activate
4. **Testing Phase**: QA agent validates implementation
5. **Deployment Phase**: DevOps agent handles deployment
6. **Review Phase**: Security/Performance agents as needed

## Example Workflows

### Feature Development Flow
```
1. /team:pm requirements "user authentication feature"
   - PM gathers requirements, creates specifications
   - Handoff → Tech Lead

2. /team:lead architecture
   - Tech Lead designs system architecture
   - Handoff → Backend & Frontend

3. /team:backend api
   - Backend implements authentication API
   - Handoff → Frontend

4. /team:frontend component
   - Frontend builds login UI
   - Handoff → QA

5. /team:qa test
   - QA validates implementation
   - Handoff → DevOps

6. /team:devops deploy
   - DevOps deploys to production
```

### Cross-Team Collaboration
```
/team standup
- All team agents provide status updates
- Identify blockers and dependencies
- Coordinate next steps

/team:security audit
- Security reviews all team implementations
- Provides security requirements to all teams
- Has veto power on security issues
```

## Integration with SuperClaude

### Persona Activation
When team agents activate, they automatically:
- Load their specific persona (e.g., backend agent → backend persona)
- Apply domain-specific decision frameworks
- Use appropriate MCP servers and tools
- Follow team workflows (TDD, spec-driven)

### Tool Orchestration
Each team member uses specialized tools:
- **PM**: Context7 (research), Write (documentation)
- **Tech Lead**: Sequential (analysis), Context7 (patterns)
- **Backend**: Context7 (frameworks), Sequential (logic)
- **Frontend**: Magic (UI), Playwright (testing)
- **DevOps**: Context7 (platforms), Bash (automation)
- **QA**: Playwright (testing), Sequential (analysis)
- **Security**: Sequential (threats), Context7 (standards)
- **Performance**: Playwright (testing), Sequential (analysis)

### Handoff Protocols
Automatic handoffs trigger when:
- Requirements complete → Tech Lead activation
- Architecture approved → Engineering activation
- Implementation done → QA activation
- Testing complete → DevOps activation

## Testing Team Activation

To test the team agent system:

1. **Test Direct Activation**:
   ```
   /team:pm requirements
   ```
   Should load PM agent context and activate scribe persona

2. **Test Auto-Activation**:
   ```
   I need to gather requirements for a new feature
   ```
   Should automatically activate PM agent

3. **Test Handoff**:
   ```
   /team:pm requirements
   [Complete requirements]
   Requirements are complete and approved
   ```
   Should trigger handoff to Tech Lead

4. **Test Team Coordination**:
   ```
   /team standup
   ```
   Should coordinate all team members

## Verification

The team agent system is working correctly when:
- ✅ Team commands load agent-specific contexts
- ✅ Appropriate personas activate automatically
- ✅ Handoffs trigger at workflow boundaries
- ✅ Team members use their specialized tools
- ✅ Coordination maintains shared context