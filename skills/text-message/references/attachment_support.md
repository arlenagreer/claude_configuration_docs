# Attachment Support Reference

## Overview

The text-message skill supports sending file attachments via Apple Messages app, including images, videos, audio files, documents, and more. This document provides detailed information about attachment handling.

## Supported File Formats

### Image Formats
- **JPEG/JPG**: Standard photo format
- **PNG**: Lossless image format with transparency
- **GIF**: Animated or static images
- **HEIC/HEIF**: Apple's high-efficiency image format (iPhone photos)
- **BMP**: Bitmap images
- **TIFF/TIF**: Tagged image format
- **WEBP**: Modern web image format
- **SVG**: Scalable vector graphics

### Video Formats
- **MP4**: Most common video format
- **MOV**: QuickTime video format (native on macOS)
- **M4V**: MPEG-4 video format
- **AVI**: Audio Video Interleave
- **MKV**: Matroska video container
- **WMV**: Windows Media Video
- **FLV**: Flash video
- **WEBM**: Web video format

### Audio Formats
- **MP3**: MPEG audio format
- **M4A**: MPEG-4 audio (AAC)
- **WAV**: Waveform audio
- **AAC**: Advanced Audio Coding
- **FLAC**: Free Lossless Audio Codec
- **OGG**: Ogg Vorbis audio
- **WMA**: Windows Media Audio

### Document Formats
- **PDF**: Portable Document Format
- **DOC/DOCX**: Microsoft Word documents
- **TXT**: Plain text files
- **RTF**: Rich Text Format
- **PAGES**: Apple Pages documents

### Archive Formats
- **ZIP**: Compressed archive
- **RAR**: WinRAR archive
- **7Z**: 7-Zip archive
- **TAR**: Tape archive
- **GZ**: Gzip compressed file

### Contact Formats
- **VCF/VCARD**: vCard contact file

## Usage

### Basic Syntax

```bash
# Text-only message (existing functionality)
~/.claude/skills/text-message/scripts/send_message.sh "PHONE_NUMBER" "MESSAGE_TEXT"

# Message with attachment (NEW)
~/.claude/skills/text-message/scripts/send_message.sh "PHONE_NUMBER" "MESSAGE_TEXT" "/path/to/file"

# Attachment-only, no text message (NEW)
~/.claude/skills/text-message/scripts/send_message.sh "PHONE_NUMBER" "" "/path/to/file"
```

### File Path Requirements

1. **Absolute paths**: Recommended for reliability
   ```bash
   /Users/arlenagreer/Documents/photo.jpg
   ```

2. **Relative paths**: Will be converted to absolute paths automatically
   ```bash
   ~/Desktop/image.png
   ./documents/report.pdf
   ../photos/vacation.jpg
   ```

3. **Paths with spaces**: Properly handled by script
   ```bash
   "/Users/arlenagreer/My Documents/photo.jpg"
   ```

### Validation Process

The script performs the following validations:

1. **File Existence Check**: Verifies file exists at specified path
2. **Readability Check**: Ensures file has read permissions
3. **Format Validation**: Checks file extension against known formats
4. **Path Resolution**: Converts relative paths to absolute paths for AppleScript

### Response Format

#### Success Response (Text Only)
```json
{
  "status": "success",
  "recipient": "+15551234567",
  "message": "Hello, this is a test message"
}
```

#### Success Response (With Attachment)
```json
{
  "status": "success",
  "recipient": "+15551234567",
  "message": "Check out this photo!",
  "attachment": "/Users/arlenagreer/Desktop/photo.jpg"
}
```

#### Error Response (Attachment Not Found)
```json
{
  "status": "error",
  "code": "ATTACHMENT_NOT_FOUND",
  "message": "Attachment file not found: /path/to/missing/file.jpg"
}
```

#### Error Response (Attachment Not Readable)
```json
{
  "status": "error",
  "code": "ATTACHMENT_NOT_READABLE",
  "message": "Attachment file not readable: /path/to/restricted/file.jpg"
}
```

## AppleScript Implementation

### Text-Only Message
```applescript
tell application "Messages"
    send "MESSAGE_TEXT" to buddy "PHONE_NUMBER"
end tell
```

### Message with Attachment
```applescript
tell application "Messages"
    set targetBuddy to buddy "PHONE_NUMBER"
    if "MESSAGE_TEXT" is not "" then
        send "MESSAGE_TEXT" to targetBuddy
    end if
    send POSIX file "/absolute/path/to/file" to targetBuddy
end tell
```

### Key Implementation Details

1. **Buddy Reference**: Creates a buddy reference to ensure proper message threading
2. **Conditional Text**: Only sends text message if not empty string
3. **POSIX File**: Uses POSIX file format for cross-platform compatibility
4. **Sequential Sending**: Sends text first, then attachment (if both provided)

## Limitations

### Size Limits
- **iMessage**: Typically supports files up to 100MB
- **SMS/MMS**: Limited to ~1-3MB depending on carrier
- Messages app will automatically choose delivery method based on file size and recipient capability

### Format Compatibility
- Not all file formats are universally supported across all devices
- Recipient's device may not support certain formats
- Script warns about potentially unsupported formats but allows sending

### Carrier Restrictions
- MMS (SMS with media) has carrier-specific limitations
- Some carriers may compress or reject certain file types
- iMessage (between Apple devices) has fewer restrictions

## Error Handling

### Common Errors

**ATTACHMENT_NOT_FOUND**
- **Cause**: File doesn't exist at specified path
- **Resolution**: Verify file path and ensure file exists

**ATTACHMENT_NOT_READABLE**
- **Cause**: Insufficient permissions to read file
- **Resolution**: Check file permissions with `ls -l` and adjust if needed

**SEND_FAILED**
- **Cause**: Messages app failed to send (network, permissions, or format issue)
- **Resolution**: Check Messages app configuration, network connection, and file format

## Best Practices

1. **File Size**: Keep attachments reasonable in size (under 25MB recommended)
2. **Format Selection**: Use widely-supported formats (JPEG for photos, MP4 for videos, PDF for documents)
3. **Path Validation**: Always validate file paths before attempting to send
4. **User Confirmation**: Confirm attachment details with user before sending
5. **Error Messaging**: Provide clear error messages and recovery steps
6. **Compression**: Consider compressing large files or high-resolution images

## Examples

### Example 1: Send Photo
```bash
# User request: "Send Rob this photo: ~/Desktop/vacation.jpg"

# 1. Look up Rob's phone number
PHONE=$(~/.claude/skills/contacts/scripts/contacts_manager.rb --search "Rob" | jq -r '.contacts[0].phones[0].value')

# 2. Send photo with message
~/.claude/skills/text-message/scripts/send_message.sh "$PHONE" "Check out our vacation!" "/Users/arlenagreer/Desktop/vacation.jpg"

# Response:
# {"status":"success","recipient":"+15551234567","message":"Check out our vacation!","attachment":"/Users/arlenagreer/Desktop/vacation.jpg"}
```

### Example 2: Send Document Without Message
```bash
# User request: "Text Julie this PDF: ~/Documents/report.pdf"

# 1. Look up Julie's phone number
PHONE=$(~/.claude/skills/contacts/scripts/contacts_manager.rb --search "Julie" | jq -r '.contacts[0].phones[0].value')

# 2. Send PDF without text message
~/.claude/skills/text-message/scripts/send_message.sh "$PHONE" "" "/Users/arlenagreer/Documents/report.pdf"

# Response:
# {"status":"success","recipient":"+15552345678","message":"","attachment":"/Users/arlenagreer/Documents/report.pdf"}
```

### Example 3: Send Video with Message
```bash
# User request: "Send Mark this video: ~/Movies/demo.mp4 with message 'Here's the demo'"

# 1. Look up Mark's phone number
PHONE=$(~/.claude/skills/contacts/scripts/contacts_manager.rb --search "Mark" | jq -r '.contacts[0].phones[0].value')

# 2. Send video with message
~/.claude/skills/text-message/scripts/send_message.sh "$PHONE" "Here's the demo" "/Users/arlenagreer/Movies/demo.mp4"

# Response:
# {"status":"success","recipient":"+15553456789","message":"Here's the demo","attachment":"/Users/arlenagreer/Movies/demo.mp4"}
```

## Testing

### Test Script
```bash
#!/bin/bash

# Test 1: Text-only message
echo "Test 1: Text-only message"
~/.claude/skills/text-message/scripts/send_message.sh "YOUR_PHONE" "Test message"

# Test 2: Image with message
echo "Test 2: Image with message"
~/.claude/skills/text-message/scripts/send_message.sh "YOUR_PHONE" "Test photo" "/path/to/test/image.jpg"

# Test 3: Image without message
echo "Test 3: Image without message"
~/.claude/skills/text-message/scripts/send_message.sh "YOUR_PHONE" "" "/path/to/test/image.jpg"

# Test 4: Invalid file path
echo "Test 4: Invalid file path (should fail)"
~/.claude/skills/text-message/scripts/send_message.sh "YOUR_PHONE" "This should fail" "/nonexistent/file.jpg"

# Test 5: Unsupported format warning
echo "Test 5: Unsupported format (should warn)"
~/.claude/skills/text-message/scripts/send_message.sh "YOUR_PHONE" "Unusual format" "/path/to/file.xyz"
```

## Troubleshooting

### Issue: "Attachment file not found"
**Solutions**:
- Verify file path is correct
- Use absolute paths instead of relative paths
- Check for typos in filename or path
- Ensure file hasn't been moved or deleted

### Issue: "Attachment file not readable"
**Solutions**:
- Check file permissions: `ls -l /path/to/file`
- Make file readable: `chmod +r /path/to/file`
- Verify you have access to parent directories

### Issue: Message sends but attachment doesn't
**Solutions**:
- Check file size (may be too large for SMS/MMS)
- Verify file format is supported
- Ensure recipient's device can receive attachments
- Try with a smaller or different format file

### Issue: "Permission denied" error
**Solutions**:
- Grant Messages app automation permissions in System Settings
- System Settings → Privacy & Security → Automation → Terminal/Claude → Messages

## Version History

- **1.3.0** (2025-11-01) - Initial attachment support implementation
  - Added file attachment parameter to send_message.sh
  - Implemented file validation (existence, readability, format)
  - Added support for images, videos, audio, documents, archives
  - Created comprehensive attachment documentation
  - Updated SKILL.md with attachment workflows and examples

---

*This reference provides comprehensive documentation for attachment support in the text-message skill.*
