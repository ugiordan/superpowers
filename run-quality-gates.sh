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
run_gate "timeout-test" "sleep 1 && echo completed" "true" "3"

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
