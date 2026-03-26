# Context Loader Utility

## Purpose
Load project context files for informed decision-making across all phases.

## Process

Check if the `.claude/context/` directory exists. If it does not, skip context loading — the skill works fully without it using general best practices.

If the directory exists, read each of the following files (skip any that don't exist):

| File | Purpose | Used By |
|------|---------|---------|
| `architecture.md` | Architectural patterns, constraints, system design | Planning (approach alignment), Verification (quality review) |
| `conventions.md` | Coding standards, naming, file structure | Implementation (follow patterns), Verification (consistency check) |
| `security-standards.md` | Security requirements, compliance needs | Planning (constraint), Verification (security audit) |
| `testing-patterns.md` | Test structure, coverage expectations | Implementation (match structure), Verification (test review) |
| `tech-stack.md` | Technologies, frameworks, libraries in use | Planning (approach selection), Implementation (tech choices) |
| `decisions.md` | Past architectural decisions and rationale | Planning (avoid contradicting past decisions) |

Track which files were loaded so phases can check availability (e.g., "if security-standards were loaded, pass them to the security auditor").

## Usage in Phases

**Planning:** Reference architecture.md for constraints, decisions.md for past choices, tech-stack.md for available technologies.

**Implementation:** Follow conventions.md patterns, use tech-stack.md technologies, match testing-patterns.md structure.

**Verification:** Pass security-standards.md to the security auditor. Pass conventions.md to the code quality reviewer for consistency checking.

## Graceful Degradation

If no context directory exists or no files are found:
- Planning: Use general best practices for approach comparison
- Implementation: Follow common patterns for the language/framework
- Verification: Use standard checklists (OWASP, general quality metrics)
- The skill remains fully functional
