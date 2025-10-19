# Quality Automation System - User Guide

## Overview

The Quality Automation System is a comprehensive, multi-language code quality tool that works globally across all your projects. It provides automated quality checks, fixes, and enforcement for Ruby, JavaScript/TypeScript, Python, Go, and more.

## Installation

### Quick Install

```bash
~/.claude/quality/install.sh
```

### Manual Installation

1. Ensure the quality system is installed at `~/.claude/quality/`
2. Add to PATH: `export PATH="$PATH:$HOME/.claude/quality/bin"`
3. Reload shell: `source ~/.bashrc` (or `~/.zshrc`)

## Getting Started

### Initialize a Project

```bash
cd your-project
quality init
```

This will:
- Detect your project type and languages
- Identify available tools
- Create a `.quality.yml` configuration file

### Run Quality Checks

```bash
# Check entire project
quality check

# Check specific directory
quality check src/

# Check specific file
quality check src/main.rb
```

### Apply Automatic Fixes

```bash
# Fix issues in current directory
quality fix

# Preview fixes without applying (dry run)
quality fix --dry-run

# Fix specific file
quality fix src/app.js
```

### Enforce Quality Gates

```bash
# Check quality gates (non-blocking)
quality gate

# Enforce strict quality gates (blocking)
quality gate --strict
```

## Configuration

### Project Configuration (.quality.yml)

Create a `.quality.yml` file in your project root:

```yaml
version: 1.0

# Quality gates
gates:
  strict: false
  fail_on_warnings: false

# Custom thresholds
thresholds:
  error_count: 0
  warning_count: 10
  code_coverage: 80
  complexity: 10

# Auto-fix settings
autofix:
  enabled: true
  backup: true
  dry_run: false

# Language-specific settings
languages:
  ruby:
    rubocop_errors: 0
    rubocop_warnings: 20
  javascript:
    eslint_errors: 0
    eslint_warnings: 15
  python:
    pylint_errors: 0
    pylint_warnings: 10

# Exclude patterns
exclude:
  - node_modules/
  - vendor/
  - .git/
  - tmp/
  - log/
```

### Global Configuration

Global configuration is stored in `~/.claude/quality/config/`:

- `thresholds.conf` - Default quality thresholds
- `tools.json` - Available tools detection cache
- `project.json` - Last project detection results

## Language Support

### Ruby/Rails

**Tools**: RuboCop, Brakeman, Bundler Audit, Reek

```bash
# Run Ruby-specific checks
quality check --plugin ruby

# Generate RuboCop config
quality config
```

### JavaScript/TypeScript

**Tools**: ESLint, Prettier, TypeScript Compiler

```bash
# Run JavaScript checks
quality check --plugin javascript

# Auto-fix with ESLint and Prettier
quality fix
```

### Python

**Tools**: Pylint, Flake8, Black, isort, MyPy, Bandit

```bash
# Run Python checks
quality check --plugin python

# Format with Black
quality fix
```

### Go

**Tools**: golangci-lint, gofmt, go vet, gosec

```bash
# Run Go checks
quality check --plugin go

# Format with gofmt
quality fix
```

## Advanced Usage

### Parallel Checking

```bash
# Check multiple directories in parallel
quality check src/ test/ lib/
```

### Custom Thresholds

```bash
# Override thresholds for one run
ERROR_COUNT=5 WARNING_COUNT=20 quality gate
```

### CI/CD Integration

```bash
# In your CI pipeline
quality gate --strict || exit 1
```

### Git Hooks

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
quality check --quiet || exit 1
```

## Commands Reference

| Command | Description | Options |
|---------|-------------|---------|
| `check [path]` | Run quality checks | `--plugin`, `--verbose` |
| `fix [path]` | Apply automatic fixes | `--dry-run`, `--plugin` |
| `init` | Initialize project | - |
| `detect` | Detect project type | - |
| `dashboard` | Launch quality dashboard | - |
| `gate [path]` | Enforce quality gates | `--strict` |
| `config` | Generate configuration | - |
| `test` | Run system tests | - |
| `update` | Check for updates | - |
| `version` | Show version | - |
| `help` | Show help | - |

## Global Options

| Option | Description |
|--------|-------------|
| `--dry-run` | Preview changes without applying |
| `--strict` | Enforce strict quality gates |
| `--verbose` | Enable verbose output |
| `--quiet` | Suppress non-essential output |
| `--no-cache` | Disable caching |
| `--plugin <name>` | Use specific plugin only |

## Troubleshooting

### Common Issues

#### "Command not found"
- Ensure `~/.claude/quality/bin` is in your PATH
- Restart your shell or run `source ~/.bashrc`

#### "No tools found"
- Install language-specific tools:
  - Ruby: `gem install rubocop brakeman`
  - JavaScript: `npm install -g eslint prettier`
  - Python: `pip install pylint black flake8`
  - Go: `go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest`

#### "Plugin not loading"
- Check plugin exists: `ls ~/.claude/quality/plugins/`
- Verify plugin permissions: `chmod +x ~/.claude/quality/plugins/*/plugin.sh`

### Debug Mode

```bash
# Enable debug output
LOG_LEVEL=0 quality check
```

### Reset Cache

```bash
rm -rf ~/.claude/quality/cache/*
```

## Plugin Development

### Creating a Custom Plugin

1. Create plugin directory:
```bash
mkdir ~/.claude/quality/plugins/mylang
```

2. Create `plugin.sh` with required functions:
```bash
#!/bin/bash

plugin_init() {
    # Initialize plugin
    return 0
}

plugin_get_tools() {
    # Return available tools
    echo "tool1 tool2"
}

plugin_get_config() {
    # Return plugin configuration JSON
    echo '{"name": "mylang", "version": "1.0.0"}'
}

plugin_check() {
    # Run quality checks
    local target="$1"
    # ... check logic ...
    return 0
}

plugin_fix() {
    # Apply fixes
    local target="$1"
    # ... fix logic ...
    return 0
}
```

3. Make executable:
```bash
chmod +x ~/.claude/quality/plugins/mylang/plugin.sh
```

## Best Practices

1. **Regular Checks**: Run quality checks before committing code
2. **Incremental Fixes**: Fix issues incrementally rather than all at once
3. **Custom Thresholds**: Adjust thresholds based on project maturity
4. **CI Integration**: Always run quality gates in CI/CD pipelines
5. **Team Standards**: Share `.quality.yml` with your team

## Security Considerations

- Auto-fix operations create backups by default
- Audit logs track all modifications
- Sandboxed execution prevents path traversal
- No sensitive data stored in global config

## Performance Tips

- Use `--plugin` to check specific languages only
- Enable caching for faster subsequent runs
- Exclude large directories (node_modules, vendor)
- Run checks on changed files only in CI

## Contributing

The Quality Automation System is extensible:

1. **Add Languages**: Create new plugins
2. **Add Tools**: Extend existing plugins
3. **Improve Detection**: Enhance project detector
4. **Add Features**: Contribute to core scripts

## Support

- Check logs: `~/.claude/quality/logs/`
- Debug mode: `LOG_LEVEL=0 quality check`
- Configuration: `~/.claude/quality/config/`

## Version History

- **1.0.0** - Initial release with Ruby, JavaScript, Python, Go support

## License

This tool is provided as part of the Claude Code integration.