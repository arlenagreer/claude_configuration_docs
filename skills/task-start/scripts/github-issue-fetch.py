#!/usr/bin/env python3
"""
GitHub issue fetcher for task-start skill.
Fetches highest priority issue or specific issue by number.
"""

import json
import os
import sys
import subprocess
from typing import Optional, Dict, Any, List

# Priority order for labels (highest to lowest)
DEFAULT_PRIORITY_LABELS = ["urgent", "high", "medium", "low"]

class GitHubIssueFetcher:
    """Fetches GitHub issues using gh CLI."""

    def __init__(self, priority_labels: Optional[List[str]] = None):
        self.priority_labels = priority_labels or DEFAULT_PRIORITY_LABELS

    def check_gh_cli(self) -> bool:
        """Check if gh CLI is installed and authenticated."""
        try:
            subprocess.run(
                ["gh", "auth", "status"],
                check=True,
                capture_output=True,
                text=True
            )
            return True
        except (subprocess.CalledProcessError, FileNotFoundError):
            return False

    def get_issue(self, issue_number: Optional[int] = None) -> Optional[Dict[str, Any]]:
        """
        Get specific issue by number or highest priority open issue.

        Args:
            issue_number: Specific issue number, or None for highest priority

        Returns:
            Issue dict with keys: number, title, body, labels, state
        """
        if not self.check_gh_cli():
            print("❌ GitHub CLI (gh) not installed or not authenticated", file=sys.stderr)
            print("   Install: brew install gh", file=sys.stderr)
            print("   Authenticate: gh auth login", file=sys.stderr)
            return None

        try:
            if issue_number:
                # Fetch specific issue
                result = subprocess.run(
                    ["gh", "issue", "view", str(issue_number), "--json",
                     "number,title,body,labels,state"],
                    capture_output=True,
                    text=True,
                    check=True
                )
                issue = json.loads(result.stdout)

                if issue.get("state") != "OPEN":
                    print(f"⚠️  Issue #{issue_number} is not open (state: {issue.get('state')})", file=sys.stderr)
                    return None

                return self._format_issue(issue)

            else:
                # Fetch all open issues
                result = subprocess.run(
                    ["gh", "issue", "list", "--state", "open", "--json",
                     "number,title,body,labels,state", "--limit", "100"],
                    capture_output=True,
                    text=True,
                    check=True
                )
                issues = json.loads(result.stdout)

                if not issues:
                    print("⚠️  No open issues found", file=sys.stderr)
                    return None

                # Find highest priority issue
                highest_priority = self._find_highest_priority(issues)
                return highest_priority

        except subprocess.CalledProcessError as e:
            print(f"❌ Failed to fetch GitHub issue: {e.stderr}", file=sys.stderr)
            return None
        except json.JSONDecodeError as e:
            print(f"❌ Failed to parse GitHub response: {e}", file=sys.stderr)
            return None

    def _format_issue(self, issue: Dict[str, Any]) -> Dict[str, Any]:
        """Format issue data for consistent structure."""
        label_names = [label.get("name", "") for label in issue.get("labels", [])]

        return {
            "number": issue["number"],
            "title": issue["title"],
            "body": issue.get("body", ""),
            "labels": label_names,
            "state": issue.get("state", "OPEN"),
            "priority": self._get_priority_level(label_names)
        }

    def _get_priority_level(self, labels: List[str]) -> str:
        """Determine priority level from labels."""
        for priority in self.priority_labels:
            if priority in labels:
                return priority
        return "none"

    def _find_highest_priority(self, issues: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
        """Find highest priority issue from list."""
        if not issues:
            return None

        # Format all issues
        formatted = [self._format_issue(issue) for issue in issues]

        # Sort by priority level
        def priority_key(issue):
            priority = issue.get("priority", "none")
            try:
                return self.priority_labels.index(priority)
            except ValueError:
                return len(self.priority_labels)  # No priority label = lowest

        sorted_issues = sorted(formatted, key=priority_key)
        return sorted_issues[0] if sorted_issues else None

    def format_summary(self, issue: Dict[str, Any]) -> str:
        """Format issue for display to user."""
        lines = [
            "=" * 60,
            f"📋 GitHub Issue #{issue['number']}",
            "=" * 60,
            f"Title: {issue['title']}",
            f"Priority: {issue['priority'].upper() if issue['priority'] != 'none' else 'None'}",
            f"Labels: {', '.join(issue['labels']) if issue['labels'] else 'None'}",
            "",
            "Description:",
            "-" * 60,
            issue['body'][:500] + ("..." if len(issue['body']) > 500 else ""),
            "=" * 60,
        ]
        return "\n".join(lines)


def main():
    """CLI interface."""
    import argparse

    parser = argparse.ArgumentParser(description="Fetch GitHub issues")
    parser.add_argument("--issue", "-i", type=int, help="Specific issue number")
    parser.add_argument("--priority-labels", nargs="+", help="Priority labels in order")
    parser.add_argument("--format", choices=["json", "summary"], default="summary",
                       help="Output format")

    args = parser.parse_args()

    # Initialize fetcher
    fetcher = GitHubIssueFetcher(priority_labels=args.priority_labels)

    # Fetch issue
    issue = fetcher.get_issue(issue_number=args.issue)

    if not issue:
        sys.exit(1)

    # Output
    if args.format == "json":
        print(json.dumps(issue, indent=2))
    else:
        print(fetcher.format_summary(issue))


if __name__ == "__main__":
    main()
