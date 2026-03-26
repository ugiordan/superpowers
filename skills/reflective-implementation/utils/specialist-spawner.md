# Specialist Spawner Utility

## Purpose
Determine which specialist agents to spawn based on adversarial findings and change context.

## Decision Logic

The adversarial reviewer produces structured concern flags in its report. Combined with the change context profile, these determine which specialists to spawn.

> **Note:** The logic below is pseudocode illustrating the decision rules. The AI agent should follow this logic when deciding which specialists to spawn — it is not executable code.

### Spawning Rules

| Specialist | Spawn When |
|-----------|------------|
| **Performance analyst** | Adversarial `Performance: YES`, OR change touches database/query files, OR lines changed > 100 |
| **Security auditor** | Adversarial `Security: YES`, OR change touches auth/API files, OR project has security-standards.md |
| **Correctness verifier** | Adversarial `Correctness: YES`, OR change adds complex algorithms, OR change modifies core business logic |
| **Code quality reviewer** | Adversarial `Code Quality: YES`, OR lines changed > 200, OR project has conventions.md |

### Fallback Rule

If no specialists are triggered by the rules above, spawn the **code quality reviewer** as a minimum sanity check.

## Change Context Classification

To classify changes, analyze the `git diff` output and file paths:

| Signal | How to Detect |
|--------|--------------|
| touches_database | Files in models/, migrations/, schema/, or containing SQL |
| touches_auth | Files containing "auth", "jwt", "session", "permission" |
| touches_api | Files in api/, routes/, handlers/, or endpoint definitions |
| adds_complex_algorithm | New loops, recursion, state machines in the diff |
| modifies_core_logic | Files in core/, service/, domain/, or business logic |

## Agent Tool Integration

For each specialist to spawn, use the Agent tool with:

```
Agent tool call:
  subagent_type: "general-purpose"
  description: "[Specialist name] analysis"
  prompt: |
    You are a [specialist type]. Follow the specialist definition
    in agents/specialists/[name].md.

    Code to review: [changed files]
    Focus areas: [from spawning rules]
    Project context: [relevant context files, if loaded]
    Adversarial concerns: [specific concerns from adversarial report]

    Produce a detailed report per the output format in your definition.
```

Spawn all selected specialists in parallel. Collect all reports before proceeding to the iterative fixing step.
