#!/bin/bash
# Extract coding conventions from CONTRIBUTING.md and config files

set -e

OUTPUT_DIR=".claude/context"
OUTPUT_FILE="$OUTPUT_DIR/conventions.md"

echo "📝 Extracting coding conventions..."

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Start with template header
cat > "$OUTPUT_FILE" << 'EOF'
# Coding Conventions

> Coding standards, patterns, and style guidelines

*Auto-generated from project configuration*

EOF

# Extract from CONTRIBUTING.md
if [ -f "CONTRIBUTING.md" ]; then
  echo "   Processing CONTRIBUTING.md..."
  echo "" >> "$OUTPUT_FILE"
  echo "## Contributing Guidelines" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  cat "CONTRIBUTING.md" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# Extract from CODE_OF_CONDUCT.md style sections
if [ -f "docs/style-guide.md" ] || [ -f "STYLE_GUIDE.md" ]; then
  echo "   Processing style guide..."
  for file in "docs/style-guide.md" "STYLE_GUIDE.md"; do
    if [ -f "$file" ]; then
      echo "" >> "$OUTPUT_FILE"
      cat "$file" >> "$OUTPUT_FILE"
      break
    fi
  done
fi

# Detect linter/formatter configurations
echo "" >> "$OUTPUT_FILE"
echo "## Automated Style Enforcement" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# ESLint (JavaScript/TypeScript)
if [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ] || [ -f "eslint.config.js" ]; then
  echo "### ESLint Configuration" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "Linting configured via: " >> "$OUTPUT_FILE"

  for file in .eslintrc.js .eslintrc.json eslint.config.js; do
    if [ -f "$file" ]; then
      echo "- \`$file\`" >> "$OUTPUT_FILE"
    fi
  done

  echo "" >> "$OUTPUT_FILE"
  echo "Run with: \`npm run lint\`" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# Prettier (JavaScript/TypeScript)
if [ -f ".prettierrc" ] || [ -f ".prettierrc.json" ] || [ -f "prettier.config.js" ]; then
  echo "### Prettier Configuration" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "Code formatting configured. Run with: \`npm run format\`" >> "$OUTPUT_FILE"

  if [ -f ".prettierrc" ]; then
    echo "" >> "$OUTPUT_FILE"
    echo '```json' >> "$OUTPUT_FILE"
    cat .prettierrc >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
  fi

  echo "" >> "$OUTPUT_FILE"
fi

# Flake8 (Python)
if [ -f ".flake8" ] || [ -f "setup.cfg" ]; then
  echo "### Flake8 Configuration (Python)" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "Linting configured. Run with: \`flake8 .\`" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# Black (Python)
if [ -f "pyproject.toml" ]; then
  if grep -q "black" "pyproject.toml" 2>/dev/null; then
    echo "### Black Configuration (Python)" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "Code formatting via Black. Run with: \`black .\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
  fi
fi

# Rustfmt (Rust)
if [ -f "rustfmt.toml" ] || [ -f ".rustfmt.toml" ]; then
  echo "### Rustfmt Configuration" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "Code formatting via rustfmt. Run with: \`cargo fmt\`" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# Clippy (Rust)
if [ -f "Cargo.toml" ]; then
  echo "### Clippy Configuration (Rust)" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "Linting via Clippy. Run with: \`cargo clippy\`" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# EditorConfig
if [ -f ".editorconfig" ]; then
  echo "### EditorConfig" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo '```ini' >> "$OUTPUT_FILE"
  cat .editorconfig >> "$OUTPUT_FILE"
  echo '```' >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# Detect naming conventions from code
echo "## Naming Conventions" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if [ -f "package.json" ]; then
  echo "### JavaScript/TypeScript" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

  # Check if using TypeScript
  if grep -q "typescript" package.json 2>/dev/null; then
    echo "- TypeScript enabled" >> "$OUTPUT_FILE"

    if [ -f "tsconfig.json" ]; then
      echo "- Configuration: \`tsconfig.json\`" >> "$OUTPUT_FILE"
    fi
  fi

  echo "" >> "$OUTPUT_FILE"
  echo "**File naming:**" >> "$OUTPUT_FILE"

  # Detect file naming patterns
  if find src -name "*.component.ts" 2>/dev/null | grep -q .; then
    echo "- Components: \`*.component.ts\`" >> "$OUTPUT_FILE"
  fi

  if find src -name "*.service.ts" 2>/dev/null | grep -q .; then
    echo "- Services: \`*.service.ts\`" >> "$OUTPUT_FILE"
  fi

  if find src -name "*.test.ts" -o -name "*.spec.ts" 2>/dev/null | grep -q .; then
    echo "- Tests: \`*.test.ts\` or \`*.spec.ts\`" >> "$OUTPUT_FILE"
  fi

  echo "" >> "$OUTPUT_FILE"
fi

if [ -f "Cargo.toml" ]; then
  echo "### Rust" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "- Module files: \`mod.rs\`" >> "$OUTPUT_FILE"
  echo "- Library entry: \`lib.rs\`" >> "$OUTPUT_FILE"
  echo "- Binary entry: \`main.rs\`" >> "$OUTPUT_FILE"
  echo "- Snake_case for files and modules" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# Git conventions
if [ -f ".gitignore" ]; then
  echo "## Git Conventions" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

  # Check for conventional commits
  if [ -f "commitlint.config.js" ] || grep -q "conventional" package.json 2>/dev/null; then
    echo "### Commit Messages" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "Using Conventional Commits:" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    echo "type(scope): subject" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "Types: feat, fix, docs, style, refactor, test, chore" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
  fi

  # Branch naming
  if [ -d ".github" ]; then
    echo "### Branch Naming" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "Common patterns:" >> "$OUTPUT_FILE"
    echo "- \`feature/description\`" >> "$OUTPUT_FILE"
    echo "- \`fix/description\`" >> "$OUTPUT_FILE"
    echo "- \`docs/description\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
  fi
fi

# Code organization
echo "## Code Organization" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Detect common patterns
if [ -d "src" ]; then
  echo "### Source Structure" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "Main source directory: \`src/\`" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

  # List top-level directories
  echo "Key directories:" >> "$OUTPUT_FILE"
  find src -maxdepth 1 -type d ! -path src | while read -r dir; do
    echo "- \`$(basename "$dir")/\`" >> "$OUTPUT_FILE"
  done
  echo "" >> "$OUTPUT_FILE"
fi

# Add footer
echo "---" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "*To update: Run \`./skills/project-context/generators/extract-conventions.sh\`*" >> "$OUTPUT_FILE"

echo "✅ Conventions context written to $OUTPUT_FILE"
