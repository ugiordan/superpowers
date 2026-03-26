#!/bin/bash
# Integration tests for reflective-implementation skill

# Get the directory where the skill is located
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

check_file_exists() {
    if [ -f "$1" ]; then
        echo "  PASS: $2 exists"
        PASS=$((PASS+1))
    else
        echo "  FAIL: $2 missing"
        FAIL=$((FAIL+1))
    fi
}

check_file_nonempty() {
    if [ -s "$1" ]; then
        echo "  PASS: $2 is non-empty"
        PASS=$((PASS+1))
    else
        echo "  FAIL: $2 is empty"
        FAIL=$((FAIL+1))
    fi
}

check_file_has_header() {
    if head -5 "$1" | grep -q "^# " 2>/dev/null; then
        echo "  PASS: $2 has markdown header"
        PASS=$((PASS+1))
    else
        echo "  FAIL: $2 missing markdown header"
        FAIL=$((FAIL+1))
    fi
}

echo "=== Reflective Implementation Integration Tests ==="
echo ""

# Test 1: Main skill file
echo "Test 1: Main skill file"
check_file_exists "$SKILL_DIR/SKILL.md" "SKILL.md"
check_file_nonempty "$SKILL_DIR/SKILL.md" "SKILL.md"
if head -3 "$SKILL_DIR/SKILL.md" | grep -q "^name:" 2>/dev/null; then
    echo "  PASS: SKILL.md has frontmatter"
    PASS=$((PASS+1))
else
    echo "  FAIL: SKILL.md missing frontmatter"
    FAIL=$((FAIL+1))
fi

# Test 2: Phase files
echo ""
echo "Test 2: Phase files"
for phase in planning implementation verification; do
    check_file_exists "$SKILL_DIR/phases/$phase.md" "phases/$phase.md"
    check_file_nonempty "$SKILL_DIR/phases/$phase.md" "phases/$phase.md"
    check_file_has_header "$SKILL_DIR/phases/$phase.md" "phases/$phase.md"
done

# Test 3: Agent files
echo ""
echo "Test 3: Agent files"
check_file_exists "$SKILL_DIR/agents/adversarial-reviewer.md" "adversarial-reviewer.md"
check_file_nonempty "$SKILL_DIR/agents/adversarial-reviewer.md" "adversarial-reviewer.md"
check_file_has_header "$SKILL_DIR/agents/adversarial-reviewer.md" "adversarial-reviewer.md"

for specialist in performance-analyst security-auditor correctness-verifier code-quality-reviewer; do
    check_file_exists "$SKILL_DIR/agents/specialists/$specialist.md" "specialists/$specialist.md"
    check_file_nonempty "$SKILL_DIR/agents/specialists/$specialist.md" "specialists/$specialist.md"
    check_file_has_header "$SKILL_DIR/agents/specialists/$specialist.md" "specialists/$specialist.md"
done

# Test 4: Template files
echo ""
echo "Test 4: Template files"
for layer in layer1-tldr layer2-visual layer3-reasoning layer4-technical layer5-verification; do
    check_file_exists "$SKILL_DIR/templates/$layer.md" "templates/$layer.md"
    check_file_nonempty "$SKILL_DIR/templates/$layer.md" "templates/$layer.md"
    check_file_has_header "$SKILL_DIR/templates/$layer.md" "templates/$layer.md"
done

# Test 5: Utility files
echo ""
echo "Test 5: Utility files"
for util in context-loader specialist-spawner visualization-helper serena-helper; do
    check_file_exists "$SKILL_DIR/utils/$util.md" "utils/$util.md"
    check_file_nonempty "$SKILL_DIR/utils/$util.md" "utils/$util.md"
    check_file_has_header "$SKILL_DIR/utils/$util.md" "utils/$util.md"
done

# Test 6: Documentation
echo ""
echo "Test 6: Documentation"
check_file_exists "$SKILL_DIR/README.md" "README.md"
check_file_nonempty "$SKILL_DIR/README.md" "README.md"

# Test 7: No @ references in any skill file (they burn context)
echo ""
echo "Test 7: No @ link references in skill files"
at_count=$(grep -r --include="*.md" -c "@skills/" "$SKILL_DIR" 2>/dev/null | grep -v ":0$" | wc -l | tr -d ' ')
if [ "$at_count" -eq 0 ]; then
    echo "  PASS: No @skills/ references in any .md file"
    PASS=$((PASS+1))
else
    echo "  FAIL: Found @skills/ references in $at_count files:"
    grep -r --include="*.md" -l "@skills/" "$SKILL_DIR" 2>/dev/null || true
    FAIL=$((FAIL+1))
fi

# Test 8: README file structure matches actual files
echo ""
echo "Test 8: README structure listing accuracy"
if [ -f "$SKILL_DIR/README.md" ]; then
    missing=0
    for expected_file in SKILL.md phases/planning.md phases/implementation.md phases/verification.md \
        agents/adversarial-reviewer.md agents/specialists/performance-analyst.md \
        agents/specialists/security-auditor.md agents/specialists/correctness-verifier.md \
        agents/specialists/code-quality-reviewer.md templates/layer1-tldr.md \
        templates/layer2-visual.md templates/layer3-reasoning.md templates/layer4-technical.md \
        templates/layer5-verification.md utils/context-loader.md utils/specialist-spawner.md \
        utils/visualization-helper.md utils/serena-helper.md; do
        if [ ! -f "$SKILL_DIR/$expected_file" ]; then
            echo "  FAIL: Expected file $expected_file not found"
            ((missing++))
        fi
    done
    if [ "$missing" -eq 0 ]; then
        echo "  PASS: All expected files present"
        PASS=$((PASS+1))
    else
        FAIL=$((FAIL+1))
    fi
fi

# Summary
echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ "$FAIL" -gt 0 ]; then
    echo "FAIL: $FAIL tests failed"
    exit 1
else
    echo "ALL TESTS PASSED"
fi
