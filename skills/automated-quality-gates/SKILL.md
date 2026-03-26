---
name: automated-quality-gates
description: Configure and run automated quality checks before claiming completion
---

# Automated Quality Gates

## Overview

Quality gates are automated checks that must pass before work is considered complete. They catch issues tools can catch—so humans don't have to.

**Key principle**: Don't ask humans to review what automated tools can verify.

## When to Use

Use quality gates:
- Before claiming work is complete
- Before requesting code review
- Before merging to main
- In CI/CD pipelines
- After making changes

## Setup

### 1. Create Configuration

Create `.claude/quality-gates.yml` in your project root:

```yaml
# Project-specific quality gates configuration

# Language/framework detection (optional - helps auto-detect commands)
language: javascript  # javascript, python, rust, go, java, etc.

# Quality gates to run
gates:
  # Linting
  lint:
    command: npm run lint
    required: true
    timeout: 60  # seconds

  # Unit tests
  test:
    command: npm test
    required: true
    timeout: 300
    coverage_threshold: 80  # fail if coverage below 80%

  # Build
  build:
    command: npm run build
    required: true
    timeout: 180

  # Security scanning
  security:
    command: npm audit --audit-level=high
    required: true
    timeout: 120

  # Type checking (if applicable)
  typecheck:
    command: npm run typecheck
    required: false  # warning only
    timeout: 60

# Custom checks
custom_checks:
  - name: "API integration tests"
    command: npm run test:api
    required: true
    timeout: 300

  - name: "E2E smoke tests"
    command: npm run test:e2e:smoke
    required: false
    timeout: 600

# Skip gates in certain contexts (optional)
skip_on:
  - branch: "experimental/*"
    gates: ["security", "test"]
  - path: "docs/**"
    gates: ["lint", "test", "build"]
```

### 2. Language-Specific Examples

**JavaScript/TypeScript:**
```yaml
language: javascript
gates:
  lint:
    command: npm run lint
  test:
    command: npm test
  build:
    command: npm run build
  typecheck:
    command: npm run typecheck
  security:
    command: npm audit --audit-level=high
```

**Python:**
```yaml
language: python
gates:
  lint:
    command: flake8 .
  format_check:
    command: black --check .
  type_check:
    command: mypy .
  test:
    command: pytest
    coverage_threshold: 80
  security:
    command: safety check
```

**Rust:**
```yaml
language: rust
gates:
  lint:
    command: cargo clippy -- -D warnings
  format_check:
    command: cargo fmt --check
  test:
    command: cargo test
  build:
    command: cargo build
  security:
    command: cargo audit
```

**Go:**
```yaml
language: go
gates:
  lint:
    command: golangci-lint run
  format_check:
    command: gofmt -l .
  test:
    command: go test ./...
  build:
    command: go build ./...
  security:
    command: gosec ./...
```

**Java:**
```yaml
language: java
gates:
  lint:
    command: mvn checkstyle:check
  test:
    command: mvn test
  build:
    command: mvn package
  security:
    command: mvn dependency-check:check
```

### 3. Generate Runner Script

Use the configuration to generate a runner script:

```bash
# Auto-generate from quality-gates.yml
./skills/automated-quality-gates/generate-runner.sh

# This creates: ./run-quality-gates.sh
```

Or create manually:

```bash
#!/bin/bash
# run-quality-gates.sh - Generated from .claude/quality-gates.yml

set -e

FAILED_GATES=()
PASSED_GATES=()
SKIPPED_GATES=()

run_gate() {
  local name=$1
  local command=$2
  local required=$3
  local timeout=$4

  echo "▶ Running: $name"

  if timeout "$timeout" bash -c "$command"; then
    echo "✅ PASSED: $name"
    PASSED_GATES+=("$name")
  else
    echo "❌ FAILED: $name"
    if [ "$required" = "true" ]; then
      FAILED_GATES+=("$name")
    else
      echo "   (Warning only - not required)"
      SKIPPED_GATES+=("$name")
    fi
  fi
  echo
}

# Run gates
run_gate "Lint" "npm run lint" "true" "60"
run_gate "Tests" "npm test" "true" "300"
run_gate "Build" "npm run build" "true" "180"
run_gate "Security" "npm audit --audit-level=high" "true" "120"

# Report results
echo "============================================"
echo "Quality Gates Summary"
echo "============================================"
echo "Passed: ${#PASSED_GATES[@]}"
echo "Failed: ${#FAILED_GATES[@]}"
echo "Warnings: ${#SKIPPED_GATES[@]}"
echo

if [ ${#FAILED_GATES[@]} -gt 0 ]; then
  echo "❌ FAILED GATES:"
  for gate in "${FAILED_GATES[@]}"; do
    echo "  - $gate"
  done
  exit 1
fi

echo "✅ All required quality gates passed!"
exit 0
```

Make it executable:
```bash
chmod +x run-quality-gates.sh
```

## Usage

### Manual Execution

```bash
# Run all quality gates
./run-quality-gates.sh

# Run specific gate
npm run lint        # just linting
npm test           # just tests
npm run build      # just build
```

### In Workflows

**Before claiming completion:**
```bash
# After making changes
git add .
./run-quality-gates.sh

# If passes
git commit -m "Add feature X"
```

**Before requesting review:**
```bash
# Ensure quality baseline
./run-quality-gates.sh

# Then request review
git push
gh pr create
```

### CI/CD Integration

**GitHub Actions:**
```yaml
name: Quality Gates
on: [push, pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Setup
        run: npm install

      - name: Run Quality Gates
        run: ./run-quality-gates.sh
```

**GitLab CI:**
```yaml
quality_gates:
  stage: test
  script:
    - npm install
    - ./run-quality-gates.sh
```

## Integration with Skills

### verification-before-completion

The verification skill automatically detects and runs quality gates:

```markdown
## Verification Protocol

1. Check for quality gates configuration
   - If `.claude/quality-gates.yml` exists
   - Run: `./run-quality-gates.sh`
   - All required gates must pass

2. Manual verification (if no gates configured)
   - [Manual checks...]
```

### requesting-code-review

Before requesting review, run quality gates:

```markdown
## Pre-Review Quality Gates

If `.claude/quality-gates.yml` exists:
  ./run-quality-gates.sh

All gates must pass before requesting human review.
```

## Auto-Detection

If no configuration exists, auto-detect from project:

```bash
# Detect language and common tools
detect_quality_gates() {
  if [ -f "package.json" ]; then
    # Check for common scripts
    if grep -q '"lint"' package.json; then
      echo "npm run lint"
    fi
    if grep -q '"test"' package.json; then
      echo "npm test"
    fi
    if grep -q '"build"' package.json; then
      echo "npm run build"
    fi
  elif [ -f "Cargo.toml" ]; then
    echo "cargo clippy -- -D warnings"
    echo "cargo test"
    echo "cargo build"
  elif [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
    echo "pytest"
    if command -v flake8 &> /dev/null; then
      echo "flake8 ."
    fi
  fi
}
```

## Common Gates

### Linting

**Purpose**: Catch style issues, potential bugs

**JavaScript/TypeScript:**
```bash
npm run lint          # ESLint
npm run lint:fix      # Auto-fix
```

**Python:**
```bash
flake8 .              # Linting
black --check .       # Format check
black .               # Auto-format
```

**Rust:**
```bash
cargo clippy -- -D warnings  # Linting
cargo fmt --check            # Format check
cargo fmt                    # Auto-format
```

### Testing

**Purpose**: Ensure functionality works

**With coverage threshold:**
```bash
npm test -- --coverage --coverageThreshold='{"global":{"lines":80}}'
pytest --cov --cov-fail-under=80
cargo tarpaulin --fail-under 80
```

**Fast tests only:**
```bash
npm test -- --testPathIgnorePatterns=e2e
pytest -m "not slow"
```

### Building

**Purpose**: Ensure code compiles/bundles

```bash
npm run build         # JavaScript
cargo build          # Rust
go build ./...       # Go
mvn package          # Java
```

### Security Scanning

**Purpose**: Find known vulnerabilities

**Dependency scanning:**
```bash
npm audit --audit-level=high     # JavaScript
safety check                      # Python
cargo audit                       # Rust
gosec ./...                       # Go
```

**Code scanning:**
```bash
semgrep --config=auto .
bandit -r .                      # Python
```

### Type Checking

**Purpose**: Catch type errors

```bash
npm run typecheck    # TypeScript
mypy .              # Python
```

## Advanced Configuration

### Conditional Gates

```yaml
gates:
  expensive_test:
    command: npm run test:e2e
    required: true
    run_only:
      - on_branch: main
      - on_branch: release/*
      - when_changed: "src/api/**"
```

### Parallel Execution

```yaml
execution:
  parallel: true  # Run gates in parallel
  fail_fast: true # Stop on first failure
```

### Custom Thresholds

```yaml
gates:
  test:
    command: npm test
    coverage_threshold: 80
    performance_threshold:
      max_duration: 300  # seconds
      max_memory: 512    # MB
```

### Gate Dependencies

```yaml
gates:
  lint:
    command: npm run lint

  test:
    command: npm test
    depends_on: [lint]  # Only run if lint passes

  build:
    command: npm run build
    depends_on: [lint, test]
```

## Troubleshooting

**Gates fail but should pass:**
- Check command is correct: `npm run lint` vs `npx eslint .`
- Verify tools are installed: `npm install`
- Check timeout isn't too short
- Run command manually to debug

**Gates pass but shouldn't:**
- Verify `required: true` is set
- Check exit codes: command should return non-zero on failure
- Ensure thresholds are configured

**Too slow:**
- Run gates in parallel
- Use faster test subsets for pre-commit
- Cache dependencies in CI
- Increase timeouts

**Skipping gates inappropriately:**
- Review `skip_on` configuration
- Check branch/path patterns are correct
- Ensure required gates can't be skipped

## Best Practices

**Start minimal:**
```yaml
gates:
  lint:
    command: npm run lint
  test:
    command: npm test
```

**Grow as needed:**
- Add security scanning
- Add coverage thresholds
- Add custom checks

**Keep gates fast:**
- Use fast linters
- Run subset of tests pre-commit
- Full suite in CI only

**Make failures clear:**
- Good error messages
- Point to fix instructions
- Auto-fix when possible

**Don't over-gate:**
- Don't require perfection for WIP
- Use `required: false` for nice-to-haves
- Skip expensive gates on feature branches

## Examples

### Minimal Setup

```yaml
gates:
  test:
    command: npm test
    required: true
```

### Comprehensive Setup

```yaml
language: javascript

gates:
  lint:
    command: npm run lint
    required: true
    timeout: 60

  format_check:
    command: npm run format:check
    required: true
    timeout: 30

  typecheck:
    command: npm run typecheck
    required: true
    timeout: 90

  unit_test:
    command: npm run test:unit
    required: true
    timeout: 300
    coverage_threshold: 80

  integration_test:
    command: npm run test:integration
    required: true
    timeout: 600

  build:
    command: npm run build
    required: true
    timeout: 180

  security_audit:
    command: npm audit --audit-level=high
    required: true
    timeout: 60

  license_check:
    command: npm run license-check
    required: false
    timeout: 30

custom_checks:
  - name: "Bundle size check"
    command: npm run size-limit
    required: true

  - name: "API contract validation"
    command: npm run validate:api
    required: true

execution:
  parallel: true
  fail_fast: false
```

## Migration

### From Manual Checks

**Before:**
```bash
# Remember to run before committing:
npm run lint
npm test
npm run build
```

**After:**
```bash
# One command, configured once
./run-quality-gates.sh
```

### From Pre-Commit Hooks

Quality gates can replace or complement pre-commit hooks:

```bash
# .git/hooks/pre-commit
#!/bin/bash
./run-quality-gates.sh
```

### From CI Only

Start running gates locally before CI:

1. Create `.claude/quality-gates.yml`
2. Generate runner: `./skills/automated-quality-gates/generate-runner.sh`
3. Run before pushing: `./run-quality-gates.sh`
4. CI runs same gates for verification

## Summary

Quality gates ensure baseline quality before human review:

✅ Automated checks catch obvious issues
✅ Consistent across team
✅ Fast feedback loop
✅ Reduces review burden

Configure once, run always.
