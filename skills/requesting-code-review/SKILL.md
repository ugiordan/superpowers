---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review

Dispatch superpowers:code-reviewer subagent to catch issues before they cascade.

**Core principle:** Review early, review often.

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## Pre-Review Quality Gates

Before requesting human code review, run automated quality checks to catch issues that tools can find.

**Core principle**: Don't ask humans to review what automated tools can verify.

### Automated Checks (Must Pass)

Run these before requesting review:

```bash
# 1. Linting
npm run lint        # or: flake8 ., cargo clippy, golangci-lint run

# 2. Tests
npm test           # or: pytest, cargo test, go test ./...

# 3. Build
npm run build      # or: cargo build, go build ./...

# 4. Security scan
npm audit --audit-level=high  # or: cargo audit, gosec ./...
```

**Exit codes must be 0** - if any check fails, fix it before requesting review.

### Using Quality Gates Configuration

If `.claude/quality-gates.yml` exists:

```bash
# Run all configured quality gates
./run-quality-gates.sh
```

This runs all project-specific gates automatically. See `automated-quality-gates` skill for setup.

### Verification Checklist

Before requesting review, verify:

- [ ] **Linter passes** with zero errors
  - Run: `npm run lint` (or language equivalent)
  - Exit code: 0
  - No new warnings

- [ ] **All tests pass**
  - Run: `npm test` (or language equivalent)
  - Exit code: 0
  - No skipped tests without justification
  - Coverage meets project threshold

- [ ] **Build succeeds**
  - Run: `npm run build` (or language equivalent)
  - Exit code: 0
  - No build warnings

- [ ] **No new security vulnerabilities**
  - Run: `npm audit --audit-level=high` (or equivalent)
  - Exit code: 0 or only known/acceptable issues
  - Document any exceptions

- [ ] **Code actually works**
  - Manually test one happy path
  - Manually test one error case
  - Behavior matches specification

### Common Issues to Check

**Before requesting review, verify these yourself:**

**Error handling**:
- [ ] External calls have error handling
- [ ] Edge cases are handled
- [ ] Error messages are helpful

**Input validation**:
- [ ] User input is validated at boundaries
- [ ] Type checking is present
- [ ] Range checking where applicable

**Security**:
- [ ] No hardcoded secrets or credentials
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] Input sanitized before use

**Tests**:
- [ ] New code has test coverage
- [ ] Tests actually test the behavior
- [ ] Edge cases are tested

**Code quality**:
- [ ] No commented-out code
- [ ] No debug logging left in
- [ ] No temporary hacks marked TODO

### When Gates Fail

**Fix before requesting review:**

1. Read the actual error output (don't skim)
2. Fix the underlying issue (don't just disable the check)
3. Re-run the gate to verify fix
4. Commit the fix

**Never:**
- Disable linter rules to make it pass
- Skip tests with `.skip()` or `@skip`
- Ignore security warnings without understanding them
- Request review with failing gates

### Rationale

**Why automated checks first?**

- Faster feedback than waiting for human reviewer
- Catches obvious issues immediately
- Reduces review cycle time
- Lets human reviewer focus on architecture, logic, design
- Shows respect for reviewer's time

**What humans review:**
- Architecture and design decisions
- Business logic correctness
- Code organization and clarity
- Security implications beyond automated tools
- Performance considerations
- Edge cases that tools can't detect

**What tools review:**
- Syntax and style
- Common bug patterns
- Known security vulnerabilities
- Test coverage
- Build configuration

## How to Request

**1. Get git SHAs:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch code-reviewer subagent:**

Use Task tool with superpowers:code-reviewer type, fill template at `code-reviewer.md`

**Placeholders:**
- `{WHAT_WAS_IMPLEMENTED}` - What you just built
- `{PLAN_OR_REQUIREMENTS}` - What it should do
- `{BASE_SHA}` - Starting commit
- `{HEAD_SHA}` - Ending commit
- `{DESCRIPTION}` - Brief summary

**3. Act on feedback:**
- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)

## Example

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch superpowers:code-reviewer subagent]
  WHAT_WAS_IMPLEMENTED: Verification and repair functions for conversation index
  PLAN_OR_REQUIREMENTS: Task 2 from docs/superpowers/plans/deployment-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [Fix progress indicators]
[Continue to Task 3]
```

## Integration with Workflows

**Subagent-Driven Development:**
- Review after EACH task
- Catch issues before they compound
- Fix before moving to next task

**Executing Plans:**
- Review after each batch (3 tasks)
- Get feedback, apply, continue

**Ad-Hoc Development:**
- Review before merge
- Review when stuck

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback

**If reviewer wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

See template at: requesting-code-review/code-reviewer.md
