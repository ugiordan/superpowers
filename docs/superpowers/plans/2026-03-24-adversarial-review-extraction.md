# Adversarial Review Extraction Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract the adversarial-review skill from the superpowers plugin into a standalone GitHub repo that works as a Claude Code plugin (global install), Cursor plugin (degraded mode), and AGENTS.md universal integration.

**Architecture:** The repo is both a marketplace and a plugin. The skill directory structure (`skills/adversarial-review/SKILL.md` with companions nested inside) matches the superpowers convention exactly, so extraction is a copy + targeted content edits. Three new files are created: marketplace.json, AGENTS.md, and .cursor/rules/adversarial-review.mdc.

**Tech Stack:** Bash, Python3 (in scripts only), Claude Code plugin system, Git

**Spec:** `docs/superpowers/specs/2026-03-24-adversarial-review-extraction-design.md`

---

### Task 1: Create standalone repo and marketplace scaffolding

**Files:**
- Create: `adversarial-review/.claude-plugin/marketplace.json`
- Create: `adversarial-review/adversarial-review/.claude-plugin/plugin.json`
- Create: `adversarial-review/README.md`
- Create: `adversarial-review/LICENSE`
- Create: `adversarial-review/.gitignore`

**Context:** The repo root is the marketplace. The `adversarial-review/` subdirectory is the plugin. This matches the `security-plugin-system` pattern where `"source": "./adversarial-review"` in marketplace.json points to the plugin subdirectory.

- [ ] **Step 1: Create the repo directory**

```bash
mkdir -p /Users/ugogiordano/workdir/rhoai/adversarial-review
cd /Users/ugogiordano/workdir/rhoai/adversarial-review
git init
```

- [ ] **Step 2: Create marketplace.json**

Create `.claude-plugin/marketplace.json`:

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

- [ ] **Step 3: Create plugin.json**

Create `adversarial-review/.claude-plugin/plugin.json`:

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

- [ ] **Step 4: Create .gitignore**

```
.DS_Store
*.swp
*.swo
*~
/tmp/
```

- [ ] **Step 5: Create LICENSE**

Apache-2.0 license file.

- [ ] **Step 6: Create README.md**

Include: overview, three install paths (Claude Code plugin, Cursor, AGENTS.md), security properties table from spec, dependencies, link to spec.

- [ ] **Step 7: Commit scaffolding**

```bash
git add -A
git commit -m "Initial repo scaffolding: marketplace, plugin metadata, README, LICENSE"
```

---

### Task 2: Copy skill directory into plugin structure

**Files:**
- Create: `adversarial-review/adversarial-review/skills/adversarial-review/` (entire directory tree)

**Context:** Copy the 49 files from `superpowers/skills/adversarial-review/` into `adversarial-review/adversarial-review/skills/adversarial-review/`. The skill directory nests inside the plugin directory, which nests inside the marketplace repo. This preserves the `skills/<name>/SKILL.md` discovery convention.

Source: `/Users/ugogiordano/workdir/rhoai/superpowers/skills/adversarial-review/`
Destination: `/Users/ugogiordano/workdir/rhoai/adversarial-review/adversarial-review/skills/adversarial-review/`

- [ ] **Step 1: Copy the entire skill directory**

```bash
mkdir -p /Users/ugogiordano/workdir/rhoai/adversarial-review/adversarial-review/skills/
cp -r /Users/ugogiordano/workdir/rhoai/superpowers/skills/adversarial-review \
      /Users/ugogiordano/workdir/rhoai/adversarial-review/adversarial-review/skills/adversarial-review
```

- [ ] **Step 2: Verify file count**

```bash
find /Users/ugogiordano/workdir/rhoai/adversarial-review/adversarial-review/skills/adversarial-review -type f | wc -l
```

Expected: `49`

- [ ] **Step 3: Run existing tests to confirm baseline**

```bash
cd /Users/ugogiordano/workdir/rhoai/adversarial-review/adversarial-review/skills/adversarial-review
bash tests/run-all-tests.sh
```

Expected: `TOTAL: 51 passed, 0 failed`

- [ ] **Step 4: Commit**

```bash
cd /Users/ugogiordano/workdir/rhoai/adversarial-review
git add -A
git commit -m "Copy adversarial-review skill from superpowers"
```

---

### Task 3: Apply content changes to extracted skill

**Files:**
- Modify: `adversarial-review/adversarial-review/skills/adversarial-review/SKILL.md` (3 edits)
- Modify: `adversarial-review/adversarial-review/skills/adversarial-review/phases/report.md` (2 lines)
- Modify: `adversarial-review/adversarial-review/skills/adversarial-review/templates/report-template.md` (2 lines)
- Modify: `adversarial-review/adversarial-review/skills/adversarial-review/protocols/delta-mode.md` (1 line)

**Context:** Four content changes from the spec: replace `docs/superpowers/reviews/` with `docs/reviews/`, remove `reflective-implementation` cross-reference, update file structure reference in SKILL.md, ensure script invocations use `bash scripts/...` form.

- [ ] **Step 1: Replace report save path in SKILL.md**

In `SKILL.md` line 219, replace:
```
docs/superpowers/reviews/YYYY-MM-DD-<topic>-review.md
```
with:
```
docs/reviews/YYYY-MM-DD-<topic>-review.md
```

- [ ] **Step 2: Replace report save path in phases/report.md**

Lines 126-127, replace:
```
2. **Construct path:** `docs/superpowers/reviews/YYYY-MM-DD-<topic>-review.md`
3. **Create directories** if they do not exist: `mkdir -p docs/superpowers/reviews/`
```
with:
```
2. **Construct path:** `docs/reviews/YYYY-MM-DD-<topic>-review.md`
3. **Create directories** if they do not exist: `mkdir -p docs/reviews/`
```

- [ ] **Step 3: Replace report save path in templates/report-template.md**

Line 5 and line 223, replace both occurrences of `docs/superpowers/reviews/` with `docs/reviews/`.

- [ ] **Step 4: Replace report save path in protocols/delta-mode.md**

Line 13, replace `docs/superpowers/reviews/` with `docs/reviews/`.

- [ ] **Step 5: Remove reflective-implementation cross-reference in SKILL.md**

Line 20, replace:
```
- Verification step after implementation (integrates with `reflective-implementation` Phase 3)
```
with:
```
- Verification step after implementation
```

- [ ] **Step 6: Update file structure reference in SKILL.md**

Replace the file structure block (lines 371-422) with the complete inventory. Add missing items:
- `protocols/injection-resistance.md`
- `tests/test-coverage-gaps.sh`
- `tests/fixtures/changed-finding.txt`
- `tests/fixtures/no-findings.txt`
- `tests/fixtures/provenance-injection-finding.txt`
- `tests/fixtures/two-findings-nonoverlap.txt`
- `tests/fixtures/two-findings-overlap.txt`
- `tests/fixtures/valid-finding-2.txt`
- `tests/fixtures/valid-finding-perf.txt`
- `tests/run-all-tests.sh` (already listed but verify)

Updated block:

```
skills/adversarial-review/
  SKILL.md                              # This file — main orchestrator
  config/
    model-config.yml.example            # Future multi-model routing (v2)
  agents/
    security-auditor.md                 # SEC specialist prompt
    performance-analyst.md              # PERF specialist prompt
    code-quality-reviewer.md            # QUAL specialist prompt
    correctness-verifier.md             # CORR specialist prompt
    architecture-reviewer.md            # ARCH specialist prompt
    devils-advocate.md                  # Single-specialist challenge agent
  phases/
    self-refinement.md                  # Phase 1 procedure
    challenge-round.md                  # Phase 2 procedure
    resolution.md                       # Phase 3 procedure
    report.md                           # Phase 4 procedure
    remediation.md                      # Phase 5 procedure (--fix)
  protocols/
    input-isolation.md                  # Delimiter-based code isolation
    mediated-communication.md           # Cross-agent message mediation
    convergence-detection.md            # Finding set stability detection
    delta-mode.md                       # Re-review protocol
    token-budget.md                     # Budget tracking protocol
    injection-resistance.md             # Two-tier injection detection
  scripts/
    generate-delimiters.sh              # Produces unique code delimiters
    validate-output.sh                  # Validates agent output structure
    detect-convergence.sh               # Checks finding set stability
    deduplicate.sh                      # Removes duplicate findings
    track-budget.sh                     # Token budget tracking
  templates/
    finding-template.md                 # Required output format for findings
    challenge-response-template.md      # Challenge/defense exchange format
    report-template.md                  # Final report format
    delta-report-template.md            # Delta review report format
    sanitized-document-template.md      # Sanitized cross-agent message format
    jira-template.md                    # Jira ticket template (--fix)
  tests/
    run-all-tests.sh                    # Test runner
    test-validation-script.sh           # Validation script tests
    test-single-agent.sh                # Single-agent pipeline integration tests
    test-injection-resistance.sh        # Injection resistance tests
    test-coverage-gaps.sh               # Coverage gap and edge case tests
    fixtures/
      sample-code.py                    # Sample code for testing
      sample-code-with-injection.py     # Code with embedded injection attempts
      valid-finding.txt                 # Valid finding for test input
      valid-finding-2.txt               # Second valid finding (different specialist)
      valid-finding-perf.txt            # Valid PERF finding
      malformed-finding.txt             # Malformed finding for test input
      injection-finding.txt             # Finding containing injection patterns
      provenance-injection-finding.txt  # Finding with provenance marker injection
      no-findings.txt                   # Zero-finding output (NO_FINDINGS_REPORTED)
      changed-finding.txt               # Modified finding for convergence tests
      two-findings-overlap.txt          # Overlapping findings for dedup tests
      two-findings-nonoverlap.txt       # Non-overlapping findings for dedup tests
      expected-findings.md              # Expected findings reference
      sample-prior-report.md            # Prior report for delta mode tests
```

- [ ] **Step 6b: Verify file structure update**

Confirm the updated block contains exactly: 6 agents, 5 phases, 6 protocols (including `injection-resistance.md`), 5 scripts, 6 templates, 5 test scripts (including `run-all-tests.sh` and `test-coverage-gaps.sh`), 14 fixtures.

```bash
cd /Users/ugogiordano/workdir/rhoai/adversarial-review/adversarial-review/skills/adversarial-review
grep -c "\.md\|\.sh\|\.py\|\.yml" SKILL.md | head -1
```

- [ ] **Step 7: Verify script invocation forms**

Search for `./scripts/` in all files. If any are found, change to `bash scripts/...` form:

```bash
grep -rn '\./scripts/' /Users/ugogiordano/workdir/rhoai/adversarial-review/adversarial-review/skills/adversarial-review/
```

Fix any occurrences found.

- [ ] **Step 8: Run tests to confirm no regressions**

```bash
cd /Users/ugogiordano/workdir/rhoai/adversarial-review/adversarial-review/skills/adversarial-review
bash tests/run-all-tests.sh
```

Expected: `TOTAL: 51 passed, 0 failed`

- [ ] **Step 9: Commit**

```bash
cd /Users/ugogiordano/workdir/rhoai/adversarial-review
git add -A
git commit -m "Apply extraction content changes: paths, cross-refs, file inventory"
```

---

### Task 4: Create slash command

**Files:**
- Create: `adversarial-review/adversarial-review/commands/adversarial-review.md`

- [ ] **Step 1: Create commands directory and slash command**

Create `adversarial-review/adversarial-review/commands/adversarial-review.md`:

```markdown
---
description: Run multi-agent adversarial code review
---

Invoke the adversarial-review skill to perform a multi-agent code review.
Pass any arguments from the user as the review target.
```

- [ ] **Step 2: Commit**

```bash
cd /Users/ugogiordano/workdir/rhoai/adversarial-review
git add -A
git commit -m "Add /adversarial-review slash command"
```

---

### Task 5: Create AGENTS.md universal entry point

**Files:**
- Create: `adversarial-review/AGENTS.md`

**Context:** Self-contained version of the skill instructions for non-Claude-Code tools. Includes preamble check for installation, degraded single-agent mode documentation, and all instructions inlined. Script paths use `$ADVERSARIAL_REVIEW_HOME` with `$HOME/.adversarial-review/adversarial-review` default.

- [ ] **Step 1: Create AGENTS.md**

The file should contain:

1. **Preamble** — installation check:
```bash
AR_HOME="${ADVERSARIAL_REVIEW_HOME:-$HOME/.adversarial-review/adversarial-review}"
[ -d "$AR_HOME/scripts" ] || echo "ERROR: adversarial-review not found at $AR_HOME. Clone it or set ADVERSARIAL_REVIEW_HOME."
```

2. **Overview** — what the skill does, when to use it

3. **Multi-agent mode** (tools with sub-agent support) — full skill instructions from SKILL.md with script paths prefixed by `$AR_HOME/`:
   - `bash $AR_HOME/scripts/validate-output.sh`
   - `bash $AR_HOME/scripts/detect-convergence.sh`
   - `bash $AR_HOME/scripts/deduplicate.sh`
   - `bash $AR_HOME/scripts/track-budget.sh`
   - `bash $AR_HOME/scripts/generate-delimiters.sh`

4. **Degraded single-agent mode** (tools without sub-agent support) — sequential persona role-play:
   - Agent assumes each specialist persona in sequence
   - No true isolation or mediated communication
   - Output validation via scripts still applies when shell is available
   - Note which security properties are advisory only

5. **References** — point to the companion files (agents, phases, protocols, templates) in `$AR_HOME/`

6. **Report save path** — `docs/reviews/YYYY-MM-DD-<topic>-review.md`

Source the core content from the current SKILL.md, adapting paths. Do NOT include the YAML frontmatter (that's Claude Code specific). Do NOT reference superpowers-specific features.

- [ ] **Step 2: Commit**

```bash
cd /Users/ugogiordano/workdir/rhoai/adversarial-review
git add AGENTS.md
git commit -m "Add AGENTS.md universal entry point with degraded mode"
```

---

### Task 6: Create Cursor rules file

**Files:**
- Create: `adversarial-review/.cursor/rules/adversarial-review.mdc`

**Context:** Cursor .mdc file with skill instructions adapted for Cursor's single-agent model. Uses literal path `$HOME/.adversarial-review/adversarial-review` (not env var — Cursor doesn't expand env vars in .mdc content). Documents that this is degraded single-agent mode.

- [ ] **Step 1: Create .cursor/rules directory and .mdc file**

The `.mdc` file should contain:

1. **Header comment**: `<!-- If you cloned to a different location, replace the path below -->`
2. **Default path**: `$HOME/.adversarial-review/adversarial-review`
3. **Degraded mode explanation**: Cursor cannot spawn isolated sub-agents. The agent role-plays each specialist sequentially.
4. **Workflow**: Condensed version of the SKILL.md phases adapted for single-agent sequential execution:
   - For each specialist: read the specialist prompt from `$HOME/.adversarial-review/adversarial-review/agents/<name>.md`, analyze code from that perspective, produce findings in the standard template format
   - Run `bash $HOME/.adversarial-review/adversarial-review/scripts/validate-output.sh` on output if shell available
   - Self-challenge findings (simplified Phase 2)
   - Deduplicate and produce report
5. **Security note**: Mediated communication and agent isolation are advisory only in this mode

- [ ] **Step 2: Commit**

```bash
cd /Users/ugogiordano/workdir/rhoai/adversarial-review
git add .cursor/
git commit -m "Add Cursor rules file (degraded single-agent mode)"
```

---

### Task 7: Create CI workflow

**Files:**
- Create: `adversarial-review/.github/workflows/test.yml`

- [ ] **Step 1: Create workflow**

Create `.github/workflows/test.yml`:

```yaml
name: Tests
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Run tests
        run: |
          cd adversarial-review/skills/adversarial-review
          bash tests/run-all-tests.sh 2>&1 | tee test-output.txt
          # Assert no failures
          grep -q "0 failed" test-output.txt
```

- [ ] **Step 2: Commit**

```bash
cd /Users/ugogiordano/workdir/rhoai/adversarial-review
git add .github/
git commit -m "Add CI workflow for test suite"
```

---

### Task 8: Final verification and push

**Files:** None (verification only)

- [ ] **Step 1: Verify complete file inventory**

```bash
cd /Users/ugogiordano/workdir/rhoai/adversarial-review
find . -not -path './.git/*' -type f | sort
```

Verify all expected files are present:
- `.claude-plugin/marketplace.json`
- `adversarial-review/.claude-plugin/plugin.json`
- `adversarial-review/skills/adversarial-review/SKILL.md` + all 48 companion files
- `adversarial-review/commands/adversarial-review.md`
- `AGENTS.md`
- `.cursor/rules/adversarial-review.mdc`
- `.github/workflows/test.yml`
- `.gitignore`
- `README.md`
- `LICENSE`

- [ ] **Step 2: Run full test suite one final time**

```bash
cd /Users/ugogiordano/workdir/rhoai/adversarial-review/adversarial-review/skills/adversarial-review
bash tests/run-all-tests.sh
```

Expected: `TOTAL: 51 passed, 0 failed`

- [ ] **Step 3: Verify no superpowers-specific references remain**

```bash
cd /Users/ugogiordano/workdir/rhoai/adversarial-review
grep -rn "superpowers" --include='*.md' --include='*.sh' . | grep -v '.git/'
```

Expected: zero results (or only the spec reference link in README, if included).

- [ ] **Step 4: Create GitHub repo and push**

```bash
cd /Users/ugogiordano/workdir/rhoai/adversarial-review
gh repo create ugiordan/adversarial-review --private --source=. --push
```

- [ ] **Step 5: Test plugin installation**

```bash
claude marketplace add --git https://github.com/ugiordan/adversarial-review.git
claude plugin add adversarial-review --scope user
```

Verify the skill appears in available skills and `/adversarial-review` slash command is registered.

---

### Task 9: Remove skill from superpowers fork

**Files:**
- Delete: `superpowers/skills/adversarial-review/` (entire directory)

**Context:** Per migration plan — remove after standalone is verified. Only proceed after Task 8 Step 5 confirms plugin works.

- [ ] **Step 1: Verify standalone plugin is working**

Confirm Task 8 Step 5 passed. The standalone plugin must install and be discoverable before removing from superpowers.

- [ ] **Step 2: Remove from superpowers**

```bash
cd /Users/ugogiordano/workdir/rhoai/superpowers
rm -rf skills/adversarial-review/
```

- [ ] **Step 3: Run remaining superpowers tests (if any)**

Verify no other superpowers skills depend on adversarial-review files.

- [ ] **Step 4: Commit and push**

```bash
cd /Users/ugogiordano/workdir/rhoai/superpowers
git add -A
git commit -m "Remove adversarial-review skill (extracted to standalone plugin)"
git push origin custom
```
