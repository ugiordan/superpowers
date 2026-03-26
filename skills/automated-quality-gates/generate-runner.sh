#!/bin/bash
# Generate run-quality-gates.sh from .claude/quality-gates.yml

set -e

CONFIG_FILE=".claude/quality-gates.yml"
OUTPUT_FILE="run-quality-gates.sh"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Configuration file not found: $CONFIG_FILE"
  echo "   Create it first or use a template from:"
  echo "   skills/automated-quality-gates/SKILL.md"
  exit 1
fi

echo "📝 Generating quality gates runner from $CONFIG_FILE..."

# Check if yq is available for YAML parsing
if ! command -v yq &> /dev/null; then
  echo "⚠️  yq not found. Install with: brew install yq (macOS) or https://github.com/mikefarah/yq"
  echo "   Falling back to template-based generation..."

  # Simple template fallback
  cat > "$OUTPUT_FILE" << 'TEMPLATE_EOF'
#!/bin/bash
# run-quality-gates.sh - Auto-generated quality gates runner
# Regenerate with: ./skills/automated-quality-gates/generate-runner.sh

set -e

FAILED_GATES=()
PASSED_GATES=()
WARNED_GATES=()

echo "🚦 Running Quality Gates..."
echo

# Cross-platform timeout function
run_with_timeout() {
  local timeout_seconds=$1
  shift
  local command="$@"

  # Check if GNU timeout is available
  if command -v timeout &> /dev/null && timeout --version 2>&1 | grep -q "GNU"; then
    timeout "$timeout_seconds" bash -c "$command"
  # macOS fallback using perl
  elif command -v perl &> /dev/null; then
    perl -e "alarm $timeout_seconds; exec @ARGV" bash -c "$command"
  else
    # No timeout available, run without timeout
    bash -c "$command"
  fi
}

run_gate() {
  local name=$1
  local command=$2
  local required=$3
  local timeout=${4:-300}

  echo "▶️  Running: $name"
  echo "   Command: $command"

  if run_with_timeout "$timeout" "$command" > /tmp/gate-$name.log 2>&1; then
    echo "   ✅ PASSED"
    PASSED_GATES+=("$name")
  else
    echo "   ❌ FAILED"
    echo "   Output:"
    cat /tmp/gate-$name.log | head -20

    if [ "$required" = "true" ]; then
      FAILED_GATES+=("$name")
    else
      echo "   ⚠️  Warning only (not required)"
      WARNED_GATES+=("$name")
    fi
  fi
  echo
}

# Auto-detect and run common quality gates
if [ -f "package.json" ]; then
  # JavaScript/TypeScript project
  if grep -q '"lint"' package.json 2>/dev/null; then
    run_gate "Lint" "npm run lint" "true" "60"
  fi

  if grep -q '"test"' package.json 2>/dev/null; then
    run_gate "Tests" "npm test" "true" "300"
  fi

  if grep -q '"build"' package.json 2>/dev/null; then
    run_gate "Build" "npm run build" "true" "180"
  fi

  if command -v npm &> /dev/null; then
    run_gate "Security Audit" "npm audit --audit-level=high" "true" "60"
  fi

elif [ -f "Cargo.toml" ]; then
  # Rust project
  run_gate "Clippy" "cargo clippy -- -D warnings" "true" "120"
  run_gate "Tests" "cargo test" "true" "300"
  run_gate "Build" "cargo build" "true" "180"

  if command -v cargo-audit &> /dev/null; then
    run_gate "Security Audit" "cargo audit" "true" "60"
  fi

elif [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
  # Python project
  if command -v flake8 &> /dev/null; then
    run_gate "Lint" "flake8 ." "true" "60"
  fi

  if command -v pytest &> /dev/null; then
    run_gate "Tests" "pytest" "true" "300"
  fi

  if command -v safety &> /dev/null; then
    run_gate "Security Check" "safety check" "true" "60"
  fi

elif [ -f "go.mod" ]; then
  # Go project
  if command -v golangci-lint &> /dev/null; then
    run_gate "Lint" "golangci-lint run" "true" "120"
  fi

  run_gate "Tests" "go test ./..." "true" "300"
  run_gate "Build" "go build ./..." "true" "180"

else
  echo "⚠️  No recognized project type found"
  echo "   Create .claude/quality-gates.yml for custom configuration"
  exit 1
fi

# Report results
echo "================================================"
echo "🚦 Quality Gates Summary"
echo "================================================"
echo "✅ Passed: ${#PASSED_GATES[@]}"
echo "❌ Failed: ${#FAILED_GATES[@]}"
echo "⚠️  Warnings: ${#WARNED_GATES[@]}"
echo

if [ ${#FAILED_GATES[@]} -gt 0 ]; then
  echo "❌ FAILED REQUIRED GATES:"
  for gate in "${FAILED_GATES[@]}"; do
    echo "   • $gate"
  done
  echo
  echo "Fix failures and re-run: ./run-quality-gates.sh"
  exit 1
fi

echo "✅ All required quality gates passed!"
exit 0
TEMPLATE_EOF

  chmod +x "$OUTPUT_FILE"
  echo "✅ Generated $OUTPUT_FILE (auto-detect mode)"
  echo "   Run with: ./$OUTPUT_FILE"
  exit 0
fi

# Full generation with yq
echo "   Using yq to parse configuration..."

# Generate runner script with yq
cat > "$OUTPUT_FILE" << 'RUNNER_HEADER'
#!/bin/bash
# run-quality-gates.sh - Auto-generated from .claude/quality-gates.yml
# Regenerate with: ./skills/automated-quality-gates/generate-runner.sh

set -e

FAILED_GATES=()
PASSED_GATES=()
WARNED_GATES=()

echo "🚦 Running Quality Gates..."
echo

# Cross-platform timeout function
run_with_timeout() {
  local timeout_seconds=$1
  shift
  local command="$@"

  # Check if GNU timeout is available
  if command -v timeout &> /dev/null && timeout --version 2>&1 | grep -q "GNU"; then
    timeout "$timeout_seconds" bash -c "$command"
  # macOS fallback using perl
  elif command -v perl &> /dev/null; then
    perl -e "alarm $timeout_seconds; exec @ARGV" bash -c "$command"
  else
    # No timeout available, run without timeout
    bash -c "$command"
  fi
}

run_gate() {
  local name=$1
  local command=$2
  local required=$3
  local timeout=${4:-300}

  echo "▶️  Running: $name"
  echo "   Command: $command"

  if run_with_timeout "$timeout" "$command" > /tmp/gate-$name.log 2>&1; then
    echo "   ✅ PASSED"
    PASSED_GATES+=("$name")
  else
    echo "   ❌ FAILED"
    echo "   Output:"
    cat /tmp/gate-$name.log | head -20

    if [ "$required" = "true" ]; then
      FAILED_GATES+=("$name")
    else
      echo "   ⚠️  Warning only (not required)"
      WARNED_GATES+=("$name")
    fi
  fi
  echo
}

# Gates from configuration
RUNNER_HEADER

# Parse gates from YAML and add to script
# Escape double quotes in commands and wrap in double quotes
yq eval '.gates | to_entries | .[] |
  "run_gate \"" + .key + "\" \"" +
  (.value.command | sub("\""; "\\\""; "g")) +
  "\" \"" + (.value.required // true | tostring) +
  "\" \"" + (.value.timeout // 300 | tostring) + "\""' "$CONFIG_FILE" >> "$OUTPUT_FILE"

# Add footer
cat >> "$OUTPUT_FILE" << 'RUNNER_FOOTER'

# Report results
echo "================================================"
echo "🚦 Quality Gates Summary"
echo "================================================"
echo "✅ Passed: ${#PASSED_GATES[@]}"
echo "❌ Failed: ${#FAILED_GATES[@]}"
echo "⚠️  Warnings: ${#WARNED_GATES[@]}"
echo

if [ ${#FAILED_GATES[@]} -gt 0 ]; then
  echo "❌ FAILED REQUIRED GATES:"
  for gate in "${FAILED_GATES[@]}"; do
    echo "   • $gate"
  done
  echo
  echo "Fix failures and re-run: ./run-quality-gates.sh"
  exit 1
fi

echo "✅ All required quality gates passed!"
exit 0
RUNNER_FOOTER

chmod +x "$OUTPUT_FILE"
echo "✅ Generated $OUTPUT_FILE"
echo "   Run with: ./$OUTPUT_FILE"
