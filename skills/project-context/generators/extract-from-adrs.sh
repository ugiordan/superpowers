#!/bin/bash
# Extract Architectural Decision Records (ADRs) into decisions context

set -e

OUTPUT_DIR=".claude/context"
OUTPUT_FILE="$OUTPUT_DIR/decisions.md"

echo "📋 Extracting architectural decisions..."

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Start with template header
cat > "$OUTPUT_FILE" << 'EOF'
# Architectural Decisions

> Key decisions, trade-offs, and the reasoning behind them

*Auto-generated from ADRs*

## About This Document

This document contains Architectural Decision Records (ADRs) - important decisions made about the project's architecture, technology choices, and design patterns.

---

EOF

# Common ADR directory locations
ADR_DIRS=(
  "docs/adr"
  "docs/adrs"
  "docs/decisions"
  "doc/adr"
  "doc/adrs"
  "adr"
  "adrs"
  "decisions"
)

ADR_FOUND=false

# Search for ADR directories
for adr_dir in "${ADR_DIRS[@]}"; do
  if [ -d "$adr_dir" ]; then
    echo "   Found ADRs in $adr_dir/"
    ADR_FOUND=true

    # Process each ADR file (typically numbered like 0001-*.md)
    find "$adr_dir" -name "*.md" -type f | sort | while read -r adr_file; do
      filename=$(basename "$adr_file")
      echo "   Processing $filename..."

      echo "" >> "$OUTPUT_FILE"
      echo "---" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"

      # Include the full ADR
      cat "$adr_file" >> "$OUTPUT_FILE"

      echo "" >> "$OUTPUT_FILE"
    done

    break  # Use first found ADR directory
  fi
done

# If no ADR directory found, check for decision docs
if [ "$ADR_FOUND" = false ]; then
  echo "   No ADR directory found, checking for decision documents..."

  # Check for decision-related files in docs
  if [ -d "docs" ]; then
    find docs -name "*decision*" -o -name "*choice*" | while read -r doc_file; do
      if [ -f "$doc_file" ]; then
        echo "   Processing $doc_file..."
        echo "" >> "$OUTPUT_FILE"
        echo "## From $(basename "$doc_file")" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        cat "$doc_file" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        ADR_FOUND=true
      fi
    done
  fi
fi

# Create decision index
if [ "$ADR_FOUND" = true ]; then
  echo "" >> "$OUTPUT_FILE"
  echo "---" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "## Decision Index" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "| Number | Title | Status |" >> "$OUTPUT_FILE"
  echo "|--------|-------|--------|" >> "$OUTPUT_FILE"

  # Extract decision info for index
  for adr_dir in "${ADR_DIRS[@]}"; do
    if [ -d "$adr_dir" ]; then
      find "$adr_dir" -name "*.md" -type f | sort | while read -r adr_file; do
        filename=$(basename "$adr_file")

        # Extract number (e.g., 0001 from 0001-use-markdown.md)
        number=$(echo "$filename" | grep -oE '^[0-9]+' || echo "-")

        # Extract title from first heading
        title=$(grep -m 1 "^# " "$adr_file" | sed 's/^# //' || echo "$filename")

        # Try to extract status
        status=$(grep -i "status:" "$adr_file" | head -1 | sed 's/.*status://i' | xargs || echo "Accepted")

        echo "| $number | $title | $status |" >> "$OUTPUT_FILE"
      done
      break
    fi
  done
fi

# If still no decisions found, provide guidance
if [ "$ADR_FOUND" = false ]; then
  echo "" >> "$OUTPUT_FILE"
  echo "## No ADRs Found" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "No Architectural Decision Records found in standard locations:" >> "$OUTPUT_FILE"
  for dir in "${ADR_DIRS[@]}"; do
    echo "- \`$dir/\`" >> "$OUTPUT_FILE"
  done
  echo "" >> "$OUTPUT_FILE"
  echo "### Creating ADRs" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "To create ADRs for this project:" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo '1. Create directory: `mkdir -p docs/adr`' >> "$OUTPUT_FILE"
  echo '2. Use template from: `skills/project-context/templates/decisions-template.md`' >> "$OUTPUT_FILE"
  echo '3. Re-run: `./skills/project-context/generators/extract-from-adrs.sh`' >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# Add footer
echo "" >> "$OUTPUT_FILE"
echo "---" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "*To update: Run \`./skills/project-context/generators/extract-from-adrs.sh\`*" >> "$OUTPUT_FILE"

if [ "$ADR_FOUND" = true ]; then
  echo "✅ Decision context written to $OUTPUT_FILE"
else
  echo "⚠️  No ADRs found. Created template guidance in $OUTPUT_FILE"
fi
