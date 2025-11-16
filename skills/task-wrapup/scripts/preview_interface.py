#!/usr/bin/env python3
"""
Preview Interface for Task Wrap-Up Skill

Interactive preview and confirmation workflow for work session wrap-up.
Displays proposed content and allows user to confirm, edit, or customize before sending.
"""

import json
import sys
from typing import Dict, List, Any, Optional


def format_summary_preview(summary: Dict[str, Any]) -> str:
    """Format summary for user preview."""
    lines = []
    lines.append("=" * 70)
    lines.append("WORK SESSION SUMMARY PREVIEW")
    lines.append("=" * 70)
    lines.append("")

    # Full summary
    lines.append("Full Summary (Email & Slack):")
    lines.append("-" * 70)
    lines.append(summary["full_summary"])
    lines.append("")

    # Concise summary
    lines.append("Concise Summary (SMS & Worklog):")
    lines.append("-" * 70)
    lines.append(summary["concise_summary"])
    lines.append("")

    # Sources used
    if "sources_used" in summary:
        lines.append(f"Sources: {', '.join(summary['sources_used'])}")
        lines.append("")

    return "\n".join(lines)


def format_distribution_plan(config: Dict[str, Any]) -> str:
    """Format distribution plan for user preview."""
    lines = []
    lines.append("=" * 70)
    lines.append("DISTRIBUTION PLAN")
    lines.append("=" * 70)
    lines.append("")

    comm = config.get("communication", {})

    # Email
    email_config = comm.get("email", {})
    if email_config.get("enabled", False):
        recipients = email_config.get("recipients", [])
        cc = email_config.get("cc", [])

        lines.append("📧 EMAIL:")
        if recipients:
            lines.append(f"   To: {', '.join([f'{r['first_name']} {r['last_name']}' for r in recipients])}")
        if cc:
            lines.append(f"   CC: {', '.join([f'{r['first_name']} {r['last_name']}' for r in cc])}")
        lines.append("")

    # SMS
    sms_config = comm.get("sms", {})
    if sms_config.get("enabled", False):
        recipients = sms_config.get("recipients", [])

        lines.append("💬 SMS (Individual Messages):")
        for recipient in recipients:
            lines.append(f"   - {recipient['first_name']} {recipient['last_name']} ({recipient['phone']})")
        lines.append("")

    # Slack
    slack_config = comm.get("slack", {})
    if slack_config.get("enabled", False):
        channel = slack_config.get("channel", "")
        mention_users = slack_config.get("mention_users", [])

        lines.append("💼 SLACK:")
        lines.append(f"   Channel: #{channel}")
        if mention_users:
            lines.append(f"   Mentions: {', '.join(['@' + u for u in mention_users])}")
        lines.append("")

    # Worklog
    worklog_config = config.get("worklog", {})
    if worklog_config.get("enabled", False):
        lines.append("⏱️  WORKLOG:")
        lines.append("   Log entry will be created")
        if worklog_config.get("prompt_for_duration", True):
            lines.append("   (Duration will be prompted)")
        lines.append("")

    # Documentation
    docs_config = config.get("documentation", {})
    if docs_config.get("enabled", False):
        paths = docs_config.get("paths", [])

        lines.append("📝 DOCUMENTATION:")
        lines.append(f"   Strategy: {docs_config.get('strategy', 'smart_merge')}")
        lines.append(f"   Paths: {', '.join(paths)}")
        lines.append("")

    # Optional actions
    optional = config.get("optional_actions", {})

    if optional.get("calendar", {}).get("enabled", False):
        lines.append("📅 CALENDAR:")
        lines.append("   Event creation enabled")
        lines.append("")

    if optional.get("github", {}).get("enabled", False):
        lines.append("🐙 GITHUB:")
        lines.append("   Issue/PR creation enabled")
        lines.append("")

    return "\n".join(lines)


def format_menu() -> str:
    """Format interactive menu options."""
    lines = []
    lines.append("=" * 70)
    lines.append("OPTIONS")
    lines.append("=" * 70)
    lines.append("")
    lines.append("[1] Send as-is")
    lines.append("[2] Edit summary")
    lines.append("[3] Customize per channel")
    lines.append("[4] Modify distribution")
    lines.append("[5] Cancel")
    lines.append("")
    return "\n".join(lines)


def get_user_choice() -> str:
    """Get user's menu choice."""
    while True:
        choice = input("Choose an option [1-5]: ").strip()
        if choice in ["1", "2", "3", "4", "5"]:
            return choice
        print("Invalid choice. Please enter 1, 2, 3, 4, or 5.")


def edit_summary(summary: Dict[str, Any]) -> Dict[str, Any]:
    """Allow user to edit summary content."""
    print("\n" + "=" * 70)
    print("EDIT SUMMARY")
    print("=" * 70)
    print("\nCurrent full summary:")
    print(summary["full_summary"])
    print("\n[Press Enter to keep current, or type new summary]")

    new_full = input("Full summary: ").strip()
    if new_full:
        summary["full_summary"] = new_full

    print("\nCurrent concise summary:")
    print(summary["concise_summary"])
    print("\n[Press Enter to keep current, or type new summary]")

    new_concise = input("Concise summary: ").strip()
    if new_concise:
        summary["concise_summary"] = new_concise

    return summary


def customize_per_channel(summary: Dict[str, Any]) -> Dict[str, Any]:
    """Allow user to customize content per channel."""
    print("\n" + "=" * 70)
    print("CUSTOMIZE PER CHANNEL")
    print("=" * 70)

    # Email content
    print("\nEmail content:")
    print(summary["full_summary"])
    print("\n[Press Enter to keep current, or type custom email content]")
    email_content = input("Email: ").strip()
    if email_content:
        summary["email_summary"] = email_content
    else:
        summary["email_summary"] = summary["full_summary"]

    # SMS content
    print("\nSMS content:")
    print(summary["concise_summary"])
    print("\n[Press Enter to keep current, or type custom SMS content]")
    sms_content = input("SMS: ").strip()
    if sms_content:
        summary["sms_summary"] = sms_content
    else:
        summary["sms_summary"] = summary["concise_summary"]

    # Slack content
    print("\nSlack content:")
    print(summary["full_summary"])
    print("\n[Press Enter to keep current, or type custom Slack content]")
    slack_content = input("Slack: ").strip()
    if slack_content:
        summary["slack_summary"] = slack_content
    else:
        summary["slack_summary"] = summary["full_summary"]

    # Worklog content
    print("\nWorklog description:")
    print(summary["concise_summary"])
    print("\n[Press Enter to keep current, or type custom worklog description]")
    worklog_content = input("Worklog: ").strip()
    if worklog_content:
        summary["worklog_summary"] = worklog_content
    else:
        summary["worklog_summary"] = summary["concise_summary"]

    return summary


def modify_distribution(config: Dict[str, Any]) -> Dict[str, Any]:
    """Allow user to modify distribution settings."""
    print("\n" + "=" * 70)
    print("MODIFY DISTRIBUTION")
    print("=" * 70)
    print("\nToggle channels (y/n):")

    comm = config.get("communication", {})

    # Email toggle
    email_enabled = comm.get("email", {}).get("enabled", False)
    email_choice = input(f"Email [currently {'ON' if email_enabled else 'OFF'}]: ").strip().lower()
    if email_choice in ["y", "n"]:
        comm["email"]["enabled"] = (email_choice == "y")

    # SMS toggle
    sms_enabled = comm.get("sms", {}).get("enabled", False)
    sms_choice = input(f"SMS [currently {'ON' if sms_enabled else 'OFF'}]: ").strip().lower()
    if sms_choice in ["y", "n"]:
        comm["sms"]["enabled"] = (sms_choice == "y")

    # Slack toggle
    slack_enabled = comm.get("slack", {}).get("enabled", False)
    slack_choice = input(f"Slack [currently {'ON' if slack_enabled else 'OFF'}]: ").strip().lower()
    if slack_choice in ["y", "n"]:
        comm["slack"]["enabled"] = (slack_choice == "y")

    # Worklog toggle
    worklog_enabled = config.get("worklog", {}).get("enabled", False)
    worklog_choice = input(f"Worklog [currently {'ON' if worklog_enabled else 'OFF'}]: ").strip().lower()
    if worklog_choice in ["y", "n"]:
        config["worklog"]["enabled"] = (worklog_choice == "y")

    # Documentation toggle
    docs_enabled = config.get("documentation", {}).get("enabled", False)
    docs_choice = input(f"Documentation [currently {'ON' if docs_enabled else 'OFF'}]: ").strip().lower()
    if docs_choice in ["y", "n"]:
        config["documentation"]["enabled"] = (docs_choice == "y")

    return config


def preview_and_confirm(summary: Dict[str, Any], config: Dict[str, Any]) -> Dict[str, Any]:
    """
    Interactive preview and confirmation workflow.

    Returns a dictionary with:
    - action: "send" | "cancel"
    - summary: potentially modified summary
    - config: potentially modified config
    """
    while True:
        # Display preview
        print("\n" + format_summary_preview(summary))
        print(format_distribution_plan(config))
        print(format_menu())

        # Get user choice
        choice = get_user_choice()

        if choice == "1":
            # Send as-is
            return {
                "action": "send",
                "summary": summary,
                "config": config
            }

        elif choice == "2":
            # Edit summary
            summary = edit_summary(summary)
            # Continue loop to show updated preview

        elif choice == "3":
            # Customize per channel
            summary = customize_per_channel(summary)
            # Continue loop to show updated preview

        elif choice == "4":
            # Modify distribution
            config = modify_distribution(config)
            # Continue loop to show updated preview

        elif choice == "5":
            # Cancel
            return {
                "action": "cancel",
                "summary": summary,
                "config": config
            }


def main():
    """Command-line interface for preview workflow."""
    import argparse

    parser = argparse.ArgumentParser(description="Preview and confirm task wrap-up")
    parser.add_argument("--summary", required=True, help="Path to summary JSON file")
    parser.add_argument("--config", required=True, help="Path to configuration JSON file")

    args = parser.parse_args()

    # Load summary
    try:
        with open(args.summary, 'r') as f:
            summary = json.load(f)
    except Exception as e:
        print(json.dumps({
            "status": "error",
            "code": "SUMMARY_LOAD_ERROR",
            "message": f"Failed to load summary: {e}"
        }), file=sys.stderr)
        sys.exit(1)

    # Load config
    try:
        with open(args.config, 'r') as f:
            config = json.load(f)
    except Exception as e:
        print(json.dumps({
            "status": "error",
            "code": "CONFIG_LOAD_ERROR",
            "message": f"Failed to load config: {e}"
        }), file=sys.stderr)
        sys.exit(1)

    # Run preview workflow
    result = preview_and_confirm(summary, config)

    # Output result
    print(json.dumps({
        "status": "success",
        "result": result
    }))


if __name__ == "__main__":
    main()
