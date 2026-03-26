# Adversarial Review Extraction Design

**Date:** 2026-03-24
**Status:** Draft
**Author:** Ugo Giordano

## Summary

Extract the `adversarial-review` skill from the superpowers plugin into a standalone repository (`ugiordan/adversarial-review`) that supports three installation paths:

1. **Claude Code plugin** — global install via marketplace, works in every project (full feature set)
2. **Cursor plugin** — `.cursor/rules/` integration (degraded single-agent mode)
3. **AGENTS.md** — universal AI tool support (feature set depends on tool capabilities)

## Motivation

The adversarial-review skill is self-contained — it has its own scripts, agents, protocols, phases, templates, and tests. It has no dependencies on other superpowers skills. Extracting it enables:

- Broader adoption across AI coding tools (not just Claude Code)
- Independent versioning and release cycle
- Easier contribution and onboarding
- Installation as a global Claude Code plugin (no per-project setup)

## Repository Structure

```
adversarial-review/                              # Git repo = marketplace
├── .claude-plugin/
│   └── marketplace.json                         # Marketplace metadata
├── adversarial-review/                          # Plugin directory
│   ├── .claude-plugin/
│   │   └── plugin.json                          # Plugin metadata
│   ├── skills/
│   │   └── adversarial-review/                  # Skill directory (matches superpowers convention)
│   │       ├── SKILL.md                         # Skill definition (frontmatter + body)
│   │       ├── agents/
│   │       │   ├── devils-advocate.md
│   │       │   ├── performance-analyst.md
│   │       │   ├── architecture-reviewer.md
│   │       │   ├── correctness-verifier.md
│   │       │   ├── security-auditor.md
│   │       │   └── code-quality-reviewer.md
│   │       ├── scripts/
│   │       │   ├── track-budget.sh
│   │       │   ├── generate-delimiters.sh
│   │       │   ├── detect-convergence.sh
│   │       │   ├── validate-output.sh
│   │       │   └── deduplicate.sh
│   │       ├── phases/
│   │       │   ├── self-refinement.md
│   │       │   ├── challenge-round.md
│   │       │   ├── resolution.md
│   │       │   ├── report.md
│   │       │   └── remediation.md
│   │       ├── protocols/
│   │       │   ├── convergence-detection.md
│   │       │   ├── delta-mode.md
│   │       │   ├── mediated-communication.md
│   │       │   ├── input-isolation.md
│   │       │   ├── token-budget.md
│   │       │   └── injection-resistance.md
│   │       ├── templates/
│   │       │   ├── finding-template.md
│   │       │   ├── report-template.md
│   │       │   ├── delta-report-template.md
│   │       │   ├── challenge-response-template.md
│   │       │   ├── sanitized-document-template.md
│   │       │   └── jira-template.md
│   │       ├── tests/
│   │       │   ├── run-all-tests.sh
│   │       │   ├── test-validation-script.sh
│   │       │   ├── test-coverage-gaps.sh
│   │       │   ├── test-injection-resistance.sh
│   │       │   ├── test-single-agent.sh
│   │       │   └── fixtures/              # 14 test fixture files (see source)
│   │       └── config/
│   │           └── model-config.yml.example
│   └── commands/
│       └── adversarial-review.md                # Slash command
├── AGENTS.md                                    # Universal AI tool entry point
├── .cursor/
│   └── rules/
│       └── adversarial-review.mdc               # Cursor rules (degraded mode)
├── .gitignore
├── .github/
│   └── workflows/
│       └── test.yml                             # CI: runs tests, asserts 0 failures
├── README.md                                    # Documentation + install instructions
└── LICENSE                                      # Apache-2.0
```

The skill directory structure (`skills/adversarial-review/SKILL.md` with companions nested inside) matches the superpowers convention exactly. The Skill tool discovers skills by scanning `skills/*/SKILL.md`. All companion files (agents, scripts, phases, protocols, templates) live inside the skill directory so relative path references work unchanged.

## Installation Paths

### 1. Claude Code Plugin (Global) — Full Feature Set

**One-time marketplace registration (from inside a Claude Code session):**

```
/plugin marketplace add ugiordan/adversarial-review
```

**Install (global, works in every project):**

```
/plugin install adversarial-review@ugiordan-adversarial-review
```

This installs to `$HOME/.claude/plugins/cache/<marketplace>/adversarial-review/<version>/` and registers in `$HOME/.claude/plugins/installed_plugins.json` with `"scope": "user"`.

After installation:
- The `Skill` tool can invoke `adversarial-review:adversarial-review`
- The slash command `/adversarial-review` is available
- Works in every Claude Code session without per-project configuration

**Marketplace metadata** (`.claude-plugin/marketplace.json`). Marketplace name is prefixed with the GitHub handle (`ugiordan-`) to avoid collisions with other marketplaces:

```json
{
  "name": "ugiordan-adversarial-review",
  "owner": {
    "name": "Ugo Giordano",
    "email": "ugiordan@redhat.com"
  },
  "plugins": [
    {
      "name": "adversarial-review",
      "source": "./adversarial-review",
      "description": "Multi-agent adversarial code review with debate protocol",
      "version": "1.0.0",
      "author": { "name": "Ugo Giordano" }
    }
  ]
}
```

**Plugin metadata** (`adversarial-review/.claude-plugin/plugin.json`):

```json
{
  "name": "adversarial-review",
  "description": "Multi-agent adversarial code review with isolated specialists, programmatic validation, and consensus-based findings.",
  "version": "1.0.0",
  "author": {
    "name": "Ugo Giordano",
    "email": "ugiordan@redhat.com"
  }
}
```

### 2. Cursor Plugin — Degraded Single-Agent Mode

Cursor uses `.cursor/rules/*.mdc` files for custom rules. The repo includes a pre-built rule file at `.cursor/rules/adversarial-review.mdc`.

**Limitation:** Cursor does not support spawning isolated sub-agents. The `.mdc` file adapts the workflow to a **single-agent sequential mode** where Cursor's agent role-plays each specialist persona in sequence. This provides the structured review process and finding format but without true agent isolation or mediated communication. See "Security Properties by Install Path" below.

**Installation:**

```bash
# Clone repo
git clone https://github.com/ugiordan/adversarial-review.git $HOME/.adversarial-review

# Copy into project (preferred over symlink for portability)
mkdir -p .cursor/rules
cp $HOME/.adversarial-review/.cursor/rules/adversarial-review.mdc .cursor/rules/

# Add to .gitignore to avoid committing
echo '.cursor/rules/adversarial-review.mdc' >> .gitignore
```

The `.mdc` file uses the literal default path `$HOME/.adversarial-review/adversarial-review` for script references. Users who clone to a different location edit the path in the `.mdc` file.

### 3. AGENTS.md (Universal) — Feature Set Depends on Tool

For any AI tool that supports `AGENTS.md` (Windsurf, Cline, generic Claude Code without plugin support, etc.):

**Limitation:** Like Cursor, most AI tools lack sub-agent spawning. The AGENTS.md includes a degraded single-agent mode section. Tools that support the Claude Code Agent tool (or equivalent) can use the full multi-agent workflow.

**Option A — Clone and reference (if tool follows file references):**

```bash
git clone https://github.com/ugiordan/adversarial-review.git $HOME/.adversarial-review
```

Add to project `AGENTS.md`:

```markdown
## Adversarial Review

For multi-agent adversarial code review, follow the instructions in:
$HOME/.adversarial-review/AGENTS.md
```

**Option B — Inline (most reliable):** Copy the root `AGENTS.md` content directly into the project's `AGENTS.md`. This is the recommended approach since not all tools follow file references from AGENTS.md.

The root `AGENTS.md` is a self-contained version of the skill with all instructions inlined. Script paths use `$HOME/.adversarial-review/adversarial-review` as the default location. A preamble check verifies the installation exists before proceeding:

```bash
AR_HOME="${ADVERSARIAL_REVIEW_HOME:-$HOME/.adversarial-review/adversarial-review}"
[ -d "$AR_HOME/scripts" ] || echo "ERROR: adversarial-review not found at $AR_HOME. Clone it or set ADVERSARIAL_REVIEW_HOME."
```

## Skill Definition

The skill file (`skills/adversarial-review/SKILL.md`) has YAML frontmatter for Claude Code registration:

```yaml
---
name: adversarial-review
description: >
  Multi-agent adversarial review with isolated specialists, programmatic
  validation, and consensus-based findings. Use when: reviewing code from
  multiple perspectives, pre-merge review, security-sensitive changes,
  architecture decisions needing adversarial challenge. Triggers: 'review
  my code', 'adversarial review', 'security audit', 'architecture review',
  'multi-agent review'.
---
```

Only `name` and `description` in frontmatter — consistent with all superpowers skills. Version lives exclusively in `.claude-plugin/plugin.json`.

The body is the current `SKILL.md` content. No content changes needed for Claude Code — relative paths resolve from the skill's install location.

## Content Changes During Extraction

The following content changes are needed in the SKILL.md body before extraction:

1. **Report save path:** Replace `docs/superpowers/reviews/` with `docs/reviews/` in SKILL.md, `protocols/delta-mode.md`, `phases/report.md`, and `templates/report-template.md` (4 files).
2. **Remove superpowers cross-reference:** The "When to Use" section references `reflective-implementation Phase 3`. Remove this superpowers-specific reference.
3. **Update file structure reference:** The SKILL.md body lists 7 of 14 fixtures and omits `injection-resistance.md` from the protocols list. Update to match actual file inventory.
4. **Script invocation:** Ensure all script calls use `bash scripts/validate-output.sh` form (not `./scripts/validate-output.sh`) to avoid chmod +x dependency on fresh clones.

## Slash Command

`commands/adversarial-review.md` provides a `/adversarial-review` entry point:

```markdown
---
description: Run multi-agent adversarial code review
---

Invoke the adversarial-review skill to perform a multi-agent code review.
Pass any arguments from the user as the review target.
```

Command name is derived from the filename (`adversarial-review.md` -> `/adversarial-review`).

## What Changes

| Item | Current (superpowers) | Extracted (standalone) |
|------|----------------------|----------------------|
| Skill location | `superpowers/skills/adversarial-review/SKILL.md` | `adversarial-review/skills/adversarial-review/SKILL.md` |
| Skill format | `SKILL.md` (name + description frontmatter, discovered by superpowers skill loader) | Same frontmatter, same filename, same discovery mechanism |
| Plugin metadata | Part of superpowers `package.json` | Own `.claude-plugin/plugin.json` |
| Marketplace | `claude-plugins-official` (superpowers) | Own marketplace (`ugiordan-adversarial-review`) |
| Slash command | None (invoked via Skill tool) | `/adversarial-review` |
| AGENTS.md | None | Root-level universal entry point |
| Cursor support | None | `.cursor/rules/adversarial-review.mdc` (degraded mode) |
| Report save path | `docs/superpowers/reviews/` | `docs/reviews/` |

## What Stays the Same

Everything else is unchanged:

- All 5 bash scripts (validate-output, deduplicate, detect-convergence, track-budget, generate-delimiters)
- All 6 agent definitions
- All 5 phase documents
- All 6 protocol documents
- All 6 templates
- All test files and fixtures
- The entire review workflow (phases 1-5)
- Two-tier injection detection
- Mediated communication protocol
- Input isolation with delimiter generation
- Token budget tracking
- Convergence detection
- Delta mode support

## Path Resolution

Scripts are referenced in the skill body with relative paths like `scripts/validate-output.sh`, invoked as `bash scripts/validate-output.sh` (avoids chmod +x dependency). Path resolution per install path:

| Install Path | Resolution |
|-------------|------------|
| Claude Code plugin | Relative to skill dir (`$HOME/.claude/plugins/cache/.../skills/adversarial-review/`) — handled automatically |
| Cursor | Literal path in `.mdc` file: `$HOME/.adversarial-review/adversarial-review/scripts/...` |
| AGENTS.md | `$ADVERSARIAL_REVIEW_HOME` env var or `$HOME/.adversarial-review/adversarial-review` default |

## Security Properties by Install Path

The three install paths provide different security guarantees. The full multi-agent architecture is only available in Claude Code:

| Property | Claude Code Plugin | Cursor (.mdc) | AGENTS.md |
|----------|-------------------|----------------|-----------|
| Agent isolation | Enforced (separate Agent contexts) | Not available (single agent) | Depends on tool |
| Mediated communication | Orchestrator-enforced | Advisory only | Advisory only |
| Output validation (scripts) | Runs programmatically | Depends on agent compliance | Depends on agent compliance |
| Input isolation (delimiters) | Orchestrator-managed | Advisory only | Advisory only |
| Provenance markers | Orchestrator adds/verifies | Not enforced | Not enforced |
| Injection detection | `validate-output.sh` enforced | Advisory only | Advisory only |
| Update mechanism | `claude plugin update` | Manual `git pull` | Manual `git pull` |

**Trust model:** AGENTS.md and `.mdc` files are treated as code (like any instruction file). Users should only install from trusted sources — the same trust model as any Claude Code plugin or AGENTS.md configuration.

## Testing

The existing test suite (51 tests, all passing) ships with the plugin and can be run:

```bash
cd <plugin-dir>/skills/adversarial-review
bash tests/run-all-tests.sh
```

The CI workflow (`.github/workflows/test.yml`) runs `tests/run-all-tests.sh` on every push and PR, asserting "0 failed" in the output.

## Future Integration

After extraction, evaluate integration with `ugiordan/ai-code-analyst`:
- Shared agent prompt library
- Adversarial debate protocol for ai-code-analyst's consensus
- ai-code-analyst as optional backend for PR/history analysis modes

## Migration Plan

After extraction:

1. **Remove from superpowers:** Delete `superpowers/skills/adversarial-review/` from the superpowers fork. The skill will live exclusively in the standalone repo.
2. **No stub needed:** The superpowers fork (`origin/custom`) is private. No external users depend on the skill being inside superpowers.
3. **Timeline:** Remove from superpowers immediately after the standalone plugin is verified working (all 51 tests pass, plugin installs and invokes correctly).
4. **Existing users:** Only the current team uses this. Switch by running `claude plugin add adversarial-review --scope user` after the standalone repo is published.
5. **Rollback:** Restore from Git history (`git checkout <commit> -- skills/adversarial-review/`) if the standalone repo has issues within the first week.

## Dependencies

- `bash` (4.0+; scripts use `bash` invocation so macOS stock Bash 3.2 may work but is untested)
- `python3` (for JSON serialization and unicode normalization in scripts)
- Claude Code Agent tool (for spawning specialist sub-agents — full feature set; Cursor/AGENTS.md use degraded single-agent mode)
- No npm/pip packages required
