# Google Skills Implementation Plan

**Date**: November 10, 2025
**Objective**: Implement google-drive, google-sheets, and google-docs skills with shared OAuth authentication
**Strategy**: Parallel development using subagents with systematic coordination
**Status**: 🔄 IN PROGRESS

---

## Implementation Architecture

### Three Skills to Implement

```
~/.claude/skills/
├── google-drive/          ✅ Priority 1: File management
│   ├── SKILL.md
│   ├── scripts/
│   │   └── drive_manager.rb
│   ├── references/
│   │   ├── drive_operations.md
│   │   └── mime_types.md
│   └── assets/
│       └── (future use)
│
├── google-sheets/         ✅ Priority 2: Spreadsheet operations
│   ├── SKILL.md
│   ├── scripts/
│   │   └── sheets_manager.rb
│   ├── references/
│   │   ├── sheets_operations.md
│   │   └── cell_formats.md
│   └── examples/
│       └── sample_operations.md
│
└── google-docs/          ✅ Priority 3: Document operations
    ├── SKILL.md
    ├── scripts/
    │   └── docs_manager.rb
    ├── references/
    │   ├── docs_operations.md
    │   └── formatting_guide.md
    └── examples/
        └── sample_operations.md
```

---

## OAuth Token Sharing Strategy

### Unified Authentication

**Token Location**: `~/.claude/.google/token.json` (shared across ALL Google skills)

**Required Scopes**:
```ruby
[
  # Existing scopes
  "https://www.googleapis.com/auth/gmail.modify",      # Email skill
  "https://www.googleapis.com/auth/calendar",          # Calendar skill
  "https://www.googleapis.com/auth/contacts",          # Contacts skill

  # NEW scopes to add
  "https://www.googleapis.com/auth/drive",             # Drive skill
  "https://www.googleapis.com/auth/spreadsheets",      # Sheets skill
  "https://www.googleapis.com/auth/documents"          # Docs skill
]
```

**Re-Authorization Required**: ✅ One-time re-auth will grant access to all new scopes

---

## Implementation Workflow

### Phase 1: Planning & Setup ⏳ IN PROGRESS
- [x] Research complete
- [x] Implementation plan created
- [ ] Skill directories created
- [ ] Ruby gem dependencies documented

### Phase 2: Parallel Skill Development 📋 PENDING
- [ ] **Subagent 1**: google-drive skill implementation
- [ ] **Subagent 2**: google-sheets skill implementation
- [ ] **Subagent 3**: google-docs skill implementation

### Phase 3: OAuth Integration 📋 PENDING
- [ ] Update all Google skills with new scopes
- [ ] Test token sharing across skills
- [ ] Verify re-authorization workflow

### Phase 4: Validation & Testing 📋 PENDING
- [ ] Test each skill independently
- [ ] Test cross-skill workflows
- [ ] Validate OAuth token sharing
- [ ] Documentation review

---

## Parallel Development Tasks

### Task 1: Google Drive Skill (Subagent)
**Assigned to**: skill-creator subagent
**Priority**: 1 (Highest)
**Status**: 📋 PENDING

**Core Operations**:
- List files and folders (with pagination)
- Search files (by name, type, folder)
- Upload files
- Download files
- Create folders
- Delete files/folders
- Move/rename files
- Share files (manage permissions)
- Export Sheets/Docs to PDF/CSV/DOCX

**Ruby Gem**: `google-apis-drive_v3`
**OAuth Scope**: `https://www.googleapis.com/auth/drive`

**Deliverables**:
- ✅ SKILL.md following email/calendar pattern
- ✅ scripts/drive_manager.rb with OAuth integration
- ✅ references/drive_operations.md with all operations
- ✅ references/mime_types.md for file type reference

---

### Task 2: Google Sheets Skill (Subagent)
**Assigned to**: skill-creator subagent
**Priority**: 2
**Status**: 📋 PENDING

**Core Operations**:
- Read cell values (single cell, ranges)
- Write cell values (single, batch)
- Read/write formulas
- Create new sheets within spreadsheet
- Update cell formatting (basic)
- Append rows to sheet
- Clear ranges
- Get spreadsheet metadata

**Ruby Gem**: `google-apis-sheets_v4`
**OAuth Scope**: `https://www.googleapis.com/auth/spreadsheets`

**Deliverables**:
- ✅ SKILL.md following email/calendar pattern
- ✅ scripts/sheets_manager.rb with OAuth integration
- ✅ references/sheets_operations.md with all operations
- ✅ references/cell_formats.md for formatting reference
- ✅ examples/sample_operations.md with usage examples

---

### Task 3: Google Docs Skill (Subagent)
**Assigned to**: skill-creator subagent
**Priority**: 3
**Status**: 📋 PENDING

**Core Operations**:
- Read document content
- Insert/append text
- Replace text (find and replace)
- Basic text formatting (bold, italic, underline)
- Insert page breaks
- Get document structure
- Create new document
- Delete document content

**Ruby Gem**: `google-apis-docs_v1`
**OAuth Scope**: `https://www.googleapis.com/auth/documents`

**Deliverables**:
- ✅ SKILL.md following email/calendar pattern
- ✅ scripts/docs_manager.rb with OAuth integration
- ✅ references/docs_operations.md with all operations
- ✅ references/formatting_guide.md for text formatting
- ✅ examples/sample_operations.md with usage examples

---

## Shared OAuth Implementation Pattern

### Ruby Authorization Template
```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require 'google/apis/drive_v3'      # or sheets_v4, docs_v1
require 'google/apis/calendar_v3'   # Shared scopes
require 'google/apis/people_v1'     # Shared scopes
require 'googleauth'
require 'googleauth/stores/file_token_store'

class [Drive|Sheets|Docs]Manager
  # OAuth scopes - ALL Google skills share these
  DRIVE_SCOPE = Google::Apis::DriveV3::AUTH_DRIVE
  SHEETS_SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS
  DOCS_SCOPE = Google::Apis::DocsV1::AUTH_DOCUMENTS
  CALENDAR_SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR
  CONTACTS_SCOPE = Google::Apis::PeopleV1::AUTH_CONTACTS
  GMAIL_SCOPE = 'https://www.googleapis.com/auth/gmail.modify'

  # Shared credentials path
  CREDENTIALS_PATH = File.join(Dir.home, '.claude', '.google', 'client_secret.json')
  TOKEN_PATH = File.join(Dir.home, '.claude', '.google', 'token.json')

  def initialize
    @service = Google::Apis::[Drive|Sheets|Docs]V[3|4|1]::[Drive|Sheets|Docs]Service.new
    @service.client_options.application_name = 'Claude [Drive|Sheets|Docs] Skill'
    @service.authorization = authorize
  end

  def authorize
    client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)

    # Include ALL scopes for shared token
    authorizer = Google::Auth::UserAuthorizer.new(
      client_id,
      [DRIVE_SCOPE, SHEETS_SCOPE, DOCS_SCOPE, CALENDAR_SCOPE, CONTACTS_SCOPE, GMAIL_SCOPE],
      token_store
    )

    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)

    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: 'urn:ietf:wg:oauth:2.0:oob')
      # Trigger OAuth flow
      output_json({
        status: 'error',
        error_code: 'AUTH_REQUIRED',
        message: 'Authorization required',
        auth_url: url
      })
      exit 2
    end

    # Auto-refresh expired tokens
    credentials.refresh! if credentials.expired?
    credentials
  end
end
```

---

## Quality Standards

### SKILL.md Requirements
- ✅ Follow existing email/calendar/contacts pattern
- ✅ Progressive disclosure (overview → core workflows → advanced features)
- ✅ Clear "When to Use This Skill" section
- ✅ Bundled resources documentation (scripts, references, examples)
- ✅ Error handling patterns
- ✅ Version history
- ✅ Integration notes with other skills

### Ruby Script Requirements
- ✅ Shared OAuth pattern from existing skills
- ✅ JSON input/output for all operations
- ✅ Consistent exit codes (0=success, 1=failed, 2=auth, 3=api, 4=args)
- ✅ Comprehensive error handling
- ✅ Auto-refresh expired tokens
- ✅ Clear operation documentation

### Reference Documentation
- ✅ Complete operation reference
- ✅ Parameter documentation
- ✅ Example commands
- ✅ Error scenarios and solutions

---

## Cross-Skill Integration Examples

### Example 1: Create and Populate Spreadsheet
```bash
# Step 1: google-drive creates spreadsheet file
drive_manager.rb --create \
  --name "Q4 Budget" \
  --type "application/vnd.google-apps.spreadsheet"

# Returns: {"file_id": "abc123xyz"}

# Step 2: google-sheets populates data
sheets_manager.rb --write \
  --spreadsheet-id "abc123xyz" \
  --range "A1:D10" \
  --values '[[...data...]]'

# Step 3: google-drive shares with team
drive_manager.rb --share \
  --file-id "abc123xyz" \
  --email "team@company.com" \
  --role "writer"
```

### Example 2: Generate Report Document
```bash
# Step 1: google-drive creates document
drive_manager.rb --create \
  --name "Monthly Report" \
  --type "application/vnd.google-apps.document"

# Step 2: google-docs adds content
docs_manager.rb --insert \
  --document-id "xyz789abc" \
  --text "# Monthly Report\n\nExecutive Summary..."

# Step 3: google-drive exports to PDF
drive_manager.rb --export \
  --file-id "xyz789abc" \
  --format "pdf" \
  --output "report.pdf"
```

---

## Ruby Gem Dependencies

### Installation Commands
```bash
# For google-drive skill
gem install google-apis-drive_v3

# For google-sheets skill
gem install google-apis-sheets_v4

# For google-docs skill
gem install google-apis-docs_v1

# Shared dependencies (already installed)
# - googleauth (OAuth)
# - google-apis-calendar_v3
# - google-apis-people_v1
```

### Gemfile (Optional)
```ruby
# ~/.claude/skills/Gemfile
source 'https://rubygems.org'

gem 'googleauth'
gem 'google-apis-gmail_v1'
gem 'google-apis-calendar_v3'
gem 'google-apis-people_v1'
gem 'google-apis-drive_v3'
gem 'google-apis-sheets_v4'
gem 'google-apis-docs_v1'
```

---

## Testing Checklist

### OAuth Token Sharing Tests
- [ ] Delete existing token: `rm ~/.claude/.google/token.json`
- [ ] Run any skill to trigger re-auth
- [ ] Verify all 6 scopes appear in consent screen
- [ ] Authorize and store new token
- [ ] Test each skill independently
- [ ] Verify token file contains all scopes
- [ ] Test token auto-refresh on expiry

### Individual Skill Tests

**google-drive**:
- [ ] List files
- [ ] Search files
- [ ] Upload file
- [ ] Download file
- [ ] Create folder
- [ ] Delete file
- [ ] Move/rename file
- [ ] Share file
- [ ] Export Sheets to CSV

**google-sheets**:
- [ ] Read cell values
- [ ] Write cell values
- [ ] Read/write ranges
- [ ] Write formulas
- [ ] Create new sheet
- [ ] Append rows
- [ ] Clear range

**google-docs**:
- [ ] Read document content
- [ ] Insert text
- [ ] Append text
- [ ] Replace text
- [ ] Basic formatting
- [ ] Get document structure

### Cross-Skill Workflow Tests
- [ ] Create spreadsheet (Drive) → Populate (Sheets) → Share (Drive)
- [ ] Create document (Drive) → Edit content (Docs) → Export PDF (Drive)
- [ ] Search for Sheets files (Drive) → Read data (Sheets)

---

## Risk Mitigation

### Potential Issues

1. **OAuth Scope Conflicts**
   - **Risk**: New scopes may require token deletion/re-auth
   - **Mitigation**: Document re-auth process clearly
   - **Rollback**: Existing skills continue working with old token

2. **Ruby Gem Compatibility**
   - **Risk**: Version conflicts between gems
   - **Mitigation**: Use latest stable versions, test individually
   - **Rollback**: Pin gem versions if conflicts occur

3. **API Quota Limits**
   - **Risk**: Google API rate limiting
   - **Mitigation**: Implement retry logic, respect rate limits
   - **Solution**: Document quota limits in references

4. **Parallel Development Conflicts**
   - **Risk**: Subagents may create conflicting implementations
   - **Mitigation**: Clear separation of concerns, distinct file paths
   - **Validation**: Review all implementations before merge

---

## Progress Tracking

### Implementation Status

| Skill | Status | Subagent | Progress |
|-------|--------|----------|----------|
| google-drive | ✅ Complete | Completed Nov 10, 2025 | 100% |
| google-sheets | 📋 Pending | Not started | 0% |
| google-docs | 📋 Pending | Not started | 0% |

### Overall Progress: 33% (1 of 3 skills complete)

**Completed**:
1. ✅ google-drive skill fully implemented
   - Directory structure created
   - drive_manager.rb with all operations
   - SKILL.md documentation (14KB)
   - drive_operations.md reference (17KB)
   - mime_types.md reference (14KB)
   - All required Ruby gems installed
   - OAuth integration with 6 scopes tested

**Next Steps**:
1. ✅ Create skill directories (COMPLETE - google-drive)
2. 🔄 Launch remaining subagents for google-sheets and google-docs
3. Monitor progress and coordinate OAuth integration
4. Validate and test all implementations

---

## Success Criteria

### Phase Completion Checklist

**Phase 1: Planning** ✅
- [x] Research documented
- [x] Implementation plan created
- [ ] Directories created
- [ ] Dependencies documented

**Phase 2: Development** 📋
- [ ] All three skills implemented
- [ ] Ruby scripts functional
- [ ] SKILL.md documentation complete
- [ ] Reference materials created

**Phase 3: OAuth Integration** 📋
- [ ] All skills use shared token
- [ ] Re-authorization tested
- [ ] Scope verification complete

**Phase 4: Validation** 📋
- [ ] Individual skill tests pass
- [ ] Cross-skill workflows validated
- [ ] Documentation reviewed
- [ ] User acceptance criteria met

---

**Plan Created**: November 10, 2025
**Last Updated**: November 10, 2025
**Next Update**: After subagent task completion
