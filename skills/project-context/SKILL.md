---
name: project-context
description: Initialize or update project context system for smarter, context-aware development
---

# Project Context

## Overview

The Project Context system provides machine-readable project knowledge that can be loaded on-demand into AI assistants. Instead of re-discovering patterns every session, context is extracted once from your existing documentation and code, then loaded only when relevant.

**Key benefits:**
- Token efficiency: Only load relevant context when needed
- Knowledge capture: Document tribal knowledge in machine-readable format
- Maintainability: Update one context file, all sessions benefit
- Onboarding: New engineers (and AI) get up to speed faster

## When to Use

Use this skill to:
- **Initialize**: Set up context system for new or existing projects
- **Update**: Regenerate context when source docs change
- **Integrate**: Load context into MCP memory server
- **Maintain**: Keep context synchronized with project evolution

## The Context System

### Directory Structure

Context lives in `.claude/context/` with focused modules:

```
.claude/context/
├── architecture.md        # System design, components, data flow
├── conventions.md         # Coding standards, patterns, style
├── testing-patterns.md    # Test structure, fixtures, best practices
├── security-standards.md  # Validation, sanitization, secrets
├── tech-stack.md         # Technologies, versions, dependencies
└── decisions.md          # ADRs and architectural decisions
```

### What Goes in Each File

**architecture.md** - How the system is organized
- Layered architecture patterns
- Component responsibilities
- Data flow between components
- Key abstractions and interfaces

**conventions.md** - How code should be written
- Naming conventions
- File organization
- Code style preferences
- Common patterns to follow

**testing-patterns.md** - How tests are structured
- Unit, integration, E2E patterns
- Test fixtures and helpers
- Mocking strategies
- Coverage expectations

**security-standards.md** - How to handle security
- Input validation rules
- Sanitization requirements
- Secret management
- Security boundaries

**tech-stack.md** - What technologies are used
- Languages and versions
- Frameworks and libraries
- Build tools and infrastructure
- Development tools

**decisions.md** - Why things are the way they are
- Architectural Decision Records (ADRs)
- Key design choices
- Trade-offs made
- Rejected alternatives

## Getting Started

### Initialize Context System

**1. Create directory structure:**

```bash
mkdir -p .claude/context
```

**2. Generate context from existing sources:**

Use the generation utilities in this skill's `generators/` directory:

```bash
# Extract from Architecture Decision Records
./skills/project-context/generators/extract-from-adrs.sh

# Extract from README and docs
./skills/project-context/generators/extract-architecture.sh

# Extract from CONTRIBUTING.md
./skills/project-context/generators/extract-conventions.sh

# Analyze test files to extract patterns
./skills/project-context/generators/analyze-testing.sh

# Extract from security documentation
./skills/project-context/generators/extract-security.sh
```

**3. Review and refine:**

The generators create initial content. Review and enhance with:
- Tribal knowledge not in docs
- Unwritten conventions
- Common gotchas
- Team preferences

### Update Context

When source documentation changes:

```bash
# Regenerate specific context
./skills/project-context/generators/extract-architecture.sh

# Or regenerate all
for script in ./skills/project-context/generators/*.sh; do
    bash "$script"
done
```

### Load into MCP Memory Server

For relationship tracking and enhanced context:

```bash
# Load all context files into local MCP server
./skills/project-context/generators/load-to-mcp.sh
```

Then add to your `.claude/claude.md`:
```markdown
Context is available in the local MCP memory server.
Query with: "load architecture context" or "load security standards"
```

## Using Context in Skills

Other superpowers skills can load context on-demand:

### In Brainstorming

```markdown
Should I load project context before designing?
- architecture.md - Understand existing system structure
- conventions.md - Follow established patterns
- tech-stack.md - Use approved technologies
```

### In Systematic Debugging

```markdown
When debugging test failures, load:
- testing-patterns.md - Understand how tests should work
```

### In Code Review

```markdown
For better reviews, load:
- conventions.md - Check against coding standards
- security-standards.md - Verify security requirements
```

**Loading is explicit and on-demand** - not automatic. This keeps token usage efficient.

## Maintenance

### When to Update

Update context when:
- New ADR is created → regenerate decisions.md
- Architecture changes → regenerate architecture.md
- New coding patterns adopted → update conventions.md
- Tech stack changes → update tech-stack.md
- Security policies change → regenerate security-standards.md

### Keeping Context Fresh

**Option 1: Manual trigger**
```bash
# After making significant doc changes
./regenerate-context.sh
```

**Option 2: Git hooks**
```bash
# .git/hooks/post-commit
# Regenerate if docs changed
if git diff HEAD~1 --name-only | grep -q 'docs/'; then
    ./regenerate-context.sh
fi
```

**Option 3: CI/CD**
```yaml
# .github/workflows/update-context.yml
name: Update Context
on:
  push:
    paths:
      - 'docs/**'
      - 'README.md'
      - 'CONTRIBUTING.md'
jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Regenerate context
        run: ./regenerate-context.sh
      - name: Commit if changed
        run: |
          git config user.name "Context Bot"
          git add .claude/context/
          git commit -m "Update context from docs" || true
```

## Templates

If you prefer manual creation, templates are available in `skills/project-context/templates/`:

- `architecture-template.md`
- `conventions-template.md`
- `testing-patterns-template.md`
- `security-standards-template.md`
- `tech-stack-template.md`
- `decisions-template.md`

Copy templates to `.claude/context/` and fill in project-specific information.

## Best Practices

**Keep it focused:**
- Each file addresses one concern
- Avoid duplication across files
- Link to detailed docs for deep dives

**Keep it current:**
- Automate regeneration when possible
- Review quarterly for drift
- Remove outdated information

**Keep it actionable:**
- Provide examples, not just principles
- Show code snippets demonstrating patterns
- Include anti-patterns to avoid

**Keep it accessible:**
- Use simple markdown
- No tool-specific formats
- Human-readable, machine-parseable

## Integration with Other Systems

### MCP Memory Server

Load context into Anthropic's Memory MCP server for enhanced querying:

```bash
# Load all context
mcp-memory load .claude/context/*.md

# Query in conversation
"Based on our architecture context, where should this feature go?"
```

### CI/CD Pipelines

Use context in automated workflows:

```yaml
- name: Review with context
  run: |
    # Load context before AI review
    export CONTEXT=$(cat .claude/context/conventions.md)
    # Pass to AI reviewer
    ai-reviewer --context "$CONTEXT" review.diff
```

### Onboarding

New team members can:
1. Read `.claude/context/` files to understand project
2. Use context with AI pair programming
3. Reference during code review

## Troubleshooting

**Context files empty after generation:**
- Check if source docs exist (README.md, docs/adr/, etc.)
- Run generators with verbose flag for debugging
- Fall back to templates and fill manually

**Context seems stale:**
- Check last update date in files
- Regenerate from current docs
- Set up automatic updates (git hooks or CI)

**Skills not finding context:**
- Verify `.claude/context/` exists in project root
- Check file names match exactly
- Ensure markdown files are valid

**Token usage too high:**
- Only load relevant context, not all files
- Keep individual files focused and small (<2000 words each)
- Use MCP memory server for relationship queries instead of loading full text

## Example: Complete Setup

```bash
# 1. Initialize structure
mkdir -p .claude/context

# 2. Generate from existing docs
cd skills/project-context/generators
./extract-from-adrs.sh
./extract-architecture.sh
./extract-conventions.sh
./analyze-testing.sh
./extract-security.sh

# 3. Review generated content
ls -lh .claude/context/
cat .claude/context/architecture.md

# 4. Enhance with tribal knowledge
vim .claude/context/conventions.md
# Add team-specific patterns

# 5. Optional: Load into MCP
./load-to-mcp.sh

# 6. Use in development
# When brainstorming new feature:
# "Load architecture and conventions context before we design"
```

Done! Context system is ready to make all skills smarter and more project-aware.
