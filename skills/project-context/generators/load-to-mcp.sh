#!/bin/bash
# Load project context into MCP memory server

set -e

CONTEXT_DIR=".claude/context"

echo "📤 Loading context into MCP memory server..."

if [ ! -d "$CONTEXT_DIR" ]; then
  echo "❌ Context directory not found: $CONTEXT_DIR"
  echo "   Run context generation scripts first:"
  echo "   - ./skills/project-context/generators/extract-architecture.sh"
  echo "   - ./skills/project-context/generators/extract-conventions.sh"
  echo "   etc."
  exit 1
fi

# Check if mcp-memory command is available
if ! command -v mcp-memory &> /dev/null; then
  echo "⚠️  MCP memory CLI not found"
  echo ""
  echo "This script requires the MCP memory server CLI."
  echo "Install it according to: https://github.com/anthropics/mcp-memory-server"
  echo ""
  echo "Alternative: Load context manually in Claude Code by referencing .claude/context/ files"
  exit 1
fi

# Load each context file
echo ""
echo "Loading context files..."
echo ""

for context_file in "$CONTEXT_DIR"/*.md; do
  if [ -f "$context_file" ]; then
    filename=$(basename "$context_file")
    echo "📄 Loading $filename..."

    # Load into MCP memory with appropriate namespace
    namespace=$(basename "$filename" .md)

    mcp-memory load \
      --namespace "project:$namespace" \
      --file "$context_file" \
      --metadata "source=project-context,updated=$(date +%Y-%m-%d)"

    echo "   ✅ Loaded as namespace: project:$namespace"
  fi
done

echo ""
echo "✅ All context loaded into MCP memory server"
echo ""
echo "Query in Claude Code with:"
echo "  'load architecture context'"
echo "  'load conventions context'"
echo "  'load testing patterns context'"
echo ""
