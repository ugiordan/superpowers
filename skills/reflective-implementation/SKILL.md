---
name: reflective-implementation
description: "Use when implementing complex features requiring architectural decisions, critical systems like authentication or payments, high-stakes refactoring, or when the human needs to understand alternatives and trade-offs deeply."
---

# Reflective Implementation

## Overview

This skill implements a human-in-the-loop transparency framework that ensures you understand not just *what* is being built, but *why*, what alternatives were considered, and how it was verified to be the best solution.

**When to use:**
- Complex features requiring architectural decisions
- Critical systems (authentication, payments, security)
- When the human wants to learn and understand deeply
- High-stakes refactoring

**When NOT to use:**
- Trivial fixes (typos, one-line changes)
- Time-critical hotfixes
- Quick experiments

## Usage

**Interactive mode (default):**
```
/reflective-implementation add user authentication
```
You approve the approach, get progress updates, then comprehensive review.

**Autonomous mode:**
```
/reflective-implementation --autonomous optimize database queries
```
AI works independently, presents complete analysis at the end.

## The Three Phases

### Phase 1: Planning
- Load project context (architecture, conventions, security standards)
- Generate 2-3 viable approaches with comparison
- Present recommendation with reasoning
- Interactive: Get approval | Autonomous: Proceed

### Phase 2: Implementation
- Execute the approved plan
- Make tactical decisions
- Announce decisions: "Implemented X using Y (over Z: reason)"
- Interactive: Real-time updates | Autonomous: Collect for final review

### Phase 3: Verification
- Run quality gates (if the automated-quality-gates skill is configured)
- Spawn adversarial reviewer (challenges implementation, flags concerns)
- Spawn specialist agents based on adversarial findings:
  - Performance analyst
  - Security auditor
  - Correctness verifier
  - Code quality reviewer
- Fix issues iteratively (max 3 attempts)
- Generate comprehensive verification report

## Final Review: 5 Layers of Explanation

**Layer 1 (TL;DR):** 30 seconds - Quick summary
**Layer 2 (Visual):** 2 minutes - Architecture diagram and key metrics
**Layer 3 (Reasoning):** 5 minutes - All alternatives and trade-offs
**Layer 4 (Technical):** 10+ minutes - Code walkthrough, patterns, data flow
**Layer 5 (Verification):** Full verification report with all findings

Interactive mode: presents incrementally. Autonomous mode: all at once.

---

## Workflow

### 1. Parse Mode

Check if the user provided the `--autonomous` flag. If present, operate in autonomous mode (no interruptions, full report at end). Otherwise, use interactive mode (approval gates, real-time updates).

### 2. Load Context

Check if `.claude/context/` directory exists. If present, read the following files (skip any that don't exist):
- `architecture.md` — architectural patterns and constraints
- `conventions.md` — coding standards and naming
- `security-standards.md` — security requirements
- `testing-patterns.md` — test structure and coverage expectations
- `tech-stack.md` — technologies and frameworks in use
- `decisions.md` — past architectural decisions and rationale

If no context directory exists, use general best practices. The skill works fully without project context.

See `utils/context-loader.md` for detailed loading guidance.

### 3. Execute Phases

Follow each phase in sequence. Each phase's detailed instructions are in:
- `phases/planning.md` — approach selection and approval
- `phases/implementation.md` — execution with decision announcements
- `phases/verification.md` — multi-agent verification and fixing

### 4. Generate Final Report

After verification, generate a layered explanation using the templates:
- `templates/layer1-tldr.md` — 30-second summary
- `templates/layer2-visual.md` — architecture diagram and metrics (no approach comparison — that's Layer 3)
- `templates/layer3-reasoning.md` — all decisions and alternatives (no diagrams — that's Layer 2)
- `templates/layer4-technical.md` — annotated code walkthrough (no architecture overview — that's Layer 2)
- `templates/layer5-verification.md` — complete verification report

### 5. Documentation

Write comprehensive report to: `docs/plans/YYYY-MM-DD-<task-name>-implementation.md`

---

## Integration

**Uses (when available):**
- `project-context` skill — loads architecture, conventions, security standards
- `automated-quality-gates` skill — runs gates before adversarial review
- Agent tool — spawns adversarial and specialist agents

**Graceful degradation:**
- Works without project-context (uses general best practices)
- Works without quality-gates (adversarial verification still thorough)
