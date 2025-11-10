# Google Drive Skill Research & Implementation Strategy

**Date**: November 10, 2025
**Research Objective**: Determine optimal approach for implementing Google Drive skill with potential Sheets/Docs integration
**Status**: Research Complete - Ready for Implementation

---

## Executive Summary

**Key Findings**:
1. ✅ **OAuth Token Sharing**: Single OAuth token can be shared across email, calendar, contacts, Drive, Sheets, and Docs
2. ✅ **Scope Strategy**: Use `https://www.googleapis.com/auth/drive` for full Drive access
3. ⚠️ **API Separation**: Drive API cannot access Sheets/Docs content - separate APIs required
4. 📋 **Recommendation**: Implement THREE separate skills (Drive, Sheets, Docs) with shared authentication

---

## 1. Existing Architecture Analysis

### Current OAuth Implementation Pattern

**Location**: `~/.claude/.google/token.json` (shared across all Google skills)

**Current Scopes in Use**:
```ruby
[
  "https://www.googleapis.com/auth/gmail.modify",    # Email skill
  "https://www.googleapis.com/auth/calendar",        # Calendar skill
  "https://www.googleapis.com/auth/contacts"         # Contacts skill
]
```

**Ruby Implementation Pattern** (from `gmail_manager.rb` and `calendar_manager.rb`):
```ruby
# Shared OAuth setup
CREDENTIALS_PATH = File.join(Dir.home, '.claude', '.google', 'client_secret.json')
TOKEN_PATH = File.join(Dir.home, '.claude', '.google', 'token.json')

# Multiple scopes in single authorizer
authorizer = Google::Auth::UserAuthorizer.new(
  client_id,
  [CALENDAR_SCOPE, CONTACTS_SCOPE, GMAIL_SCOPE],  # Array of scopes
  token_store
)
```

**Key Observations**:
- ✅ All skills use same token file (`~/.claude/.google/token.json`)
- ✅ Scopes accumulate as new skills are added
- ✅ Single re-authorization grants access to all scopes
- ✅ Token auto-refreshes when expired
- ✅ Ruby gems: `google-apis-*` pattern (e.g., `google-apis-drive_v3`)

---

## 2. Google Drive API Capabilities

### Available OAuth2 Scopes

**Recommended for General-Purpose Drive Skill**:
```
https://www.googleapis.com/auth/drive
```

**Capabilities with Full Drive Scope**:
- ✅ Create/upload files and folders
- ✅ Download/export files
- ✅ Delete, move, rename files
- ✅ Manage permissions and sharing
- ✅ Search across all Drive files
- ✅ Access file metadata
- ✅ Copy files
- ✅ Organize folder hierarchy

**Alternative Scopes** (more restrictive):
- `https://www.googleapis.com/auth/drive.readonly` - Read-only access
- `https://www.googleapis.com/auth/drive.file` - Only files created by app
- `https://www.googleapis.com/auth/drive.metadata` - Metadata only

**Ruby Gem**: `google-apis-drive_v3`

---

## 3. Google Sheets & Docs Integration

### Critical Finding: API Separation Required

**Question**: Will Google Drive access allow Claude Code to work directly with Google Sheets and Google Docs?

**Answer**: **NO** - Separate APIs required for content manipulation

### What Drive API CAN Do with Sheets/Docs Files

**Drive API Capabilities**:
- ✅ Create empty Sheets/Docs files
- ✅ List/search for Sheets/Docs files
- ✅ Delete/move/rename Sheets/Docs files
- ✅ Manage sharing and permissions
- ✅ Export to alternative formats (PDF, CSV, DOCX, HTML)
- ✅ Download exported versions

**Drive API CANNOT**:
- ❌ Read cell values in Sheets
- ❌ Write cell data in Sheets
- ❌ Read document text in Docs
- ❌ Write/format text in Docs
- ❌ Access formulas, charts, or internal structure

### What Requires Specialized APIs

**Google Sheets API** (`google-apis-sheets_v4`):
- ✅ Read/write cell values and formulas
- ✅ Read/write ranges (e.g., A1:B10)
- ✅ Create/modify sheets within spreadsheet
- ✅ Cell formatting (colors, fonts, borders)
- ✅ Charts and pivot tables
- ✅ Data validation rules
- ✅ Batch operations

**Google Docs API** (`google-apis-docs_v1`):
- ✅ Read document text content
- ✅ Write/insert text
- ✅ Apply text formatting (bold, italic, fonts)
- ✅ Manage paragraphs and styling
- ✅ Work with lists and tables
- ✅ Insert images and page breaks
- ✅ Headers and footers

---

## 4. OAuth Token Sharing Strategy

### Unified Token Approach ✅ CONFIRMED

**Key Discovery**: Single OAuth token with multiple scopes works across ALL Google APIs

**Proposed Scope Array**:
```ruby
[
  "https://www.googleapis.com/auth/gmail.modify",    # Existing: Email
  "https://www.googleapis.com/auth/calendar",        # Existing: Calendar
  "https://www.googleapis.com/auth/contacts",        # Existing: Contacts
  "https://www.googleapis.com/auth/drive",           # NEW: Drive (full access)
  "https://www.googleapis.com/auth/spreadsheets",    # NEW: Sheets (optional but explicit)
  "https://www.googleapis.com/auth/documents"        # NEW: Docs (optional but explicit)
]
```

**Important Note**: The `drive` scope technically provides access to Sheets and Docs APIs, but adding explicit scopes makes permissions clearer to users.

### Re-Authorization Required

When adding new scopes:
1. Delete existing token: `rm ~/.claude/.google/token.json`
2. Run any skill operation to trigger OAuth flow
3. User authorizes ALL scopes in single consent screen
4. New token stored with all scopes
5. All skills (email, calendar, contacts, drive, sheets, docs) now work

**User Experience**: One-time re-authorization grants access to all current and future Google API skills

---

## 5. Recommended Implementation Strategy

### Architecture: THREE SEPARATE SKILLS

```
~/.claude/skills/
├── google-drive/          ← File management focus
│   ├── SKILL.md
│   ├── scripts/
│   │   └── drive_manager.rb
│   └── references/
│       └── drive_operations.md
│
├── google-sheets/         ← Spreadsheet data operations
│   ├── SKILL.md
│   ├── scripts/
│   │   └── sheets_manager.rb
│   └── references/
│       └── sheets_operations.md
│
└── google-docs/          ← Document content operations
    ├── SKILL.md
    ├── scripts/
    │   └── docs_manager.rb
    └── references/
        └── docs_operations.md
```

### Rationale for Separate Skills

**1. Distinct API Boundaries**
- Each API has completely different capabilities and methods
- Drive = file management, Sheets = data manipulation, Docs = text editing
- Different Ruby gems required for each

**2. Clear User Mental Model**
- "Manage my Drive files" → google-drive skill
- "Update spreadsheet data" → google-sheets skill
- "Edit document content" → google-docs skill

**3. Independent Development**
- Each skill can evolve without affecting others
- Easier to maintain and extend
- Clear separation of concerns

**4. OAuth Scope Clarity**
- Users understand exactly what permissions each skill needs
- Easier to debug authorization issues
- More secure (principle of least privilege per skill)

### Alternative Rejected: Unified "google-workspace" Skill

**Why Not Unified?**
- ❌ Too many distinct operations (file mgmt + spreadsheet + document editing)
- ❌ Overly complex SKILL.md (would be 1000+ lines)
- ❌ Mixed concerns violate single responsibility principle
- ❌ Difficult to extend and maintain
- ❌ Confusing for users ("What does this skill do?")

---

## 6. Implementation Priorities

### Phase 1: Google Drive Skill (HIGHEST PRIORITY)

**Core Operations**:
- List files and folders
- Search Drive
- Upload files
- Download files
- Create folders
- Delete/move/rename files
- Manage sharing and permissions
- Export Sheets/Docs to other formats

**Ruby Gem**: `google-apis-drive_v3`

**OAuth Scope**: `https://www.googleapis.com/auth/drive`

**Skill Pattern**: Follow existing email/calendar/contacts pattern

### Phase 2: Google Sheets Skill (MEDIUM PRIORITY)

**Core Operations**:
- Read cell values and ranges
- Write cell data
- Update formulas
- Create new sheets within spreadsheet
- Basic formatting operations
- Batch operations

**Ruby Gem**: `google-apis-sheets_v4`

**OAuth Scope**: `https://www.googleapis.com/auth/spreadsheets`

**Integration**: Works with Drive skill to manage Sheets files

### Phase 3: Google Docs Skill (LOWER PRIORITY)

**Core Operations**:
- Read document text
- Insert/append text
- Basic text formatting
- Replace text
- Document structure navigation

**Ruby Gem**: `google-apis-docs_v1`

**OAuth Scope**: `https://www.googleapis.com/auth/documents`

**Integration**: Works with Drive skill to manage Docs files

---

## 7. Implementation Checklist

### Google Drive Skill

**Setup**:
- [ ] Install Ruby gem: `gem install google-apis-drive_v3`
- [ ] Create skill directory: `~/.claude/skills/google-drive/`
- [ ] Create SKILL.md following existing email/calendar pattern
- [ ] Create `scripts/drive_manager.rb` based on existing OAuth pattern

**OAuth Integration**:
- [ ] Use shared `~/.claude/.google/client_secret.json`
- [ ] Use shared `~/.claude/.google/token.json`
- [ ] Add Drive scope to authorizer array
- [ ] Test token sharing with existing skills

**Core Operations to Implement**:
- [ ] List files (with pagination)
- [ ] Search files by name/type/folder
- [ ] Upload file
- [ ] Download file
- [ ] Create folder
- [ ] Delete file/folder
- [ ] Move file/folder
- [ ] Rename file/folder
- [ ] Share file (add permissions)
- [ ] Export Sheets/Docs to PDF/CSV/DOCX

**Error Handling**:
- [ ] Authentication errors (re-auth prompt)
- [ ] API quota limits
- [ ] File not found
- [ ] Permission denied
- [ ] Network errors

**Documentation**:
- [ ] SKILL.md with usage examples
- [ ] references/drive_operations.md with all operations
- [ ] Version history
- [ ] Integration notes with Sheets/Docs skills

---

## 8. Code Examples

### Ruby OAuth Setup (Drive Manager)

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require 'google/apis/drive_v3'
require 'google/apis/calendar_v3'
require 'google/apis/people_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'

class DriveManager
  # OAuth scopes - shared with other Google skills
  DRIVE_SCOPE = Google::Apis::DriveV3::AUTH_DRIVE
  CALENDAR_SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR
  CONTACTS_SCOPE = Google::Apis::PeopleV1::AUTH_CONTACTS
  GMAIL_SCOPE = 'https://www.googleapis.com/auth/gmail.modify'

  # Shared credentials
  CREDENTIALS_PATH = File.join(Dir.home, '.claude', '.google', 'client_secret.json')
  TOKEN_PATH = File.join(Dir.home, '.claude', '.google', 'token.json')

  def initialize
    @drive_service = Google::Apis::DriveV3::DriveService.new
    @drive_service.client_options.application_name = 'Claude Drive Skill'
    @drive_service.authorization = authorize
  end

  def authorize
    client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)

    authorizer = Google::Auth::UserAuthorizer.new(
      client_id,
      [DRIVE_SCOPE, CALENDAR_SCOPE, CONTACTS_SCOPE, GMAIL_SCOPE],
      token_store
    )

    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)

    if credentials.nil?
      # Trigger OAuth flow
      url = authorizer.get_authorization_url(base_url: 'urn:ietf:wg:oauth:2.0:oob')
      # ... prompt user for authorization
    end

    credentials
  end

  # Example: List files
  def list_files(page_size: 100, query: nil)
    response = @drive_service.list_files(
      page_size: page_size,
      q: query,
      fields: 'nextPageToken, files(id, name, mimeType, createdTime, modifiedTime, size, shared)'
    )

    {
      status: 'success',
      files: response.files.map { |f| format_file(f) },
      next_page_token: response.next_page_token
    }
  rescue StandardError => e
    { status: 'error', message: e.message }
  end

  private

  def format_file(file)
    {
      id: file.id,
      name: file.name,
      type: file.mime_type,
      created: file.created_time,
      modified: file.modified_time,
      size: file.size,
      shared: file.shared
    }
  end
end
```

### Example Usage Pattern

```bash
# Create Drive manager instance
drive = DriveManager.new

# List all files
drive.list_files

# Search for spreadsheets
drive.list_files(query: "mimeType='application/vnd.google-apps.spreadsheet'")

# Upload file
drive.upload_file(local_path: '/path/to/file.pdf', name: 'Report.pdf')

# Create folder
drive.create_folder(name: 'Projects')

# Share file
drive.share_file(file_id: '123abc', email: 'user@example.com', role: 'writer')
```

---

## 9. Integration Workflow Example

**User Request**: "Create a spreadsheet called 'Q4 Budget' and populate it with department data"

**Multi-Skill Workflow**:

```ruby
# Step 1: google-drive skill creates the spreadsheet file
result = drive_skill.create_file(
  name: 'Q4 Budget',
  mime_type: 'application/vnd.google-apps.spreadsheet'
)
spreadsheet_id = result[:file_id]

# Step 2: google-sheets skill populates data
sheets_skill.write_range(
  spreadsheet_id: spreadsheet_id,
  range: 'A1:D10',
  values: department_data
)

# Step 3: google-drive skill shares with stakeholders
drive_skill.share_file(
  file_id: spreadsheet_id,
  email: 'finance@company.com',
  role: 'reader'
)
```

---

## 10. Security Considerations

### OAuth Scope Permissions

**User Consent Screen Will Show**:
- "View and manage your Drive files" (Drive scope)
- "View and manage your spreadsheets" (Sheets scope)
- "View and manage your documents" (Docs scope)
- "Send email on your behalf" (Gmail scope)
- "View and manage your calendar" (Calendar scope)
- "View and manage your contacts" (Contacts scope)

**Security Best Practices**:
1. ✅ Use shared token to minimize re-authorization
2. ✅ Store credentials securely in `~/.claude/.google/`
3. ✅ Token auto-refreshes when expired
4. ✅ Never log or expose access tokens
5. ✅ Validate file permissions before operations
6. ✅ Sanitize file paths to prevent directory traversal

---

## 11. Questions Answered

### Q1: Will Google Drive access allow Claude Code to work directly with Google Sheets and Google Docs?

**Answer**: **Partially**

**What Drive API Provides**:
- ✅ File management (create, delete, move, rename, share)
- ✅ Export Sheets to CSV/PDF/Excel
- ✅ Export Docs to PDF/DOCX/HTML
- ✅ Search and organize Sheets/Docs files

**What Drive API Does NOT Provide**:
- ❌ Reading/writing cell data in Sheets
- ❌ Reading/writing text content in Docs
- ❌ Formulas, charts, formatting in Sheets
- ❌ Text styling, paragraphs, tables in Docs

**Conclusion**:
- **File operations**: Drive API sufficient
- **Content operations**: Separate Sheets/Docs APIs required

### Q2: Will these activities require separately-implemented skills?

**Answer**: **YES - Three separate skills recommended**

**Rationale**:
1. Distinct API capabilities and boundaries
2. Clear user mental model (file mgmt vs data vs content)
3. Independent development and maintenance
4. OAuth scope clarity
5. Single responsibility per skill

**Implementation Order**:
1. **Priority 1**: google-drive (file management)
2. **Priority 2**: google-sheets (spreadsheet data)
3. **Priority 3**: google-docs (document content)

### Q3: Can we use the same OAuth token?

**Answer**: **YES - Single token with multiple scopes**

**Implementation**:
- Same `~/.claude/.google/token.json` file
- Add Drive/Sheets/Docs scopes to existing scope array
- One-time re-authorization grants access to all
- All skills share same token seamlessly

---

## 12. Next Steps

**Immediate Actions**:
1. ✅ Research complete - findings documented
2. **Next**: Create google-drive skill following email/calendar pattern
3. **Next**: Test OAuth token sharing with existing skills
4. **Next**: Implement core Drive operations (list, upload, download, search)

**Future Enhancements**:
1. google-sheets skill (after Drive is stable)
2. google-docs skill (after Sheets is stable)
3. Advanced Drive features (versioning, comments, activity)

---

## 13. References

**Official Documentation**:
- [Google Drive API v3](https://developers.google.com/drive/api/v3/reference)
- [Google Sheets API v4](https://developers.google.com/sheets/api/reference/rest)
- [Google Docs API v1](https://developers.google.com/docs/api/reference/rest)
- [OAuth 2.0 Scopes](https://developers.google.com/identity/protocols/oauth2/scopes)

**Ruby Gems**:
- `google-apis-drive_v3` - Drive API client
- `google-apis-sheets_v4` - Sheets API client
- `google-apis-docs_v1` - Docs API client
- `googleauth` - OAuth authentication (shared)

**Existing Skills for Reference**:
- `~/.claude/skills/email/` - Gmail API integration pattern
- `~/.claude/skills/calendar/` - Calendar API integration pattern
- `~/.claude/skills/contacts/` - Contacts API integration pattern

---

**Research Completed**: November 10, 2025
**Researcher**: Claude Code (deep-research-agent)
**Next Action**: Begin google-drive skill implementation
