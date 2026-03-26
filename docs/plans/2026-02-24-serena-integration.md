# Serena Integration for Reflective Implementation

**Date:** 2026-02-24
**Goal:** Add optional Serena MCP server support to reflective-implementation for semantic code operations

## Overview

Serena (https://github.com/oraios/serena) provides semantic, symbol-level code operations instead of basic text manipulation. This enhancement will make reflective-implementation more efficient for large codebases while maintaining graceful degradation.

## Current State

Reflective-implementation uses:
- **Glob/Grep** for code discovery
- **Read/Edit** for file operations
- **Task tool with Explore agent** for codebase understanding

**Works well but:**
- Token-intensive for large files
- Text-based search (not semantic)
- Must read entire files

## Serena Benefits

**Symbol-level operations:**
- `find_symbol(name)` - Locate classes/functions by name
- `find_referencing_symbols(symbol)` - Understand dependencies
- `insert_after_symbol(symbol, code)` - Precise edits
- Multi-language support (30+ languages via LSP)

**Advantages:**
- 10x faster codebase analysis
- More precise edits (symbol-aware)
- Better token efficiency
- Understands code structure

## Integration Strategy

### Principle: Graceful Degradation

```
If Serena MCP available:
  ✅ Use semantic operations (faster, more accurate)
Else:
  ✅ Fall back to Glob/Grep/Read/Edit (still works)
```

### Detection

Check for Serena MCP server availability:

```typescript
// In planning/implementation/verification phases
const hasSerena = await checkMCPServer('serena');

if (hasSerena) {
  // Use Serena tools
  const symbol = await find_symbol('UserService');
  const refs = await find_referencing_symbols(symbol);
} else {
  // Fall back to traditional tools
  const files = await glob('**/*.ts');
  const matches = await grep('class UserService');
}
```

## Implementation Tasks

### Task 1: Update Planning Phase

**File:** `skills/reflective-implementation/phases/planning.md`

**Changes:**
```markdown
### 1. Analyze Request (Enhanced with Serena if available)

**With Serena MCP:**
- Use `find_symbol` to locate relevant code
- Use `find_referencing_symbols` to understand dependencies
- Build architecture understanding from symbol graph

**Fallback (no Serena):**
- Use Task tool with Explore agent
- Use Glob/Grep for code discovery
```

### Task 2: Update Implementation Phase

**File:** `skills/reflective-implementation/phases/implementation.md`

**Changes:**
```markdown
### 1. Execute Plan (Enhanced with Serena if available)

**With Serena MCP:**
- Use `insert_after_symbol` for precise edits
- Use `replace_symbol` for refactoring
- Symbol-level changes (less fragile)

**Fallback (no Serena):**
- Use Edit tool with text matching
- Read full files for context
```

### Task 3: Update Verification Phase

**File:** `skills/reflective-implementation/phases/verification.md`

**Changes:**
```markdown
### Step 2: Spawn Adversarial Reviewer (Enhanced with Serena)

**With Serena MCP:**
Pass symbol-level context to adversarial agent:
- Symbol definitions
- Reference graph
- Call hierarchies

**Fallback (no Serena):**
Pass file-level context as usual
```

### Task 4: Update Utilities

**New File:** `skills/reflective-implementation/utils/serena-helper.md`

```markdown
# Serena Helper Utility

## Purpose
Detect and use Serena MCP server when available

## Detection

\`\`\`python
def has_serena():
    """Check if Serena MCP server is available"""
    try:
        # Check if Serena tools are available
        tools = list_available_tools()
        return 'find_symbol' in tools
    except:
        return False
\`\`\`

## Symbol Operations

### Find Symbol
\`\`\`python
if has_serena():
    symbol = find_symbol('ClassName')
else:
    # Fall back to grep
    matches = grep('class ClassName')
\`\`\`

### Find References
\`\`\`python
if has_serena():
    refs = find_referencing_symbols(symbol)
else:
    # Fall back to text search
    refs = grep(f'{symbol.name}')
\`\`\`

### Precise Edits
\`\`\`python
if has_serena():
    insert_after_symbol('UserService.login', new_code)
else:
    # Fall back to Edit tool with text matching
    edit_file(path, old_text, new_text)
\`\`\`
\`\`\`

### Task 5: Update Documentation

**File:** `skills/reflective-implementation/README.md`

Add section:

```markdown
## Optional Enhancements

### Serena Integration (Recommended for Large Codebases)

Serena provides semantic code operations for enhanced performance:
- **10x faster** codebase analysis in planning phase
- **Symbol-level editing** (more precise than text matching)
- **Better token efficiency** (only reads relevant symbols)

**Installation:**
```bash
# Install Serena MCP server
# See: https://github.com/oraios/serena
```

**Usage:**
Automatically detected and used when available. The skill works fully without Serena but benefits significantly from it on large codebases (>10k LOC).

**When it helps most:**
- Large monorepos
- Complex dependency graphs
- Refactoring tasks
- Performance-sensitive workflows
```

### Task 6: Update Main README

**File:** `README.md`

Update reflective-implementation entry:

```markdown
- **reflective-implementation** - Transparent AI implementation with multi-agent verification (planning → implementation → verification, 5 layers of explanation). Optional Serena MCP integration for semantic code operations.
```

## Testing Strategy

### Test 1: Without Serena
Verify graceful degradation:
- Use skill without Serena installed
- Confirm falls back to Glob/Grep/Read/Edit
- All functionality works

### Test 2: With Serena
Verify enhancement:
- Install Serena MCP server
- Use skill on codebase
- Confirm uses semantic operations
- Measure token savings

### Test 3: Mixed Environment
Verify detection:
- Serena available then becomes unavailable
- Skill switches to fallback mode
- No errors

## Benefits Summary

**Performance:**
- Planning phase: 5-10x faster (symbol search vs full file reads)
- Implementation phase: More precise edits (fewer errors)
- Verification phase: Faster analysis (symbol-level inspection)

**Token Efficiency:**
- Read only relevant symbols (not entire files)
- Significant savings on large codebases

**Code Quality:**
- Symbol-level edits less fragile than text matching
- Better understanding of dependencies
- More accurate refactoring

## Migration Path

1. **Phase 1:** Add Serena detection and fallback logic
2. **Phase 2:** Enhance planning phase with symbol operations
3. **Phase 3:** Enhance implementation phase with precise edits
4. **Phase 4:** Enhance verification phase with symbol analysis
5. **Phase 5:** Update documentation and examples

**Timeline:** 1-2 days
**Backward compatibility:** 100% (graceful degradation)
**Risk:** Low (optional enhancement)

## Example Usage Comparison

### Without Serena
```
Planning:
  Read file: src/services/user.ts (500 lines, 15k tokens)
  Read file: src/controllers/auth.ts (400 lines, 12k tokens)
  Total: 27k tokens

Implementation:
  Edit via text matching (fragile if code changes)

Verification:
  Read full files again for analysis
```

### With Serena
```
Planning:
  find_symbol('UserService') (50 tokens)
  find_referencing_symbols('UserService') (200 tokens)
  Total: 250 tokens (98% reduction)

Implementation:
  insert_after_symbol('UserService.login', code) (precise, robust)

Verification:
  Symbol-level inspection (only relevant code)
```

## Next Steps

1. ✅ Document integration plan (this file)
2. ⏳ Implement Task 1-6
3. ⏳ Test without Serena (graceful degradation)
4. ⏳ Test with Serena (enhancement validation)
5. ⏳ Update documentation
6. ⏳ Commit and push

## References

- Serena GitHub: https://github.com/oraios/serena
- MCP Protocol: https://modelcontextprotocol.io/
- Superpowers: https://github.com/obra/superpowers
