# Serena Helper Utility

## Purpose
Optional enhancement: use Serena MCP server for semantic code operations when available.

## What is Serena?

[Serena](https://github.com/oraios/serena) provides symbol-level code operations via MCP instead of text-based manipulation. It supports 30+ languages through LSP.

## Detection

Check if Serena MCP tools are available in the current session. Look for tools like `find_symbol`, `find_referencing_symbols`, `insert_after_symbol`, `replace_symbol`. If any are missing, fall back to traditional tools.

## When It Helps

- **Planning phase**: Find symbols and their references without reading entire files. Useful for understanding dependencies in large codebases.
- **Implementation phase**: Edit code at the symbol level (insert after a method, replace a function body) instead of text matching. More robust against formatting changes.
- **Verification phase**: Analyze specific symbols without reading full files. Useful for specialists reviewing targeted code sections.

## Graceful Degradation

The skill works fully without Serena. All operations have equivalent fallbacks:

| With Serena | Without Serena |
|-------------|----------------|
| `find_symbol('UserService')` | `Grep` for class/function definition |
| `find_referencing_symbols(symbol)` | `Grep` for usage across codebase |
| `insert_after_symbol(name, code)` | `Edit` tool with text matching |
| `replace_symbol(name, code)` | `Edit` tool with text matching |

Both approaches produce correct results. Serena is faster on large codebases but not required.

## Installation

See https://github.com/oraios/serena for setup instructions.
