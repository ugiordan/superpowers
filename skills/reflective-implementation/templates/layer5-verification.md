# Layer 5: Verification Template

## Purpose
Complete verification report from all agents.

**Scope:** Include only sections for specialists that were actually spawned. Omit sections for specialists not triggered by the spawning rules.

## Format

```markdown
## Layer 5: Verification

### Quality Gates
[If .claude/quality-gates.yml exists]

✅ Linting passed (0 warnings)
✅ Tests passed (47/47, 94% coverage)
✅ Build successful
✅ Security scan clean

### Adversarial Review

**Scenarios Tested:** [N]

[List of scenarios with results]

**Issues Found:** [N]

[List of issues if any]

**Overall:** ✅ All scenarios passing

### Specialist Reports

#### Performance Analyst

[Benchmark table]
[Complexity analysis]
[Resource usage]
[Optimizations considered]

**Assessment:** [Status]

#### Security Auditor

[OWASP Top 10 check results]
[Auth/authz flow validation]
[Vulnerability scan]

**Assessment:** [Status]

#### Correctness Verifier

[Business logic validation]
[Error handling coverage]
[Edge cases tested]

**Assessment:** [Status]

#### Code Quality Reviewer

[Pattern usage]
[Maintainability metrics]
[Consistency check]
[Tech debt]

**Assessment:** [Status]

### Verification Iterations

[If issues were found and fixed]

**Attempt 1:**
❌ [Issues found]

**Fixes Applied:**
✅ [What was fixed, why, how]

**Attempt 2:**
✅ All verification passed

### Synthesis

✅ Implementation verified as optimal
✅ No critical issues remaining
✅ Performance goals [met/exceeded]
✅ Security standards met
✅ Follows project conventions
✅ Well-tested and maintainable

**Confidence Level:** HIGH - Ready for production

**Recommendations:** [If any follow-up needed]
```
