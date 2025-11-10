# Google Drive File Types Reference

## MIME Type Categories

### Google Workspace Files

**Google Docs**:
- MIME: `application/vnd.google-apps.document`
- Export formats:
  - `text/plain` - Plain text
  - `text/html` - HTML
  - `application/pdf` - PDF
  - `application/vnd.openxmlformats-officedocument.wordprocessingml.document` - Word (.docx)
  - `application/rtf` - Rich Text Format
  - `application/epub+zip` - EPUB

**Google Sheets**:
- MIME: `application/vnd.google-apps.spreadsheet`
- Export formats:
  - `text/csv` - CSV (first sheet only)
  - `application/pdf` - PDF
  - `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` - Excel (.xlsx)
  - `application/vnd.oasis.opendocument.spreadsheet` - OpenDocument (.ods)
  - `text/tab-separated-values` - TSV (first sheet only)

**Google Slides**:
- MIME: `application/vnd.google-apps.presentation`
- Export formats:
  - `application/pdf` - PDF
  - `application/vnd.openxmlformats-officedocument.presentationml.presentation` - PowerPoint (.pptx)
  - `application/vnd.oasis.opendocument.presentation` - OpenDocument (.odp)
  - `text/plain` - Plain text

**Google Forms**:
- MIME: `application/vnd.google-apps.form`
- Export formats:
  - `application/zip` - Form responses as ZIP

**Google Drawings**:
- MIME: `application/vnd.google-apps.drawing`
- Export formats:
  - `application/pdf` - PDF
  - `image/svg+xml` - SVG
  - `image/png` - PNG
  - `image/jpeg` - JPEG

**Google Sites**:
- MIME: `application/vnd.google-apps.site`
- No export available

**Google My Maps**:
- MIME: `application/vnd.google-apps.map`
- Export formats:
  - `application/pdf` - PDF
  - `application/vnd.google-earth.kml+xml` - KML

### Microsoft Office Files

**Word Documents**:
- `.doc`: `application/msword`
- `.docx`: `application/vnd.openxmlformats-officedocument.wordprocessingml.document`

**Excel Spreadsheets**:
- `.xls`: `application/vnd.ms-excel`
- `.xlsx`: `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`

**PowerPoint Presentations**:
- `.ppt`: `application/vnd.ms-powerpoint`
- `.pptx`: `application/vnd.openxmlformats-officedocument.presentationml.presentation`

### Document Files

**PDF**:
- MIME: `application/pdf`

**Text Files**:
- Plain text: `text/plain`
- Rich text: `application/rtf`
- Markdown: `text/markdown`
- CSV: `text/csv`
- TSV: `text/tab-separated-values`

**HTML**:
- MIME: `text/html`

**XML**:
- MIME: `text/xml` or `application/xml`

**JSON**:
- MIME: `application/json`

### Image Files

**Common Formats**:
- JPEG: `image/jpeg`
- PNG: `image/png`
- GIF: `image/gif`
- BMP: `image/bmp`
- WebP: `image/webp`
- SVG: `image/svg+xml`
- TIFF: `image/tiff`

**RAW Formats**:
- Various RAW formats have specific MIME types

### Video Files

**Common Formats**:
- MP4: `video/mp4`
- MOV: `video/quicktime`
- AVI: `video/x-msvideo`
- WMV: `video/x-ms-wmv`
- FLV: `video/x-flv`
- WebM: `video/webm`

### Audio Files

**Common Formats**:
- MP3: `audio/mpeg`
- WAV: `audio/wav`
- OGG: `audio/ogg`
- M4A: `audio/mp4`
- FLAC: `audio/flac`

### Archive Files

**Common Formats**:
- ZIP: `application/zip`
- TAR: `application/x-tar`
- GZIP: `application/gzip`
- RAR: `application/vnd.rar`
- 7Z: `application/x-7z-compressed`

### Code Files

**Common Languages**:
- JavaScript: `application/javascript` or `text/javascript`
- Python: `text/x-python`
- Java: `text/x-java-source`
- C/C++: `text/x-c` or `text/x-c++`
- Ruby: `text/x-ruby`
- PHP: `application/x-httpd-php`
- Shell: `text/x-shellscript`

### Folders

**Google Drive Folder**:
- MIME: `application/vnd.google-apps.folder`

## Usage Examples

### Filter by Type

```bash
# List only PDFs
drive_manager.rb --list --type "application/pdf"

# List only Google Docs
drive_manager.rb --list --type "application/vnd.google-apps.document"

# List only folders
drive_manager.rb --list --type folder

# List images (use query for pattern matching)
drive_manager.rb --query "mimeType contains 'image/'"
```

### Export Google Workspace Files

```bash
# Export Google Doc as PDF
drive_manager.rb --download FILE_ID --export-format "application/pdf"

# Export Google Sheet as Excel
drive_manager.rb --download FILE_ID --export-format "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

# Export Google Slides as PowerPoint
drive_manager.rb --download FILE_ID --export-format "application/vnd.openxmlformats-officedocument.presentationml.presentation"

# Read Google Doc as plain text
drive_manager.rb --read FILE_ID --export-format "text/plain"
```

### Query by MIME Type

```bash
# Find all spreadsheets (Google Sheets and Excel)
drive_manager.rb --query "mimeType contains 'spreadsheet'"

# Find all documents (Google Docs and Word)
drive_manager.rb --query "mimeType contains 'document'"

# Find all images
drive_manager.rb --query "mimeType contains 'image/'"

# Find all videos
drive_manager.rb --query "mimeType contains 'video/'"

# Combine with other criteria
drive_manager.rb --query "mimeType='application/pdf' and modifiedTime > '2024-01-01'"
```

## Common MIME Type Shortcuts

For convenience, the script recognizes these shortcuts:

- `folder` → `application/vnd.google-apps.folder`
- `doc` → `application/vnd.google-apps.document`
- `sheet` → `application/vnd.google-apps.spreadsheet`
- `slide` → `application/vnd.google-apps.presentation`
- `pdf` → `application/pdf`
- `image` → `image/*` (pattern match)
- `video` → `video/*` (pattern match)
- `audio` → `audio/*` (pattern match)

## Best Practices

1. **Use specific MIME types** when possible for faster queries
2. **Export Google Workspace files** to compatible formats for offline use
3. **Pattern matching** with `contains` for finding all files of a category
4. **Combine filters** in queries for precise file discovery
5. **Check MIME type** before attempting to read/export files

## Additional Resources

- [Google Drive API MIME Types](https://developers.google.com/drive/api/guides/mime-types)
- [IANA Media Types Registry](https://www.iana.org/assignments/media-types/media-types.xhtml)
- [Google Workspace Export Formats](https://developers.google.com/drive/api/guides/ref-export-formats)
