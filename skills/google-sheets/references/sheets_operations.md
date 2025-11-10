# Google Sheets Operations Reference

Complete reference for all spreadsheet operations available in the google-sheets skill.

## Table of Contents

1. [Read Operations](#read-operations)
2. [Write Operations](#write-operations)
3. [Append Operations](#append-operations)
4. [Clear Operations](#clear-operations)
5. [Metadata Operations](#metadata-operations)
6. [Sheet Management](#sheet-management)
7. [Format Operations](#format-operations)
8. [Batch Operations](#batch-operations)
9. [Common Patterns](#common-patterns)
10. [Error Codes](#error-codes)

---

## Read Operations

### Read Cell Values

**Command**: `read`

**Required Parameters**:
- `spreadsheet_id`: The unique ID of the spreadsheet
- `range`: A1 notation range to read

**Optional Parameters**: None

**Examples**:

```bash
# Read single cell
echo '{"spreadsheet_id":"abc123","range":"Sheet1!A1"}' | sheets_manager.rb read

# Read range
echo '{"spreadsheet_id":"abc123","range":"Sheet1!A1:D10"}' | sheets_manager.rb read

# Read entire column
echo '{"spreadsheet_id":"abc123","range":"Sheet1!A:A"}' | sheets_manager.rb read

# Read entire row
echo '{"spreadsheet_id":"abc123","range":"Sheet1!1:1"}' | sheets_manager.rb read

# Read from named sheet with spaces
echo '{"spreadsheet_id":"abc123","range":"'\''Budget 2024'\''!A1:Z100"}' | sheets_manager.rb read
```

**Success Response**:
```json
{
  "status": "success",
  "operation": "read",
  "spreadsheet_id": "abc123",
  "range": "Sheet1!A1:D10",
  "values": [
    ["Header1", "Header2", "Header3", "Header4"],
    ["Value1", "Value2", "Value3", "Value4"]
  ],
  "row_count": 2
}
```

**Notes**:
- Empty cells are returned as empty strings within rows
- Rows with all empty cells may be omitted
- Formulas are returned as their calculated values, not the formula text
- Returns raw values without formatting

---

## Write Operations

### Write Cell Values

**Command**: `write`

**Required Parameters**:
- `spreadsheet_id`: The unique ID of the spreadsheet
- `range`: A1 notation range to write to
- `values`: 2D array of values to write

**Optional Parameters**:
- `input_option`: How to interpret input data
  - `USER_ENTERED` (default): Parse as if typed by user (formulas, dates, numbers)
  - `RAW`: Store exactly as provided (everything as strings)

**Examples**:

```bash
# Write single cell
echo '{
  "spreadsheet_id": "abc123",
  "range": "Sheet1!A1",
  "values": [["Hello World"]]
}' | sheets_manager.rb write

# Write range
echo '{
  "spreadsheet_id": "abc123",
  "range": "Sheet1!A1:B2",
  "values": [
    ["Name", "Age"],
    ["Alice", 30]
  ]
}' | sheets_manager.rb write

# Write formula
echo '{
  "spreadsheet_id": "abc123",
  "range": "Sheet1!C1",
  "values": [["=SUM(A1:A10)"]],
  "input_option": "USER_ENTERED"
}' | sheets_manager.rb write

# Write date (parsed automatically with USER_ENTERED)
echo '{
  "spreadsheet_id": "abc123",
  "range": "Sheet1!D1",
  "values": [["2024-11-10"]],
  "input_option": "USER_ENTERED"
}' | sheets_manager.rb write

# Write numbers
echo '{
  "spreadsheet_id": "abc123",
  "range": "Sheet1!E1:E3",
  "values": [[100], [200], [300]]
}' | sheets_manager.rb write
```

**Success Response**:
```json
{
  "status": "success",
  "operation": "write",
  "spreadsheet_id": "abc123",
  "range": "Sheet1!A1:B2",
  "updated_cells": 4,
  "updated_rows": 2,
  "updated_columns": 2
}
```

**Notes**:
- Overwrites existing data in the range
- Use USER_ENTERED for formulas, dates, and automatic type parsing
- Use RAW to store literal strings
- Values array must be 2D (array of arrays)
- Mismatched dimensions will write partial data

---

## Append Operations

### Append Rows

**Command**: `append`

**Required Parameters**:
- `spreadsheet_id`: The unique ID of the spreadsheet
- `range`: Starting range (e.g., "Sheet1!A1")
- `values`: 2D array of rows to append

**Optional Parameters**:
- `input_option`: How to interpret input data (same as write)

**Examples**:

```bash
# Append single row
echo '{
  "spreadsheet_id": "abc123",
  "range": "Sheet1!A1",
  "values": [["New", "Row", "Data"]]
}' | sheets_manager.rb append

# Append multiple rows
echo '{
  "spreadsheet_id": "abc123",
  "range": "Sheet1!A1",
  "values": [
    ["Row1Col1", "Row1Col2", "Row1Col3"],
    ["Row2Col1", "Row2Col2", "Row2Col3"],
    ["Row3Col1", "Row3Col2", "Row3Col3"]
  ]
}' | sheets_manager.rb append

# Append with formulas
echo '{
  "spreadsheet_id": "abc123",
  "range": "Sheet1!A1",
  "values": [["Value", "100", "=B1*2"]],
  "input_option": "USER_ENTERED"
}' | sheets_manager.rb append
```

**Success Response**:
```json
{
  "status": "success",
  "operation": "append",
  "spreadsheet_id": "abc123",
  "range": "Sheet1!A10:C12",
  "updated_cells": 9,
  "updated_rows": 3
}
```

**How Append Works**:
- Finds the last row with data in the specified range
- Appends new rows immediately after the last data row
- Does not overwrite existing data
- Table range in response shows where data was appended

**Use Cases**:
- Logging data over time
- Adding entries to a tracker
- Building datasets incrementally
- Recording events or transactions

---

## Clear Operations

### Clear Cell Values

**Command**: `clear`

**Required Parameters**:
- `spreadsheet_id`: The unique ID of the spreadsheet
- `range`: A1 notation range to clear

**Optional Parameters**: None

**Examples**:

```bash
# Clear specific range
echo '{
  "spreadsheet_id": "abc123",
  "range": "Sheet1!A1:D10"
}' | sheets_manager.rb clear

# Clear entire sheet
echo '{
  "spreadsheet_id": "abc123",
  "range": "Sheet1"
}' | sheets_manager.rb clear

# Clear entire column
echo '{
  "spreadsheet_id": "abc123",
  "range": "Sheet1!C:C"
}' | sheets_manager.rb clear

# Clear entire row
echo '{
  "spreadsheet_id": "abc123",
  "range": "Sheet1!5:5"
}' | sheets_manager.rb clear
```

**Success Response**:
```json
{
  "status": "success",
  "operation": "clear",
  "spreadsheet_id": "abc123",
  "range": "Sheet1!A1:D10"
}
```

**Important Notes**:
- Clears cell **values** only
- Does NOT remove cell formatting (colors, fonts, etc.)
- Does NOT remove formulas (they remain but show no value)
- Does NOT delete rows or columns
- To remove formatting, use format operations with default styles

---

## Metadata Operations

### Get Spreadsheet Metadata

**Command**: `metadata`

**Required Parameters**:
- `spreadsheet_id`: The unique ID of the spreadsheet

**Optional Parameters**: None

**Example**:

```bash
echo '{
  "spreadsheet_id": "abc123"
}' | sheets_manager.rb metadata
```

**Success Response**:
```json
{
  "status": "success",
  "operation": "metadata",
  "spreadsheet_id": "abc123",
  "title": "Budget 2024",
  "locale": "en_US",
  "timezone": "America/Chicago",
  "sheets": [
    {
      "sheet_id": 0,
      "title": "Sheet1",
      "index": 0,
      "row_count": 1000,
      "column_count": 26
    },
    {
      "sheet_id": 123456,
      "title": "Q4 Summary",
      "index": 1,
      "row_count": 500,
      "column_count": 15
    }
  ]
}
```

**Use Cases**:
- Discover available sheets in a spreadsheet
- Get sheet_id for format operations
- Check spreadsheet structure before operations
- Verify spreadsheet properties (timezone, locale)

**Notes**:
- `sheet_id` is required for format operations (not the same as index)
- `index` indicates the order of sheets (0-based)
- `row_count` and `column_count` show sheet dimensions

---

## Sheet Management

### Create New Sheet

**Command**: `create_sheet`

**Required Parameters**:
- `spreadsheet_id`: The unique ID of the spreadsheet
- `title`: Name for the new sheet

**Optional Parameters**:
- `row_count`: Number of rows (default: 1000)
- `column_count`: Number of columns (default: 26)

**Examples**:

```bash
# Create sheet with default size
echo '{
  "spreadsheet_id": "abc123",
  "title": "Q4 Data"
}' | sheets_manager.rb create_sheet

# Create large sheet
echo '{
  "spreadsheet_id": "abc123",
  "title": "Large Dataset",
  "row_count": 5000,
  "column_count": 50
}' | sheets_manager.rb create_sheet

# Create small sheet
echo '{
  "spreadsheet_id": "abc123",
  "title": "Lookup Table",
  "row_count": 100,
  "column_count": 10
}' | sheets_manager.rb create_sheet
```

**Success Response**:
```json
{
  "status": "success",
  "operation": "create_sheet",
  "spreadsheet_id": "abc123",
  "sheet_id": 987654,
  "title": "Q4 Data",
  "row_count": 1000,
  "column_count": 26
}
```

**Notes**:
- New sheet is created at the end of existing sheets
- Sheet title must be unique within the spreadsheet
- `sheet_id` in response is needed for format operations
- Default size (1000x26) is suitable for most use cases

---

## Format Operations

### Update Cell Formatting

**Command**: `format`

**Required Parameters**:
- `spreadsheet_id`: The unique ID of the spreadsheet
- `sheet_id`: The numeric sheet ID (from metadata operation)
- `start_row`: Starting row index (0-based)
- `end_row`: Ending row index (exclusive, 0-based)
- `start_col`: Starting column index (0-based)
- `end_col`: Ending column index (exclusive, 0-based)
- `format`: Format object with styling options

**Format Options**:
- `bold`: Boolean (true/false)
- `italic`: Boolean (true/false)
- `fontSize`: Number (e.g., 10, 12, 14)
- `backgroundColor`: Object with `red`, `green`, `blue`, `alpha` (0-1 scale)

**Examples**:

```bash
# Format header row (bold)
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 0,
  "end_row": 1,
  "start_col": 0,
  "end_col": 10,
  "format": {
    "bold": true,
    "fontSize": 12
  }
}' | sheets_manager.rb format

# Highlight cells with background color
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 5,
  "end_row": 6,
  "start_col": 2,
  "end_col": 3,
  "format": {
    "backgroundColor": {
      "red": 1.0,
      "green": 0.9,
      "blue": 0.0,
      "alpha": 1.0
    }
  }
}' | sheets_manager.rb format

# Format with multiple styles
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 0,
  "end_row": 1,
  "start_col": 0,
  "end_col": 5,
  "format": {
    "bold": true,
    "italic": false,
    "fontSize": 14,
    "backgroundColor": {
      "red": 0.85,
      "green": 0.85,
      "blue": 0.85,
      "alpha": 1.0
    }
  }
}' | sheets_manager.rb format
```

**Success Response**:
```json
{
  "status": "success",
  "operation": "format",
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "formatted_range": "R0C0:R1C10"
}
```

**Important Notes**:
- Indices are 0-based (first row = 0, first column = 0)
- End indices are exclusive (to format row 1: start_row=0, end_row=1)
- Get sheet_id from metadata operation first
- RGB colors use 0-1 scale (not 0-255)
- Alpha channel: 1.0 = fully opaque, 0.0 = fully transparent

**Common Color Values**:
- White: `{"red": 1, "green": 1, "blue": 1, "alpha": 1}`
- Black: `{"red": 0, "green": 0, "blue": 0, "alpha": 1}`
- Light Gray: `{"red": 0.9, "green": 0.9, "blue": 0.9, "alpha": 1}`
- Yellow: `{"red": 1, "green": 1, "blue": 0, "alpha": 1}`
- Light Blue: `{"red": 0.8, "green": 0.9, "blue": 1, "alpha": 1}`

---

## Batch Operations

### Batch Update Multiple Ranges

**Command**: `batch_update`

**Required Parameters**:
- `spreadsheet_id`: The unique ID of the spreadsheet
- `updates`: Array of update objects, each containing:
  - `range`: A1 notation range
  - `values`: 2D array of values

**Examples**:

```bash
# Update multiple ranges at once
echo '{
  "spreadsheet_id": "abc123",
  "updates": [
    {
      "range": "Sheet1!A1:A3",
      "values": [["Name"], ["Alice"], ["Bob"]]
    },
    {
      "range": "Sheet1!B1:B3",
      "values": [["Age"], [30], [25]]
    },
    {
      "range": "Sheet1!C1:C3",
      "values": [["City"], ["Chicago"], ["New York"]]
    }
  ]
}' | sheets_manager.rb batch_update

# Update with formulas
echo '{
  "spreadsheet_id": "abc123",
  "updates": [
    {
      "range": "Sheet1!A1:A5",
      "values": [[100], [200], [300], [400], [500]]
    },
    {
      "range": "Sheet1!B1",
      "values": [["=SUM(A1:A5)"]]
    },
    {
      "range": "Sheet1!B2",
      "values": [["=AVERAGE(A1:A5)"]]
    }
  ]
}' | sheets_manager.rb batch_update
```

**Success Response**:
```json
{
  "status": "success",
  "operation": "batch_update",
  "spreadsheet_id": "abc123",
  "total_updated_cells": 15,
  "total_updated_rows": 5,
  "responses": 3
}
```

**Benefits**:
- Single API call for multiple updates
- More efficient than individual write operations
- Atomic operation (all updates succeed or all fail)
- Perfect for populating templates or importing data

**Use Cases**:
- Populating data entry templates
- Importing CSV or JSON data
- Setting up calculated fields with formulas
- Updating multiple sheets simultaneously

---

## Common Patterns

### Data Import Pattern

```bash
# 1. Clear existing data
echo '{"spreadsheet_id":"abc123","range":"Sheet1"}' | sheets_manager.rb clear

# 2. Write headers with formatting
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 0,
  "end_row": 1,
  "start_col": 0,
  "end_col": 5,
  "format": {"bold": true, "backgroundColor": {"red": 0.9, "green": 0.9, "blue": 0.9, "alpha": 1}}
}' | sheets_manager.rb format

# 3. Batch update data
echo '{
  "spreadsheet_id": "abc123",
  "updates": [
    {"range": "Sheet1!A1:E1", "values": [["Name", "Age", "City", "Score", "Rank"]]},
    {"range": "Sheet1!A2:E5", "values": [...data rows...]}
  ]
}' | sheets_manager.rb batch_update
```

### Logging Pattern

```bash
# Append new log entry with timestamp
echo '{
  "spreadsheet_id": "abc123",
  "range": "Logs!A1",
  "values": [["2024-11-10 10:30:00", "INFO", "Operation completed successfully"]],
  "input_option": "USER_ENTERED"
}' | sheets_manager.rb append
```

### Report Generation Pattern

```bash
# 1. Create new sheet for report
echo '{
  "spreadsheet_id": "abc123",
  "title": "Monthly Report - Nov 2024"
}' | sheets_manager.rb create_sheet

# 2. Populate report data
echo '{
  "spreadsheet_id": "abc123",
  "updates": [
    {"range": "Monthly Report - Nov 2024!A1", "values": [["Monthly Sales Report"]]},
    {"range": "Monthly Report - Nov 2024!A3:C3", "values": [["Product", "Sales", "Profit"]]},
    {"range": "Monthly Report - Nov 2024!A4:C10", "values": [...report data...]}
  ]
}' | sheets_manager.rb batch_update
```

---

## Error Codes

### Common Errors

**AUTH_REQUIRED**:
- OAuth authorization needed
- Follow auth_url in response
- Run auth command with code

**API_ERROR**:
- Google Sheets API returned an error
- Check error message and details
- Common causes:
  - Invalid spreadsheet_id
  - Invalid range notation
  - Permission denied
  - Rate limit exceeded

**MISSING_REQUIRED_FIELDS**:
- Required parameters missing from request
- Review command documentation
- Check JSON structure

**INVALID_COMMAND**:
- Unknown command specified
- Use one of: read, write, append, clear, metadata, create_sheet, format, batch_update

**Operation Specific Errors**:
- `READ_FAILED`: Error reading cell values
- `WRITE_FAILED`: Error writing cell values
- `APPEND_FAILED`: Error appending rows
- `CLEAR_FAILED`: Error clearing values
- `METADATA_FAILED`: Error retrieving metadata
- `CREATE_SHEET_FAILED`: Error creating sheet
- `FORMAT_FAILED`: Error updating format
- `BATCH_UPDATE_FAILED`: Error in batch update

### Troubleshooting

**"Requested entity was not found"**:
- Spreadsheet ID is incorrect
- Sheet name in range doesn't exist
- Verify ID from Google Sheets URL

**"Unable to parse range"**:
- Invalid A1 notation
- Check sheet name spelling
- Use single quotes for sheet names with spaces

**"The caller does not have permission"**:
- Spreadsheet not shared with authorized account
- Share spreadsheet with OAuth email
- Check sharing settings in Google Sheets

**"Quota exceeded"**:
- Too many API calls in short time
- Wait and retry
- Use batch operations to reduce API calls

---

**Last Updated**: November 10, 2025
**Version**: 1.0.0
