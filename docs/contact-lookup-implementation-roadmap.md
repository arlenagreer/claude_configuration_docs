# Google Contacts Email Lookup - Implementation Roadmap

**Project**: Standalone Ruby script for contact email lookup via Google People API
**Owner**: Arlen Greer
**Created**: 2025-10-19
**Status**: Planning Phase

---

## 📋 Executive Summary

**Objective**: Build a command-line Ruby script that queries Google Contacts to find email addresses by exact name match, returning JSON-formatted results for integration with Claude Agent Skills.

**Key Requirements**:
- Exact first + last name matching
- JSON output format (extensible)
- Portable credentials across machines
- Error codes for automation
- No caching required

**Success Criteria**:
- ✅ Script returns correct email for exact name matches
- ✅ Error handling with descriptive JSON responses
- ✅ OAuth credentials portable between Mac and laptop
- ✅ Integration test with Claude Agent Skill passes
- ✅ Zero false positives on name matching

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│ Claude Agent Skill (Email Sender)                      │
│  - Receives contact name from user                     │
│  - Invokes lookup_contact_email.rb                     │
│  - Parses JSON response                                │
│  - Proceeds with email composition                     │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│ lookup_contact_email.rb                                 │
│  - Accepts: --name "First Last"                        │
│  - Returns: JSON with email or error                   │
│  - Exit codes: 0=success, 1=no match, 2=auth, 3=api   │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│ Google People API (v1)                                  │
│  - people.connections.list                              │
│  - Filter: names.displayName exact match               │
│  - Returns: emailAddresses array                       │
└─────────────────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│ OAuth 2.0 Credentials (~/.claude/.google/)             │
│  - client_secret.json (from Google Cloud Console)     │
│  - token.json (auto-generated, auto-refreshed)        │
└─────────────────────────────────────────────────────────┘
```

---

## 📅 Implementation Phases

### **Phase 1: Google Cloud Setup & OAuth Configuration**
**Duration**: 30-45 minutes
**Persona**: DevOps + Security

#### Tasks:

**1.1 Google Cloud Project Setup**
- [ ] Create Google Cloud project "claude-contacts-lookup"
- [ ] Enable Google People API
- [ ] Configure OAuth consent screen
  - Application type: Desktop
  - Scopes: `https://www.googleapis.com/auth/contacts.readonly`
  - Test users: Add your Gmail address

**1.2 OAuth Credentials Creation**
- [ ] Create OAuth 2.0 Client ID (Desktop application)
- [ ] Download `client_secret.json`
- [ ] Create directory: `~/.claude/.google/`
- [ ] Move `client_secret.json` to `~/.claude/.google/`
- [ ] Set permissions: `chmod 600 ~/.claude/.google/client_secret.json`

**1.3 Documentation**
- [ ] Create `~/.claude/.google/README.md` with setup instructions
- [ ] Document credential sync process for laptop migration

**Deliverables**:
- ✅ Google Cloud project with People API enabled
- ✅ OAuth credentials in `~/.claude/.google/client_secret.json`
- ✅ Setup documentation

**Validation**:
- Verify People API shows "Enabled" in Google Cloud Console
- Confirm OAuth consent screen configured for "External" with test user

---

### **Phase 2: Core Script Development**
**Duration**: 1.5-2 hours
**Persona**: Backend Engineer + Architect

#### Tasks:

**2.1 Script Foundation**
- [ ] Create `~/.claude/lookup_contact_email.rb`
- [ ] Add shebang: `#!/usr/bin/env ruby`
- [ ] Set executable permissions: `chmod +x`
- [ ] Add command-line argument parsing (OptionParser)
  - `--name "First Last"` (required)
  - `--help` (show usage)
  - `--version` (show script version)

**2.2 Dependency Management**
- [ ] Check for `google-api-client` gem
- [ ] Add installation instructions if missing
- [ ] Require necessary libraries:
  ```ruby
  require 'google/apis/people_v1'
  require 'googleauth'
  require 'googleauth/stores/file_token_store'
  require 'json'
  require 'optparse'
  ```

**2.3 Authentication Module**
- [ ] Implement OAuth flow with file-based token storage
- [ ] Handle first-time authorization (browser redirect)
- [ ] Implement automatic token refresh
- [ ] Error handling for auth failures
- [ ] Credential paths:
  - Client secret: `~/.claude/.google/client_secret.json`
  - Token storage: `~/.claude/.google/token.json`

**2.4 Contact Lookup Logic**
- [ ] Initialize People API service
- [ ] Implement exact name matching algorithm:
  ```ruby
  # Split input into first and last name
  # Query: people.connections.list with personFields=names,emailAddresses
  # Filter results for exact match on givenName + familyName
  # Return primary email address
  ```
- [ ] Handle edge cases:
  - Contact with no email address
  - Contact with multiple email addresses (return primary)
  - Name format variations (handle middle names gracefully)

**2.5 Response Formatting**
- [ ] Implement JSON output generator
- [ ] Success response structure:
  ```json
  {
    "status": "success",
    "email": "contact@example.com",
    "name": "First Last",
    "matched_contact_id": "people/c123456789"
  }
  ```
- [ ] Error response structure:
  ```json
  {
    "status": "error",
    "code": "NO_MATCH_FOUND|AUTH_ERROR|API_ERROR",
    "message": "Descriptive error message",
    "query": "First Last"
  }
  ```

**2.6 Exit Code Implementation**
- [ ] `0` = Success (contact found)
- [ ] `1` = No match found
- [ ] `2` = Authentication error
- [ ] `3` = API error (network, quota, etc.)
- [ ] `4` = Invalid arguments

**Deliverables**:
- ✅ Functional Ruby script at `~/.claude/lookup_contact_email.rb`
- ✅ JSON output format implemented
- ✅ Exit codes properly set
- ✅ OAuth authentication working

**Validation**:
- Script runs without syntax errors
- `--help` flag displays usage information
- Authentication flow completes successfully
- Test lookup returns valid JSON

---

### **Phase 3: Testing & Validation**
**Duration**: 45-60 minutes
**Persona**: QA Engineer

#### Tasks:

**3.1 Manual Testing Scenarios**
- [ ] **Test Case 1: Successful Lookup**
  - Input: Exact match from Google Contacts
  - Expected: JSON with email, exit code 0
  - Validation: Email matches contact record

- [ ] **Test Case 2: No Match Found**
  - Input: Non-existent contact name
  - Expected: Error JSON with NO_MATCH_FOUND, exit code 1
  - Validation: Clear error message

- [ ] **Test Case 3: Partial Name Match (Should Fail)**
  - Input: First name only
  - Expected: Error JSON, exit code 1
  - Validation: Confirms exact match requirement

- [ ] **Test Case 4: Name Case Sensitivity**
  - Input: "john doe" vs "John Doe"
  - Expected: Case-insensitive match
  - Validation: Both formats return same result

- [ ] **Test Case 5: Multiple Contacts with Same Name**
  - Input: Exact match but duplicate names in contacts
  - Expected: Return first match or prompt (design decision needed)
  - Validation: Consistent behavior documented

- [ ] **Test Case 6: Authentication Failure**
  - Simulate: Delete token.json
  - Expected: Auth error JSON, exit code 2
  - Validation: OAuth flow re-initiates

- [ ] **Test Case 7: Network Error**
  - Simulate: Disconnect internet
  - Expected: API error JSON, exit code 3
  - Validation: Descriptive error message

**3.2 Integration Testing**
- [ ] Test from command line: `./lookup_contact_email.rb --name "Test Contact"`
- [ ] Verify JSON parsing in bash: `./lookup_contact_email.rb --name "..." | jq .`
- [ ] Test with Claude Agent Skill invocation pattern

**3.3 Edge Case Validation**
- [ ] Contact with no email address
- [ ] Contact with multiple email addresses
- [ ] Special characters in names (O'Brien, José, etc.)
- [ ] Empty/whitespace-only input
- [ ] Missing required arguments

**Deliverables**:
- ✅ Test results documented
- ✅ All edge cases handled
- ✅ Error messages clear and actionable

**Validation Criteria**:
- Zero false positives on name matching
- All exit codes return correctly
- JSON always valid (no malformed output)

---

### **Phase 4: Claude Agent Skill Integration**
**Duration**: 30-45 minutes
**Persona**: Integration Engineer

#### Tasks:

**4.1 Skill Design**
- [ ] Define skill interface:
  ```yaml
  skill: lookup_contact_email
  inputs:
    - contact_name (string, required)
  outputs:
    - email_address (string)
    - status (success|error)
  ```

**4.2 Skill Implementation**
- [ ] Create skill file structure (location TBD based on Claude Agent framework)
- [ ] Implement script invocation:
  ```ruby
  result = `~/.claude/lookup_contact_email.rb --name "#{contact_name}"`
  exit_code = $?.exitstatus
  parsed = JSON.parse(result)
  ```
- [ ] Error handling for skill:
  - Exit code 0: Proceed with email
  - Exit code 1: Ask user for email address manually
  - Exit code 2/3: Report error to user

**4.3 Workflow Integration**
- [ ] Test email sending workflow:
  1. User: "Send progress update to John Doe"
  2. Skill: Invoke lookup → Get email
  3. Skill: Compose email with retrieved address
  4. Skill: Send via Gmail MCP or Himalaya CLI

**Deliverables**:
- ✅ Claude Agent Skill definition
- ✅ End-to-end email workflow tested
- ✅ Error handling graceful

**Validation**:
- Skill successfully retrieves email and sends message
- Errors reported clearly to user
- Workflow feels seamless

---

### **Phase 5: Portability & Documentation**
**Duration**: 30 minutes
**Persona**: Technical Writer + DevOps

#### Tasks:

**5.1 Credential Portability Guide**
- [ ] Document laptop migration steps:
  1. On Mac: `tar -czf google-creds.tar.gz ~/.claude/.google/`
  2. Transfer to laptop via secure method
  3. On laptop: `tar -xzf google-creds.tar.gz -C ~/`
  4. Verify permissions preserved
- [ ] Alternative: Use cloud sync (Dropbox, iCloud) with symlink

**5.2 Script Documentation**
- [ ] Add inline comments for key functions
- [ ] Create usage examples in header comments
- [ ] Document JSON response schema
- [ ] Add troubleshooting section

**5.3 README Creation**
- [ ] Create `~/.claude/docs/contact-lookup-readme.md`
- [ ] Sections:
  - Overview
  - Installation
  - Usage
  - JSON Response Format
  - Error Codes
  - Troubleshooting
  - Integration Examples

**Deliverables**:
- ✅ Complete documentation
- ✅ Portability tested between machines
- ✅ Troubleshooting guide

**Validation**:
- Documentation clear enough for future reference
- Credential migration works without re-authentication

---

## 🔧 Technical Specifications

### **Dependencies**
```ruby
# Gemfile (if using Bundler)
gem 'google-api-client', '~> 0.53'
gem 'googleauth', '~> 1.3'

# Or install directly:
# gem install google-api-client googleauth
```

### **File Structure**
```
~/.claude/
├── lookup_contact_email.rb          # Main script (executable)
├── send_sms.rb                      # Existing SMS script
├── contacts.csv                     # Deprecated
├── .google/                         # Google credentials
│   ├── client_secret.json          # OAuth client credentials
│   ├── token.json                  # Access tokens (auto-generated)
│   └── README.md                   # Setup instructions
└── docs/
    ├── contact-lookup-readme.md    # Usage documentation
    └── contact-lookup-implementation-roadmap.md  # This file
```

### **Script Interface**
```bash
# Usage
./lookup_contact_email.rb --name "First Last"

# Output (success)
{"status":"success","email":"first.last@example.com","name":"First Last"}

# Output (error)
{"status":"error","code":"NO_MATCH_FOUND","message":"No contact found matching 'First Last'","query":"First Last"}

# Exit codes
echo $?  # 0=success, 1=no match, 2=auth error, 3=api error, 4=invalid args
```

### **OAuth Scopes Required**
- `https://www.googleapis.com/auth/contacts.readonly`

### **API Endpoints Used**
- `GET https://people.googleapis.com/v1/people/me/connections`
  - Query parameters: `personFields=names,emailAddresses&pageSize=1000`

---

## ⚠️ Risk Assessment & Mitigation

### **Risk 1: OAuth Consent Screen Verification Delay**
- **Impact**: Medium
- **Probability**: Low
- **Mitigation**: Use "External" with test users during development
- **Contingency**: Apply for verification if production use required

### **Risk 2: API Quota Limits**
- **Impact**: Low (usage expected to be minimal)
- **Probability**: Very Low
- **Mitigation**: Monitor quota usage in Google Cloud Console
- **Contingency**: Request quota increase if needed

### **Risk 3: Name Matching Ambiguity**
- **Impact**: Medium (affects accuracy)
- **Probability**: Medium
- **Mitigation**: Exact match on both first and last name
- **Contingency**: If duplicate names exist, return first match with warning

### **Risk 4: Credential Sync Issues**
- **Impact**: Low
- **Probability**: Low
- **Mitigation**: Document clear sync process, use tar.gz method
- **Contingency**: Re-authenticate on new machine (one-time setup)

### **Risk 5: API Changes/Deprecation**
- **Impact**: High
- **Probability**: Very Low (People API is stable)
- **Mitigation**: Use official `google-api-client` gem (handles versioning)
- **Contingency**: Monitor Google API announcements

---

## 📊 Success Metrics

### **Functionality**
- ✅ 100% accuracy on exact name matches
- ✅ 0% false positive rate
- ✅ Error handling covers all edge cases

### **Performance**
- ⏱️ Lookup completes in <3 seconds (network dependent)
- 🔄 OAuth token refresh transparent to user

### **Usability**
- 📖 Documentation clear and complete
- 🔧 Installation requires minimal steps
- 🚀 Integration with Claude Agent Skill seamless

### **Portability**
- 💻 Credentials sync between machines without re-auth
- 🔐 Security maintained across environments

---

## 🚀 Next Steps After Approval

1. **Immediate**: Phase 1 - Google Cloud setup (30 min)
2. **Day 1**: Phase 2 - Script development (2 hours)
3. **Day 1**: Phase 3 - Testing (1 hour)
4. **Day 2**: Phase 4 - Skill integration (45 min)
5. **Day 2**: Phase 5 - Documentation & portability (30 min)

**Total Estimated Time**: 4.5-5 hours over 1-2 days

---

## 📝 Open Questions / Decisions Needed

1. **Multiple Contacts with Same Name**:
   - Current plan: Return first match
   - Alternative: Return all matches and prompt user
   - **Decision needed before Phase 2.4**

2. **Middle Name Handling**:
   - Current plan: Ignore middle names in matching
   - Alternative: Include middle name if provided
   - **Decision needed before Phase 2.4**

3. **Claude Agent Skill Framework**:
   - Need confirmation on skill definition format
   - Need location for skill files
   - **Decision needed before Phase 4**

---

## 🔗 Related Documentation

- [Gmail MCP Configuration](../.mcp.json)
- [SMS Script Reference](../send_sms.rb)
- [SuperClaude Email Commands](CLAUDE.md#email-communication)
- [Google People API Documentation](https://developers.google.com/people/api/rest/v1/people.connections/list)

---

**Roadmap Version**: 1.0
**Last Updated**: 2025-10-19
**Status**: Ready for Implementation Approval
