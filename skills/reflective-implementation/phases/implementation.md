# Implementation Phase

## Purpose
Execute the approved plan while keeping the human informed of tactical decisions.

## Inputs
- Approved approach from planning
- Loaded context
- Mode (interactive/autonomous)

## Process

### 1. Execute Plan

Implement according to the approved approach:
- Create/modify files as planned
- Follow conventions from context
- Match testing patterns
- Use architectural patterns

Use the Edit tool for code modifications. If Serena MCP is available, use symbol-level editing for more precise changes — otherwise standard text-matching edits work well.

### 2. Generate Decision Announcements

For each tactical decision during implementation, announce it using this format:

```
"Implemented [component] using [approach] (chosen over [alternative]: [reason]). Moving to [next]."
```

**What to announce:**
- Decisions with meaningful alternatives (not obvious choices)
- Technology/library selections within the approved approach
- Algorithm or pattern choices
- Trade-offs between competing concerns (performance vs readability)
- Deviations from the obvious path (and why)

**What NOT to announce:**
- Obvious implementations with no real alternatives
- Standard boilerplate code
- Routine file structure decisions

**Examples:**
```
"Implemented token service using JWT HS256 (chose over RS256: simpler key
management for single-service per architecture.md). Moving to middleware."

"Added caching with Redis (better persistence than in-memory per
architecture.md distributed requirement). Moving to invalidation logic."
```

### 3. Mode-Specific Handling

**Interactive mode:**
Output each decision announcement as it happens. The user sees real-time progress and can intervene if the direction looks wrong.

**Autonomous mode:**
Collect all decision announcements in a decision log. Store full context for each decision including alternatives considered. Present comprehensively in the Layer 3 report at the end.

### 4. Context Usage

Reference loaded context in decisions:
- Follow `conventions.md` patterns
- Use `tech-stack.md` technologies
- Respect `architecture.md` constraints
- Apply `security-standards.md` requirements
- Match `testing-patterns.md` structure

## Outputs
- Implemented code
- Decision announcement log
- Files modified/created list
