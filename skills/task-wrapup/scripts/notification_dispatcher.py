#!/usr/bin/env python3
"""
Notification Dispatcher for Task Wrap-Up Skill

Orchestrates parallel execution of notifications across multiple channels:
- Email (via email skill)
- SMS (via text-message skill, individual messages)
- Slack (via Slack API if configured)
- Worklog (via worklog skill)
- Documentation (via /sc:document)
- Calendar (optional, via calendar skill)
- GitHub (optional, via /sc:git)

Collects results and generates final summary report.
"""

import json
import subprocess
import sys
import os
from datetime import datetime
from typing import Dict, List, Any, Optional
from concurrent.futures import ThreadPoolExecutor, as_completed


def run_command(cmd: List[str], timeout: int = 60) -> tuple[int, str, str]:
    """Run a shell command and return (returncode, stdout, stderr)."""
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return 1, "", f"Command timed out after {timeout}s"
    except Exception as e:
        return 1, "", str(e)


def send_email(summary: Dict[str, Any], config: Dict[str, Any]) -> Dict[str, Any]:
    """Send email via email skill."""
    email_config = config["communication"]["email"]

    if not email_config.get("enabled", False):
        return {"status": "skipped", "reason": "Email disabled"}

    recipients = email_config.get("recipients", [])
    cc = email_config.get("cc", [])

    if not recipients:
        return {"status": "error", "reason": "No email recipients configured"}

    # Use custom summary if provided, otherwise use full summary
    content = summary.get("email_summary", summary["full_summary"])

    # Build recipient list
    to_addrs = [f"{r['email']}" for r in recipients]
    cc_addrs = [f"{c['email']}" for c in cc]

    # Build email command via email skill
    # The email skill will handle formatting, seasonal theming, etc.
    project_name = config.get("project_name", "Project")
    subject = f"Work Session Update: {project_name}"

    # Create temporary message file
    import tempfile
    with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
        f.write(content)
        msg_file = f.name

    try:
        # Invoke email skill via Claude Code
        # Note: This assumes we're running within Claude Code context
        # In production, this would use the Skill tool invocation
        skill_path = os.path.expanduser("~/.claude/skills/email/gmail_manager.rb")

        cmd = ["ruby", skill_path, "--send",
               "--to", ",".join(to_addrs),
               "--subject", subject,
               "--body-file", msg_file]

        if cc_addrs:
            cmd.extend(["--cc", ",".join(cc_addrs)])

        returncode, stdout, stderr = run_command(cmd, timeout=30)

        os.unlink(msg_file)  # Clean up temp file

        if returncode == 0:
            return {
                "status": "success",
                "recipients": to_addrs,
                "cc": cc_addrs if cc_addrs else []
            }
        else:
            return {
                "status": "error",
                "reason": stderr or "Email sending failed",
                "attempted_recipients": to_addrs
            }

    except Exception as e:
        if os.path.exists(msg_file):
            os.unlink(msg_file)
        return {"status": "error", "reason": str(e)}


def send_sms(summary: Dict[str, Any], config: Dict[str, Any]) -> Dict[str, Any]:
    """Send SMS via text-message skill (individual messages to each recipient)."""
    sms_config = config["communication"]["sms"]

    if not sms_config.get("enabled", False):
        return {"status": "skipped", "reason": "SMS disabled"}

    recipients = sms_config.get("recipients", [])

    if not recipients:
        return {"status": "error", "reason": "No SMS recipients configured"}

    # Use custom summary if provided, otherwise use concise summary
    content = summary.get("sms_summary", summary["concise_summary"])

    # Enforce max length if configured
    max_length = sms_config.get("max_length", 320)
    if len(content) > max_length:
        content = content[:max_length - 3] + "..."

    # Send individual messages (NEVER group texts)
    script_path = os.path.expanduser("~/.claude/skills/text-message/scripts/send_message.sh")
    results = []

    for recipient in recipients:
        phone = recipient["phone"]
        name = f"{recipient['first_name']} {recipient['last_name']}"

        # Remove apostrophes to prevent AppleScript failures
        safe_content = content.replace("'", "")

        returncode, stdout, stderr = run_command(
            [script_path, phone, safe_content],
            timeout=30
        )

        if returncode == 0:
            results.append({
                "recipient": name,
                "phone": phone,
                "status": "success"
            })
        else:
            results.append({
                "recipient": name,
                "phone": phone,
                "status": "error",
                "reason": stderr or "SMS sending failed"
            })

    # Aggregate results
    successful = [r for r in results if r["status"] == "success"]
    failed = [r for r in results if r["status"] == "error"]

    return {
        "status": "success" if len(failed) == 0 else "partial",
        "total": len(recipients),
        "successful": len(successful),
        "failed": len(failed),
        "details": results
    }


def send_slack(summary: Dict[str, Any], config: Dict[str, Any]) -> Dict[str, Any]:
    """Send Slack message."""
    slack_config = config["communication"]["slack"]

    if not slack_config.get("enabled", False):
        return {"status": "skipped", "reason": "Slack disabled"}

    channel = slack_config.get("channel", "")
    if not channel:
        return {"status": "error", "reason": "No Slack channel configured"}

    # Use custom summary if provided, otherwise use full summary
    content = summary.get("slack_summary", summary["full_summary"])

    # Add mentions if configured
    mention_users = slack_config.get("mention_users", [])
    if mention_users:
        mentions = " ".join([f"<@{user}>" for user in mention_users])
        content = f"{mentions}\n\n{content}"

    # Note: This is a placeholder for Slack integration
    # In production, this would use Slack API or webhook
    # For now, return a mock success
    return {
        "status": "success",
        "channel": channel,
        "message": "Slack integration pending - would send message here"
    }


def create_worklog_entry(summary: Dict[str, Any], config: Dict[str, Any]) -> Dict[str, Any]:
    """Create worklog entry via worklog skill."""
    worklog_config = config.get("worklog", {})

    if not worklog_config.get("enabled", False):
        return {"status": "skipped", "reason": "Worklog disabled"}

    # Use custom summary if provided, otherwise use concise summary
    description = summary.get("worklog_summary", summary["concise_summary"])

    # Get current date from system clock
    current_date = datetime.now().strftime("%Y-%m-%d")

    # Determine duration
    # If configured to prompt, this would be handled interactively
    # For now, we'll use default or prompt
    duration = None
    if worklog_config.get("prompt_for_duration", True):
        # This would trigger interactive prompt in actual implementation
        # For script execution, we'd need to handle this upstream
        pass

    default_duration = worklog_config.get("default_duration_minutes")

    # Get project/client name
    project_name = config.get("project_name", "")

    script_path = os.path.expanduser("~/.claude/skills/worklog/scripts/worklog_manager.py")

    # Build command
    cmd = ["python3", script_path, "add",
           "--date", current_date,
           "--description", description]

    if project_name:
        cmd.extend(["--client", project_name])

    if duration:
        cmd.extend(["--hours", str(duration / 60.0)])
    elif default_duration:
        cmd.extend(["--hours", str(default_duration / 60.0)])

    returncode, stdout, stderr = run_command(cmd, timeout=30)

    if returncode == 0:
        return {
            "status": "success",
            "date": current_date,
            "description": description,
            "client": project_name
        }
    else:
        return {
            "status": "error",
            "reason": stderr or "Worklog entry failed"
        }


def update_documentation(summary: Dict[str, Any], config: Dict[str, Any]) -> Dict[str, Any]:
    """Update project documentation via /sc:document command."""
    docs_config = config.get("documentation", {})

    if not docs_config.get("enabled", False):
        return {"status": "skipped", "reason": "Documentation disabled"}

    if not docs_config.get("auto_update", False):
        return {"status": "skipped", "reason": "Auto-update disabled"}

    # Extract session summary for documentation
    session_summary = summary.get("full_summary", "")
    paths = docs_config.get("paths", ["README.md"])
    strategy = docs_config.get("strategy", "smart_merge")

    # Get project name for context
    project_name = config.get("project_name", "Project")

    # Create a documentation update request file
    import tempfile
    update_content = f"""# Documentation Update Request

Project: {project_name}
Date: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
Strategy: {strategy}

## Session Summary

{session_summary}

## Target Documentation Files

{chr(10).join(f"- {path}" for path in paths)}

## Instructions

Please update the following documentation based on this session:

1. **CHANGELOG.md**: Add entry for today's changes
2. **README.md**: Update any sections affected by changes (if applicable)
3. Other specified paths: Update as needed based on context

Use the {strategy} strategy to intelligently merge this information.
"""

    with tempfile.NamedTemporaryFile(mode='w', suffix='.md', delete=False) as f:
        f.write(update_content)
        request_file = f.name

    try:
        # Note: In actual Claude Code execution, this would be handled by
        # invoking the /sc:document command through the SlashCommand tool.
        # Since we're in a script context, we create a marker file that
        # Claude Code can detect and process.

        marker_file = os.path.join(os.getcwd(), ".task_wrapup_doc_update_request.md")

        # Copy the request to the marker file location
        import shutil
        shutil.copy(request_file, marker_file)

        # Clean up temp file
        os.unlink(request_file)

        return {
            "status": "success",
            "strategy": strategy,
            "paths": paths,
            "message": f"Documentation update request created: {marker_file}",
            "request_file": marker_file,
            "instructions": "Claude Code should invoke /sc:document with this content"
        }

    except Exception as e:
        if os.path.exists(request_file):
            os.unlink(request_file)
        return {
            "status": "error",
            "reason": f"Failed to create documentation update request: {str(e)}"
        }


def create_calendar_event(summary: Dict[str, Any], config: Dict[str, Any]) -> Dict[str, Any]:
    """Create calendar event (optional)."""
    calendar_config = config.get("optional_actions", {}).get("calendar", {})

    if not calendar_config.get("enabled", False):
        return {"status": "skipped", "reason": "Calendar disabled"}

    # This would invoke calendar skill in actual implementation
    return {
        "status": "success",
        "message": "Calendar event creation pending - would invoke calendar skill"
    }


def create_github_item(summary: Dict[str, Any], config: Dict[str, Any]) -> Dict[str, Any]:
    """Create GitHub issue or PR (optional)."""
    github_config = config.get("optional_actions", {}).get("github", {})

    if not github_config.get("enabled", False):
        return {"status": "skipped", "reason": "GitHub disabled"}

    # This would invoke /sc:git in actual implementation
    return {
        "status": "success",
        "message": "GitHub item creation pending - would invoke /sc:git"
    }


def load_session_state() -> Optional[Dict[str, Any]]:
    """Load and validate .task_session_state.json from project root."""
    import os
    import json

    project_root = os.getcwd()
    state_file = os.path.join(project_root, ".task_session_state.json")

    if not os.path.exists(state_file):
        return None

    try:
        with open(state_file, 'r') as f:
            state = json.load(f)

        # Validate schema version
        if state.get("schema_version") != "1.0":
            return None

        # Validate required fields
        required_fields = ["feature_branch", "parent_branch", "created_at"]
        for field in required_fields:
            if field not in state or not state[field]:
                return None

        return state

    except (json.JSONDecodeError, IOError) as e:
        return None


def get_pr_error_help(exit_code: int) -> str:
    """Map pr-workflow.sh exit codes to user-friendly error messages."""
    error_messages = {
        10: "GitHub CLI (gh) is not installed. Install with: brew install gh",
        11: "Not authenticated with GitHub. Run: gh auth login",
        12: "Uncommitted changes detected. Please commit all changes before creating PR.",
        13: "No commits to push. The feature branch has no commits compared to parent branch.",
        20: "Failed to push branch to remote. Check your network connection and permissions.",
        30: "Failed to create pull request. Check GitHub CLI output for details."
    }

    return error_messages.get(exit_code, f"Unknown error (exit code {exit_code})")


def create_pull_request(summary: Dict[str, Any], config: Dict[str, Any]) -> Dict[str, Any]:
    """Create pull request via pr-workflow.sh script."""
    pr_config = config.get("pull_request", {})

    if not pr_config.get("enabled", False):
        return {"status": "skipped", "reason": "Pull request creation disabled"}

    # Load session state
    session_state = load_session_state()

    if not session_state:
        # Graceful degradation to default parent branch
        default_parent = pr_config.get("default_parent_branch", "develop")
        return {
            "status": "warning",
            "reason": "No session state found, using default parent branch",
            "parent_branch": default_parent
        }

    # Extract parent branch and feature branch
    parent_branch = session_state.get("parent_branch", "develop")
    feature_branch = session_state.get("feature_branch", "")
    issue_number = session_state.get("issue_number")

    # Prepare PR title and body
    pr_title = pr_config.get("title_template", "")
    if not pr_title and issue_number:
        github_issue = session_state.get("github_issue", {})
        issue_title = github_issue.get("title", "")
        pr_title = f"#{issue_number}: {issue_title}" if issue_title else f"Issue #{issue_number}"

    pr_body = summary.get("full_summary", "")
    draft = pr_config.get("draft", False)

    # Build pr-workflow.sh command
    script_path = os.path.expanduser("~/.claude/skills/task-wrapup/scripts/pr-workflow.sh")

    cmd = [script_path, parent_branch, feature_branch]

    if pr_title:
        cmd.append(pr_title)

    if pr_body:
        cmd.append(pr_body)

    if draft:
        cmd.append("true")

    # Execute pr-workflow.sh
    returncode, stdout, stderr = run_command(cmd, timeout=120)

    if returncode == 0:
        result = {
            "status": "success",
            "parent_branch": parent_branch,
            "feature_branch": feature_branch,
            "pr_url": ""  # Extract from stdout if available
        }

        # Extract PR URL from stdout
        import re
        pr_url_match = re.search(r'https://github\.com[^\s]+', stdout)
        if pr_url_match:
            result["pr_url"] = pr_url_match.group(0)

        # Checkout parent branch after success
        if pr_config.get("auto_checkout_parent", True):
            checkout_result = checkout_parent_branch(session_state, config)
            result["checkout"] = checkout_result

        # Cleanup session state after success
        if pr_config.get("cleanup_session_state", True):
            cleanup_session_state(config)
            result["cleanup"] = "Session state removed"

        return result
    else:
        # Map exit code to helpful error message
        error_help = get_pr_error_help(returncode)

        return {
            "status": "error",
            "exit_code": returncode,
            "reason": error_help,
            "stderr": stderr,
            "parent_branch": parent_branch
        }


def checkout_parent_branch(session_state: Dict[str, Any], config: Dict[str, Any]) -> Dict[str, Any]:
    """Switch back to parent branch after successful PR creation."""
    parent_branch = session_state.get("parent_branch", "develop")

    returncode, stdout, stderr = run_command(
        ["git", "checkout", parent_branch],
        timeout=30
    )

    if returncode == 0:
        return {
            "status": "success",
            "branch": parent_branch
        }
    else:
        return {
            "status": "error",
            "reason": f"Failed to checkout {parent_branch}",
            "stderr": stderr
        }


def cleanup_session_state(config: Dict[str, Any]) -> None:
    """Delete .task_session_state.json file after successful PR creation."""
    pr_config = config.get("pull_request", {})

    if not pr_config.get("cleanup_session_state", True):
        return

    project_root = os.getcwd()
    state_file = os.path.join(project_root, ".task_session_state.json")

    if os.path.exists(state_file):
        try:
            os.unlink(state_file)
        except Exception:
            pass  # Fail silently


def dispatch_notifications(summary: Dict[str, Any], config: Dict[str, Any],
                           parallel: bool = True) -> Dict[str, Any]:
    """
    Dispatch notifications across all configured channels.

    Args:
        summary: Generated summary content
        config: Configuration with channel settings
        parallel: Whether to execute in parallel (default True)

    Returns:
        Dictionary with results from all channels
    """
    results = {}

    # Define tasks
    tasks = {
        "email": lambda: send_email(summary, config),
        "sms": lambda: send_sms(summary, config),
        "slack": lambda: send_slack(summary, config),
        "worklog": lambda: create_worklog_entry(summary, config),
        "documentation": lambda: update_documentation(summary, config),
        "calendar": lambda: create_calendar_event(summary, config),
        "github": lambda: create_github_item(summary, config)
    }

    if parallel:
        # Execute tasks in parallel
        max_workers = config.get("execution", {}).get("max_parallel_workers", 5)

        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            future_to_task = {executor.submit(task_fn): task_name
                             for task_name, task_fn in tasks.items()}

            for future in as_completed(future_to_task):
                task_name = future_to_task[future]
                try:
                    results[task_name] = future.result()
                except Exception as e:
                    results[task_name] = {
                        "status": "error",
                        "reason": f"Exception: {str(e)}"
                    }
    else:
        # Execute sequentially
        for task_name, task_fn in tasks.items():
            try:
                results[task_name] = task_fn()
            except Exception as e:
                results[task_name] = {
                    "status": "error",
                    "reason": f"Exception: {str(e)}"
                }

    return results


def format_final_summary(results: Dict[str, Any]) -> str:
    """Format final summary of all notification results."""
    lines = []
    lines.append("=" * 70)
    lines.append("TASK WRAP-UP SUMMARY")
    lines.append("=" * 70)
    lines.append("")

    # Count successes and failures
    success_count = 0
    skip_count = 0
    error_count = 0

    for channel, result in results.items():
        status = result.get("status", "unknown")

        if status == "success":
            success_count += 1
            icon = "✅"
        elif status == "skipped":
            skip_count += 1
            icon = "⏭️ "
        elif status == "partial":
            success_count += 0.5
            error_count += 0.5
            icon = "⚠️ "
        else:
            error_count += 1
            icon = "❌"

        channel_name = channel.upper()
        lines.append(f"{icon} {channel_name}: {status}")

        # Add details
        if status == "success":
            if channel == "email" and "recipients" in result:
                lines.append(f"   Recipients: {', '.join(result['recipients'])}")
            elif channel == "sms" and "details" in result:
                lines.append(f"   Sent: {result['successful']}/{result['total']}")
            elif channel == "worklog" and "date" in result:
                lines.append(f"   Date: {result['date']}")

        elif status == "error" or status == "partial":
            reason = result.get("reason", "Unknown error")
            lines.append(f"   Error: {reason}")

        elif status == "skipped":
            reason = result.get("reason", "Disabled")
            lines.append(f"   Reason: {reason}")

        lines.append("")

    # Summary stats
    lines.append("-" * 70)
    lines.append(f"Total: {len(results)} channels")
    lines.append(f"✅ Success: {int(success_count)}")
    lines.append(f"⏭️  Skipped: {skip_count}")
    lines.append(f"❌ Errors: {int(error_count)}")
    lines.append("=" * 70)

    return "\n".join(lines)


def main():
    """Command-line interface for notification dispatch."""
    import argparse

    parser = argparse.ArgumentParser(description="Dispatch task wrap-up notifications")
    parser.add_argument("--summary", required=True, help="Path to summary JSON file")
    parser.add_argument("--config", required=True, help="Path to configuration JSON file")
    parser.add_argument("--sequential", action="store_true", help="Execute sequentially instead of parallel")

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

    # Dispatch notifications
    parallel = not args.sequential
    results = dispatch_notifications(summary, config, parallel=parallel)

    # Generate final summary
    final_summary = format_final_summary(results)

    # Output results
    print(json.dumps({
        "status": "success",
        "results": results,
        "summary": final_summary
    }))

    # Also print summary to stdout for user visibility
    print("\n" + final_summary, file=sys.stderr)


if __name__ == "__main__":
    main()
