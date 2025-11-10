# Cell Formatting Reference

Complete guide to cell formatting options in Google Sheets skill.

## Table of Contents

1. [Formatting Overview](#formatting-overview)
2. [Text Formatting](#text-formatting)
3. [Background Colors](#background-colors)
4. [Color Reference](#color-reference)
5. [Format Combinations](#format-combinations)
6. [Best Practices](#best-practices)
7. [Common Formatting Patterns](#common-formatting-patterns)

---

## Formatting Overview

### Format Command Structure

```bash
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
    "fontSize": 12,
    "backgroundColor": {
      "red": 0.9,
      "green": 0.9,
      "blue": 0.9,
      "alpha": 1.0
    }
  }
}' | sheets_manager.rb format
```

### Key Concepts

**Row/Column Indices**:
- 0-based indexing
- End indices are exclusive
- Example: To format row 1 (the first row):
  - `start_row: 0, end_row: 1`
- Example: To format columns A-E (first 5 columns):
  - `start_col: 0, end_col: 5`

**Sheet ID vs Sheet Index**:
- `sheet_id`: Unique numeric identifier (use this for formatting)
- `sheet_index`: Position in sheet list (0, 1, 2, ...)
- Get `sheet_id` from metadata operation

**Format Application**:
- Applied to entire specified range
- Overwrites existing formatting in that range
- Does not affect cell values

---

## Text Formatting

### Bold Text

**Property**: `bold`
**Type**: Boolean
**Values**: `true` or `false`

```bash
# Make text bold
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 0,
  "end_row": 1,
  "start_col": 0,
  "end_col": 10,
  "format": {
    "bold": true
  }
}' | sheets_manager.rb format

# Remove bold
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 0,
  "end_row": 1,
  "start_col": 0,
  "end_col": 10,
  "format": {
    "bold": false
  }
}' | sheets_manager.rb format
```

**Use Cases**:
- Header rows
- Section titles
- Emphasis on key data
- Summary rows

### Italic Text

**Property**: `italic`
**Type**: Boolean
**Values**: `true` or `false`

```bash
# Make text italic
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 5,
  "end_row": 6,
  "start_col": 0,
  "end_col": 5,
  "format": {
    "italic": true
  }
}' | sheets_manager.rb format
```

**Use Cases**:
- Notes or comments
- Dates or timestamps
- Secondary information
- Placeholder text

### Font Size

**Property**: `fontSize`
**Type**: Number
**Common Values**: 8, 9, 10, 11, 12, 14, 16, 18, 24

```bash
# Large header text
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 0,
  "end_row": 1,
  "start_col": 0,
  "end_col": 10,
  "format": {
    "fontSize": 14,
    "bold": true
  }
}' | sheets_manager.rb format

# Small footnote text
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 20,
  "end_row": 21,
  "start_col": 0,
  "end_col": 5,
  "format": {
    "fontSize": 9,
    "italic": true
  }
}' | sheets_manager.rb format
```

**Recommended Sizes**:
- **8-9**: Fine print, footnotes
- **10-11**: Regular body text
- **12**: Standard size, good readability
- **14**: Section headers, important data
- **16-18**: Main headers
- **24+**: Title text

---

## Background Colors

### Color Object Structure

```json
{
  "backgroundColor": {
    "red": 0.9,
    "green": 0.9,
    "blue": 0.9,
    "alpha": 1.0
  }
}
```

**Properties**:
- `red`: Float 0.0 - 1.0 (0% to 100%)
- `green`: Float 0.0 - 1.0 (0% to 100%)
- `blue`: Float 0.0 - 1.0 (0% to 100%)
- `alpha`: Float 0.0 - 1.0 (transparency: 0=transparent, 1=opaque)

### RGB Scale Conversion

**From 0-255 to 0-1 scale**:
```
0-1 value = (0-255 value) / 255
```

**Examples**:
- RGB(255, 255, 255) → (1.0, 1.0, 1.0) - White
- RGB(128, 128, 128) → (0.5, 0.5, 0.5) - Gray
- RGB(255, 0, 0) → (1.0, 0.0, 0.0) - Red
- RGB(230, 230, 230) → (0.9, 0.9, 0.9) - Light Gray

### Basic Background Colors

```bash
# Light gray background (headers)
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 0,
  "end_row": 1,
  "start_col": 0,
  "end_col": 10,
  "format": {
    "backgroundColor": {
      "red": 0.9,
      "green": 0.9,
      "blue": 0.9,
      "alpha": 1.0
    }
  }
}' | sheets_manager.rb format

# Yellow highlight
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
      "green": 1.0,
      "blue": 0.0,
      "alpha": 1.0
    }
  }
}' | sheets_manager.rb format

# Light blue background
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 10,
  "end_row": 11,
  "start_col": 0,
  "end_col": 5,
  "format": {
    "backgroundColor": {
      "red": 0.8,
      "green": 0.9,
      "blue": 1.0,
      "alpha": 1.0
    }
  }
}' | sheets_manager.rb format
```

---

## Color Reference

### Neutral Colors

| Color | Red | Green | Blue | Use Case |
|-------|-----|-------|------|----------|
| White | 1.0 | 1.0 | 1.0 | Default, clean |
| Light Gray | 0.9 | 0.9 | 0.9 | Headers, sections |
| Medium Gray | 0.7 | 0.7 | 0.7 | Disabled, inactive |
| Dark Gray | 0.5 | 0.5 | 0.5 | Emphasis |
| Black | 0.0 | 0.0 | 0.0 | Strong contrast |

### Highlight Colors

| Color | Red | Green | Blue | Use Case |
|-------|-----|-------|------|----------|
| Light Yellow | 1.0 | 1.0 | 0.8 | Attention, caution |
| Yellow | 1.0 | 1.0 | 0.0 | Highlight, warning |
| Light Green | 0.8 | 1.0 | 0.8 | Success, positive |
| Green | 0.0 | 1.0 | 0.0 | Active, go |
| Light Red | 1.0 | 0.8 | 0.8 | Error, caution |
| Red | 1.0 | 0.0 | 0.0 | Alert, danger |
| Light Blue | 0.8 | 0.9 | 1.0 | Information |
| Blue | 0.0 | 0.5 | 1.0 | Primary, active |

### Pastel Colors (Professional)

| Color | Red | Green | Blue | Use Case |
|-------|-----|-------|------|----------|
| Pastel Pink | 1.0 | 0.9 | 0.95 | Soft emphasis |
| Pastel Peach | 1.0 | 0.95 | 0.85 | Warm highlight |
| Pastel Yellow | 1.0 | 1.0 | 0.9 | Subtle attention |
| Pastel Green | 0.9 | 1.0 | 0.9 | Success, positive |
| Pastel Blue | 0.9 | 0.95 | 1.0 | Information |
| Pastel Purple | 0.95 | 0.9 | 1.0 | Alternative |

### Data Visualization Colors

| Color | Red | Green | Blue | Use Case |
|-------|-----|-------|------|----------|
| Light Orange | 1.0 | 0.85 | 0.7 | Metrics, KPIs |
| Orange | 1.0 | 0.65 | 0.0 | Warnings |
| Light Teal | 0.7 | 0.95 | 0.95 | Data ranges |
| Teal | 0.0 | 0.8 | 0.8 | Categories |
| Light Purple | 0.9 | 0.8 | 1.0 | Grouping |
| Purple | 0.5 | 0.0 | 0.8 | Special cases |

---

## Format Combinations

### Header Row (Professional)

```bash
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 0,
  "end_row": 1,
  "start_col": 0,
  "end_col": 10,
  "format": {
    "bold": true,
    "fontSize": 12,
    "backgroundColor": {
      "red": 0.85,
      "green": 0.85,
      "blue": 0.85,
      "alpha": 1.0
    }
  }
}' | sheets_manager.rb format
```

### Title Row (Large and Bold)

```bash
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 0,
  "end_row": 1,
  "start_col": 0,
  "end_col": 10,
  "format": {
    "bold": true,
    "fontSize": 16,
    "backgroundColor": {
      "red": 0.2,
      "green": 0.4,
      "blue": 0.8,
      "alpha": 1.0
    }
  }
}' | sheets_manager.rb format
```

### Summary Row (Bold with Yellow)

```bash
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 15,
  "end_row": 16,
  "start_col": 0,
  "end_col": 10,
  "format": {
    "bold": true,
    "fontSize": 12,
    "backgroundColor": {
      "red": 1.0,
      "green": 1.0,
      "blue": 0.8,
      "alpha": 1.0
    }
  }
}' | sheets_manager.rb format
```

### Warning Cell (Bold with Light Red)

```bash
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 10,
  "end_row": 11,
  "start_col": 5,
  "end_col": 6,
  "format": {
    "bold": true,
    "fontSize": 12,
    "backgroundColor": {
      "red": 1.0,
      "green": 0.8,
      "blue": 0.8,
      "alpha": 1.0
    }
  }
}' | sheets_manager.rb format
```

### Note Row (Italic with Light Blue)

```bash
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 20,
  "end_row": 21,
  "start_col": 0,
  "end_col": 10,
  "format": {
    "italic": true,
    "fontSize": 10,
    "backgroundColor": {
      "red": 0.9,
      "green": 0.95,
      "blue": 1.0,
      "alpha": 1.0
    }
  }
}' | sheets_manager.rb format
```

---

## Best Practices

### Readability

1. **Use sufficient contrast**: Dark text on light backgrounds, or vice versa
2. **Avoid bright colors**: Use pastel shades for backgrounds
3. **Consistent sizing**: Use 2-3 font sizes maximum per sheet
4. **Bold for emphasis**: Don't overuse - reserve for important data

### Professional Appearance

1. **Neutral color palette**: Grays, blues, and greens are professional
2. **Subtle highlights**: Light pastels instead of bright neons
3. **Consistent patterns**: Use same formatting for same types of data
4. **White space**: Don't fill every cell with color

### Performance

1. **Format ranges, not individual cells**: More efficient API usage
2. **Batch formatting operations**: Combine multiple format calls when possible
3. **Reuse formats**: Apply same format to multiple similar ranges
4. **Minimal formatting**: Only format what needs emphasis

### Accessibility

1. **High contrast**: Ensure text is readable against background
2. **Don't rely on color alone**: Use text labels or icons too
3. **Consistent patterns**: Similar data gets similar formatting
4. **Test readability**: View sheet at different zoom levels

---

## Common Formatting Patterns

### Spreadsheet Template Pattern

```bash
# 1. Title row
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 0,
  "end_row": 1,
  "start_col": 0,
  "end_col": 10,
  "format": {
    "bold": true,
    "fontSize": 14,
    "backgroundColor": {"red": 0.2, "green": 0.4, "blue": 0.8, "alpha": 1.0}
  }
}' | sheets_manager.rb format

# 2. Header row
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 2,
  "end_row": 3,
  "start_col": 0,
  "end_col": 10,
  "format": {
    "bold": true,
    "fontSize": 11,
    "backgroundColor": {"red": 0.85, "green": 0.85, "blue": 0.85, "alpha": 1.0}
  }
}' | sheets_manager.rb format

# 3. Alternating row colors (light gray)
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 4,
  "end_row": 5,
  "start_col": 0,
  "end_col": 10,
  "format": {
    "backgroundColor": {"red": 0.95, "green": 0.95, "blue": 0.95, "alpha": 1.0}
  }
}' | sheets_manager.rb format

# 4. Total row
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 15,
  "end_row": 16,
  "start_col": 0,
  "end_col": 10,
  "format": {
    "bold": true,
    "backgroundColor": {"red": 1.0, "green": 1.0, "blue": 0.8, "alpha": 1.0}
  }
}' | sheets_manager.rb format
```

### Data Dashboard Pattern

```bash
# KPI cells (bold, large, light blue)
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 0,
  "end_row": 2,
  "start_col": 0,
  "end_col": 4,
  "format": {
    "bold": true,
    "fontSize": 14,
    "backgroundColor": {"red": 0.8, "green": 0.9, "blue": 1.0, "alpha": 1.0}
  }
}' | sheets_manager.rb format

# Positive metrics (light green)
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 5,
  "end_row": 8,
  "start_col": 2,
  "end_col": 3,
  "format": {
    "backgroundColor": {"red": 0.8, "green": 1.0, "blue": 0.8, "alpha": 1.0}
  }
}' | sheets_manager.rb format

# Negative metrics (light red)
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 9,
  "end_row": 12,
  "start_col": 2,
  "end_col": 3,
  "format": {
    "backgroundColor": {"red": 1.0, "green": 0.8, "blue": 0.8, "alpha": 1.0}
  }
}' | sheets_manager.rb format
```

### Report Format Pattern

```bash
# Section headers (bold, medium gray)
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 0,
  "end_row": 1,
  "start_col": 0,
  "end_col": 8,
  "format": {
    "bold": true,
    "fontSize": 13,
    "backgroundColor": {"red": 0.7, "green": 0.7, "blue": 0.7, "alpha": 1.0}
  }
}' | sheets_manager.rb format

# Subheaders (bold, light gray)
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 3,
  "end_row": 4,
  "start_col": 0,
  "end_col": 8,
  "format": {
    "bold": true,
    "backgroundColor": {"red": 0.9, "green": 0.9, "blue": 0.9, "alpha": 1.0}
  }
}' | sheets_manager.rb format

# Notes (italic, small, light blue)
echo '{
  "spreadsheet_id": "abc123",
  "sheet_id": 0,
  "start_row": 20,
  "end_row": 22,
  "start_col": 0,
  "end_col": 8,
  "format": {
    "italic": true,
    "fontSize": 9,
    "backgroundColor": {"red": 0.9, "green": 0.95, "blue": 1.0, "alpha": 1.0}
  }
}' | sheets_manager.rb format
```

---

## Index Calculation Examples

### Converting Row/Column to Indices

**Example: Format row 5 (fifth row)**
- Row 5 is index 4 (0-based)
- To format: `start_row: 4, end_row: 5`

**Example: Format columns A-F**
- A=0, B=1, C=2, D=3, E=4, F=5
- To format A-F: `start_col: 0, end_col: 6` (6 is exclusive)

**Example: Format cells B3:D7**
- Row 3 = index 2, Row 7 = index 6
- Column B = index 1, Column D = index 3
- To format: `start_row: 2, end_row: 7, start_col: 1, end_col: 4`

### Quick Reference Table

| Excel Range | start_row | end_row | start_col | end_col |
|-------------|-----------|---------|-----------|---------|
| A1:A1 | 0 | 1 | 0 | 1 |
| A1:E1 | 0 | 1 | 0 | 5 |
| A1:A10 | 0 | 10 | 0 | 1 |
| B2:D5 | 1 | 5 | 1 | 4 |
| C10:F15 | 9 | 15 | 2 | 6 |

---

**Last Updated**: November 10, 2025
**Version**: 1.0.0
