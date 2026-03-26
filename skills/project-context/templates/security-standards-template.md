# Security Standards

> Validation, sanitization, and security requirements for this project

## Security Philosophy

[Team's approach to security: defense in depth, least privilege, etc.]

## Input Validation

### Where to Validate

**Security Boundaries** (MUST validate):
- ✅ All external input (user input, API requests, file uploads)
- ✅ Data from external services
- ✅ URL parameters and query strings
- ✅ HTTP headers
- ✅ Environment variables (external)

**Trusted Internal** (Can skip validation):
- ✅ Internal service-to-service calls
- ✅ Data already validated at boundary
- ✅ Hardcoded constants

### Validation Pattern

```[language]
function processUserInput(input: unknown): ValidatedData {
  // 1. Type validation
  if (typeof input !== 'expected type') {
    throw new ValidationError('Invalid type')
  }

  // 2. Format validation
  if (!matchesExpectedFormat(input)) {
    throw new ValidationError('Invalid format')
  }

  // 3. Range validation
  if (!isWithinAllowedRange(input)) {
    throw new ValidationError('Out of range')
  }

  // 4. Business rule validation
  if (!meetsBusinessRules(input)) {
    throw new ValidationError('Business rule violation')
  }

  return input as ValidatedData
}
```

### Common Validations

**Email:**
```[language]
[email validation pattern]
```

**URLs:**
```[language]
[URL validation pattern]
```

**Numeric input:**
```[language]
[numeric validation pattern]
```

**String length:**
```[language]
[string length validation]
```

**File uploads:**
```[language]
[file validation: type, size, content]
```

## Sanitization

### When to Sanitize

Before:
- Rendering in HTML
- Inserting into database queries
- Executing system commands
- Writing to files
- Logging (to prevent log injection)

### HTML Sanitization

```[language]
// Escape HTML entities
[example]

// Use safe rendering
[example]
```

### SQL Injection Prevention

**Use parameterized queries:**
```[language]
// Good - parameterized
[example of safe query]

// Bad - string concatenation
// NEVER DO THIS
[example of unsafe query]
```

### Command Injection Prevention

```[language]
// Avoid executing shell commands with user input
// If necessary, use allowlist validation
[example]
```

### Path Traversal Prevention

```[language]
// Validate file paths
[example of safe path handling]
```

## Authentication

### Authentication Method

[e.g., JWT, Session-based, OAuth2, etc.]

### Implementation

```[language]
[authentication pattern used in project]
```

### Password Requirements

- Minimum length: [e.g., 12 characters]
- Complexity: [requirements]
- Hashing: [algorithm, e.g., bcrypt, Argon2]
- Salt: [approach]

### Token Management

**JWT (if applicable):**
- Algorithm: [e.g., RS256, HS256]
- Expiration: [e.g., 15 minutes for access, 7 days for refresh]
- Storage: [where tokens are stored]
- Rotation: [refresh token rotation policy]

## Authorization

### Authorization Model

[e.g., RBAC, ABAC, ACL]

### Permission Checks

```[language]
// Check before every protected operation
function performAction(user: User, resource: Resource, action: Action) {
  if (!hasPermission(user, resource, action)) {
    throw new UnauthorizedError()
  }

  // Proceed with action
}
```

### Common Roles

- `[role 1]`: [Permissions]
- `[role 2]`: [Permissions]
- `[role 3]`: [Permissions]

## Secrets Management

### Never

- ❌ Hardcode secrets in code
- ❌ Commit secrets to git
- ❌ Log secrets
- ❌ Pass secrets in URLs
- ❌ Store secrets in frontend code

### Secret Storage

**Development:**
- `.env` files (gitignored)
- Local environment variables

**Production:**
- [Secret management service, e.g., AWS Secrets Manager, HashiCorp Vault]
- Environment variables (in secure deployment)

### Secret Access Pattern

```[language]
[example of securely accessing secrets]
```

## HTTPS/TLS

### Requirements

- ✅ All production traffic over HTTPS
- ✅ TLS 1.2 or higher
- ✅ Valid certificates (no self-signed in production)
- ✅ Redirect HTTP to HTTPS

### Certificate Management

[How certificates are managed and rotated]

## CORS

### Configuration

```[language]
// Allowed origins (never use '*' in production)
[CORS configuration]
```

## Rate Limiting

### Endpoints

- Login: [e.g., 5 attempts per 15 minutes]
- API calls: [e.g., 100 requests per minute]
- File uploads: [e.g., 10 per hour]

### Implementation

```[language]
[rate limiting pattern]
```

## Security Headers

### Required Headers

```http
Content-Security-Policy: [policy]
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

## Error Handling

### Safe Error Messages

```[language]
// Good - generic user-facing error
throw new UserError('Invalid credentials')

// Bad - leaks information
// throw new Error('User not found in database table users')
```

### Error Logging

```[language]
// Log detailed errors internally
logger.error('Authentication failed', {
  userId: userId,
  reason: 'password mismatch',
  timestamp: Date.now()
})

// Return generic error to user
return { error: 'Authentication failed' }
```

## File Upload Security

### Validation

```[language]
function validateFileUpload(file: File) {
  // 1. Check file type (don't trust MIME type)
  const allowedExtensions = ['.jpg', '.png', '.pdf']
  if (!allowedExtensions.includes(getExtension(file))) {
    throw new ValidationError('Invalid file type')
  }

  // 2. Check file size
  const maxSize = 10 * 1024 * 1024 // 10MB
  if (file.size > maxSize) {
    throw new ValidationError('File too large')
  }

  // 3. Scan for malware (if applicable)
  scanForMalware(file)

  // 4. Store with random filename
  const safeFilename = generateRandomFilename(file)

  return safeFilename
}
```

## Database Security

### Query Safety

- ✅ Always use parameterized queries
- ✅ Least privilege database users
- ✅ Encrypt sensitive data at rest
- ✅ Encrypt connections (TLS)

### Sensitive Data

**Encryption:**
- [What gets encrypted]
- [Encryption method]
- [Key management]

**Access logging:**
- [What accesses are logged]
- [Log retention]

## Common Vulnerabilities to Avoid

### SQL Injection
❌ **Never**: String concatenation in queries
✅ **Always**: Parameterized queries

### XSS (Cross-Site Scripting)
❌ **Never**: Insert unsanitized user input into HTML
✅ **Always**: Escape or sanitize before rendering

### CSRF (Cross-Site Request Forgery)
❌ **Never**: Accept state-changing requests without CSRF tokens
✅ **Always**: Use CSRF protection for forms

### Command Injection
❌ **Never**: Execute shell commands with user input
✅ **Always**: Validate with strict allowlist if needed

### Path Traversal
❌ **Never**: Use user input directly in file paths
✅ **Always**: Validate and sanitize file paths

### Insecure Deserialization
❌ **Never**: Deserialize untrusted data
✅ **Always**: Validate format and use safe parsers

## Security Testing

### Automated Scanning

**Tools:**
- [Tool 1]: [What it checks]
- [Tool 2]: [What it checks]

**Schedule:**
- On every PR: [quick scans]
- Nightly: [full scans]
- Before release: [comprehensive audit]

### Manual Security Review

**Checklist:**
- [ ] Input validation at all boundaries
- [ ] Authentication required for protected resources
- [ ] Authorization checks before operations
- [ ] Secrets not in code or logs
- [ ] Error messages don't leak information
- [ ] HTTPS enforced
- [ ] Security headers configured
- [ ] Rate limiting on sensitive endpoints

## Incident Response

### Reporting Security Issues

[How to report security vulnerabilities]

### Security Contact

[Security team contact information]

## Compliance

[Any relevant compliance requirements: GDPR, HIPAA, PCI-DSS, etc.]

## References

- [OWASP Top 10]
- [Security policy document]
- [Incident response playbook]
- [Security training materials]
