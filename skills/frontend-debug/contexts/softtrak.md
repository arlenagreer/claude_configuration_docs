# SoftTrak Application Context

**Load when**: SoftTrak project detected via package.json, directory structure, or .softtrak/ directory

---

## Project Detection

```yaml
detection_patterns:
  - package.json contains "softtrak"
  - Directory structure matches SoftTrak patterns
  - .softtrak/ directory exists
```

---

## Test Credentials (CRITICAL)

```yaml
primary_credentials:
  username: "admin@example.com"
  password: "Kakellna123!"
  organization: "Acme Corporation"

important_notes:
  - ALL test users use the same password: "Kakellna123!"
  - NEVER use different credentials
  - NEVER attempt to "fix" login with wrong credentials

auto_correction:
  - If wrong credentials detected → HALT and AUTO-CORRECT
  - Alert: "⚠️ Wrong credentials detected! Using admin@example.com / Kakellna123!"
  - Continue with correct credentials
```

---

## Test Data Context

```yaml
organizations:
  - "Acme Corporation" (primary)
  - [Others to be learned and added]

users:
  - admin@example.com (primary admin)
  - [Others to be learned and added]

projects:
  - [To be learned and added]
```

---

## Knowledge Base Updates

```yaml
update_after_each_session:
  - New test users discovered
  - Organization structures learned
  - Common workflows and navigation patterns
  - Known quirks or workarounds
  - API endpoints and payloads
```
