# Verification Phase

## Purpose
Ensure implementation quality through multi-agent verification and iterative fixing.

## Inputs
- Implemented code
- Change context (see "Deriving Change Context" below)
- Loaded project context
- Decision log from implementation

## Deriving Change Context

Before spawning reviewers, analyze what changed by running `git diff` to build a change profile:

- **files_modified**: List of all created/modified files
- **lines_changed**: Total lines added/removed (from git diff stat)
- **touches_database**: True if changes include model files, migrations, schema files, or SQL
- **touches_auth**: True if changes include auth, JWT, session, or permission files
- **touches_api**: True if changes include API routes, handlers, or endpoint definitions
- **modifies_core_logic**: True if changes include core business logic or service files
- **adds_complex_algorithm**: True if new algorithmic logic was added (loops, recursion, state machines)

## Process

### Step 1: Run Quality Gates (If Configured)

If the project has the `automated-quality-gates` skill configured (check for `.claude/quality-gates.yml`), run quality gates first. Fix any failures before proceeding to adversarial review.

If quality gates are not configured, skip this step.

### Step 2: Spawn Adversarial Reviewer

Use the Agent tool to spawn a subagent with the adversarial reviewer role defined in `agents/adversarial-reviewer.md`.

Provide the subagent with:
- The implemented code (changed files)
- The planning decisions and approved approach
- The change context profile

The adversarial reviewer will challenge the implementation and return a report with structured concern flags (performance, security, correctness, code quality) that determine which specialists to spawn.

### Step 3: Spawn Specialist Agents

Based on the adversarial reviewer's concern flags AND the change context, determine which specialists to spawn. See `utils/specialist-spawner.md` for the full decision logic.

**Spawning rules:**
- **Performance analyst**: Spawn if the adversarial reviewer flagged a performance concern, OR the change touches database/query code, OR lines changed > 100
- **Security auditor**: Spawn if the adversarial reviewer flagged a security concern, OR the change touches auth/API code, OR the project has security-standards.md
- **Correctness verifier**: Spawn if the adversarial reviewer flagged a correctness concern, OR the change adds complex algorithms or modifies core logic
- **Code quality reviewer**: Spawn if the adversarial reviewer flagged a quality concern, OR lines changed > 200, OR the project has conventions.md

**Fallback**: If no specialists are triggered by the rules above, spawn the code quality reviewer as a minimum sanity check. Every implementation deserves at least one specialist review.

Spawn all selected specialists in parallel using the Agent tool. Each specialist follows its definition in `agents/specialists/`.

### Step 4: Iterative Fixing

Collect all findings from the adversarial reviewer and specialists. If there are issues:

1. Fix all reported issues (Critical and High severity first)
2. Document each fix: what was changed, why, and what alternative was considered
3. Re-run only the specialists that found issues (not all of them) to verify fixes
4. Repeat up to 3 iterations total

If issues remain after 3 iterations, stop and present the remaining issues to the human with a clear message: "These issues could not be resolved automatically. Human guidance needed." Include the issue details, what was attempted, and why it didn't resolve.

In interactive mode, escalate after 2 iterations instead of 3 to get human input earlier.

### Step 5: Generate Verification Report

Generate the final verification report using the template in `templates/layer5-verification.md`. This becomes Layer 5 of the final explanation.

## Outputs
- Adversarial review report with concern flags
- Specialist reports (from whichever specialists were spawned)
- Iteration log (issues found, fixes applied, re-verification results)
- Final verification report (Layer 5)
