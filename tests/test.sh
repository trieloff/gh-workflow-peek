#!/usr/bin/env bash
#
# Test suite for gh-workflow-peek
#

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
test_start() {
    local test_name="$1"
    printf "Testing %s... " "$test_name"
    ((TESTS_RUN++))
}

test_pass() {
    echo -e "${GREEN}PASS${NC}"
    ((TESTS_PASSED++))
}

test_fail() {
    local reason="$1"
    echo -e "${RED}FAIL${NC}"
    echo "  Reason: $reason"
    ((TESTS_FAILED++))
}

# Test 1: Script exists and is executable
test_start "script exists and is executable"
if [[ -f "gh-workflow-peek" && -x "gh-workflow-peek" ]]; then
    test_pass
else
    test_fail "Script not found or not executable"
fi

# Test 2: Script passes shellcheck
test_start "shellcheck validation"
if command -v shellcheck &> /dev/null; then
    if shellcheck gh-workflow-peek; then
        test_pass
    else
        test_fail "Shellcheck found issues"
    fi
else
    echo "SKIP (shellcheck not installed)"
fi

# Test 3: Help flag works
test_start "--help flag"
# Check if gh is available before running
if ! command -v gh &> /dev/null; then
    echo "SKIP (gh not available)"
elif ./gh-workflow-peek --help &> /dev/null; then
    test_pass
else
    test_fail "Help flag returned non-zero exit code"
fi

# Test 4: Version flag works
test_start "--version flag"
if ! command -v gh &> /dev/null; then
    echo "SKIP (gh not available)"
elif output=$(./gh-workflow-peek --version 2>&1); then
    if [[ "$output" =~ "gh-workflow-peek version" ]]; then
        test_pass
    else
        test_fail "Version output doesn't match expected format"
    fi
else
    test_fail "Version flag returned non-zero exit code"
fi

# Test 5: Check for required text in help output
test_start "help output contains required sections"
if ! command -v gh &> /dev/null; then
    echo "SKIP (gh not available)"
else
    help_output=$(./gh-workflow-peek --help 2>&1)
required_sections=("USAGE:" "DESCRIPTION:" "OPTIONS:" "SEVERITY LEVELS" "EXAMPLES:")
all_found=true
for section in "${required_sections[@]}"; do
    if ! echo "$help_output" | grep -q "$section"; then
        all_found=false
        break
    fi
done
    if $all_found; then
        test_pass
    else
        test_fail "Help output missing required sections"
    fi
fi

# Test 6: Script handles missing dependencies gracefully
test_start "dependency check messaging"
# We can't easily test actual missing dependencies, but we can verify the function exists
if grep -q "check_dependencies" gh-workflow-peek; then
    test_pass
else
    test_fail "Dependency check function not found"
fi

# Test 7: Verify shebang is portable
test_start "portable shebang"
if head -n 1 gh-workflow-peek | grep -q "#!/usr/bin/env bash"; then
    test_pass
else
    test_fail "Shebang is not portable"
fi

# Test 8: Check for set -euo pipefail
test_start "error handling setup"
if grep -q "^set -euo pipefail" gh-workflow-peek; then
    test_pass
else
    test_fail "Missing 'set -euo pipefail' for proper error handling"
fi

# Test 9: Verify extension metadata
test_start "extension metadata"
if grep -q 'VERSION=' gh-workflow-peek && grep -q 'EXTENSION_NAME=' gh-workflow-peek; then
    test_pass
else
    test_fail "Missing VERSION or EXTENSION_NAME metadata"
fi

# Test 10: Check command line parsing doesn't have common issues
test_start "command line parsing safety"
# Check for proper quoting in variable assignments
if ! grep -E '\$[0-9]' gh-workflow-peek | grep -v '"' | grep -q '='; then
    test_pass
else
    test_fail "Potential unquoted variable assignment found"
fi

# Summary
echo ""
echo "Test Summary:"
echo "============="
echo "Tests run:    $TESTS_RUN"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "\n${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed!${NC}"
    exit 1
fi