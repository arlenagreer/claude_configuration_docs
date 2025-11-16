#!/usr/bin/env python3
"""
Configuration manager for task-start skill.
Shares configuration file with task-wrapup skill (.task_wrapup_skill_data.json).
"""

import json
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, Optional

CONFIG_FILENAME = ".task_wrapup_skill_data.json"
SCHEMA_VERSION = "1.0"

class ConfigManager:
    """Manages shared configuration file for task-start and task-wrapup skills."""

    def __init__(self, project_dir: str = "."):
        self.project_dir = Path(project_dir).resolve()
        self.config_path = self.project_dir / CONFIG_FILENAME

    def exists(self) -> bool:
        """Check if config file exists."""
        return self.config_path.exists()

    def load(self) -> Dict[str, Any]:
        """Load configuration from file."""
        if not self.exists():
            raise FileNotFoundError(f"Config file not found: {self.config_path}")

        with open(self.config_path, 'r') as f:
            return json.load(f)

    def save(self, config: Dict[str, Any]) -> None:
        """Save configuration to file."""
        config['last_updated'] = datetime.now().isoformat()

        with open(self.config_path, 'w') as f:
            json.dump(config, f, indent=2)

    def create_default(self, project_name: str, **kwargs) -> Dict[str, Any]:
        """Create default configuration structure."""
        now = datetime.now().isoformat()

        config = {
            "schema_version": SCHEMA_VERSION,
            "project_name": project_name,
            "created_at": now,
            "last_updated": now,

            # Task-start specific configuration
            "task_start": {
                "default_base_branch": "develop",
                "protected_branches": ["main", "master", "production"],
                "branch_naming": {
                    "prefix": "feature",
                    "include_issue_number": True,
                    "max_length": 50
                },
                "github": {
                    "enabled": True,
                    "default_behavior": "fetch_highest_priority",
                    "labels_priority_order": ["urgent", "high", "medium", "low"]
                },
                "environment": {
                    "docker": {
                        "enabled": True,
                        "auto_start": True,
                        "health_check_url": "http://localhost:3000/health",
                        "services": ["backend", "frontend", "db"]
                    },
                    "database": {
                        "check_migrations": True,
                        "auto_migrate": True
                    },
                    "dependencies": {
                        "check_updates": True,
                        "package_managers": ["npm", "bundler"]
                    },
                    "env_files": {
                        "required": [".env", ".env.development"],
                        "critical_vars": ["DATABASE_URL", "SECRET_KEY_BASE"]
                    }
                },
                "logging": {
                    "session_logs_dir": ".claude/sessions",
                    "track_start_time": True,
                    "create_session_file": False
                },
                "integrations": {
                    "frontend_debug_skill": True,
                    "invoke_on_github_issue": True
                }
            },

            # Shared configuration (used by task-wrapup)
            "summary_generation": kwargs.get("summary_generation", {
                "strategy": "hybrid",
                "sources": {
                    "git_commits": True,
                    "todo_tasks": True,
                    "serena_memory": True,
                    "file_changes": True
                }
            }),

            "communication": kwargs.get("communication", {
                "email": {"enabled": False, "recipients": []},
                "sms": {"enabled": False, "recipients": []},
                "slack": {"enabled": False, "channel": ""}
            }),

            "worklog": kwargs.get("worklog", {
                "enabled": False,
                "prompt_for_duration": True
            }),

            "documentation": kwargs.get("documentation", {
                "enabled": True,
                "auto_update": True,
                "paths": ["README.md", "CHANGELOG.md"]
            })
        }

        return config

    def prompt_for_config(self) -> Dict[str, Any]:
        """Interactive configuration creation."""
        print("📋 Task-Start Configuration Setup")
        print("=" * 50)

        # Project name
        project_name = input("Project name: ").strip()
        if not project_name:
            print("❌ Project name is required")
            sys.exit(1)

        # Base branch
        base_branch = input("Default base branch [develop]: ").strip() or "develop"

        # Docker configuration
        docker_enabled = input("Is this a dockerized project? [Y/n]: ").strip().lower() != 'n'

        docker_config = {}
        if docker_enabled:
            docker_config = {
                "enabled": True,
                "auto_start": input("Auto-start Docker services? [Y/n]: ").strip().lower() != 'n',
                "health_check_url": input("Health check URL [http://localhost:3000/health]: ").strip() or "http://localhost:3000/health",
                "services": input("Docker services (comma-separated) [backend,frontend,db]: ").strip().split(',') or ["backend", "frontend", "db"]
            }
        else:
            docker_config = {"enabled": False}

        # GitHub integration
        github_enabled = input("Enable GitHub integration? [Y/n]: ").strip().lower() != 'n'

        # Create config
        config = self.create_default(project_name)
        config["task_start"]["default_base_branch"] = base_branch
        config["task_start"]["environment"]["docker"] = docker_config
        config["task_start"]["github"]["enabled"] = github_enabled

        return config

    def validate(self, config: Dict[str, Any]) -> tuple[bool, list[str]]:
        """Validate configuration structure."""
        errors = []

        # Check required top-level fields
        required_fields = ["schema_version", "project_name", "created_at"]
        for field in required_fields:
            if field not in config:
                errors.append(f"Missing required field: {field}")

        # Check task_start section
        if "task_start" not in config:
            errors.append("Missing task_start configuration section")
        else:
            task_start = config["task_start"]

            # Check required task_start fields
            if "default_base_branch" not in task_start:
                errors.append("Missing task_start.default_base_branch")

            if "environment" not in task_start:
                errors.append("Missing task_start.environment section")

        return len(errors) == 0, errors


def main():
    """CLI interface for configuration management."""
    import argparse

    parser = argparse.ArgumentParser(description="Manage task-start configuration")
    parser.add_argument("command", choices=["create", "show", "validate", "path"],
                       help="Command to execute")
    parser.add_argument("--directory", default=".", help="Project directory")
    parser.add_argument("--project-name", help="Project name (for create)")

    args = parser.parse_args()

    manager = ConfigManager(args.directory)

    if args.command == "create":
        if manager.exists():
            print(f"⚠️  Config file already exists: {manager.config_path}")
            overwrite = input("Overwrite? [y/N]: ").strip().lower() == 'y'
            if not overwrite:
                print("❌ Cancelled")
                sys.exit(0)

        if args.project_name:
            config = manager.create_default(args.project_name)
        else:
            config = manager.prompt_for_config()

        manager.save(config)
        print(f"✅ Configuration created: {manager.config_path}")

    elif args.command == "show":
        if not manager.exists():
            print(f"❌ Config file not found: {manager.config_path}")
            sys.exit(1)

        config = manager.load()
        print(json.dumps(config, indent=2))

    elif args.command == "validate":
        if not manager.exists():
            print(f"❌ Config file not found: {manager.config_path}")
            sys.exit(1)

        config = manager.load()
        valid, errors = manager.validate(config)

        if valid:
            print("✅ Configuration is valid")
        else:
            print("❌ Configuration validation failed:")
            for error in errors:
                print(f"  - {error}")
            sys.exit(1)

    elif args.command == "path":
        print(manager.config_path)


if __name__ == "__main__":
    main()
