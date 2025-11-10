# Google Sheets Sample Operations

Real-world usage examples demonstrating common workflows and patterns with the Google Sheets Agent Skill.

---

## Table of Contents
1. [Basic Operations](#basic-operations)
2. [Data Management](#data-management)
3. [Formatting Workflows](#formatting-workflows)
4. [Integration Examples](#integration-examples)
5. [Advanced Patterns](#advanced-patterns)

---

## Basic Operations

### Reading Data from a Sheet

**Scenario**: Read sales data from a quarterly report.

```bash
# Read a specific range
echo '{
  "operation": "read",
  "spreadsheet_id": "1abc123xyz456",
  "range": "Q1 Sales!A1:E10"
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb

# Expected output:
{
  "status": "success",
  "values": [
    ["Date", "Product", "Quantity", "Price", "Total"],
    ["2025-01-05", "Widget A", "50", "$25.00", "$1,250.00"],
    ["2025-01-12", "Widget B", "30", "$40.00", "$1,200.00"]
  ],
  "range": "Q1 Sales!A1:E10",
  "majorDimension": "ROWS"
}
```

**Natural Language**: "Read the sales data from cells A1 to E10 in the Q1 Sales sheet"

---

### Writing Data to Cells

**Scenario**: Update monthly expenses in a budget tracker.

```bash
# Write expense data
echo '{
  "operation": "write",
  "spreadsheet_id": "1abc123xyz456",
  "range": "Expenses!A2:D5",
  "values": [
    ["2025-11-01", "Office Supplies", "Stationery", "150.00"],
    ["2025-11-05", "Travel", "Conference", "850.00"],
    ["2025-11-10", "Marketing", "Social Media Ads", "500.00"],
    ["2025-11-15", "Utilities", "Internet", "120.00"]
  ],
  "input_option": "USER_ENTERED"
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb

# Expected output:
{
  "status": "success",
  "updated_range": "Expenses!A2:D5",
  "updated_rows": 4,
  "updated_columns": 4,
  "updated_cells": 16
}
```

**Natural Language**: "Write the November expenses to the Expenses sheet starting at row 2"

---

## Data Management

### Creating a Budget Template

**Workflow**: Create a new budget sheet with categories and formulas.

```bash
# Step 1: Create a new sheet
echo '{
  "operation": "create_sheet",
  "spreadsheet_id": "1abc123xyz456",
  "title": "2025 Budget"
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb

# Step 2: Write headers
echo '{
  "operation": "write",
  "spreadsheet_id": "1abc123xyz456",
  "range": "2025 Budget!A1:E1",
  "values": [["Category", "Planned", "Actual", "Difference", "% Variance"]],
  "input_option": "USER_ENTERED"
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb

# Step 3: Write categories with formulas
echo '{
  "operation": "write",
  "spreadsheet_id": "1abc123xyz456",
  "range": "2025 Budget!A2:E6",
  "values": [
    ["Housing", "2000", "", "=B2-C2", "=IF(B2>0,(C2-B2)/B2,0)"],
    ["Transportation", "500", "", "=B3-C3", "=IF(B3>0,(C3-B3)/B3,0)"],
    ["Food", "800", "", "=B4-C4", "=IF(B4>0,(C4-B4)/B4,0)"],
    ["Utilities", "300", "", "=B5-C5", "=IF(B5>0,(C5-B5)/B5,0)"],
    ["Entertainment", "200", "", "=B6-C6", "=IF(B6>0,(C6-B6)/B6,0)"]
  ],
  "input_option": "USER_ENTERED"
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb

# Step 4: Add totals row
echo '{
  "operation": "write",
  "spreadsheet_id": "1abc123xyz456",
  "range": "2025 Budget!A7:E7",
  "values": [["TOTAL", "=SUM(B2:B6)", "=SUM(C2:C6)", "=SUM(D2:D6)", "=IF(B7>0,(C7-B7)/B7,0)"]],
  "input_option": "USER_ENTERED"
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb
```

**Natural Language**: "Create a budget tracker for 2025 with categories, planned amounts, actual amounts, and variance calculations"

---

### Appending Transaction Records

**Scenario**: Add new transactions to a running log without overwriting existing data.

```bash
# Append transactions to the end of the sheet
echo '{
  "operation": "append",
  "spreadsheet_id": "1abc123xyz456",
  "range": "Transactions!A:D",
  "values": [
    ["2025-11-10", "Lunch", "Dining", "45.00"],
    ["2025-11-10", "Gas", "Transportation", "60.00"],
    ["2025-11-10", "Groceries", "Food", "120.00"]
  ],
  "input_option": "USER_ENTERED"
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb

# Expected output:
{
  "status": "success",
  "updated_range": "Transactions!A25:D27",
  "updated_rows": 3,
  "updated_columns": 4,
  "updated_cells": 12,
  "message": "Appended 3 rows"
}
```

**Natural Language**: "Add today's transactions to the transaction log"

---

## Formatting Workflows

### Creating a Professional Report Header

**Workflow**: Format a report header with styling.

```bash
# Step 1: Write header text
echo '{
  "operation": "write",
  "spreadsheet_id": "1abc123xyz456",
  "range": "Report!A1:F1",
  "values": [["Q4 2025 Sales Report"]],
  "input_option": "USER_ENTERED"
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb

# Step 2: Format header (bold, large font, blue background)
echo '{
  "operation": "format",
  "spreadsheet_id": "1abc123xyz456",
  "sheet_id": 0,
  "start_row": 0,
  "end_row": 1,
  "start_column": 0,
  "end_column": 6,
  "format": {
    "text_format": {
      "bold": true,
      "fontSize": 14
    },
    "background_color": {
      "red": 0.26,
      "green": 0.52,
      "blue": 0.96
    }
  }
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb

# Step 3: Write and format column headers
echo '{
  "operation": "write",
  "spreadsheet_id": "1abc123xyz456",
  "range": "Report!A2:F2",
  "values": [["Region", "Product", "Units Sold", "Revenue", "Growth %", "Target"]],
  "input_option": "USER_ENTERED"
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb

echo '{
  "operation": "format",
  "spreadsheet_id": "1abc123xyz456",
  "sheet_id": 0,
  "start_row": 1,
  "end_row": 2,
  "start_column": 0,
  "end_column": 6,
  "format": {
    "text_format": {
      "bold": true
    },
    "background_color": {
      "red": 0.85,
      "green": 0.85,
      "blue": 0.85
    }
  }
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb
```

**Natural Language**: "Create a professional report header with blue background and bold column headers"

---

### Conditional Formatting for Data Visualization

**Scenario**: Highlight high-performing sales regions.

```bash
# Format cells with revenue >$50,000 in green
echo '{
  "operation": "format",
  "spreadsheet_id": "1abc123xyz456",
  "sheet_id": 0,
  "start_row": 2,
  "end_row": 10,
  "start_column": 3,
  "end_column": 4,
  "format": {
    "background_color": {
      "red": 0.72,
      "green": 0.88,
      "blue": 0.80
    }
  }
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb
```

**Natural Language**: "Highlight the revenue column in green for high-performing regions"

---

## Integration Examples

### Creating a Spreadsheet from Scratch

**Workflow**: Combine google-drive and google-sheets skills.

```bash
# Step 1: Create spreadsheet file (using google-drive skill)
echo '{
  "operation": "create",
  "name": "Project Tracker 2025",
  "mime_type": "application/vnd.google-apps.spreadsheet"
}' | ~/.claude/skills/google-drive/scripts/drive_manager.rb

# Returns: {"file_id": "1new_spreadsheet_id"}

# Step 2: Add project data (using google-sheets skill)
echo '{
  "operation": "write",
  "spreadsheet_id": "1new_spreadsheet_id",
  "range": "Sheet1!A1:E1",
  "values": [["Task", "Owner", "Status", "Due Date", "Priority"]],
  "input_option": "USER_ENTERED"
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb

# Step 3: Share with team (using google-drive skill)
echo '{
  "operation": "share",
  "file_id": "1new_spreadsheet_id",
  "email": "team@company.com",
  "role": "writer"
}' | ~/.claude/skills/google-drive/scripts/drive_manager.rb
```

**Natural Language**: "Create a new project tracker spreadsheet and share it with the team"

---

### Exporting Data to CSV

**Workflow**: Read sheet data and export to CSV (using google-drive skill).

```bash
# Step 1: Read data from sheet
echo '{
  "operation": "read",
  "spreadsheet_id": "1abc123xyz456",
  "range": "Sales Data!A1:Z1000"
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb > data.json

# Step 2: Export to CSV (using google-drive skill)
echo '{
  "operation": "export",
  "file_id": "1abc123xyz456",
  "format": "csv",
  "output_path": "/Users/arlenagreer/Downloads/sales_data.csv"
}' | ~/.claude/skills/google-drive/scripts/drive_manager.rb
```

**Natural Language**: "Export the sales data sheet to CSV format"

---

## Advanced Patterns

### Batch Update for Performance

**Scenario**: Update multiple sections of a sheet efficiently.

```bash
# Single API call for multiple updates
echo '{
  "operation": "batch_update",
  "spreadsheet_id": "1abc123xyz456",
  "requests": [
    {
      "updateCells": {
        "range": {
          "sheetId": 0,
          "startRowIndex": 0,
          "endRowIndex": 1,
          "startColumnIndex": 0,
          "endColumnIndex": 5
        },
        "rows": [
          {
            "values": [
              {"userEnteredValue": {"stringValue": "Dashboard"}},
              {"userEnteredValue": {"stringValue": ""}},
              {"userEnteredValue": {"stringValue": ""}},
              {"userEnteredValue": {"stringValue": ""}},
              {"userEnteredValue": {"stringValue": ""}}
            ]
          }
        ],
        "fields": "userEnteredValue"
      }
    },
    {
      "repeatCell": {
        "range": {
          "sheetId": 0,
          "startRowIndex": 0,
          "endRowIndex": 1,
          "startColumnIndex": 0,
          "endColumnIndex": 5
        },
        "cell": {
          "userEnteredFormat": {
            "textFormat": {
              "bold": true,
              "fontSize": 16
            },
            "backgroundColor": {
              "red": 0.26,
              "green": 0.52,
              "blue": 0.96
            }
          }
        },
        "fields": "userEnteredFormat(textFormat,backgroundColor)"
      }
    }
  ]
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb
```

**Natural Language**: "Create a dashboard header with title and formatting in a single operation"

---

### Creating a Data Dashboard

**Complete Workflow**: Build a formatted dashboard with data and charts.

```bash
# Step 1: Create dashboard sheet
echo '{
  "operation": "create_sheet",
  "spreadsheet_id": "1abc123xyz456",
  "title": "Dashboard"
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb

# Step 2: Write KPI headers
echo '{
  "operation": "write",
  "spreadsheet_id": "1abc123xyz456",
  "range": "Dashboard!A1:D1",
  "values": [["Revenue", "Customers", "Conversion Rate", "AOV"]],
  "input_option": "USER_ENTERED"
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb

# Step 3: Write KPI values with formulas
echo '{
  "operation": "write",
  "spreadsheet_id": "1abc123xyz456",
  "range": "Dashboard!A2:D2",
  "values": [["=SUM(Sales!D:D)", "=COUNTA(Sales!A:A)-1", "=B2/COUNTA(Visitors!A:A)", "=A2/B2"]],
  "input_option": "USER_ENTERED"
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb

# Step 4: Format KPI section
echo '{
  "operation": "format",
  "spreadsheet_id": "1abc123xyz456",
  "sheet_id": 1234567890,
  "start_row": 0,
  "end_row": 2,
  "start_column": 0,
  "end_column": 4,
  "format": {
    "text_format": {
      "bold": true,
      "fontSize": 12
    },
    "background_color": {
      "red": 0.85,
      "green": 0.92,
      "blue": 0.95
    }
  }
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb
```

**Natural Language**: "Build a dashboard with KPIs including revenue, customers, conversion rate, and average order value"

---

### Data Validation and Cleanup

**Workflow**: Clear and prepare a sheet for new data.

```bash
# Step 1: Get sheet metadata to identify the right sheet
echo '{
  "operation": "metadata",
  "spreadsheet_id": "1abc123xyz456"
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb

# Step 2: Clear existing data (keeping headers)
echo '{
  "operation": "clear",
  "spreadsheet_id": "1abc123xyz456",
  "range": "Data Import!A2:Z1000"
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb

# Step 3: Write new validated data
echo '{
  "operation": "write",
  "spreadsheet_id": "1abc123xyz456",
  "range": "Data Import!A2:C100",
  "values": [
    ["2025-11-10", "Valid Record", "100.00"],
    ["2025-11-10", "Valid Record", "250.00"]
  ],
  "input_option": "USER_ENTERED"
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb
```

**Natural Language**: "Clear the old data and import the new validated records"

---

## Common Patterns

### Reading with Error Handling

```bash
# Try to read, check for errors
RESULT=$(echo '{
  "operation": "read",
  "spreadsheet_id": "1abc123xyz456",
  "range": "Sheet1!A1:B10"
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb)

if echo "$RESULT" | jq -e '.status == "success"' > /dev/null; then
  echo "✅ Read successful"
  echo "$RESULT" | jq '.values'
else
  echo "❌ Read failed"
  echo "$RESULT" | jq '.error'
fi
```

---

### Writing with Validation

```bash
# Validate data before writing
DATA='[["2025-11-10", "Valid", "100"]]'

if echo "$DATA" | jq -e 'length > 0' > /dev/null; then
  echo "{
    \"operation\": \"write\",
    \"spreadsheet_id\": \"1abc123xyz456\",
    \"range\": \"Sheet1!A2:C2\",
    \"values\": $DATA,
    \"input_option\": \"USER_ENTERED\"
  }" | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb
else
  echo '{"status": "error", "message": "No data to write"}'
fi
```

---

### Appending with Auto-Range

```bash
# Append to any column, script finds the right row
echo '{
  "operation": "append",
  "spreadsheet_id": "1abc123xyz456",
  "range": "Log!A:E",
  "values": [["'$(date +%Y-%m-%d)'", "System", "Info", "Operation complete", "Success"]],
  "input_option": "USER_ENTERED"
}' | ~/.claude/skills/google-sheets/scripts/sheets_manager.rb
```

---

## Best Practices

1. **Use USER_ENTERED for formulas**: Always use `"input_option": "USER_ENTERED"` when writing formulas
2. **Batch operations**: Use `batch_update` for multiple changes to reduce API calls
3. **Format after data**: Write data first, then apply formatting for cleaner workflows
4. **Check metadata**: Use `metadata` operation to get sheet IDs before formatting
5. **Clear carefully**: Use specific ranges when clearing to avoid deleting headers
6. **Test ranges**: Verify ranges with small datasets before bulk operations
7. **Handle errors**: Always check operation status before proceeding
8. **Use A1 notation**: Prefer readable A1 notation (e.g., "A1:B10") over R1C1

---

## Quick Reference Commands

```bash
# Authentication check
echo '{"operation": "auth"}' | sheets_manager.rb

# Read data
echo '{"operation": "read", "spreadsheet_id": "ID", "range": "Sheet!A1:B10"}' | sheets_manager.rb

# Write data
echo '{"operation": "write", "spreadsheet_id": "ID", "range": "Sheet!A1:B2", "values": [["A","B"]], "input_option": "USER_ENTERED"}' | sheets_manager.rb

# Append data
echo '{"operation": "append", "spreadsheet_id": "ID", "range": "Sheet!A:B", "values": [["C","D"]], "input_option": "USER_ENTERED"}' | sheets_manager.rb

# Clear range
echo '{"operation": "clear", "spreadsheet_id": "ID", "range": "Sheet!A1:B10"}' | sheets_manager.rb

# Get metadata
echo '{"operation": "metadata", "spreadsheet_id": "ID"}' | sheets_manager.rb

# Create sheet
echo '{"operation": "create_sheet", "spreadsheet_id": "ID", "title": "New Sheet"}' | sheets_manager.rb

# Format cells
echo '{"operation": "format", "spreadsheet_id": "ID", "sheet_id": 0, "start_row": 0, "end_row": 1, "start_column": 0, "end_column": 2, "format": {"text_format": {"bold": true}}}' | sheets_manager.rb

# Batch update
echo '{"operation": "batch_update", "spreadsheet_id": "ID", "requests": [...]}' | sheets_manager.rb
```

---

## Version History

- **v1.0** (2025-11-10): Initial examples with core operations and workflows
