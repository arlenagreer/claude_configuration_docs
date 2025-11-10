#!/usr/bin/env python3
"""
Worklog Manager - Track billable hours for clients
"""

import json
import os
from datetime import datetime
from pathlib import Path
from typing import Optional, List, Dict

# Path to worklog data file
WORKLOG_FILE = Path(__file__).parent.parent / "worklog.json"
INVOICE_CLIENTS_FILE = Path.home() / ".claude/skills/invoice/clients.json"


def load_worklog() -> Dict:
    """Load worklog data from JSON file"""
    if not WORKLOG_FILE.exists():
        return {"entries": []}

    with open(WORKLOG_FILE, 'r') as f:
        return json.load(f)


def save_worklog(data: Dict) -> None:
    """Save worklog data to JSON file"""
    with open(WORKLOG_FILE, 'w') as f:
        json.dump(data, f, indent=2)


def load_invoice_clients() -> List[Dict]:
    """Load client list from invoice skill"""
    if not INVOICE_CLIENTS_FILE.exists():
        return []

    with open(INVOICE_CLIENTS_FILE, 'r') as f:
        data = json.load(f)
        return data.get("clients", [])


def get_client_names() -> List[str]:
    """Get list of valid client names from invoice skill"""
    clients = load_invoice_clients()
    return [client["name"] for client in clients]


def validate_client(client_name: str) -> bool:
    """Check if client name exists in invoice skill"""
    valid_clients = get_client_names()
    return client_name in valid_clients


def get_client_rate(client_name: str) -> Optional[float]:
    """Get hourly rate for a client (if hourly billing)"""
    clients = load_invoice_clients()
    for client in clients:
        if client["name"] == client_name:
            if client.get("invoice_type") == "hourly":
                return client.get("hourly_rate")
    return None


def add_entry(
    client_name: str,
    hours: float,
    description: str,
    date: Optional[str] = None
) -> Dict:
    """
    Add a new worklog entry

    Args:
        client_name: Name of the client (must match invoice skill)
        hours: Number of hours worked
        description: Description of work performed
        date: Date of work (YYYY-MM-DD format), defaults to today

    Returns:
        The created entry dictionary
    """
    # Validate client exists
    if not validate_client(client_name):
        valid_clients = get_client_names()
        raise ValueError(
            f"Client '{client_name}' not found in invoice skill. "
            f"Valid clients: {', '.join(valid_clients)}"
        )

    # Validate hours
    if hours <= 0:
        raise ValueError("Hours must be greater than 0")

    # Use today's date if not specified
    if date is None:
        date = datetime.now().strftime("%Y-%m-%d")

    # Validate date format
    try:
        datetime.strptime(date, "%Y-%m-%d")
    except ValueError:
        raise ValueError("Date must be in YYYY-MM-DD format")

    # Create entry
    entry = {
        "client": client_name,
        "date": date,
        "hours": hours,
        "description": description,
        "hourly_rate": get_client_rate(client_name),
        "created_at": datetime.now().isoformat()
    }

    # Load, append, save
    worklog = load_worklog()
    worklog["entries"].append(entry)
    save_worklog(worklog)

    return entry


def list_entries(
    client_name: Optional[str] = None,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None
) -> List[Dict]:
    """
    List worklog entries with optional filters

    Args:
        client_name: Filter by client name
        start_date: Filter entries on or after this date (YYYY-MM-DD)
        end_date: Filter entries on or before this date (YYYY-MM-DD)

    Returns:
        List of matching entries
    """
    worklog = load_worklog()
    entries = worklog.get("entries", [])

    # Apply filters
    if client_name:
        entries = [e for e in entries if e["client"] == client_name]

    if start_date:
        entries = [e for e in entries if e["date"] >= start_date]

    if end_date:
        entries = [e for e in entries if e["date"] <= end_date]

    # Sort by date (most recent first)
    entries.sort(key=lambda e: e["date"], reverse=True)

    return entries


def get_total_hours(
    client_name: Optional[str] = None,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None
) -> Dict[str, float]:
    """
    Calculate total hours worked

    Args:
        client_name: Filter by client name
        start_date: Filter entries on or after this date (YYYY-MM-DD)
        end_date: Filter entries on or before this date (YYYY-MM-DD)

    Returns:
        Dictionary with total hours by client
    """
    entries = list_entries(client_name, start_date, end_date)

    totals = {}
    for entry in entries:
        client = entry["client"]
        hours = entry["hours"]
        totals[client] = totals.get(client, 0) + hours

    return totals


def delete_entry(index: int) -> bool:
    """
    Delete an entry by its index in the list

    Args:
        index: Zero-based index of entry to delete

    Returns:
        True if deleted, False if index out of range
    """
    worklog = load_worklog()
    entries = worklog.get("entries", [])

    if 0 <= index < len(entries):
        deleted = entries.pop(index)
        save_worklog(worklog)
        return True

    return False


def main():
    """CLI interface for worklog manager"""
    import argparse

    parser = argparse.ArgumentParser(description="Manage billable hours worklog")
    subparsers = parser.add_subparsers(dest="command", help="Command to execute")

    # Add entry command
    add_parser = subparsers.add_parser("add", help="Add a new worklog entry")
    add_parser.add_argument("--client", required=True, help="Client name")
    add_parser.add_argument("--hours", type=float, required=True, help="Hours worked")
    add_parser.add_argument("--description", required=True, help="Work description")
    add_parser.add_argument("--date", help="Date (YYYY-MM-DD), defaults to today")

    # List entries command
    list_parser = subparsers.add_parser("list", help="List worklog entries")
    list_parser.add_argument("--client", help="Filter by client name")
    list_parser.add_argument("--start-date", help="Start date (YYYY-MM-DD)")
    list_parser.add_argument("--end-date", help="End date (YYYY-MM-DD)")
    list_parser.add_argument("--format", choices=["json", "table"], default="table")

    # Total hours command
    total_parser = subparsers.add_parser("total", help="Calculate total hours")
    total_parser.add_argument("--client", help="Filter by client name")
    total_parser.add_argument("--start-date", help="Start date (YYYY-MM-DD)")
    total_parser.add_argument("--end-date", help="End date (YYYY-MM-DD)")

    # List clients command
    subparsers.add_parser("clients", help="List available clients")

    # Delete entry command
    delete_parser = subparsers.add_parser("delete", help="Delete an entry")
    delete_parser.add_argument("index", type=int, help="Entry index to delete")

    args = parser.parse_args()

    if args.command == "add":
        try:
            entry = add_entry(
                args.client,
                args.hours,
                args.description,
                args.date
            )
            print(f"✅ Added entry: {entry['hours']} hours for {entry['client']} on {entry['date']}")
        except ValueError as e:
            print(f"❌ Error: {e}")
            return 1

    elif args.command == "list":
        entries = list_entries(args.client, args.start_date, args.end_date)

        if args.format == "json":
            print(json.dumps(entries, indent=2))
        else:
            if not entries:
                print("No entries found.")
            else:
                print(f"\n{'Date':<12} {'Client':<25} {'Hours':<8} {'Description'}")
                print("-" * 80)
                for entry in entries:
                    desc = entry["description"][:40] + "..." if len(entry["description"]) > 40 else entry["description"]
                    print(f"{entry['date']:<12} {entry['client']:<25} {entry['hours']:<8.2f} {desc}")
                print()

    elif args.command == "total":
        totals = get_total_hours(args.client, args.start_date, args.end_date)

        if not totals:
            print("No entries found.")
        else:
            print("\nTotal Hours by Client:")
            print("-" * 40)
            for client, hours in sorted(totals.items()):
                rate = get_client_rate(client)
                if rate:
                    amount = hours * rate
                    print(f"{client:<30} {hours:>6.2f} hrs (${amount:,.2f})")
                else:
                    print(f"{client:<30} {hours:>6.2f} hrs")
            print()

    elif args.command == "clients":
        clients = load_invoice_clients()
        print("\nAvailable Clients:")
        print("-" * 60)
        for client in clients:
            rate_info = f"${client['hourly_rate']}/hr" if client.get('invoice_type') == 'hourly' else client.get('invoice_type', 'N/A')
            print(f"{client['name']:<35} ({rate_info})")
        print()

    elif args.command == "delete":
        if delete_entry(args.index):
            print(f"✅ Deleted entry at index {args.index}")
        else:
            print(f"❌ Error: Invalid index {args.index}")
            return 1

    else:
        parser.print_help()
        return 1

    return 0


if __name__ == "__main__":
    exit(main())
