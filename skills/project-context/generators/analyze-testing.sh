#!/bin/bash
# Analyze test patterns from actual test files

set -e

OUTPUT_DIR=".claude/context"
OUTPUT_FILE="$OUTPUT_DIR/testing-patterns.md"

echo "🧪 Analyzing testing patterns..."

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Start with template header
cat > "$OUTPUT_FILE" << 'EOF'
# Testing Patterns

> Test structure, fixtures, and best practices

*Auto-generated from test analysis*

EOF

# Detect test framework and patterns
TESTS_FOUND=false

# JavaScript/TypeScript
if [ -f "package.json" ]; then
  echo "   Analyzing JavaScript/TypeScript tests..."

  echo "" >> "$OUTPUT_FILE"
  echo "## Test Framework" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

  # Detect test framework
  if grep -q '"jest"' package.json 2>/dev/null; then
    echo "**Framework**: Jest" >> "$OUTPUT_FILE"
    TESTS_FOUND=true
  elif grep -q '"mocha"' package.json 2>/dev/null; then
    echo "**Framework**: Mocha" >> "$OUTPUT_FILE"
    TESTS_FOUND=true
  elif grep -q '"vitest"' package.json 2>/dev/null; then
    echo "**Framework**: Vitest" >> "$OUTPUT_FILE"
    TESTS_FOUND=true
  fi

  # Find test files
  test_files=$(find . -name "*.test.ts" -o -name "*.test.js" -o -name "*.spec.ts" -o -name "*.spec.js" 2>/dev/null | head -5)

  if [ -n "$test_files" ]; then
    echo "" >> "$OUTPUT_FILE"
    echo "**Test file pattern**: \`*.test.ts\` or \`*.spec.ts\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

    # Run tests command
    if grep -q '"test"' package.json 2>/dev/null; then
      test_cmd=$(grep '"test"' package.json | head -1 | sed 's/.*"test"[: ]*"\([^"]*\)".*/\1/')
      echo "**Run tests**: \`npm test\` (\`$test_cmd\`)" >> "$OUTPUT_FILE"
    fi

    echo "" >> "$OUTPUT_FILE"
    echo "## Test Structure" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

    # Analyze first test file for patterns
    first_test=$(echo "$test_files" | head -1)
    if [ -f "$first_test" ]; then
      echo "Example from \`$(basename "$first_test")\`:" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"

      # Check for common patterns
      if grep -q "describe(" "$first_test" 2>/dev/null; then
        echo "- Uses \`describe()\` blocks for grouping" >> "$OUTPUT_FILE"
      fi

      if grep -q "it(" "$first_test" 2>/dev/null || grep -q "test(" "$first_test" 2>/dev/null; then
        echo "- Uses \`it()\` or \`test()\` for individual tests" >> "$OUTPUT_FILE"
      fi

      if grep -q "beforeEach(" "$first_test" 2>/dev/null; then
        echo "- Uses \`beforeEach()\` for setup" >> "$OUTPUT_FILE"
      fi

      if grep -q "afterEach(" "$first_test" 2>/dev/null; then
        echo "- Uses \`afterEach()\` for cleanup" >> "$OUTPUT_FILE"
      fi

      # Show a snippet
      echo "" >> "$OUTPUT_FILE"
      echo '```typescript' >> "$OUTPUT_FILE"
      head -30 "$first_test" | tail -20 >> "$OUTPUT_FILE"
      echo '```' >> "$OUTPUT_FILE"
    fi

    echo "" >> "$OUTPUT_FILE"
    echo "## Test Categories" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

    # Detect test types
    if find . -path "*/test/unit/*" -o -path "*/tests/unit/*" 2>/dev/null | grep -q .; then
      echo "- **Unit tests**: \`tests/unit/\`" >> "$OUTPUT_FILE"
    fi

    if find . -path "*/test/integration/*" -o -path "*/tests/integration/*" 2>/dev/null | grep -q .; then
      echo "- **Integration tests**: \`tests/integration/\`" >> "$OUTPUT_FILE"
    fi

    if find . -path "*/test/e2e/*" -o -path "*/tests/e2e/*" -o -name "*.e2e.spec.ts" 2>/dev/null | grep -q .; then
      echo "- **E2E tests**: \`tests/e2e/\` or \`*.e2e.spec.ts\`" >> "$OUTPUT_FILE"
    fi

    echo "" >> "$OUTPUT_FILE"
  fi
fi

# Python
if [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
  echo "   Analyzing Python tests..."

  echo "" >> "$OUTPUT_FILE"
  echo "## Test Framework (Python)" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

  # Detect pytest
  if [ -f "pyproject.toml" ] && grep -q "pytest" pyproject.toml 2>/dev/null; then
    echo "**Framework**: pytest" >> "$OUTPUT_FILE"
    TESTS_FOUND=true
  elif [ -f "requirements.txt" ] && grep -q "pytest" requirements.txt 2>/dev/null; then
    echo "**Framework**: pytest" >> "$OUTPUT_FILE"
    TESTS_FOUND=true
  elif [ -f "requirements-dev.txt" ] && grep -q "pytest" requirements-dev.txt 2>/dev/null; then
    echo "**Framework**: pytest" >> "$OUTPUT_FILE"
    TESTS_FOUND=true
  fi

  # Find test files
  test_files=$(find . -name "test_*.py" -o -name "*_test.py" 2>/dev/null | head -5)

  if [ -n "$test_files" ]; then
    echo "" >> "$OUTPUT_FILE"
    echo "**Test file pattern**: \`test_*.py\` or \`*_test.py\`" >> "$OUTPUT_FILE"
    echo "**Run tests**: \`pytest\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

    echo "## Test Structure" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

    first_test=$(echo "$test_files" | head -1)
    if [ -f "$first_test" ]; then
      echo "Example from \`$(basename "$first_test")\`:" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
      echo '```python' >> "$OUTPUT_FILE"
      head -30 "$first_test" | tail -20 >> "$OUTPUT_FILE"
      echo '```' >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
    fi

    # Check for fixtures
    if grep -r "@pytest.fixture" . 2>/dev/null | grep -q .; then
      echo "## Fixtures" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
      echo "Uses pytest fixtures for test setup and dependency injection." >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"

      # Find conftest.py
      if [ -f "tests/conftest.py" ] || [ -f "conftest.py" ]; then
        echo "Fixtures defined in: \`conftest.py\`" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
      fi
    fi
  fi
fi

# Rust
if [ -f "Cargo.toml" ]; then
  echo "   Analyzing Rust tests..."

  echo "" >> "$OUTPUT_FILE"
  echo "## Test Framework (Rust)" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "**Framework**: Rust built-in testing" >> "$OUTPUT_FILE"
  echo "**Run tests**: \`cargo test\`" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

  # Find test modules in src
  if find src -name "*.rs" -type f 2>/dev/null | xargs grep -l "#\[test\]" > /dev/null 2>&1; then
    TESTS_FOUND=true

    echo "## Test Structure" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "Tests are typically in \`#[cfg(test)] mod tests\` blocks within source files." >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

    # Find first file with tests
    first_test=$(find src -name "*.rs" -type f -exec grep -l "#\[test\]" {} \; | head -1)
    if [ -n "$first_test" ]; then
      echo "Example from \`$(basename "$first_test")\`:" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
      echo '```rust' >> "$OUTPUT_FILE"
      # Extract test module
      awk '/#\[cfg\(test\)\]/,/^}/' "$first_test" | head -30 >> "$OUTPUT_FILE"
      echo '```' >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
    fi
  fi

  # Check for integration tests
  if [ -d "tests" ]; then
    echo "## Integration Tests" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "Integration tests in \`tests/\` directory." >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
  fi
fi

# Go
if [ -f "go.mod" ]; then
  echo "   Analyzing Go tests..."

  echo "" >> "$OUTPUT_FILE"
  echo "## Test Framework (Go)" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "**Framework**: Go built-in testing" >> "$OUTPUT_FILE"
  echo "**Run tests**: \`go test ./...\`" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

  # Find test files
  test_files=$(find . -name "*_test.go" 2>/dev/null | head -5)

  if [ -n "$test_files" ]; then
    TESTS_FOUND=true

    echo "**Test file pattern**: \`*_test.go\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

    first_test=$(echo "$test_files" | head -1)
    if [ -f "$first_test" ]; then
      echo "Example from \`$(basename "$first_test")\`:" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
      echo '```go' >> "$OUTPUT_FILE"
      head -30 "$first_test" | tail -20 >> "$OUTPUT_FILE"
      echo '```' >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
    fi
  fi
fi

# Coverage configuration
echo "## Test Coverage" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if [ -f "package.json" ] && grep -q "coverage" package.json 2>/dev/null; then
  echo "**JavaScript/TypeScript**:" >> "$OUTPUT_FILE"
  echo "- Run coverage: \`npm run test:coverage\` or \`npm test -- --coverage\`" >> "$OUTPUT_FILE"

  # Check for coverage thresholds
  if [ -f "jest.config.js" ] || [ -f "jest.config.ts" ]; then
    echo "- Configuration: \`jest.config.js\`" >> "$OUTPUT_FILE"
  fi

  echo "" >> "$OUTPUT_FILE"
elif [ -f "pytest.ini" ] || ([ -f "pyproject.toml" ] && grep -q "pytest" pyproject.toml 2>/dev/null); then
  echo "**Python**:" >> "$OUTPUT_FILE"
  echo "- Run coverage: \`pytest --cov\`" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
elif [ -f "Cargo.toml" ]; then
  echo "**Rust**:" >> "$OUTPUT_FILE"
  echo "- Run coverage: \`cargo tarpaulin\` (requires cargo-tarpaulin)" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# Mocking patterns
echo "## Mocking and Test Doubles" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if [ -f "package.json" ]; then
  if grep -q '"jest"' package.json 2>/dev/null; then
    echo "**JavaScript/TypeScript (Jest)**:" >> "$OUTPUT_FILE"
    echo "- Mock functions: \`jest.fn()\`" >> "$OUTPUT_FILE"
    echo "- Mock modules: \`jest.mock('./module')\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
  fi
fi

if grep -r "from unittest.mock import" . 2>/dev/null | grep -q .; then
  echo "**Python**:" >> "$OUTPUT_FILE"
  echo "- Uses \`unittest.mock\` for mocking" >> "$OUTPUT_FILE"
  echo "- Common: \`@patch\`, \`MagicMock\`" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# If no tests found
if [ "$TESTS_FOUND" = false ]; then
  echo "" >> "$OUTPUT_FILE"
  echo "## No Tests Found" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "No test files detected in standard locations." >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "Consider adding tests using:" >> "$OUTPUT_FILE"
  echo "- JavaScript/TypeScript: Jest, Vitest, or Mocha" >> "$OUTPUT_FILE"
  echo "- Python: pytest or unittest" >> "$OUTPUT_FILE"
  echo "- Rust: Built-in \`#[test]\` modules" >> "$OUTPUT_FILE"
  echo "- Go: Built-in \`*_test.go\` files" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# Add footer
echo "---" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "*To update: Run \`./skills/project-context/generators/analyze-testing.sh\`*" >> "$OUTPUT_FILE"

if [ "$TESTS_FOUND" = true ]; then
  echo "✅ Testing patterns context written to $OUTPUT_FILE"
else
  echo "⚠️  No tests found. Created guidance in $OUTPUT_FILE"
fi
