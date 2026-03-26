# Planning Phase

## Purpose
Establish strategic direction through approach comparison and get human approval.

## Inputs
- Task description
- Loaded context (architecture, conventions, etc.)
- Mode (interactive/autonomous)

## Process

### 1. Analyze Request

Break down the task to understand:
- Core requirement
- Constraints from context
- Affected components
- Integration points

Use Glob/Grep tools to discover relevant code, or spawn an exploration subagent via the Agent tool for broad codebase analysis. If Serena MCP is available, use symbol-level operations for faster discovery.

### 2. Generate Approaches

Create 2-3 viable approaches with:
- Clear description
- Pros and cons
- Complexity assessment
- Alignment with project context

### 3. Create Comparison

Present using this structure:

```markdown
## Goal
[One sentence: what we're building and why]

## Context Loaded
- architecture.md: [key constraints/patterns noted]
- conventions.md: [coding standards to follow]
- security-standards.md: [security requirements]

## Approach Comparison

| Approach | Pros | Cons | Complexity | Aligns with Context |
|----------|------|------|------------|---------------------|
| Option 1 | ... | ... | Medium | Per architecture.md |
| Option 2 | ... | ... | Low | Violates stateless requirement |
| Option 3 | ... | ... | High | Adds new dependency |

**Recommended: Option 1**

**Reasoning:**
- Aligns with [architectural pattern from context]
- Uses existing [technology from tech stack]
- Follows [convention from conventions.md]
- Avoids [anti-pattern from decisions.md]

**Trade-offs:**
- Gained: [benefits]
- Lost: [what we're giving up]
- Risk: [potential issues and how we mitigate]

## High-Level Implementation Plan
- Component A: [new/modify]
- Component B: [new/modify]
- Tests: [approach matching testing-patterns.md]
- Dependencies: [if any]
```

### 4. Present to User

**Interactive mode:**
Present comparison table and ask: "Proceed with recommended approach?" If approved, continue to implementation. If adjusted, incorporate feedback and update the plan.

**Autonomous mode:**
Store the decision and reasoning in a decision log for Layer 3 reporting. Proceed immediately to implementation.

## Outputs
- Approved approach
- High-level implementation plan
- Decision log (for Layer 3 reasoning)
