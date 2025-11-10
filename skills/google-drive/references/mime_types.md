# Google Drive MIME Types Reference

Comprehensive reference for Google Drive file types, MIME types, and export formats.

## Table of Contents
- [Google Workspace File Types](#google-workspace-file-types)
- [Common Document Formats](#common-document-formats)
- [Media File Types](#media-file-types)
- [Archive and Compressed Files](#archive-and-compressed-files)
- [Code and Text Files](#code-and-text-files)
- [Export Format Matrix](#export-format-matrix)

---

## Google Workspace File Types

### Google Docs
**MIME Type**: `application/vnd.google-apps.document`

**Export Formats**:
| Format | MIME Type | Extension |
|--------|-----------|-----------|
| Plain Text | `text/plain` | .txt |
| HTML | `text/html` | .html |
| Rich Text | `application/rtf` | .rtf |
| PDF | `application/pdf` | .pdf |
| Microsoft Word | `application/vnd.openxmlformats-officedocument.wordprocessingml.document` | .docx |
| OpenDocument | `application/vnd.oasis.opendocument.text` | .odt |
| EPUB | `application/epub+zip` | .epub |
| Markdown | `text/markdown` | .md |

**Usage**:
```bash
# Export as PDF
drive_manager.rb --download "1doc_id" --export-format "application/pdf"

# Export as DOCX
drive_manager.rb --download "1doc_id" --export-format "application/vnd.openxmlformats-officedocument.wordprocessingml.document"

# Read as plain text
drive_manager.rb --read "1doc_id" --export-format "text/plain"
```

### Google Sheets
**MIME Type**: `application/vnd.google-apps.spreadsheet`

**Export Formats**:
| Format | MIME Type | Extension |
|--------|-----------|-----------|
| CSV | `text/csv` | .csv |
| Tab-Separated | `text/tab-separated-values` | .tsv |
| PDF | `application/pdf` | .pdf |
| Microsoft Excel | `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` | .xlsx |
| OpenDocument | `application/x-vnd.oasis.opendocument.spreadsheet` | .ods |
| HTML | `text/html` | .html |
| ZIP (HTML) | `application/zip` | .zip |

**Usage**:
```bash
# Export as Excel
drive_manager.rb --download "1sheet_id" --export-format "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

# Export as CSV
drive_manager.rb --download "1sheet_id" --export-format "text/csv"

# Export as PDF
drive_manager.rb --download "1sheet_id" --export-format "application/pdf"
```

### Google Slides
**MIME Type**: `application/vnd.google-apps.presentation`

**Export Formats**:
| Format | MIME Type | Extension |
|--------|-----------|-----------|
| PDF | `application/pdf` | .pdf |
| Microsoft PowerPoint | `application/vnd.openxmlformats-officedocument.presentationml.presentation` | .pptx |
| OpenDocument | `application/vnd.oasis.opendocument.presentation` | .odp |
| Plain Text | `text/plain` | .txt |
| JPEG (first slide) | `image/jpeg` | .jpg |
| PNG (first slide) | `image/png` | .png |
| SVG (first slide) | `image/svg+xml` | .svg |

**Usage**:
```bash
# Export as PowerPoint
drive_manager.rb --download "1slides_id" --export-format "application/vnd.openxmlformats-officedocument.presentationml.presentation"

# Export as PDF
drive_manager.rb --download "1slides_id" --export-format "application/pdf"
```

### Google Forms
**MIME Type**: `application/vnd.google-apps.form`

**Note**: Forms cannot be exported directly. Use Google Forms API for responses.

### Google Drawings
**MIME Type**: `application/vnd.google-apps.drawing`

**Export Formats**:
| Format | MIME Type | Extension |
|--------|-----------|-----------|
| JPEG | `image/jpeg` | .jpg |
| PNG | `image/png` | .png |
| SVG | `image/svg+xml` | .svg |
| PDF | `application/pdf` | .pdf |

### Google Apps Script
**MIME Type**: `application/vnd.google-apps.script`

**Export Format**: JSON (requires Apps Script API)

### Google Sites
**MIME Type**: `application/vnd.google-apps.site`

**Note**: Sites cannot be exported via Drive API.

### Google Folders
**MIME Type**: `application/vnd.google-apps.folder`

**Usage**:
```bash
# Create folder
drive_manager.rb --create-folder "New Folder"

# List folder contents
drive_manager.rb --list --folder "1folder_id"

# Query for folders only
drive_manager.rb --query "mimeType='application/vnd.google-apps.folder'"
```

---

## Common Document Formats

### Microsoft Office Documents

**Word Documents**:
- `.doc` - `application/msword`
- `.docx` - `application/vnd.openxmlformats-officedocument.wordprocessingml.document`

**Excel Spreadsheets**:
- `.xls` - `application/vnd.ms-excel`
- `.xlsx` - `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`

**PowerPoint Presentations**:
- `.ppt` - `application/vnd.ms-powerpoint`
- `.pptx` - `application/vnd.openxmlformats-officedocument.presentationml.presentation`

**Usage**:
```bash
# Search for Excel files
drive_manager.rb --query "mimeType='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'"

# Upload Word document
drive_manager.rb --upload "document.docx"
```

### PDF Documents
**MIME Type**: `application/pdf`
**Extension**: .pdf

**Usage**:
```bash
# Search for PDFs
drive_manager.rb --query "mimeType='application/pdf'"

# Upload PDF
drive_manager.rb --upload "file.pdf"

# Download PDF
drive_manager.rb --download "1pdf_id"
```

### OpenDocument Format

**Text Documents**:
- `.odt` - `application/vnd.oasis.opendocument.text`

**Spreadsheets**:
- `.ods` - `application/vnd.oasis.opendocument.spreadsheet`

**Presentations**:
- `.odp` - `application/vnd.oasis.opendocument.presentation`

### Plain Text Files
- `.txt` - `text/plain`
- `.csv` - `text/csv`
- `.tsv` - `text/tab-separated-values`
- `.rtf` - `application/rtf`

**Usage**:
```bash
# Read text file content
drive_manager.rb --read "1text_id"

# Upload CSV
drive_manager.rb --upload "data.csv"
```

---

## Media File Types

### Images

**Common Formats**:
- `.jpg`, `.jpeg` - `image/jpeg`
- `.png` - `image/png`
- `.gif` - `image/gif`
- `.bmp` - `image/bmp`
- `.svg` - `image/svg+xml`
- `.webp` - `image/webp`
- `.ico` - `image/x-icon`
- `.tiff` - `image/tiff`

**Usage**:
```bash
# Search for images
drive_manager.rb --query "mimeType contains 'image/'"

# Upload image
drive_manager.rb --upload "photo.jpg"

# Download image
drive_manager.rb --download "1image_id"
```

### Video

**Common Formats**:
- `.mp4` - `video/mp4`
- `.mov` - `video/quicktime`
- `.avi` - `video/x-msvideo`
- `.wmv` - `video/x-ms-wmv`
- `.flv` - `video/x-flv`
- `.webm` - `video/webm`
- `.mkv` - `video/x-matroska`
- `.m4v` - `video/x-m4v`

**Usage**:
```bash
# Search for videos
drive_manager.rb --query "mimeType contains 'video/'"

# Upload video
drive_manager.rb --upload "video.mp4"
```

### Audio

**Common Formats**:
- `.mp3` - `audio/mpeg`
- `.wav` - `audio/wav`
- `.ogg` - `audio/ogg`
- `.m4a` - `audio/mp4`
- `.flac` - `audio/flac`
- `.aac` - `audio/aac`
- `.wma` - `audio/x-ms-wma`

**Usage**:
```bash
# Search for audio files
drive_manager.rb --query "mimeType contains 'audio/'"

# Upload audio
drive_manager.rb --upload "song.mp3"
```

---

## Archive and Compressed Files

**Common Formats**:
- `.zip` - `application/zip`
- `.rar` - `application/x-rar-compressed`
- `.tar` - `application/x-tar`
- `.gz` - `application/gzip`
- `.7z` - `application/x-7z-compressed`
- `.bz2` - `application/x-bzip2`

**Usage**:
```bash
# Upload archive
drive_manager.rb --upload "backup.zip"

# Search for archives
drive_manager.rb --query "mimeType='application/zip'"
```

---

## Code and Text Files

### Programming Languages

**Common Extensions**:
- `.js` - `application/javascript`
- `.json` - `application/json`
- `.py` - `text/x-python`
- `.java` - `text/x-java-source`
- `.cpp`, `.cc` - `text/x-c++src`
- `.c` - `text/x-c`
- `.h` - `text/x-c++hdr`
- `.rb` - `application/x-ruby`
- `.php` - `text/x-php`
- `.go` - `text/x-go`
- `.rs` - `text/x-rustsrc`
- `.swift` - `text/x-swift`
- `.kt` - `text/x-kotlin`
- `.ts` - `application/typescript`

**Usage**:
```bash
# Upload code file
drive_manager.rb --upload "script.py"

# Read code file
drive_manager.rb --read "1code_id"
```

### Markup and Styling

**Common Formats**:
- `.html` - `text/html`
- `.css` - `text/css`
- `.xml` - `application/xml`
- `.md` - `text/markdown`
- `.yaml`, `.yml` - `application/x-yaml`
- `.toml` - `application/toml`

**Usage**:
```bash
# Upload markdown
drive_manager.rb --upload "README.md"

# Read HTML
drive_manager.rb --read "1html_id"
```

### Configuration Files
- `.ini` - `text/plain`
- `.conf` - `text/plain`
- `.properties` - `text/plain`
- `.env` - `text/plain`

---

## Export Format Matrix

### By Source Type

**Google Docs → Exportable Formats**:
```
text/plain               → Fastest, smallest
text/html                → Web-compatible
application/rtf          → Cross-platform rich text
application/pdf          → Print-ready
application/vnd.openxmlformats-officedocument.wordprocessingml.document → Microsoft Word
application/vnd.oasis.opendocument.text → OpenOffice/LibreOffice
application/epub+zip     → E-readers
```

**Google Sheets → Exportable Formats**:
```
text/csv                 → Fastest, data interchange
text/tab-separated-values → Alternative to CSV
application/pdf          → Print-ready
application/vnd.openxmlformats-officedocument.spreadsheetml.sheet → Microsoft Excel
application/x-vnd.oasis.opendocument.spreadsheet → OpenOffice/LibreOffice
text/html                → Web-compatible
```

**Google Slides → Exportable Formats**:
```
application/pdf          → Print-ready, universal
application/vnd.openxmlformats-officedocument.presentationml.presentation → Microsoft PowerPoint
application/vnd.oasis.opendocument.presentation → OpenOffice/LibreOffice
text/plain               → Presenter notes only
image/jpeg               → First slide as image
image/png                → First slide as image
image/svg+xml            → First slide as vector
```

### By Use Case

**Data Interchange**:
```
CSV      → text/csv
JSON     → application/json
XML      → application/xml
TSV      → text/tab-separated-values
```

**Print/Publishing**:
```
PDF      → application/pdf
DOCX     → application/vnd.openxmlformats-officedocument.wordprocessingml.document
EPUB     → application/epub+zip
```

**Web Delivery**:
```
HTML     → text/html
Markdown → text/markdown
JSON     → application/json
```

**Cross-Platform**:
```
ODT      → application/vnd.oasis.opendocument.text
ODS      → application/x-vnd.oasis.opendocument.spreadsheet
ODP      → application/vnd.oasis.opendocument.presentation
PDF      → application/pdf
```

---

## File Type Detection

### Automatic Detection

The `drive_manager.rb` script automatically detects file types based on:
1. **File Extension**: Uses extension to infer MIME type
2. **Content Analysis**: Ruby's MIME type detection for unknown files
3. **Google API**: Drive API determines MIME type on upload

### Query by Type

**Find All Files of Specific Type**:
```bash
# All Google Docs
drive_manager.rb --query "mimeType='application/vnd.google-apps.document'"

# All PDFs
drive_manager.rb --query "mimeType='application/pdf'"

# All images (any format)
drive_manager.rb --query "mimeType contains 'image/'"

# All videos
drive_manager.rb --query "mimeType contains 'video/'"

# All Microsoft Office documents
drive_manager.rb --query "mimeType contains 'openxmlformats'"
```

### Type Conversion Workflows

**Google Doc → PDF**:
```bash
# Export and download as PDF
drive_manager.rb --download "1doc_id" --export-format "application/pdf" --output "document.pdf"
```

**Google Sheet → Excel**:
```bash
# Export as Excel
drive_manager.rb --download "1sheet_id" --export-format "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" --output "spreadsheet.xlsx"
```

**Google Slides → PowerPoint**:
```bash
# Export as PowerPoint
drive_manager.rb --download "1slides_id" --export-format "application/vnd.openxmlformats-officedocument.presentationml.presentation" --output "presentation.pptx"
```

---

## Special Considerations

### Google Workspace Files
- Cannot be downloaded in their native format
- Must be exported to standard formats
- Export formats vary by file type
- Size limits apply to exports

### Large Files
- Files >10GB have special handling
- Resumable uploads for >5MB files
- Download in chunks for large files
- Consider export format size impact

### File Conversion
- Uploading Office files doesn't auto-convert to Google format
- Use `--convert` flag in Drive API for conversion (future enhancement)
- Manual conversion via Drive web UI
- Export formats may lose some formatting

### MIME Type Aliases
Some MIME types have multiple valid representations:
- `image/jpg` = `image/jpeg`
- `application/x-compressed` = `application/zip`
- `text/x-python` = `application/x-python`

Always use canonical MIME types in queries.

---

## Quick Reference Tables

### Most Common MIME Types

| Type | MIME Type | Extension |
|------|-----------|-----------|
| Google Doc | `application/vnd.google-apps.document` | N/A |
| Google Sheet | `application/vnd.google-apps.spreadsheet` | N/A |
| Google Slides | `application/vnd.google-apps.presentation` | N/A |
| Folder | `application/vnd.google-apps.folder` | N/A |
| PDF | `application/pdf` | .pdf |
| Word | `application/vnd.openxmlformats-officedocument.wordprocessingml.document` | .docx |
| Excel | `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` | .xlsx |
| PowerPoint | `application/vnd.openxmlformats-officedocument.presentationml.presentation` | .pptx |
| Plain Text | `text/plain` | .txt |
| CSV | `text/csv` | .csv |
| JSON | `application/json` | .json |
| JPEG Image | `image/jpeg` | .jpg |
| PNG Image | `image/png` | .png |
| MP4 Video | `video/mp4` | .mp4 |
| MP3 Audio | `audio/mpeg` | .mp3 |
| ZIP Archive | `application/zip` | .zip |

### Search Patterns

```bash
# Documents (any type)
drive_manager.rb --query "mimeType contains 'document'"

# Spreadsheets (any type)
drive_manager.rb --query "mimeType contains 'spreadsheet'"

# Presentations (any type)
drive_manager.rb --query "mimeType contains 'presentation'"

# Google Workspace files only
drive_manager.rb --query "mimeType contains 'vnd.google-apps'"

# Non-Google files
drive_manager.rb --query "not mimeType contains 'vnd.google-apps'"

# Media files (images, video, audio)
drive_manager.rb --query "mimeType contains 'image/' or mimeType contains 'video/' or mimeType contains 'audio/'"
```

---

**Version**: 1.0.0  
**Last Updated**: November 10, 2025  
**Ruby Gem**: google-apis-drive_v3  
**API Version**: Drive API v3
