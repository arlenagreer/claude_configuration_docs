# Google Drive Operations Reference

Complete reference for Google Drive API v3 operations via `drive_manager.rb`.

## Table of Contents
- [File Operations](#file-operations)
- [Folder Operations](#folder-operations)
- [Search and Query](#search-and-query)
- [Sharing and Permissions](#sharing-and-permissions)
- [Export and Download](#export-and-download)
- [Advanced Topics](#advanced-topics)

---

## File Operations

### List Files

**Command**:
```bash
drive_manager.rb --list [--page-size N] [--page-token TOKEN] [--type MIMETYPE]
```

**Parameters**:
- `--page-size N`: Number of files to return (default: 100, max: 1000)
- `--page-token TOKEN`: Token for next page of results
- `--type MIMETYPE`: Filter by MIME type

**Response**:
```json
{
  "status": "success",
  "operation": "list",
  "files": [
    {
      "id": "1abc...",
      "name": "document.pdf",
      "mimeType": "application/pdf",
      "createdTime": "2024-01-01T10:00:00Z",
      "modifiedTime": "2024-01-02T15:30:00Z",
      "size": "1048576",
      "webViewLink": "https://drive.google.com/file/d/...",
      "parents": ["0B_folder_id"]
    }
  ],
  "nextPageToken": "token_for_next_page"
}
```

**Pagination Example**:
```bash
# Get first page
RESULT=$(drive_manager.rb --list --page-size 50)
TOKEN=$(echo $RESULT | jq -r '.nextPageToken')

# Get next page
drive_manager.rb --list --page-size 50 --page-token "$TOKEN"
```

### Get File Details

**Command**:
```bash
drive_manager.rb --get FILE_ID [--include-download-url]
```

**Parameters**:
- `FILE_ID`: The Drive file ID
- `--include-download-url`: Include download/export URLs

**Response**:
```json
{
  "status": "success",
  "operation": "get",
  "file": {
    "id": "1abc...",
    "name": "document.pdf",
    "mimeType": "application/pdf",
    "size": "1048576",
    "createdTime": "2024-01-01T10:00:00Z",
    "modifiedTime": "2024-01-02T15:30:00Z",
    "owners": [{"displayName": "User Name", "emailAddress": "user@example.com"}],
    "permissions": [...],
    "webViewLink": "https://drive.google.com/file/d/...",
    "downloadUrl": "https://www.googleapis.com/drive/v3/files/.../export"
  }
}
```

### Upload File

**Command**:
```bash
drive_manager.rb --upload /path/to/file [--folder FOLDER_ID] [--name "Custom Name"] [--description "Description"]
```

**Parameters**:
- `/path/to/file`: Local file path (required)
- `--folder FOLDER_ID`: Parent folder ID (optional, defaults to root)
- `--name "Custom Name"`: Custom file name (optional, uses original filename)
- `--description "Description"`: File description metadata (optional)

**Response**:
```json
{
  "status": "success",
  "operation": "upload",
  "file": {
    "id": "1abc...",
    "name": "uploaded_file.pdf",
    "mimeType": "application/pdf",
    "size": "1048576",
    "webViewLink": "https://drive.google.com/file/d/..."
  }
}
```

**Large File Upload**:
```bash
# Files >5MB use resumable upload automatically
drive_manager.rb --upload large_file.zip --folder "1folder_id"
```

### Update File Metadata

**Command**:
```bash
drive_manager.rb --update FILE_ID [--name "New Name"] [--description "New Description"] [--move-to FOLDER_ID]
```

**Parameters**:
- `FILE_ID`: File to update
- `--name "New Name"`: Rename file
- `--description "New Description"`: Update description
- `--move-to FOLDER_ID`: Move to different folder

**Response**:
```json
{
  "status": "success",
  "operation": "update",
  "file": {
    "id": "1abc...",
    "name": "new_name.pdf",
    "parents": ["1new_folder_id"]
  }
}
```

### Delete File

**Command**:
```bash
drive_manager.rb --delete FILE_ID [--permanent]
```

**Parameters**:
- `FILE_ID`: File to delete
- `--permanent`: Permanently delete (bypass trash)

**Response**:
```json
{
  "status": "success",
  "operation": "delete",
  "file_id": "1abc...",
  "permanent": false
}
```

**Important**: Without `--permanent`, files go to trash and can be restored.

### Copy File

**Command**:
```bash
drive_manager.rb --copy FILE_ID [--name "Copy Name"] [--folder FOLDER_ID]
```

**Parameters**:
- `FILE_ID`: File to copy
- `--name "Copy Name"`: Name for copy
- `--folder FOLDER_ID`: Destination folder

**Response**:
```json
{
  "status": "success",
  "operation": "copy",
  "file": {
    "id": "1new_id...",
    "name": "Copy of document.pdf",
    "parents": ["1folder_id"]
  }
}
```

---

## Folder Operations

### Create Folder

**Command**:
```bash
drive_manager.rb --create-folder "Folder Name" [--folder PARENT_ID] [--create-path]
```

**Parameters**:
- `"Folder Name"`: Name of new folder
- `--folder PARENT_ID`: Parent folder (optional, defaults to root)
- `--create-path`: Create nested folder structure

**Response**:
```json
{
  "status": "success",
  "operation": "create_folder",
  "folder": {
    "id": "1folder_id...",
    "name": "New Folder",
    "mimeType": "application/vnd.google-apps.folder",
    "webViewLink": "https://drive.google.com/drive/folders/..."
  }
}
```

**Nested Folder Creation**:
```bash
# Create "2024/Q4/Reports" structure
drive_manager.rb --create-folder "2024/Q4/Reports" --create-path

# Returns array of created folders
{
  "status": "success",
  "operation": "create_folder",
  "folders": [
    {"id": "1...", "name": "2024"},
    {"id": "2...", "name": "Q4"},
    {"id": "3...", "name": "Reports"}
  ]
}
```

### List Folder Contents

**Command**:
```bash
drive_manager.rb --list --folder FOLDER_ID
```

Lists all files and subfolders within specified folder.

---

## Search and Query

### Simple Search

**Command**:
```bash
drive_manager.rb --search "search term" [--exact] [--folder FOLDER_ID]
```

**Parameters**:
- `"search term"`: Text to search for in file names
- `--exact`: Match exact name (not partial)
- `--folder FOLDER_ID`: Search within specific folder

**Response**:
```json
{
  "status": "success",
  "operation": "search",
  "query": "search term",
  "count": 5,
  "files": [...]
}
```

### Advanced Query

**Command**:
```bash
drive_manager.rb --query "DRIVE_API_QUERY"
```

**Query Syntax**:

**Basic Operators**:
- `name = 'filename'` - Exact name match
- `name contains 'text'` - Partial name match
- `mimeType = 'type'` - Filter by MIME type
- `trashed = true/false` - Include/exclude trashed files
- `starred = true/false` - Only starred files

**Comparison Operators**:
- `modifiedTime > '2024-01-01T00:00:00'` - Modified after date
- `modifiedTime < '2024-12-31T23:59:59'` - Modified before date
- `createdTime >= '2024-01-01'` - Created on or after
- `size > 10485760` - Files larger than 10MB

**Logical Operators**:
- `and` - Combine conditions
- `or` - Alternative conditions
- `not` - Negate condition

**Special Queries**:
- `sharedWithMe = true` - Files shared with you
- `'user@example.com' in owners` - Files owned by user
- `'folder_id' in parents` - Files in specific folder

**Query Examples**:

```bash
# PDFs modified in last 7 days
drive_manager.rb --query "mimeType='application/pdf' and modifiedTime > '2024-10-24'"

# Large files (>10MB) not in trash
drive_manager.rb --query "size > 10485760 and trashed = false"

# Google Docs shared with me
drive_manager.rb --query "mimeType='application/vnd.google-apps.document' and sharedWithMe = true"

# Files in specific folder modified this year
drive_manager.rb --query "'1folder_id' in parents and modifiedTime > '2024-01-01'"

# Starred spreadsheets
drive_manager.rb --query "mimeType='application/vnd.google-apps.spreadsheet' and starred = true"

# Complex query with multiple conditions
drive_manager.rb --query "mimeType='application/pdf' and modifiedTime > '2024-01-01' and not trashed and size < 5242880"
```

**Date Format**: ISO 8601 format (YYYY-MM-DDTHH:MM:SS) or simplified (YYYY-MM-DD)

**Field Reference**:
- `name` - File name
- `mimeType` - MIME type
- `createdTime` - Creation timestamp
- `modifiedTime` - Last modification timestamp
- `viewedByMeTime` - Last viewed timestamp
- `size` - File size in bytes
- `starred` - Starred status
- `trashed` - Trash status
- `parents` - Parent folder IDs
- `owners` - Owner email addresses
- `sharedWithMe` - Shared with me status

---

## Sharing and Permissions

### Share File/Folder

**Command**:
```bash
drive_manager.rb --share FILE_ID --email EMAIL --role ROLE [--anyone]
```

**Parameters**:
- `FILE_ID`: File or folder to share
- `--email EMAIL`: Email address of user/group
- `--role ROLE`: Permission role (reader, commenter, writer, owner)
- `--anyone`: Share with anyone with link (omit --email)

**Permission Roles**:
- `reader` - Can view and download
- `commenter` - Can view and comment
- `writer` - Can edit and organize
- `owner` - Full control (transfer ownership)

**Response**:
```json
{
  "status": "success",
  "operation": "share",
  "file_id": "1abc...",
  "permission": {
    "id": "permission_id",
    "type": "user",
    "role": "writer",
    "emailAddress": "user@example.com"
  }
}
```

**Examples**:

```bash
# Share with specific user (writer)
drive_manager.rb --share "1file_id" --email "user@example.com" --role writer

# Share with anyone (reader)
drive_manager.rb --share "1file_id" --role reader --anyone

# Make file public
drive_manager.rb --share "1file_id" --role reader --anyone

# Share folder with team
drive_manager.rb --share "1folder_id" --email "team@company.com" --role writer
```

### List Permissions

**Command**:
```bash
drive_manager.rb --list-permissions FILE_ID
```

**Response**:
```json
{
  "status": "success",
  "operation": "list_permissions",
  "file_id": "1abc...",
  "permissions": [
    {
      "id": "permission_id",
      "type": "user",
      "role": "owner",
      "emailAddress": "owner@example.com"
    },
    {
      "id": "permission_id_2",
      "type": "user",
      "role": "writer",
      "emailAddress": "writer@example.com"
    }
  ]
}
```

### Remove Permission

**Command**:
```bash
drive_manager.rb --remove-permission FILE_ID --permission-id PERMISSION_ID
```

**Response**:
```json
{
  "status": "success",
  "operation": "remove_permission",
  "file_id": "1abc...",
  "permission_id": "permission_id"
}
```

---

## Export and Download

### Download Files

**Command**:
```bash
drive_manager.rb --download FILE_ID [--output /path/to/save] [--export-format FORMAT]
```

**Parameters**:
- `FILE_ID`: File to download
- `--output /path`: Save location (optional, defaults to current directory)
- `--export-format FORMAT`: Export format for Google Workspace files

**Regular Files**:
```bash
# Download PDF
drive_manager.rb --download "1file_id" --output "/downloads/file.pdf"

# Download to current directory
drive_manager.rb --download "1file_id"
```

**Google Workspace Files**:
```bash
# Export Google Doc as PDF
drive_manager.rb --download "1doc_id" --export-format "application/pdf"

# Export Google Sheet as Excel
drive_manager.rb --download "1sheet_id" --export-format "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

# Export Google Doc as DOCX
drive_manager.rb --download "1doc_id" --export-format "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
```

**Export Format Reference**:

**Google Docs**:
- `text/plain` - Plain text (.txt)
- `text/html` - HTML (.html)
- `application/pdf` - PDF (.pdf)
- `application/vnd.openxmlformats-officedocument.wordprocessingml.document` - DOCX (.docx)
- `application/rtf` - Rich Text Format (.rtf)
- `application/epub+zip` - EPUB (.epub)

**Google Sheets**:
- `text/csv` - CSV (.csv)
- `application/pdf` - PDF (.pdf)
- `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` - XLSX (.xlsx)
- `application/x-vnd.oasis.opendocument.spreadsheet` - ODS (.ods)
- `text/tab-separated-values` - TSV (.tsv)

**Google Slides**:
- `application/pdf` - PDF (.pdf)
- `application/vnd.openxmlformats-officedocument.presentationml.presentation` - PPTX (.pptx)
- `application/vnd.oasis.opendocument.presentation` - ODP (.odp)
- `text/plain` - Plain text (.txt)

**Response**:
```json
{
  "status": "success",
  "operation": "download",
  "file_id": "1abc...",
  "output_path": "/path/to/file.pdf",
  "size": "1048576"
}
```

### Read File Content

**Command**:
```bash
drive_manager.rb --read FILE_ID [--export-format FORMAT]
```

Reads text-based file content directly (outputs to stdout).

**Supported File Types**:
- Plain text files (.txt)
- Google Docs (exports as text)
- CSV files
- JSON files
- Markdown files (.md)

**Example**:
```bash
# Read text file content
drive_manager.rb --read "1file_id"

# Read Google Doc as plain text
drive_manager.rb --read "1doc_id" --export-format "text/plain"

# Read and process CSV
drive_manager.rb --read "1csv_id" | process_csv.sh
```

---

## Advanced Topics

### Batch Operations

**Multiple File Upload**:
```bash
# Upload multiple files to same folder
for file in /path/to/files/*; do
  drive_manager.rb --upload "$file" --folder "1folder_id"
done
```

**Bulk Download**:
```bash
# Download all PDFs from search
drive_manager.rb --query "mimeType='application/pdf'" > pdfs.json
cat pdfs.json | jq -r '.files[].id' | while read file_id; do
  drive_manager.rb --download "$file_id" --output "/backup/"
done
```

**Mass Permission Update**:
```bash
# Share all files in folder with team
drive_manager.rb --list --folder "1folder_id" > files.json
cat files.json | jq -r '.files[].id' | while read file_id; do
  drive_manager.rb --share "$file_id" --email "team@company.com" --role writer
done
```

### Error Handling

**Error Response Format**:
```json
{
  "status": "error",
  "error_code": "AUTH_ERROR|API_ERROR|FILE_NOT_FOUND|INVALID_ARGS",
  "message": "Detailed error message",
  "details": "Additional context"
}
```

**Exit Codes**:
- `0` - Success
- `1` - Operation failed
- `2` - Authentication error
- `3` - API error
- `4` - Invalid arguments
- `5` - File not found

**Common Errors**:

**Authentication Error**:
```json
{
  "status": "error",
  "error_code": "AUTH_ERROR",
  "message": "Token expired or invalid",
  "solution": "Run: rm ~/.claude/.google/token.json && drive_manager.rb --list"
}
```

**File Not Found**:
```json
{
  "status": "error",
  "error_code": "FILE_NOT_FOUND",
  "message": "File not found or access denied",
  "file_id": "1invalid_id"
}
```

**Quota Exceeded**:
```json
{
  "status": "error",
  "error_code": "API_ERROR",
  "message": "Rate limit exceeded",
  "solution": "Wait a few minutes and retry"
}
```

### Performance Optimization

**Pagination for Large Results**:
```bash
# Use smaller page sizes for faster initial response
drive_manager.rb --list --page-size 50

# Use larger page sizes for fewer API calls
drive_manager.rb --list --page-size 1000
```

**Field Filtering** (reduces response size):
```bash
# Get only essential fields (implemented in script)
drive_manager.rb --get FILE_ID
```

**Parallel Operations**:
```bash
# Download multiple files in parallel
cat file_ids.txt | xargs -P 5 -I {} drive_manager.rb --download {} --output "/backup/"
```

### Integration Examples

**Backup Strategy**:
```bash
#!/bin/bash
# Backup all important files daily

BACKUP_DIR="/backup/drive/$(date +%Y-%m-%d)"
mkdir -p "$BACKUP_DIR"

# Get all starred files
drive_manager.rb --query "starred=true" > starred.json

# Download each
cat starred.json | jq -r '.files[].id' | while read id; do
  drive_manager.rb --download "$id" --output "$BACKUP_DIR/"
done
```

**Sync Script**:
```bash
#!/bin/bash
# Sync local directory to Drive folder

FOLDER_ID="1target_folder_id"
LOCAL_DIR="/path/to/local/files"

for file in "$LOCAL_DIR"/*; do
  drive_manager.rb --upload "$file" --folder "$FOLDER_ID"
done
```

**Content Organization**:
```bash
#!/bin/bash
# Organize files by type into folders

# Create folders by type
PDF_FOLDER=$(drive_manager.rb --create-folder "PDFs" | jq -r '.folder.id')
DOCS_FOLDER=$(drive_manager.rb --create-folder "Documents" | jq -r '.folder.id')

# Move PDFs
drive_manager.rb --query "mimeType='application/pdf'" > pdfs.json
cat pdfs.json | jq -r '.files[].id' | while read id; do
  drive_manager.rb --update "$id" --move-to "$PDF_FOLDER"
done

# Move Google Docs
drive_manager.rb --query "mimeType='application/vnd.google-apps.document'" > docs.json
cat docs.json | jq -r '.files[].id' | while read id; do
  drive_manager.rb --update "$id" --move-to "$DOCS_FOLDER"
done
```

---

## API Quota Limits

Google Drive API has rate limits:
- **Queries per 100 seconds per user**: 1,000
- **Queries per 100 seconds**: 10,000

**Best Practices**:
- Use pagination for large result sets
- Implement exponential backoff on rate limit errors
- Cache frequently accessed file metadata
- Batch operations when possible

**Rate Limit Error Handling**:
```bash
# Retry with exponential backoff
attempt=1
max_attempts=5
while [ $attempt -le $max_attempts ]; do
  drive_manager.rb --list && break
  sleep $((2 ** attempt))
  attempt=$((attempt + 1))
done
```

---

## Troubleshooting

### Authentication Issues
```bash
# Re-authorize with new scopes
rm ~/.claude/.google/token.json
drive_manager.rb --list
# Follow OAuth flow
```

### Permission Denied
- Verify file ownership or sharing permissions
- Check if file is in trash
- Confirm API scopes are correct

### File Not Found
- Verify file ID is correct
- Check if file was deleted or moved
- Ensure you have access to the file

### Slow Performance
- Use field filtering to reduce response size
- Implement caching for frequently accessed files
- Use pagination for large result sets
- Consider parallel operations for bulk tasks

---

**Version**: 1.0.0  
**Last Updated**: November 10, 2025  
**Ruby Gem**: google-apis-drive_v3  
**API Version**: Drive API v3
