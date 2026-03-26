# Reflective Implementation

> Transparent AI implementation with human-in-the-loop reasoning

## Overview

This skill ensures you understand not just *what* is being built, but *why*, what alternatives were considered, and how it was verified to be optimal.

## When to Use

**Use for:**
- Complex features requiring architectural decisions
- When you want to understand alternatives and trade-offs
- Critical systems needing thorough verification
- Substantial work (multiple files, >100 LOC)

**Don't use for:**
- Trivial fixes (typos, one-line changes)
- Time-critical hotfixes
- Quick experiments
- Obvious changes with no alternatives

## Quick Start

**Interactive mode (default):**
```bash
/reflective-implementation add user authentication
```
- You approve approach in planning
- Get progress updates during work
- Comprehensive review at end

**Autonomous mode:**
```bash
/reflective-implementation --autonomous optimize query performance
```
- AI works independently
- Complete analysis presented at end
- Full transparency, zero interruption

## What You Get

### Three Phases

1. **Planning** — Approve the approach
   - 2-3 alternatives with comparison
   - References project context
   - Clear recommendation with reasoning

2. **Implementation** — Stay informed
   - Decision announcements as work progresses
   - Interactive: real-time | Autonomous: collected for review

3. **Verification** — Multi-agent quality assurance
   - Adversarial reviewer challenges implementation and flags concerns
   - Specialists spawned based on concern flags (performance, security, correctness, quality)
   - Iterative fixing until issues resolved
   - Comprehensive verification report

### Five Layers of Explanation

Each layer has a distinct scope — no duplication between layers:

- **Layer 1 (30s):** TL;DR summary
- **Layer 2 (2min):** Architecture diagram and key metrics
- **Layer 3 (5min):** All decisions, alternatives, and reasoning
- **Layer 4 (10min):** Annotated code walkthrough and data flow
- **Layer 5:** Complete verification report from all agents

Interactive mode: presents incrementally. Autonomous mode: all at once.

## Integration

**Automatically uses (when available):**
- `project-context` — Loads architecture, conventions, security standards
- `automated-quality-gates` — Runs gates before verification
- Works standalone if these aren't configured

## Optional Enhancement: Serena

Serena MCP Server provides symbol-level code operations for faster analysis on large codebases. Automatically detected when available; falls back to Glob/Grep/Edit if not.

See `utils/serena-helper.md` for details.

## File Structure

```
skills/reflective-implementation/
├── SKILL.md                  # Main entry point
├── README.md                 # This file
├── phases/
│   ├── planning.md          # Approach selection and approval
│   ├── implementation.md    # Execution with decision announcements
│   └── verification.md      # Multi-agent verification
├── agents/
│   ├── adversarial-reviewer.md    # High-level challenger and concern router
│   └── specialists/
│       ├── performance-analyst.md
│       ├── security-auditor.md
│       ├── correctness-verifier.md
│       └── code-quality-reviewer.md
├── templates/
│   ├── layer1-tldr.md       # 30-second summary
│   ├── layer2-visual.md     # Architecture and metrics
│   ├── layer3-reasoning.md  # Decisions and alternatives
│   ├── layer4-technical.md  # Code walkthrough
│   └── layer5-verification.md  # Verification report
├── utils/
│   ├── context-loader.md
│   ├── specialist-spawner.md
│   ├── visualization-helper.md
│   └── serena-helper.md
└── tests/
    └── test-integration.sh
```

## Development

**Run tests:**
```bash
./skills/reflective-implementation/tests/test-integration.sh
```

**Extend:**
- Add new specialists in `agents/specialists/`
- Customize templates in `templates/`
- Adjust spawning logic in `utils/specialist-spawner.md`
