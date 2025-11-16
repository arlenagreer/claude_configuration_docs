# Security Implementation Guide

This guide provides comprehensive instructions for maintaining security in this project.

## Quick Start Security Checklist

### Initial Setup

- [ ] Enable Dependabot alerts in repository settings
- [ ] Enable Dependabot security updates
- [ ] Enable secret scanning
- [ ] Enable code scanning (CodeQL)
- [ ] Configure branch protection rules
- [ ] Review and customize `.github/dependabot.yml`
- [ ] Set up security contact in `.github/SECURITY.md`

### Regular Maintenance

- [ ] Review Dependabot PRs weekly
- [ ] Run `npm audit` before releases
- [ ] Monitor GitHub Security Advisories
- [ ] Review security workflow results
- [ ] Update dependencies monthly
- [ ] Rotate credentials quarterly

## Dependency Management

### Checking for Vulnerabilities

```bash
# Quick audit
npm audit

# Detailed audit with JSON output
npm audit --json > audit-report.json

# Audit production dependencies only
npm audit --production

# Audit with specific severity threshold
npm audit --audit-level=high
```

### Updating Dependencies

```bash
# Update to safe versions (patch/minor)
npm update

# Fix vulnerabilities automatically
npm audit fix

# Force fix (may introduce breaking changes)
npm audit fix --force

# Update specific package
npm install <package>@latest

# Check for outdated packages
npm outdated
```

### Dependabot Configuration

The `.github/dependabot.yml` file is configured to:

- **Weekly scans** every Monday at 9 AM PST
- **Automatic PRs** for security updates
- **Group security updates** for easier review
- **Ignore major updates** for critical frameworks (requires manual review)
- **Limit to 10 open PRs** to prevent overwhelming the team

#### Customizing Dependabot

```yaml
# Adjust update frequency
schedule:
  interval: "daily" # or "weekly", "monthly"

# Change timezone
timezone: "America/New_York"

# Add more ignored dependencies
ignore:
  - dependency-name: "package-name"
    update-types: ["version-update:semver-major"]
```

## CI/CD Security Integration

### Security Workflow Features

The `.github/workflows/security-audit.yml` workflow:

1. **Runs on every push** to main/develop branches
2. **Runs on all PRs** to main/develop
3. **Weekly scheduled scans** (Mondays 9 AM PST)
4. **Manual trigger option** via workflow_dispatch
5. **Fails on high/critical vulnerabilities**
6. **Posts PR comments** with vulnerability summaries
7. **Uploads audit reports** as artifacts
8. **Dependency review** for PRs

### Customizing Security Thresholds

Edit `.github/workflows/security-audit.yml`:

```yaml
# Fail on moderate or higher
- name: Run npm audit
  run: npm audit --audit-level=moderate

# Only fail on critical
- name: Run npm audit
  run: npm audit --audit-level=critical
```

### Viewing Audit Reports

1. Go to **Actions** tab in GitHub
2. Select **Security Audit** workflow
3. Click on a specific run
4. Download **npm-audit-report** artifact
5. Open `audit-report.json` for detailed analysis

## Security Best Practices

### Environment Variables

**Never commit sensitive data:**

```bash
# ❌ BAD
API_KEY=sk_live_abc123xyz

# ✅ GOOD - Use .env files
# .env (add to .gitignore)
API_KEY=sk_live_abc123xyz
```

**Example .env.example:**

```bash
# Copy this to .env and fill in your values
API_KEY=your_api_key_here
DATABASE_URL=your_database_url_here
SECRET_KEY=your_secret_key_here
```

### Secrets Management

1. **GitHub Secrets** for CI/CD
   - Repository Settings → Secrets → Actions
   - Add secrets needed for workflows

2. **Environment Variables** for local development
   - Use `.env` files (gitignored)
   - Never commit credentials

3. **Secret Scanning**
   - GitHub automatically scans for leaked secrets
   - Review and revoke if detected

### Input Validation

```javascript
// ❌ BAD - No validation
function processUserInput(input) {
  return eval(input); // DANGEROUS!
}

// ✅ GOOD - Validate and sanitize
function processUserInput(input) {
  if (typeof input !== 'string') {
    throw new Error('Invalid input type');
  }

  const sanitized = input.trim().slice(0, 100);

  if (!/^[a-zA-Z0-9\s]+$/.test(sanitized)) {
    throw new Error('Invalid characters');
  }

  return sanitized;
}
```

### SQL Injection Prevention

```javascript
// ❌ BAD - String concatenation
const query = `SELECT * FROM users WHERE id = ${userId}`;

// ✅ GOOD - Parameterized queries
const query = 'SELECT * FROM users WHERE id = ?';
db.execute(query, [userId]);
```

### XSS Prevention

```javascript
// ❌ BAD - Direct HTML injection
element.innerHTML = userInput;

// ✅ GOOD - Use textContent or sanitize
element.textContent = userInput;

// Or use a sanitization library
import DOMPurify from 'dompurify';
element.innerHTML = DOMPurify.sanitize(userInput);
```

## Handling Security Vulnerabilities

### When Dependabot Creates a PR

1. **Review the advisory**
   - Click on the security advisory link
   - Understand the vulnerability impact
   - Check affected versions

2. **Assess the impact**
   - Is the vulnerability exploitable in our code?
   - What's the severity level?
   - Are there breaking changes?

3. **Test the update**
   - Check out the PR branch
   - Run tests: `npm test`
   - Test critical functionality
   - Check for breaking changes

4. **Merge or escalate**
   - If tests pass → Merge
   - If tests fail → Investigate and fix
   - If major changes → Review with team

### Manual Vulnerability Resolution

```bash
# 1. Identify the vulnerability
npm audit

# 2. Check for available fix
npm audit fix --dry-run

# 3. Apply the fix
npm audit fix

# 4. If automatic fix not available
npm update <vulnerable-package>

# 5. If still vulnerable, consider alternatives
npm uninstall <vulnerable-package>
npm install <alternative-package>

# 6. Verify fix
npm audit

# 7. Commit changes
git add package-lock.json package.json
git commit -m "security: fix vulnerability in <package>"
```

### No Fix Available

If no fix is available:

1. **Assess risk**
   - Is the vulnerability exploitable?
   - What's our exposure?
   - Can we mitigate?

2. **Temporary mitigation**
   - Apply workarounds from advisory
   - Add security headers
   - Implement additional validation

3. **Monitor for updates**
   - Subscribe to package updates
   - Check weekly for new versions
   - Set calendar reminder

4. **Document the decision**
   ```markdown
   ## Known Vulnerability: CVE-XXXX-XXXXX

   **Status**: No fix available
   **Package**: package-name@1.2.3
   **Severity**: Medium
   **Mitigation**: [Describe mitigation steps]
   **Review Date**: YYYY-MM-DD
   ```

## Security Monitoring

### GitHub Security Features

1. **Security Advisories**
   - Repository → Security → Advisories
   - Review and address alerts

2. **Dependabot Alerts**
   - Repository → Security → Dependabot
   - Configure auto-dismiss for false positives

3. **Code Scanning**
   - Repository → Security → Code scanning
   - Review and fix issues

4. **Secret Scanning**
   - Repository → Security → Secret scanning
   - Revoke and rotate exposed secrets

### External Monitoring

- **npm Advisory Database**: https://www.npmjs.com/advisories
- **Snyk Vulnerability Database**: https://snyk.io/vuln
- **GitHub Advisory Database**: https://github.com/advisories
- **CVE Database**: https://cve.mitre.org/

## Incident Response

### If a Vulnerability is Discovered

1. **Immediate Actions** (0-24 hours)
   - Assess severity and impact
   - Determine if actively exploited
   - Deploy emergency hotfix if critical
   - Notify affected users if necessary

2. **Short-term Response** (1-7 days)
   - Develop and test comprehensive fix
   - Update dependencies
   - Deploy fix to production
   - Monitor for exploitation attempts

3. **Long-term Response** (1-4 weeks)
   - Post-mortem analysis
   - Update security processes
   - Improve detection mechanisms
   - Document lessons learned

### If Secrets are Leaked

1. **Immediate Revocation**
   ```bash
   # Revoke compromised credentials immediately
   # Contact service provider if API key
   # Rotate database passwords
   # Update GitHub secrets
   ```

2. **Git History Cleanup** (if needed)
   ```bash
   # Use BFG Repo-Cleaner or git-filter-repo
   # DO NOT use git filter-branch (deprecated)

   # Example with BFG
   bfg --delete-files secret-file.txt
   git reflog expire --expire=now --all
   git gc --prune=now --aggressive
   git push --force
   ```

3. **Notification**
   - Notify team members
   - Notify affected users (if applicable)
   - Document the incident

## Security Checklists

### Pre-Release Security Checklist

- [ ] All tests passing
- [ ] `npm audit` shows no high/critical vulnerabilities
- [ ] Security workflow passing
- [ ] No secrets in code
- [ ] Dependencies up to date
- [ ] Security headers configured
- [ ] Input validation implemented
- [ ] Authentication tested
- [ ] Authorization tested
- [ ] Rate limiting configured
- [ ] Logging and monitoring active

### Monthly Security Review

- [ ] Review Dependabot alerts
- [ ] Update all dependencies
- [ ] Run full security audit
- [ ] Review access logs
- [ ] Rotate credentials
- [ ] Review user permissions
- [ ] Test backup restoration
- [ ] Review security documentation
- [ ] Update security training

## Resources

### Documentation

- [GitHub Security Best Practices](https://docs.github.com/en/code-security)
- [npm Security Best Practices](https://docs.npmjs.com/packages-and-modules/securing-your-code)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Node.js Security Checklist](https://nodejs.org/en/docs/guides/security/)

### Tools

- [npm audit](https://docs.npmjs.com/cli/v8/commands/npm-audit)
- [Snyk](https://snyk.io/)
- [GitHub Dependabot](https://github.com/dependabot)
- [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/)

### Training

- [OWASP WebGoat](https://owasp.org/www-project-webgoat/)
- [Node.js Security Course](https://nodejssecurity.com/)
- [GitHub Security Lab](https://securitylab.github.com/)

---

**Questions?** Check `.github/SECURITY.md` or contact the security team.
