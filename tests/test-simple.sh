#!/usr/bin/env bash
#
# Simple test suite for gh-workflow-peek
#

echo "Running gh-workflow-peek tests..."
echo "================================"

# Test 1: Script exists and is executable
echo -n "1. Script exists and is executable... "
if [[ -f "gh-workflow-peek" && -x "gh-workflow-peek" ]]; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

# Test 2: Script passes shellcheck
echo -n "2. Shellcheck validation... "
if command -v shellcheck &> /dev/null; then
    if shellcheck gh-workflow-peek 2>/dev/null; then
        echo "PASS"
    else
        echo "FAIL"
        exit 1
    fi
else
    echo "SKIP (shellcheck not installed)"
fi

# Test 3: Shebang is portable
echo -n "3. Portable shebang... "
if head -n 1 gh-workflow-peek | grep -q "#!/usr/bin/env bash"; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

# Test 4: Error handling setup
echo -n "4. Error handling (set -euo pipefail)... "
if grep -q "^set -euo pipefail" gh-workflow-peek; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

# Test 5: Extension metadata
echo -n "5. Extension metadata (VERSION/NAME)... "
if grep -q 'VERSION=' gh-workflow-peek && grep -q 'EXTENSION_NAME=' gh-workflow-peek; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

# Test 6: Dependency check function exists
echo -n "6. Dependency check function... "
if grep -q "check_dependencies" gh-workflow-peek; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

# Test 7: Help and version flags in case statement
echo -n "7. Help and version flags defined... "
if grep -q -- "--help|-h)" gh-workflow-peek && grep -q -- "--version|-v)" gh-workflow-peek; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

echo ""
echo "All tests passed!"
exit 0