#!/usr/bin/env python3
"""
Configuration Manager for Task Wrap-Up Skill

Handles CRUD operations for .task_wrapup_skill_data.json configuration files
with automatic schema migration and validation.
"""

import json
import os
import sys
from datetime import datetime
from typing import Dict, Any, Optional, List


# Current schema version
SCHEMA_VERSION = "1.0"

# Default configuration template
DEFAULT_CONFIG = {
    "schema_version": SCHEMA_VERSION,
    "project_name": "",
    "created_at": "",
    "last_updated": "",

    "summary_generation": {
        "strategy": "hybrid",
        "sources": {
            "git_commits": True,
            "todo_tasks": True,
            "serena_memory": True,
            "file_changes": True
        },
        "intelligence": {
            "extract_key_decisions": True,
            "identify_blockers": True,
            "highlight_risks": True,
            "include_metrics": False
        }
    },

    "communication": {
        "email": {
            "enabled": True,
            "recipients": [],
            "cc": [],
            "template": "professional",
            "include_attachments": False
        },
        "sms": {
            "enabled": True,
            "recipients": [],
            "max_length": 320,
            "critical_only": False
        },
        "slack": {
            "enabled": False,
            "channel": "",
            "mention_users": [],
            "thread_mode": "new_message"
        }
    },

    "worklog": {
        "enabled": True,
        "prompt_for_duration": True,
        "default_duration_minutes": None,
        "round_to_nearest": 15,
        "date_handling": {
            "prompt_for_date": False,
            "default": "today",
            "timezone": "America/New_York"
        }
    },

    "documentation": {
        "enabled": True,
        "auto_update": True,
        "paths": ["README.md"],
        "strategy": "smart_merge",
        "commit_changes": False
    },

    "pull_request": {
        "enabled": True,
        "default_parent_branch": "develop",
        "auto_checkout_parent": True,
        "cleanup_session_state": True,
        "draft": False,
        "title_template": None,
        "body_template": None
    },

    "optional_actions": {
        "calendar": {
            "enabled": False,
            "prompt_by_default": False
        },
        "github": {
            "enabled": False,
            "prompt_by_default": False
        }
    },

    "execution": {
        "preview_before_send": True,
        "parallel_execution": True,
        "max_retries": 3,
        "retry_delay_seconds": 5
    }
}


def get_config_path(directory: str = ".") -> str:
    """Get the path to the configuration file in the specified directory."""
    return os.path.join(directory, ".task_wrapup_skill_data.json")


def config_exists(directory: str = ".") -> bool:
    """Check if configuration file exists in the specified directory."""
    return os.path.exists(get_config_path(directory))


def load_config(directory: str = ".") -> Optional[Dict[str, Any]]:
    """Load configuration from file, with automatic migration if needed."""
    config_path = get_config_path(directory)

    if not os.path.exists(config_path):
        return None

    try:
        with open(config_path, 'r') as f:
            config = json.load(f)

        # Check if migration is needed
        current_version = config.get("schema_version", "0.0")
        if current_version != SCHEMA_VERSION:
            config = migrate_config(config, current_version)
            save_config(config, directory)

        return config

    except json.JSONDecodeError as e:
        print(json.dumps({
            "status": "error",
            "code": "INVALID_JSON",
            "message": f"Configuration file is not valid JSON: {e}"
        }), file=sys.stderr)
        return None
    except Exception as e:
        print(json.dumps({
            "status": "error",
            "code": "LOAD_ERROR",
            "message": f"Error loading configuration: {e}"
        }), file=sys.stderr)
        return None


def migrate_config(old_config: Dict[str, Any], from_version: str) -> Dict[str, Any]:
    """Migrate configuration from old schema version to current version."""
    # Start with default config and overlay old values
    new_config = DEFAULT_CONFIG.copy()

    # Deep merge old config into new config, preserving user data
    def deep_merge(base: Dict, overlay: Dict) -> Dict:
        """Recursively merge overlay into base, preserving overlay values."""
        result = base.copy()
        for key, value in overlay.items():
            if key in result and isinstance(result[key], dict) and isinstance(value, dict):
                result[key] = deep_merge(result[key], value)
            else:
                result[key] = value
        return result

    new_config = deep_merge(new_config, old_config)
    new_config["schema_version"] = SCHEMA_VERSION
    new_config["last_updated"] = datetime.now().isoformat()

    return new_config


def save_config(config: Dict[str, Any], directory: str = ".") -> bool:
    """Save configuration to file."""
    config_path = get_config_path(directory)

    try:
        # Update timestamp
        config["last_updated"] = datetime.now().isoformat()

        with open(config_path, 'w') as f:
            json.dump(config, f, indent=2)

        return True

    except Exception as e:
        print(json.dumps({
            "status": "error",
            "code": "SAVE_ERROR",
            "message": f"Error saving configuration: {e}"
        }), file=sys.stderr)
        return False


def create_config(project_name: str, directory: str = ".") -> Dict[str, Any]:
    """Create a new configuration file with user input."""
    config = DEFAULT_CONFIG.copy()
    config["project_name"] = project_name
    config["created_at"] = datetime.now().isoformat()
    config["last_updated"] = datetime.now().isoformat()

    save_config(config, directory)
    return config


def validate_config(config: Dict[str, Any]) -> tuple[bool, List[str]]:
    """Validate configuration structure and values."""
    errors = []

    # Check required fields
    if not config.get("project_name"):
        errors.append("Project name is required")

    # Validate email recipients
    if config["communication"]["email"]["enabled"]:
        email_recipients = config["communication"]["email"]["recipients"]
        if not email_recipients:
            errors.append("Email is enabled but no recipients specified")
        for recipient in email_recipients:
            if not all(k in recipient for k in ["first_name", "last_name", "email"]):
                errors.append(f"Invalid email recipient format: {recipient}")

    # Validate SMS recipients
    if config["communication"]["sms"]["enabled"]:
        sms_recipients = config["communication"]["sms"]["recipients"]
        if not sms_recipients:
            errors.append("SMS is enabled but no recipients specified")
        for recipient in sms_recipients:
            if not all(k in recipient for k in ["first_name", "last_name", "phone"]):
                errors.append(f"Invalid SMS recipient format: {recipient}")

    # Validate Slack channel
    if config["communication"]["slack"]["enabled"]:
        if not config["communication"]["slack"]["channel"]:
            errors.append("Slack is enabled but no channel specified")

    # Validate pull_request configuration
    if "pull_request" in config:
        pr_config = config["pull_request"]

        # Validate enabled field
        if not isinstance(pr_config.get("enabled"), bool):
            errors.append("pull_request.enabled must be a boolean")

        # Validate default_parent_branch
        if not isinstance(pr_config.get("default_parent_branch"), str):
            errors.append("pull_request.default_parent_branch must be a string")
        elif not pr_config.get("default_parent_branch"):
            errors.append("pull_request.default_parent_branch cannot be empty")

        # Validate auto_checkout_parent
        if not isinstance(pr_config.get("auto_checkout_parent"), bool):
            errors.append("pull_request.auto_checkout_parent must be a boolean")

        # Validate cleanup_session_state
        if not isinstance(pr_config.get("cleanup_session_state"), bool):
            errors.append("pull_request.cleanup_session_state must be a boolean")

        # Validate draft
        if not isinstance(pr_config.get("draft"), bool):
            errors.append("pull_request.draft must be a boolean")

        # Validate title_template (string or None)
        title_template = pr_config.get("title_template")
        if title_template is not None and not isinstance(title_template, str):
            errors.append("pull_request.title_template must be a string or null")

        # Validate body_template (string or None)
        body_template = pr_config.get("body_template")
        if body_template is not None and not isinstance(body_template, str):
            errors.append("pull_request.body_template must be a string or null")

    return len(errors) == 0, errors


def add_recipient(config: Dict[str, Any], recipient_type: str,
                  first_name: str, last_name: str, contact_info: str) -> Dict[str, Any]:
    """Add a recipient to email or SMS lists."""
    recipient = {
        "first_name": first_name,
        "last_name": last_name
    }

    if recipient_type == "email":
        recipient["email"] = contact_info
        config["communication"]["email"]["recipients"].append(recipient)
    elif recipient_type == "sms":
        recipient["phone"] = contact_info
        config["communication"]["sms"]["recipients"].append(recipient)
    else:
        raise ValueError(f"Invalid recipient type: {recipient_type}")

    return config


def remove_recipient(config: Dict[str, Any], recipient_type: str, index: int) -> Dict[str, Any]:
    """Remove a recipient from email or SMS lists by index."""
    if recipient_type == "email":
        config["communication"]["email"]["recipients"].pop(index)
    elif recipient_type == "sms":
        config["communication"]["sms"]["recipients"].pop(index)
    else:
        raise ValueError(f"Invalid recipient type: {recipient_type}")

    return config


def main():
    """Command-line interface for configuration management."""
    import argparse

    parser = argparse.ArgumentParser(description="Manage task-wrapup configuration")
    parser.add_argument("action", choices=["create", "show", "validate", "add-recipient", "remove-recipient"],
                       help="Action to perform")
    parser.add_argument("--directory", default=".", help="Directory containing config file")
    parser.add_argument("--project-name", help="Project name (for create)")
    parser.add_argument("--type", choices=["email", "sms"], help="Recipient type")
    parser.add_argument("--first-name", help="Recipient first name")
    parser.add_argument("--last-name", help="Recipient last name")
    parser.add_argument("--contact", help="Email address or phone number")
    parser.add_argument("--index", type=int, help="Recipient index (for remove)")

    args = parser.parse_args()

    if args.action == "create":
        if not args.project_name:
            print(json.dumps({
                "status": "error",
                "code": "MISSING_PROJECT_NAME",
                "message": "Project name is required for create action"
            }))
            sys.exit(1)

        config = create_config(args.project_name, args.directory)
        print(json.dumps({
            "status": "success",
            "message": "Configuration created",
            "config": config
        }))

    elif args.action == "show":
        config = load_config(args.directory)
        if config is None:
            print(json.dumps({
                "status": "error",
                "code": "NO_CONFIG",
                "message": "No configuration file found"
            }))
            sys.exit(1)

        print(json.dumps({
            "status": "success",
            "config": config
        }))

    elif args.action == "validate":
        config = load_config(args.directory)
        if config is None:
            print(json.dumps({
                "status": "error",
                "code": "NO_CONFIG",
                "message": "No configuration file found"
            }))
            sys.exit(1)

        valid, errors = validate_config(config)
        print(json.dumps({
            "status": "success" if valid else "error",
            "valid": valid,
            "errors": errors
        }))

    elif args.action == "add-recipient":
        if not all([args.type, args.first_name, args.last_name, args.contact]):
            print(json.dumps({
                "status": "error",
                "code": "MISSING_ARGUMENTS",
                "message": "type, first-name, last-name, and contact are required"
            }))
            sys.exit(1)

        config = load_config(args.directory)
        if config is None:
            print(json.dumps({
                "status": "error",
                "code": "NO_CONFIG",
                "message": "No configuration file found"
            }))
            sys.exit(1)

        config = add_recipient(config, args.type, args.first_name, args.last_name, args.contact)
        save_config(config, args.directory)

        print(json.dumps({
            "status": "success",
            "message": f"Added {args.type} recipient: {args.first_name} {args.last_name}"
        }))

    elif args.action == "remove-recipient":
        if not all([args.type, args.index is not None]):
            print(json.dumps({
                "status": "error",
                "code": "MISSING_ARGUMENTS",
                "message": "type and index are required"
            }))
            sys.exit(1)

        config = load_config(args.directory)
        if config is None:
            print(json.dumps({
                "status": "error",
                "code": "NO_CONFIG",
                "message": "No configuration file found"
            }))
            sys.exit(1)

        config = remove_recipient(config, args.type, args.index)
        save_config(config, args.directory)

        print(json.dumps({
            "status": "success",
            "message": f"Removed {args.type} recipient at index {args.index}"
        }))


if __name__ == "__main__":
    main()
