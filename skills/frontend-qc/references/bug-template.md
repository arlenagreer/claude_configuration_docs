# Bug Report Template

## Title Format
`[Component]: Brief description of issue`

Example: `Login Form: Submit button unresponsive with valid credentials`

## Bug Report Structure

**Severity**: [Critical | High | Medium | Low]

**Type**: [Bug | UI Issue | Accessibility | Performance]

**Impact**: [User-facing | Internal | Edge case]

**Description**:
Clear explanation of the issue. What's broken and why it matters.

**Steps to Reproduce**:
1. Navigate to [URL or page]
2. Perform [specific action]
3. Observe [what happens]
4. Expected: [what should happen]
5. Actual: [what actually happens]

**Environment**:
- Browser: [Chrome 120, Firefox 118, etc.]
- App URL: [http://localhost:3000 or production URL]
- User Role: [Admin, Manager, User]
- Test Account: [email if relevant]

**Console Errors** (if any):
```
[Paste console error output here]
```

**Network Errors** (if any):
```
POST /api/v1/endpoint 500 (Internal Server Error)
```

**Screenshot**: [Embedded in GitHub issue]

**Additional Context**:
Any other relevant information about the issue.

---

## Example: Critical Bug

**Title**: Login Form: Authentication fails with 500 error

**Severity**: Critical

**Type**: Bug

**Impact**: User-facing

**Description**:
Users cannot log in to the application. The login form submits but returns a 500 Internal Server Error, preventing all user access.

**Steps to Reproduce**:
1. Navigate to http://localhost:4000/login
2. Enter email: admin@example.com
3. Enter password: Kakellna123!
4. Click "Sign In" button
5. Expected: Redirect to dashboard with authentication
6. Actual: Form shows no feedback, 500 error in console, user remains on login page

**Environment**:
- Browser: Chrome 120.0.6099.109
- App URL: http://localhost:4000
- User Role: Admin
- Test Account: admin@example.com

**Console Errors**:
```
POST http://localhost:3000/api/v1/auth/login 500 (Internal Server Error)
TypeError: Cannot read property 'token' of undefined
    at authService.js:45
```

**Screenshot**: [Embedded showing error state and console]

---

## Example: UI Issue

**Title**: Registration Form: Submit button overlaps input on mobile

**Severity**: Medium

**Type**: UI Issue

**Impact**: User-facing

**Description**:
On mobile viewports (375px width), the submit button overlaps the last form field by approximately 10px, making it difficult to interact with either element.

**Steps to Reproduce**:
1. Resize browser to 375px width (or use iPhone 12 viewport)
2. Navigate to /register
3. Observe submit button position relative to last input field
4. Expected: Button has proper spacing below input
5. Actual: Button overlaps input field

**Environment**:
- Browser: Chrome 120 (mobile viewport)
- App URL: http://localhost:4000
- Viewport: 375x667px

**Recommendation**:
Add `margin-top: 20px` to submit button on mobile breakpoint (<768px).

**Screenshot**: [Embedded showing overlap]
