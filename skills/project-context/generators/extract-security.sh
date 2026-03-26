#!/bin/bash
# Extract security standards from documentation and configuration

set -e

OUTPUT_DIR=".claude/context"
OUTPUT_FILE="$OUTPUT_DIR/security-standards.md"

echo "🔒 Extracting security standards..."

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Check if template exists and use it as base
TEMPLATE_FILE="skills/project-context/templates/security-standards-template.md"

if [ -f "$TEMPLATE_FILE" ]; then
  echo "   Using template as base..."
  cp "$TEMPLATE_FILE" "$OUTPUT_FILE"
else
  # Create minimal header if template doesn't exist
  cat > "$OUTPUT_FILE" << 'EOF'
# Security Standards

> Validation, sanitization, and security requirements

*Auto-generated from project configuration*

EOF
fi

# Look for security documentation
SECURITY_FOUND=false

# Check for SECURITY.md
if [ -f "SECURITY.md" ]; then
  echo "   Found SECURITY.md..."
  SECURITY_FOUND=true

  echo "" >> "$OUTPUT_FILE"
  echo "## Security Policy" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  cat "SECURITY.md" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# Check for security docs
for sec_file in "docs/security.md" "docs/SECURITY.md" "docs/security-guide.md"; do
  if [ -f "$sec_file" ]; then
    echo "   Found $sec_file..."
    SECURITY_FOUND=true

    echo "" >> "$OUTPUT_FILE"
    echo "## From $(basename "$sec_file")" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    cat "$sec_file" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
  fi
done

# Analyze security configurations
echo "" >> "$OUTPUT_FILE"
echo "## Detected Security Configurations" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Check for dependency scanning
echo "### Dependency Scanning" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if [ -f ".github/workflows/security.yml" ] || [ -f ".github/workflows/codeql.yml" ]; then
  echo "✅ GitHub Actions security workflows configured" >> "$OUTPUT_FILE"
  SECURITY_FOUND=true

  if [ -f ".github/workflows/codeql.yml" ]; then
    echo "- CodeQL analysis enabled" >> "$OUTPUT_FILE"
  fi

  if [ -f ".github/workflows/security.yml" ]; then
    echo "- Custom security workflow: \`.github/workflows/security.yml\`" >> "$OUTPUT_FILE"
  fi
else
  echo "⚠️ No automated security scanning detected" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"

# Check for npm audit (JavaScript)
if [ -f "package.json" ]; then
  echo "### JavaScript/TypeScript Security" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "**Dependency audit**: \`npm audit\`" >> "$OUTPUT_FILE"

  if [ -f ".npmrc" ] && grep -q "audit" .npmrc 2>/dev/null; then
    echo "- Configured via \`.npmrc\`" >> "$OUTPUT_FILE"
  fi

  # Check for Snyk or other tools
  if grep -q "snyk" package.json 2>/dev/null; then
    echo "- **Snyk** integration enabled" >> "$OUTPUT_FILE"
  fi

  echo "" >> "$OUTPUT_FILE"
fi

# Check for Python security tools
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  echo "### Python Security" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

  if grep -q "safety" requirements.txt 2>/dev/null || grep -q "safety" requirements-dev.txt 2>/dev/null; then
    echo "- **Safety**: Dependency vulnerability scanning" >> "$OUTPUT_FILE"
  fi

  if grep -q "bandit" requirements.txt 2>/dev/null || grep -q "bandit" requirements-dev.txt 2>/dev/null; then
    echo "- **Bandit**: Security linter" >> "$OUTPUT_FILE"
  fi

  echo "" >> "$OUTPUT_FILE"
fi

# Check for Rust security
if [ -f "Cargo.toml" ]; then
  echo "### Rust Security" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "**Dependency audit**: \`cargo audit\`" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# Check for Go security
if [ -f "go.mod" ]; then
  echo "### Go Security" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "**Vulnerability check**: \`go list -json -m all | nancy sleuth\`" >> "$OUTPUT_FILE"
  echo "**Or use**: \`gosec ./...\`" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# Check for .env.example (indicates environment variable usage)
if [ -f ".env.example" ] || [ -f ".env.sample" ]; then
  echo "### Environment Variables" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "✅ Project uses environment variables for configuration" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "Template file: " >> "$OUTPUT_FILE"

  if [ -f ".env.example" ]; then
    echo "- \`.env.example\`" >> "$OUTPUT_FILE"

    echo "" >> "$OUTPUT_FILE"
    echo "Required variables:" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    grep -v "^#" .env.example | grep "=" | cut -d= -f1 | head -20 >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
  elif [ -f ".env.sample" ]; then
    echo "- \`.env.sample\`" >> "$OUTPUT_FILE"
  fi

  echo "" >> "$OUTPUT_FILE"
  echo "**Important**: Never commit \`.env\` file to git!" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# Check for .gitignore security patterns
if [ -f ".gitignore" ]; then
  echo "### Protected Files (from .gitignore)" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "The following patterns are excluded from git:" >> "$OUTPUT_FILE"
  echo '```' >> "$OUTPUT_FILE"

  # Extract common secret patterns
  grep -E "\\.env|\\.pem|\\.key|secrets|credentials" .gitignore 2>/dev/null | head -10 >> "$OUTPUT_FILE"

  echo '```' >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# Check for CORS configuration
echo "### CORS Configuration" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Look for CORS in common files
if grep -r "cors" --include="*.js" --include="*.ts" --include="*.py" src 2>/dev/null | grep -q .; then
  echo "✅ CORS configuration detected in source code" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "Review CORS settings to ensure proper origin restrictions." >> "$OUTPUT_FILE"
else
  echo "⚠️  No CORS configuration detected" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "If this is a web service, ensure CORS is properly configured." >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"

# Check for authentication patterns
echo "### Authentication" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if grep -r "jwt\|passport\|auth0\|oauth" --include="*.js" --include="*.ts" --include="*.py" src package.json 2>/dev/null | grep -q .; then
  echo "Authentication libraries detected:" >> "$OUTPUT_FILE"

  if grep -q "jwt" package.json 2>/dev/null; then
    echo "- JWT (JSON Web Tokens)" >> "$OUTPUT_FILE"
  fi

  if grep -q "passport" package.json 2>/dev/null; then
    echo "- Passport.js" >> "$OUTPUT_FILE"
  fi

  if grep -q "auth0" package.json 2>/dev/null; then
    echo "- Auth0" >> "$OUTPUT_FILE"
  fi

  echo "" >> "$OUTPUT_FILE"
fi

# Recommendations
if [ "$SECURITY_FOUND" = false ]; then
  echo "" >> "$OUTPUT_FILE"
  echo "## Recommendations" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "No security documentation found. Consider adding:" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "1. **SECURITY.md** - Security policy and vulnerability reporting" >> "$OUTPUT_FILE"
  echo "2. **Dependency scanning** - npm audit, cargo audit, etc." >> "$OUTPUT_FILE"
  echo "3. **GitHub Actions** - Automated security scans (CodeQL, Dependabot)" >> "$OUTPUT_FILE"
  echo "4. **Environment variables** - Use .env for secrets, never commit them" >> "$OUTPUT_FILE"
  echo "5. **Input validation** - Validate at all boundaries" >> "$OUTPUT_FILE"
  echo "6. **HTTPS** - Enforce TLS for all production traffic" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# Add footer
echo "" >> "$OUTPUT_FILE"
echo "---" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "*To update: Run \`./skills/project-context/generators/extract-security.sh\`*" >> "$OUTPUT_FILE"

if [ "$SECURITY_FOUND" = true ]; then
  echo "✅ Security standards context written to $OUTPUT_FILE"
else
  echo "⚠️  Limited security info found. Created guidance in $OUTPUT_FILE"
fi
