# Enhanced Superpowers Design

**Date**: 2026-01-27  
**Status**: Implemented  
**Contributors**: Enhanced based on spec-kit, self-review-reflection, and ambient-code patterns

## Overview

This document describes enhancements to the superpowers framework that add:
1. **Project Context System** - Machine-readable project knowledge for context-aware development
2. **Automated Quality Gates** - Concrete verification checks before claiming completion
3. **Context-Aware Skills** - Existing skills enhanced to use project context
4. **Pre-Review Gates** - Automated checks before requesting human code review

## Motivation

### Problems Addressed

**Problem 1: Re-discovering Project Patterns**  
Skills had to re-learn project architecture, conventions, and patterns in every session, wasting tokens and time.

**Problem 2: Vague "Self-Review"**  
The self-review reflection pattern, while valuable in concept, lacked concrete implementation. Asking AI to "review your work" without specific checks led to rubber-stamping.

**Problem 3: Human Reviewers Catching Tool-Detectable Issues**  
Code reviews caught linter errors, missing tests, and security scan failures that automated tools should have found first.

**Problem 4: Missing Structured Specification**  
Projects lacked a standardized way to document architectural decisions, testing patterns, and security requirements in machine-readable format.

### Solutions

**Solution 1: Project Context System**  
Create `.claude/context/` with programmatically-generated context files:
- `architecture.md` - System design and components  
- `conventions.md` - Coding standards and patterns
- `testing-patterns.md` - Test structure and fixtures
- `security-standards.md` - Validation and security rules
- `tech-stack.md` - Technologies and versions
- `decisions.md` - Architectural Decision Records

**Solution 2: Automated Verification Gates**  
Replace vague "self-review" with concrete checks:
- Run linters (must pass with exit code 0)
- Run tests (must pass, coverage thresholds met)
- Run builds (must succeed)
- Run security scans (no new HIGH/CRITICAL vulnerabilities)
- Manual verification (happy path + error case)

**Solution 3: Context-Aware Skills**  
Enhance skills to load relevant context on-demand:
- `brainstorming` - Load architecture/conventions when designing
- `systematic-debugging` - Load testing-patterns when debugging tests
- `code-reviewer` - Load conventions/security-standards for reviews

**Solution 4: Pre-Review Quality Gates**  
Add automated checks before requesting human code review, ensuring tools catch what tools can catch before humans get involved.

## Design

### New Skills

#### 1. `project-context` Skill

**Purpose**: Initialize and manage project context system

**Structure**:
```
skills/project-context/
├── SKILL.md                    # Main skill documentation
├── templates/                  # Empty templates for manual setup
│   ├── architecture-template.md
│   ├── conventions-template.md
│   ├── testing-patterns-template.md
│   ├── security-standards-template.md
│   ├── tech-stack-template.md
│   └── decisions-template.md
└── generators/                 # Scripts to extract from existing sources
    ├── extract-architecture.sh
    ├── extract-conventions.sh
    ├── extract-from-adrs.sh
    ├── analyze-testing.sh
    ├── extract-security.sh
    └── load-to-mcp.sh
```

**Key Features**:
- Auto-generates context from existing docs (README, CONTRIBUTING, ADRs)
- Analyzes code to discover patterns (test structure, naming conventions)
- Optional MCP server integration for enhanced querying
- Update scripts to keep context synchronized

**Example Usage**:
```bash
# Initialize context system
mkdir -p .claude/context

# Generate from existing sources
./skills/project-context/generators/extract-architecture.sh
./skills/project-context/generators/extract-conventions.sh
./skills/project-context/generators/analyze-testing.sh

# Use in skills
# When brainstorming: "Load architecture and conventions context"
# When debugging: "Load testing-patterns context"
```

#### 2. `automated-quality-gates` Skill

**Purpose**: Configure and run automated quality checks

**Structure**:
```
skills/automated-quality-gates/
├── SKILL.md                    # Main skill documentation  
└── generate-runner.sh          # Generate quality gates runner
```

**Configuration**:
Projects create `.claude/quality-gates.yml`:
```yaml
language: javascript

gates:
  lint:
    command: npm run lint
    required: true
    timeout: 60

  test:
    command: npm test
    required: true
    coverage_threshold: 80

  build:
    command: npm run build
    required: true

  security:
    command: npm audit --audit-level=high
    required: true
```

**Generated Runner**:
Script generates `./run-quality-gates.sh` that:
- Runs each configured gate
- Reports pass/fail for each
- Exits with code 1 if any required gate fails
- Shows summary at end

**Example Usage**:
```bash
# Generate runner from config
./skills/automated-quality-gates/generate-runner.sh

# Run before claiming completion
./run-quality-gates.sh

# Integrate with git hooks or CI/CD
```

### Enhanced Existing Skills

#### 1. Enhanced `requesting-code-review`

**Added Section**: "Pre-Review Quality Gates"

**What Changed**:
Before requesting human code review, now requires:
1. Running automated checks (lint, test, build, security)
2. Verification checklist (linter passes, tests pass, build succeeds, no new vulnerabilities, code actually works)
3. Common issues self-check (error handling, input validation, security, tests, code quality)
4. Fix any failures before requesting review

**Rationale**:
- Faster feedback than waiting for human reviewer
- Reduces review cycle time
- Shows respect for reviewer's time
- Lets humans focus on architecture/design, not linter errors

#### 2. Enhanced `code-reviewer` Agent

**Added Section**: "Self-Review Verification"

**What Changed**:
Before presenting review findings, reviewer must:
1. **Verify suggestions are valid** - Check syntax, ensure imports exist, verify patterns are better
2. **Categorize findings correctly** - Critical vs Important vs Suggestions
3. **Evidence-based review** - Specific file paths, line numbers, explanations
4. **Skip low-value feedback** - Don't nitpick style if linters pass
5. **Validation checklist** - Verify critiques are actually valid

**Rationale**:
- Prevents suggesting broken code
- Ensures reviewer isn't being pedantic
- Focuses on real issues, not hypothetical concerns
- Makes reviews more actionable

#### 3. Enhanced `brainstorming`

**Added**: Context-awareness in "Understanding the idea" and "Exploring approaches"

**What Changed**:
- Check for `.claude/context/` and offer to load relevant files
- Use loaded context when proposing approaches (align with architecture, follow conventions, respect past decisions)
- Explicit, on-demand loading (not automatic)

**Example**:
```
User: "Let's add user authentication"Agent: "I see this project has .claude/context/. Should I load:
  - architecture.md - to understand auth integration points?
  - tech-stack.md - to see if there's an existing auth library?
  - security-standards.md - to follow security requirements?"
```

#### 4. Enhanced `systematic-debugging`

**Added**: Context-awareness in "Pattern Analysis" phase

**What Changed**:
- Load `testing-patterns.md` when debugging tests
- Check `architecture.md` for component boundaries
- Verify against `conventions.md` for project patterns
- Check `tech-stack.md` for dependency versions

**Example**:
```
When debugging test failure:
1. Load .claude/context/testing-patterns.md
2. Understand how tests should be structured
3. Compare broken test against documented pattern
4. Identify deviation from pattern
```

### Implementation Details

#### Context Generation

Context files are **programmatically generated** from existing sources, not manually written:

**From Documentation**:
- `architecture.md` ← README.md, docs/architecture.md
- `conventions.md` ← CONTRIBUTING.md, .eslintrc, .prettierrc
- `decisions.md` ← docs/adr/*.md

**From Code Analysis**:
- `testing-patterns.md` ← Analyze actual test files for structure
- `tech-stack.md` ← package.json, Cargo.toml, go.mod, etc.
- `security-standards.md` ← SECURITY.md, security scan configs

**Update Mechanisms**:
- Manual: Run `./skills/project-context/generators/*.sh` scripts
- Git hooks: Regenerate on commit if docs changed
- CI/CD: Auto-update and commit on doc changes

#### Quality Gates Configuration

**Auto-Detection**:
If no `.claude/quality-gates.yml` exists, runner auto-detects:
- JavaScript: npm run lint, npm test, npm run build, npm audit
- Python: flake8, pytest, safety check
- Rust: cargo clippy, cargo test, cargo build, cargo audit
- Go: golangci-lint, go test, go build

**Custom Configuration**:
Projects can customize via YAML config with timeouts, thresholds, and skip conditions.

## Benefits

### 1. Token Efficiency

**Before**: Every session spent tokens re-discovering:
- How tests are structured
- What the architecture looks like
- Coding conventions
- Past architectural decisions

**After**: Load relevant context once per session, on-demand.

### 2. Faster Feedback

**Before**: 
- Commit → push → CI → wait → linter error → fix → repeat
- Or: Request human review → wait → "please run linter" → fix → repeat

**After**:
- Run quality gates locally → immediate feedback → fix → done

### 3. Higher Quality Reviews

**Before**: 
- Human reviewers spent time on linter errors, style issues
- Architectural feedback buried under nitpicks

**After**:
- Automated gates catch tool-detectable issues
- Human reviewers focus on architecture, design, logic

### 4. Consistent Standards

**Before**:
- Each skill might discover different patterns
- Inconsistent understanding of project conventions

**After**:
- Single source of truth in `.claude/context/`
- All skills use same understanding

## Trade-offs

### Maintenance Burden

**Challenge**: Context files can go stale if not updated

**Mitigation**:
- Auto-generation from source docs reduces staleness
- Git hooks / CI can auto-update
- Quarterly review recommended

### Initial Setup Cost

**Challenge**: Setting up context system takes time

**Mitigation**:
- Generators extract from existing sources (low effort)
- Can start with minimal context (just architecture.md)
- Templates provided for manual creation

### Not All Projects Need This

**When to use**:
- Medium to large codebases
- Projects with established patterns
- Teams wanting consistent AI behavior

**When to skip**:
- Small, simple projects
- Experimental/prototype work
- Solo projects with no conventions

## Migration Path

### For Existing Projects

**Phase 1: Minimal Context** (5 minutes)
```bash
mkdir -p .claude/context
./skills/project-context/generators/extract-architecture.sh
```

**Phase 2: Full Context** (30 minutes)
```bash
# Generate all context
for script in ./skills/project-context/generators/*.sh; do
  bash "$script"
done

# Review and enhance with tribal knowledge
vim .claude/context/*.md
```

**Phase 3: Quality Gates** (15 minutes)
```bash
# Create config
cat > .claude/quality-gates.yml << EOF
gates:
  lint: { command: "npm run lint", required: true }
  test: { command: "npm test", required: true }
  build: { command: "npm run build", required: true }
EOF

# Generate runner
./skills/automated-quality-gates/generate-runner.sh

# Test it
./run-quality-gates.sh
```

**Phase 4: Update Workflows** (ongoing)
- Add quality gates to pre-commit hooks
- Update CI/CD to use same gates
- Document in team onboarding

### For New Projects

Start with context from day one:
1. Create `.claude/context/` during project init
2. Fill in architecture.md during design phase
3. Generate conventions.md from first code
4. Configure quality gates in first sprint

## Future Enhancements

### Possible Extensions

1. **Context versioning**: Track context changes over time
2. **Multi-project context**: Share context across related projects
3. **Context validation**: Detect drift between context and code
4. **Enhanced MCP integration**: Better querying and relationship tracking
5. **Context diff**: Show what changed in context files
6. **Team context**: Shared vs. personal context files

### Not Included (Intentionally)

**Why not include spec-kit's "constitution" skill?**
- Redundant with brainstorming skill
- Brainstorming already explores constraints and requirements
- Would add friction without clear value

**Why concrete verification instead of vague self-review?**
- AI can't truly "review itself" without external validation
- Concrete checks (linter, tests) provide real value
- Prevents rubber-stamp "looks good to me" responses

## References

- [spec-kit](https://github.com/ambient-code/spec-kit) - Constitution and specification patterns
- [self-review-reflection pattern](https://github.com/ambient-code/reference/blob/main/docs/patterns/self-review-reflection.md) - Quality gate concept
- [ambient-code reference](https://github.com/ambient-code/reference/blob/main/PRESENTATION-ambient-code-reference.md) - Codebase agent and memory system

## Summary

These enhancements add:
- ✅ Project context system for token-efficient, consistent AI behavior
- ✅ Automated quality gates replacing vague "self-review"
- ✅ Context-aware skills (brainstorming, systematic-debugging)
- ✅ Pre-review gates reducing human reviewer burden

**Key insight**: Good AI collaboration requires clear conventions, concrete verification, and project-specific knowledge. This design provides all three while keeping superpowers flexible and composable.
