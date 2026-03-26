# Architectural Decisions

> Key decisions, trade-offs, and the reasoning behind them

## Decision Log Format

Each decision follows this structure:

```markdown
## ADR-NNN: [Decision Title]

**Date**: YYYY-MM-DD
**Status**: [Proposed | Accepted | Deprecated | Superseded]
**Deciders**: [Who made this decision]

### Context

[What is the issue we're trying to solve? What are the constraints?]

### Decision

[What did we decide to do?]

### Consequences

**Positive:**
- [Benefit 1]
- [Benefit 2]

**Negative:**
- [Trade-off 1]
- [Trade-off 2]

**Neutral:**
- [Change 1]
- [Change 2]

### Alternatives Considered

**Option 1: [Name]**
- Pros: [List]
- Cons: [List]
- Why not chosen: [Reason]

**Option 2: [Name]**
- Pros: [List]
- Cons: [List]
- Why not chosen: [Reason]

### References

- [Link to discussion]
- [Link to related docs]
- [Link to superseding ADR if deprecated]
```

---

## ADR-001: [First Decision Title]

**Date**: YYYY-MM-DD
**Status**: Accepted
**Deciders**: [Names/Team]

### Context

[Problem and constraints]

### Decision

[What was decided]

### Consequences

**Positive:**
- [Benefits]

**Negative:**
- [Trade-offs]

### Alternatives Considered

**[Alternative 1]:**
- Why not chosen: [Reason]

**[Alternative 2]:**
- Why not chosen: [Reason]

---

## ADR-002: [Second Decision Title]

**Date**: YYYY-MM-DD
**Status**: Accepted
**Deciders**: [Names/Team]

### Context

[Problem and constraints]

### Decision

[What was decided]

### Consequences

**Positive:**
- [Benefits]

**Negative:**
- [Trade-offs]

### Alternatives Considered

**[Alternative 1]:**
- Why not chosen: [Reason]

---

## Decision Index

Quick reference to all decisions:

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| 001 | [Title] | Accepted | YYYY-MM-DD |
| 002 | [Title] | Accepted | YYYY-MM-DD |
| 003 | [Title] | Deprecated | YYYY-MM-DD |

## Deprecated Decisions

### ADR-XXX: [Deprecated Decision]

**Superseded by**: ADR-YYY
**Reason**: [Why it was deprecated]
**Migration Path**: [How to move from old to new]

## References

- [Link to full ADR repository if separate]
- [Link to decision-making process doc]
