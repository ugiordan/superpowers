#!/bin/bash
# Extract architecture information from README and docs

set -e

OUTPUT_DIR=".claude/context"
OUTPUT_FILE="$OUTPUT_DIR/architecture.md"

echo "🏗️  Extracting architecture information..."

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Start with template header
cat > "$OUTPUT_FILE" << 'EOF'
# Architecture

> System design, components, and data flow

*Auto-generated from project documentation*

EOF

# Function to extract sections from markdown files
extract_section() {
  local file=$1
  local section=$2

  if [ -f "$file" ]; then
    # Try to find the section and extract content
    awk -v section="$section" '
      BEGIN { in_section=0; header_level=0 }
      /^#+ / {
        current_level = gsub(/#/, "", $1)
        if (tolower($0) ~ tolower(section)) {
          in_section=1
          header_level=current_level
          next
        } else if (in_section && current_level <= header_level) {
          exit
        }
      }
      in_section { print }
    ' "$file"
  fi
}

# Extract from README.md
if [ -f "README.md" ]; then
  echo "   Processing README.md..."

  echo "" >> "$OUTPUT_FILE"
  echo "## Overview" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

  # Try to get project description (usually first paragraph after title)
  awk '/^# / { p=1; next } p && /^[^#]/ { print; if (/^$/) exit }' README.md >> "$OUTPUT_FILE"

  # Look for architecture section
  arch_content=$(extract_section "README.md" "architecture")
  if [ -n "$arch_content" ]; then
    echo "" >> "$OUTPUT_FILE"
    echo "## System Architecture" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "$arch_content" >> "$OUTPUT_FILE"
  fi

  # Look for components section
  components=$(extract_section "README.md" "components")
  if [ -n "$components" ]; then
    echo "" >> "$OUTPUT_FILE"
    echo "## Components" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "$components" >> "$OUTPUT_FILE"
  fi
fi

# Extract from docs/architecture.md or docs/ARCHITECTURE.md
for arch_file in "docs/architecture.md" "docs/ARCHITECTURE.md" "ARCHITECTURE.md"; do
  if [ -f "$arch_file" ]; then
    echo "   Processing $arch_file..."
    echo "" >> "$OUTPUT_FILE"
    cat "$arch_file" >> "$OUTPUT_FILE"
    break
  fi
done

# Extract from docs/design/ directory
if [ -d "docs/design" ]; then
  echo "   Processing docs/design/..."

  for design_file in docs/design/*.md; do
    if [ -f "$design_file" ]; then
      filename=$(basename "$design_file")
      echo "" >> "$OUTPUT_FILE"
      echo "## From $filename" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
      cat "$design_file" >> "$OUTPUT_FILE"
    fi
  done
fi

# Try to detect common architecture patterns from code
echo "" >> "$OUTPUT_FILE"
echo "## Detected Structure" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Detect directory structure
if [ -d "src" ] || [ -d "lib" ]; then
  echo "### Directory Structure" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo '```' >> "$OUTPUT_FILE"

  # Show first 2 levels of key directories
  for dir in src lib pkg cmd internal; do
    if [ -d "$dir" ]; then
      find "$dir" -maxdepth 2 -type d | head -20 | sort
    fi
  done >> "$OUTPUT_FILE"

  echo '```' >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# Detect common patterns
echo "### Detected Patterns" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Check for common architecture files/patterns
if [ -d "src/api" ] || [ -d "src/routes" ]; then
  echo "- **API layer**: REST/GraphQL endpoints" >> "$OUTPUT_FILE"
fi

if [ -d "src/services" ] || [ -d "src/service" ]; then
  echo "- **Service layer**: Business logic" >> "$OUTPUT_FILE"
fi

if [ -d "src/models" ] || [ -d "src/entities" ]; then
  echo "- **Data layer**: Models and entities" >> "$OUTPUT_FILE"
fi

if [ -d "src/controllers" ]; then
  echo "- **Controller pattern**: MVC architecture" >> "$OUTPUT_FILE"
fi

if [ -d "src/components" ] && [ -f "package.json" ]; then
  if grep -q "react" package.json 2>/dev/null; then
    echo "- **Component-based**: React application" >> "$OUTPUT_FILE"
  fi
fi

# Add footer
echo "" >> "$OUTPUT_FILE"
echo "---" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "*To update: Run \`./skills/project-context/generators/extract-architecture.sh\`*" >> "$OUTPUT_FILE"

echo "✅ Architecture context written to $OUTPUT_FILE"
