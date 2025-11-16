# Security Policy

## Supported Versions

We actively maintain and provide security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security issue, please follow these steps:

### Private Disclosure

**DO NOT** create a public GitHub issue for security vulnerabilities.

Instead, please report security vulnerabilities through one of the following channels:

1. **GitHub Security Advisories** (Preferred)
   - Go to the Security tab
   - Click "Report a vulnerability"
   - Fill out the private disclosure form

2. **Direct Email**
   - Email: [Your security contact email]
   - Subject: "[SECURITY] Vulnerability Report"
   - Include detailed description and reproduction steps

### What to Include

Please provide as much information as possible:

- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact assessment
- Suggested fix (if available)
- Your contact information for follow-up

### Response Timeline

- **Initial Response**: Within 48 hours
- **Triage Assessment**: Within 5 business days
- **Security Fix**: Depends on severity
  - Critical: 1-7 days
  - High: 7-14 days
  - Medium: 14-30 days
  - Low: 30-90 days

### Disclosure Policy

- We will acknowledge your report within 48 hours
- We will provide regular updates on our progress
- We will publicly disclose the vulnerability after a fix is released
- We credit security researchers in our release notes (unless you prefer anonymity)

## Security Best Practices

### For Users

1. **Keep Dependencies Updated**
   - Regularly run `npm update` and `npm audit`
   - Review and apply Dependabot security updates
   - Subscribe to security advisories

2. **Review Changes**
   - Review all dependency updates before merging
   - Pay special attention to major version bumps
   - Test thoroughly after security updates

3. **Environment Security**
   - Never commit secrets, API keys, or credentials
   - Use environment variables for sensitive data
   - Enable GitHub secret scanning
   - Rotate credentials if accidentally exposed

### For Contributors

1. **Secure Development**
   - Follow OWASP secure coding guidelines
   - Validate all user inputs
   - Use parameterized queries for databases
   - Implement proper authentication and authorization
   - Follow principle of least privilege

2. **Dependency Management**
   - Only add necessary dependencies
   - Review dependency licenses and security history
   - Keep dependencies up to date
   - Use lock files (package-lock.json)

3. **Code Review**
   - Security-focused code reviews required
   - Automated security scanning in CI/CD
   - No bypassing of security checks

## Security Measures in Place

### Automated Security

- **Dependabot**: Automated dependency updates
- **npm audit**: CI/CD security scanning
- **Dependency Review**: PR-based security analysis
- **GitHub Code Scanning**: Static analysis security testing
- **Secret Scanning**: Credential leak prevention

### Manual Reviews

- Security-focused code reviews for all changes
- Quarterly dependency audits
- Regular security testing and penetration testing

## Known Vulnerabilities

Current known vulnerabilities are tracked in:
- GitHub Security Advisories
- Dependabot Alerts
- Public CVE database references

### Recently Addressed

- **CVE-2025-57822** (Next.js SSRF) - Fixed in v14.2.32
- **CVE-2025-64718** (js-yaml Prototype Pollution) - Fixed in v4.1.1

## Security Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)
- [npm Security Advisories](https://www.npmjs.com/advisories)
- [GitHub Security Lab](https://securitylab.github.com/)

## Contact

For security-related questions or concerns:
- Security Team: [Your contact method]
- General Issues: Use GitHub Issues (non-security only)

---

**Last Updated**: November 2025
