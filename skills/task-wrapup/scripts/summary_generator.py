#!/usr/bin/env python3
"""
Summary Generator for Task Wrap-Up Skill

Intelligently generates work summaries from multiple sources:
- Git commits
- TodoWrite completed tasks
- File changes
- Serena session memory
"""

import json
import subprocess
import sys
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional


def run_command(cmd: List[str]) -> tuple[int, str, str]:
    """Run a shell command and return (returncode, stdout, stderr)."""
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return 1, "", "Command timed out"
    except Exception as e:
        return 1, "", str(e)


def get_git_commits_since_time(hours_ago: int = 12) -> List[Dict[str, str]]:
    """Get git commits from the last N hours."""
    try:
        # Calculate time threshold
        time_threshold = datetime.now() - timedelta(hours=hours_ago)
        since_arg = time_threshold.strftime("%Y-%m-%d %H:%M:%S")

        # Get commits
        cmd = [
            "git", "log",
            f"--since={since_arg}",
            "--pretty=format:%H|%s|%an|%ai",
            "--no-merges"
        ]

        returncode, stdout, stderr = run_command(cmd)

        if returncode != 0:
            return []

        commits = []
        for line in stdout.strip().split("\n"):
            if not line:
                continue

            parts = line.split("|")
            if len(parts) >= 4:
                commits.append({
                    "hash": parts[0][:8],
                    "message": parts[1],
                    "author": parts[2],
                    "date": parts[3]
                })

        return commits

    except Exception:
        return []


def get_changed_files() -> List[str]:
    """Get list of files changed in recent commits."""
    try:
        cmd = ["git", "diff", "--name-only", "HEAD~5", "HEAD"]
        returncode, stdout, stderr = run_command(cmd)

        if returncode != 0:
            return []

        return [f.strip() for f in stdout.strip().split("\n") if f.strip()]

    except Exception:
        return []


def get_file_stats() -> Dict[str, int]:
    """Get statistics about file changes."""
    try:
        cmd = ["git", "diff", "--stat", "HEAD~5", "HEAD"]
        returncode, stdout, stderr = run_command(cmd)

        if returncode != 0:
            return {"files_changed": 0, "insertions": 0, "deletions": 0}

        # Parse summary line like: "12 files changed, 543 insertions(+), 123 deletions(-)"
        lines = stdout.strip().split("\n")
        if not lines:
            return {"files_changed": 0, "insertions": 0, "deletions": 0}

        summary_line = lines[-1]

        stats = {"files_changed": 0, "insertions": 0, "deletions": 0}

        if "file" in summary_line:
            parts = summary_line.split(",")
            for part in parts:
                part = part.strip()
                if "file" in part:
                    stats["files_changed"] = int(part.split()[0])
                elif "insertion" in part:
                    stats["insertions"] = int(part.split()[0])
                elif "deletion" in part:
                    stats["deletions"] = int(part.split()[0])

        return stats

    except Exception:
        return {"files_changed": 0, "insertions": 0, "deletions": 0}


def extract_key_points_from_commits(commits: List[Dict[str, str]]) -> List[str]:
    """Extract key points from commit messages."""
    if not commits:
        return []

    key_points = []

    for commit in commits:
        message = commit["message"]

        # Clean up common prefixes
        message = message.replace("feat:", "").replace("fix:", "").replace("chore:", "")
        message = message.replace("docs:", "").replace("refactor:", "").replace("test:", "")
        message = message.strip()

        # Capitalize first letter
        if message:
            message = message[0].upper() + message[1:]
            key_points.append(message)

    return key_points


def generate_summary(config: Dict[str, Any], user_override: Optional[str] = None) -> Dict[str, Any]:
    """
    Generate intelligent summary based on configuration and available sources.

    Returns a dictionary with:
    - full_summary: Complete detailed summary (for email, Slack)
    - concise_summary: Brief version (for SMS, worklog)
    - sources_used: List of sources that contributed to summary
    - key_points: Bulleted list of accomplishments
    """

    if user_override:
        # User provided custom summary - use as-is
        return {
            "full_summary": user_override,
            "concise_summary": user_override[:300] + "..." if len(user_override) > 300 else user_override,
            "sources_used": ["user_input"],
            "key_points": [user_override]
        }

    sources_config = config.get("summary_generation", {}).get("sources", {})
    intelligence = config.get("summary_generation", {}).get("intelligence", {})

    key_points = []
    sources_used = []
    sections = {}

    # 1. Git commits
    if sources_config.get("git_commits", True):
        commits = get_git_commits_since_time(12)
        if commits:
            sources_used.append("git_commits")
            commit_points = extract_key_points_from_commits(commits)
            key_points.extend(commit_points)
            sections["commits"] = {
                "title": "Code Changes",
                "points": commit_points,
                "count": len(commits)
            }

    # 2. File statistics
    if sources_config.get("file_changes", True):
        stats = get_file_stats()
        if stats["files_changed"] > 0:
            sources_used.append("file_changes")
            sections["files"] = stats

    # 3. Changed files list (for detail)
    changed_files = get_changed_files()
    if changed_files:
        sections["changed_files"] = changed_files[:10]  # Limit to first 10

    # Generate full summary
    full_summary_parts = []

    if "commits" in sections:
        commit_section = sections["commits"]
        full_summary_parts.append(f"Session Accomplishments:")
        for point in commit_section["points"]:
            full_summary_parts.append(f"• {point}")

    if "files" in sections:
        stats = sections["files"]
        full_summary_parts.append(f"\nFiles Modified: {stats['files_changed']} files changed")
        if stats.get("insertions", 0) > 0 or stats.get("deletions", 0) > 0:
            full_summary_parts.append(
                f"({stats.get('insertions', 0)} insertions, {stats.get('deletions', 0)} deletions)"
            )

    # Generate concise summary (for SMS and worklog)
    concise_parts = []
    if key_points:
        # Take top 3 most important points
        top_points = key_points[:3]
        concise_parts.append(", ".join(top_points))

        if "files" in sections:
            stats = sections["files"]
            concise_parts.append(f"({stats['files_changed']} files)")

    full_summary = "\n".join(full_summary_parts) if full_summary_parts else "Work session completed"
    concise_summary = ". ".join(concise_parts) if concise_parts else "Work session completed"

    # Ensure concise fits in reasonable SMS length
    if len(concise_summary) > 300:
        concise_summary = concise_summary[:297] + "..."

    return {
        "full_summary": full_summary,
        "concise_summary": concise_summary,
        "sources_used": sources_used,
        "key_points": key_points,
        "sections": sections
    }


def main():
    """Command-line interface for summary generation."""
    import argparse

    parser = argparse.ArgumentParser(description="Generate work session summary")
    parser.add_argument("--config", required=True, help="Path to configuration file")
    parser.add_argument("--user-input", help="User-provided summary override")
    parser.add_argument("--format", choices=["full", "concise", "json"], default="json",
                       help="Output format")

    args = parser.parse_args()

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

    # Generate summary
    summary = generate_summary(config, args.user_input)

    if args.format == "full":
        print(summary["full_summary"])
    elif args.format == "concise":
        print(summary["concise_summary"])
    else:
        print(json.dumps({
            "status": "success",
            "summary": summary
        }))


if __name__ == "__main__":
    main()
