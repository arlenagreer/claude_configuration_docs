# Quality Automation System - User Guide v2.0

## Overview

The Quality Automation System is a comprehensive, multi-language code quality tool that works globally across all your projects. It provides automated quality checks, fixes, and enforcement with deep Claude Code integration for iterative improvement.

### Key Features
- **🤖 Claude Code Integration**: Real-time quality feedback during coding sessions
- **🔒 Automatic Git Hooks**: Quality gates on every commit
- **🌍 Multi-Language Support**: Ruby, JavaScript, TypeScript, Python, Go
- **🔄 Iterative Improvement**: Automatic feedback loop for continuous quality
- **⚡ Zero Configuration**: Works out-of-the-box with sensible defaults

## Installation

### Complete Setup (Recommended)

```bash
# 1. Install the quality system
~/.claude/quality/install.sh

# 2. Reload your shell
source ~/.bashrc  # or ~/.zshrc

# 3. Verify installation
quality version
```

## Automatic Quality Checks

The system provides THREE levels of automatic quality checking:

### 1. Claude Code Real-Time Feedback (During Development)

**How it works**: When Claude Code writes or edits files, quality checks run automatically and provide immediate feedback.

**Location**: `~/.claude/hooks/post-write.sh` and `post-edit.sh`

**Behavior**:
```
Claude Code writes file.js
    ↓
Quality checks run automatically
    ↓
Errors shown in Claude Code terminal
    ↓
Claude Code can immediately fix issues
    ↓
Re-checks automatically after fix
```

**Example Claude Code session**:
```javascript
// Claude writes problematic code
const x = 1  // missing semicolon

// Immediately sees:
🔍 Running JavaScript quality checks...
❌ 2 errors found:
  - Missing semicolon
  - Incorrect spacing
💡 Issues found. You can fix with: quality fix file.js

// Claude Code can then fix it automatically
```

### 2. Git Commit Hooks (Pre-Commit Safety)

**How it works**: Quality checks run automatically before every commit, blocking commits with issues.

**Setup** (already configured if you followed installation):
```bash
# This is already done via install.sh, but for reference:
git config --global core.hooksPath ~/.git-hooks
```

**Behavior**:
```bash
$ git commit -m "Add feature"
🔍 Running quality checks...
❌ Quality checks failed. Fix issues or commit with --no-verify
```

**Override when needed**:
```bash
git commit --no-verify -m "Emergency commit, will fix later"
```

### 3. Manual Checks (On-Demand)

Run quality checks anytime:
```bash
quality check              # Check entire project
quality check src/         # Check directory
quality check file.js      # Check specific file
quality fix               # Auto-fix issues
quality fix --dry-run     # Preview fixes
```

## Getting Started

### Initialize a Project

```bash
cd your-project
quality init
```

This will:
- Detect your project type and languages
- Identify available tools
- Create a `.quality.yml` configuration file (optional)

### The Iterative Workflow

1. **Write Code** (Claude Code or manually)
2. **Automatic Check** (via hooks)
3. **See Issues** (immediate feedback)
4. **Auto-Fix** (quality fix or Claude Code fixes)
5. **Verify** (automatic re-check)
6. **Commit** (passes quality gates)

## Configuration

### Zero Configuration Mode

The system works without any configuration:
- Auto-detects languages
- Finds available tools
- Uses sensible defaults

### Optional Project Configuration (.quality.yml)

Only create this if you need custom settings:

```yaml
version: 1.0

# Custom thresholds
thresholds:
  error_count: 0       # No errors allowed
  warning_count: 10    # Up to 10 warnings

# Auto-fix settings
autofix:
  enabled: true
  backup: true
  dry_run: false

# Exclude patterns
exclude:
  - node_modules/
  - vendor/
  - .git/
```

### Global Configuration

Global settings are in `~/.claude/quality/config/`:
- `thresholds.conf` - Default quality thresholds
- `tools.json` - Available tools cache
- `project.json` - Last project detection

## Language Support

### Ruby/Rails
**Tools**: RuboCop, Brakeman, Bundler Audit
```bash
# Ensure tools are installed
gem install rubocop brakeman

# Run Ruby-specific checks
quality check --plugin ruby
```

### JavaScript/TypeScript
**Tools**: ESLint, Prettier, TypeScript Compiler
```bash
# Ensure tools are installed
npm install -g eslint prettier

# Run JavaScript checks
quality check --plugin javascript
```

### Python
**Tools**: Pylint, Flake8, Black, isort, MyPy, Bandit
```bash
# Ensure tools are installed
pip install pylint black flake8

# Run Python checks
quality check --plugin python
```

### Go
**Tools**: golangci-lint, gofmt, go vet
```bash
# Ensure tools are installed
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Run Go checks
quality check --plugin go
```

## Commands Reference

| Command | Description | Options |
|---------|-------------|---------|
| `check [path]` | Run quality checks | `--plugin`, `--verbose` |
| `fix [path]` | Apply automatic fixes | `--dry-run`, `--plugin` |
| `init` | Initialize project | - |
| `detect` | Detect project type | - |
| `gate [path]` | Enforce quality gates | `--strict` |
| `config` | Generate configuration | - |
| `version` | Show version | - |
| `help` | Show help | - |

## Integration Examples

### VS Code Task

Add to `.vscode/tasks.json`:
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Quality Check",
      "type": "shell",
      "command": "quality check",
      "problemMatcher": [],
      "presentation": {
        "reveal": "always"
      }
    }
  ]
}
```

### CI/CD Pipeline

```yaml
# GitHub Actions
- name: Quality Check
  run: |
    quality check --strict || exit 1
```

### Makefile Integration

```makefile
check:
	@quality check

fix:
	@quality fix

lint: check

.PHONY: check fix lint
```

## Troubleshooting

### "Command not found"
```bash
# Ensure PATH is set
export PATH="$PATH:$HOME/.claude/quality/bin"
source ~/.bashrc
```

### "No tools found"
```bash
# Install language-specific tools
gem install rubocop          # Ruby
npm install -g eslint        # JavaScript
pip install pylint           # Python
```

### Claude Code hooks not working
```bash
# Check hooks are executable
chmod +x ~/.claude/hooks/*.sh

# Test manually
~/.claude/hooks/post-write.sh test.js
```

### Disable for specific project
```bash
# Method 1: Skip file
touch .skip-quality

# Method 2: Disable git hooks for repo
cd /path/to/project
git config core.hooksPath ""

# Method 3: Disable Claude Code hooks
export CLAUDE_HOOKS_DISABLED=1
```

### Reset everything
```bash
# Uninstall
quality-uninstall

# Remove all configurations
rm -rf ~/.claude/quality
rm -rf ~/.git-hooks
git config --global --unset core.hooksPath
```

## How It All Works Together

```
┌─────────────────────────────────────────────┐
│           Claude Code Session               │
│                                             │
│  Write/Edit ──> Post-Write Hook ──> Check  │
│      ↑                                ↓     │
│      └──── Fix Issues <──── Feedback ┘     │
└─────────────────────────────────────────────┘
                      ↓
              (Clean code ready)
                      ↓
┌─────────────────────────────────────────────┐
│              Git Commit                     │
│                                             │
│  git commit ──> Pre-Commit Hook ──> Check  │
│      ↑                                ↓     │
│      └──── Block if issues ←─────────┘     │
└─────────────────────────────────────────────┐
```

## Advanced Usage

### Custom Iterations
```bash
# Set max iterations for auto-fixing
MAX_ITERATIONS=5 quality fix

# Custom iteration delay
ITERATION_DELAY=1 quality check
```

### Parallel Checking
```bash
# Check multiple directories
quality check src/ test/ lib/
```

### Force specific tools
```bash
# Ruby only with RuboCop
RUBY_TOOLS="rubocop" quality check

# JavaScript with ESLint only
JS_TOOLS="eslint" quality check
```

## Best Practices

1. **Let Claude Code iterate**: The hooks provide feedback for Claude to improve code automatically
2. **Don't skip quality gates**: Use `--no-verify` sparingly
3. **Keep tools updated**: Regularly update linters and formatters
4. **Customize per project**: Use `.quality.yml` for project-specific rules
5. **Monitor trends**: Check `~/.claude/quality/metrics/` for quality trends

## Version History

- **2.0.0** - Added Claude Code hooks for iterative improvement
- **1.0.0** - Initial release with git hooks and manual commands

## Support

- **Logs**: `~/.claude/quality/logs/`
- **Cache**: `~/.claude/quality/cache/`
- **Debug**: `LOG_LEVEL=0 quality check`

## Quick Reference Card

```bash
# Daily workflow
quality check          # Check current directory
quality fix           # Fix issues
quality gate --strict # Enforce gates

# Claude Code automatically handles:
# - Checking on write/edit
# - Showing feedback
# - Iterating on fixes

# Git automatically handles:
# - Pre-commit checks
# - Blocking bad commits

# Manual override
git commit --no-verify     # Skip checks
CLAUDE_HOOKS_DISABLED=1    # Disable Claude hooks
```

---

**The Quality Automation System provides a complete quality workflow from development through commit, ensuring code quality at every step!**