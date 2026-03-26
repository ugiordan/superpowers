# Adversarial Review + AI Code Analyst Integration Plan

**Date:** 2026-03-25
**Status:** Approved
**Repos:** `ugiordan/adversarial-review`, `ugiordan/ai-code-analyst`

## Summary

adversarial-review (AR) and ai-code-analyst (ACA) are complementary tools with distinct strengths. AR provides adversarial debate-driven code review inside Claude Code sessions. ACA provides batch multi-agent analysis (AI detection, quality scoring, PR/history analysis) via standalone CLI. Integration is via a **bridge strategy** — cross-tool CLI invocation and shared output schemas — not a merge.

## Architecture Decision

**Keep separate. Do not merge. Do not create a shared prompts repo.**

This decision was validated by three independent architecture reviews examining separate repos, merge, and user perspective. All three reached the same conclusion unanimously.

### Why Not Merge

| Concern | Finding |
|---------|---------|
| Runtime mismatch | AR runs inside Claude Code (LLM is the orchestrator). ACA runs standalone (Python is the orchestrator). Fundamentally different control planes. |
| Interactive remediation lost | AR's 4-gate remediation (Jira via MCP, worktree via Agent tool, PR proposals) cannot work from a CLI process. |
| Debate quality degrades | LLM-as-orchestrator provides nuanced judgment during mediation. Python orchestration is deterministic — loses adaptability. |
| Bloat risk | ACA already has 4 subcommands, 2 pipelines, 2 phases, FastAPI server. Adding AR's features creates a monolith. |
| Install story worsens | Merged: "pip install, but for interactive mode you also need Claude Code." Separate: each installs cleanly in its own ecosystem. |

### Why Not Create `ai-agent-prompts` (Shared Repo)

The overlap between agent prompts is **conceptual, not structural**:
- AR agents produce plaintext with `SEC-NNN` IDs, validated by bash scripts
- ACA agents produce JSON with CVSS scores and CWE references, parsed by Python
- Output format, protocol instructions, and role framing are tool-specific
- A shared repo would contain ~10-15 lines of reusable content per agent
- Version sync across heterogeneous runtimes (markdown plugin vs Python package) costs more than deduplication saves

**Preferred approach:** Copy prompts with attribution when cross-pollinating. Prompt text is cheap to maintain; dependency coordination is expensive.

### What Each Tool Owns

| | adversarial-review | ai-code-analyst |
|--|-------------------|-----------------|
| **Identity** | Interactive adversarial code review | Batch AI detection + quality analysis |
| **Runtime** | Inside Claude Code session (LLM orchestrates) | Standalone Python process (code orchestrates) |
| **Users** | Developer in editor, security reviewer | CI/CD pipeline, team lead, auditor |
| **Install** | `claude plugin add` | `pip install` |
| **Agents** | 5 specialists + devil's advocate (markdown) | 5 agents (Python Agent SDK) |
| **Consensus** | Active debate (challenge + defend, voting) | Passive convergence (spread-based) |
| **Validation** | Bash scripts (injection detection, provenance) | Python dataclass + parser |
| **Output** | Markdown (+ JSON, planned) | Markdown + JSON |

## Tool Comparison

| Aspect | adversarial-review | ai-code-analyst |
|--------|-------------------|-----------------|
| Type | Claude Code skill (markdown) | Python CLI + FastAPI server |
| Primary purpose | Multi-perspective review with adversarial debate | AI code detection + quality analysis |
| Unique features | Challenge round, mediated communication, injection resistance, remediation (Jira/PRs), delta mode, token budget enforcement | AI detection (Pattern Detective + Bayesian calibration), PR/history analysis, Test Evaluator, Statistical Phase 0, cost gating, server mode, tree-sitter AST |

## Integration Plan

### Phase 1: Quick Wins (no cross-repo dependencies)

#### 1a. Port Test Evaluator prompt to adversarial-review (6th specialist)
- **Where:** `ugiordan/adversarial-review`
- ACA's Test Evaluator assesses coverage patterns, edge cases, implementation coupling
- AR has no test quality specialist — natural gap
- Create `agents/test-evaluator.md` with prefix `TEST`, add `--tests` flag
- Copy and adapt the prompt (don't share it — different output formats)

#### 1b. Add `--json` output flag to adversarial-review
- **Where:** `ugiordan/adversarial-review`
- AR only outputs markdown — JSON enables programmatic consumption and CI/CD
- Define a `Finding` JSON schema compatible with ACA's `models.py` where possible
- This is the highest-value quick win — enables all Phase 2 cross-tool data flow

### Phase 2: Cross-Tool Data Flow (requires ACA installed)

#### 2a. ai-code-analyst collectors as adversarial-review input
- **Where:** `ugiordan/adversarial-review` (adds `--pr` and `--history` flags)
- AR shells out to `ai-code-analyst pr --json <number>` for data collection
- AR runs adversarial debate on the collected data
- Two tools > one tool: ACA's battle-tested collectors + AR's debate protocol

#### 2b. AI detection as adversarial-review pre-flight
- **Where:** `ugiordan/adversarial-review` (adds `--detect-ai` flag)
- Calls `ai-code-analyst source --detect-only --json` before review
- If AI probability > threshold, includes it in report header as context
- Specialists factor in "likely AI-generated" when assessing quality

#### 2c. Bidirectional cost gating
- **Where:** Both repos
- **AR → ACA**: AR's `--quick` (SEC + CORR, 200K tokens) as cheap pre-filter before ACA's expensive Phase 2. Skip quality council on code AR already cleared.
- **ACA → AR**: ACA's Phase 0 (free) + Phase 1 (cheap) as triage before AR's full 5-specialist review. Escalate to adversarial debate only when ACA flags concerns.

### Phase 3: Deep Integration (requires both tools mature)

#### 3a. Simplified adversarial mode for ai-code-analyst
- **Where:** `ugiordan/ai-code-analyst`
- Add `_run_challenge_round()` to `BlackboardController` — Python-native implementation inspired by AR's protocol
- Not a full port: deterministic challenge/response, no LLM mediation
- Improves finding confidence for CI/CD use where interactive debate isn't available

#### 3b. Red-teaming: injection resistance for ai-code-analyst
- **Where:** `ugiordan/ai-code-analyst`
- ACA agents read analyzed code directly via SDK tools with `bypassPermissions` — no injection resistance
- Known attack vectors:
  - Prompt injection via analyzed code (malicious code embeds instructions)
  - Consensus poisoning (crafted patterns bias multiple agents simultaneously)
  - Statistical metric gaming (code structured to fool Phase 0 heuristics)
  - Provenance forgery (no provenance markers, attribution is trust-based)
- Port AR's two-tier injection detection to Python
- Add input isolation (delimiter wrapping) to ACA's agent prompts
- Add provenance markers to ACA's consensus pipeline

#### 3c. Bayesian calibration for adversarial-review
- **Where:** `ugiordan/adversarial-review`
- AR's Phase 3 produces discrete categories via vote counting
- ACA's `compute_calibrated_probability()` uses weighted factor aggregation
- Integration: after voting, compute calibrated confidence per finding using agent confidence weights + agreement strength
- Transforms "3/5 agree Critical" into a calibrated probability with factor breakdown

#### ~~3d. Unified report format~~ → Covered by 1b
- Defining the shared JSON schema in 1b makes this redundant as a separate task

#### ~~1c. Shared agent prompt library~~ → REJECTED
- Architectural review concluded prompts are structurally incompatible
- Copy with attribution when cross-pollinating instead

## Execution Priority

```
1b (--json for AR) → 1a (Test Evaluator) → 2c (cost gating) → 3b (injection resistance for ACA)
                                                              → 3c (calibration for AR)
                                                              → 2a (AR --pr via ACA)
                                                              → 2b (AR --detect-ai)
                                                              → 3a (adversarial mode for ACA)
```

## Dependencies

| Phase | Dependency |
|-------|-----------|
| 1a, 1b | None (parallel work in AR repo) |
| 2a, 2b | ACA installed (`pip install ai-code-analyst`), 1b complete |
| 2c | Both tools available |
| 3a | ACA consensus refactoring |
| 3b | Independent (ACA security hardening) |
| 3c | ACA calibration module extraction |
