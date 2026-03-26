# Layer 3: Detailed Reasoning Template

## Purpose
5-minute deep dive on all decisions and alternatives.

**Scope:** This layer owns decision rationale. Do NOT reproduce architecture diagrams (Layer 2) or code walkthroughs (Layer 4). Reference them: "See Layer 2 for architecture diagram."

## Format

```markdown
## Layer 3: Detailed Reasoning

### Planning Decision: Approach Selection

**Alternatives Considered:**
1. [Approach 1]: [Description]
2. [Approach 2]: [Description]
3. [Approach 3]: [Description]

**Chosen:** [Approach X]

**Reasoning:**
- [Aligns with architecture.md pattern]
- [Uses existing tech from tech-stack.md]
- [Follows convention from conventions.md]

**Trade-offs:**
- Gained: [Benefits]
- Lost: [What we gave up]
- Risk: [Potential issues and mitigation]

### Implementation Decisions

[For autonomous mode: Include all decision announcements from Phase 2]
[For interactive mode: Expand on key decisions]

**Decision 1: [Topic]**

**Alternatives:**
- Option A: [Description]
- Option B: [Description]

**Chosen:** Option B
**Reasoning:** [Why this over alternatives]
**Trade-offs:** [What we gained/lost]

[Repeat for all major decisions]

### Context Usage

**From architecture.md:**
- [How architectural patterns influenced decisions]

**From conventions.md:**
- [How coding conventions were followed]

**From security-standards.md:**
- [How security requirements were met]
```
