#!/bin/bash
set -e

echo "=== Verifier: envelope-decrypt ==="

REF_DIR="/tmp/skillsbench-output/decrypt-oracle"
AGENT_DIR="/tmp/skillsbench-output/decrypt-agent"
PASS=0
FAIL=0

# Tests 1-3: content should match oracle exactly
for testfile in test1.txt test2.txt test3.txt; do
    echo -n "Verifying $testfile ... "
    REF="$REF_DIR/$testfile"
    AGENT="$AGENT_DIR/$testfile"
    if [ ! -f "$AGENT" ]; then
        echo "FAIL (file not found)"
        FAIL=$((FAIL + 1))
        continue
    fi
    if diff -q "$REF" "$AGENT" >/dev/null 2>&1; then
        echo "PASS"
        PASS=$((PASS + 1))
    else
        echo "FAIL (content differs)"
        echo "  Expected: $(cat "$REF")"
        echo "  Got:      $(cat "$AGENT")"
        FAIL=$((FAIL + 1))
    fi
done

# Test 4: agent output should not exist (decrypt must fail)
echo -n "Verifying test4 (must fail) ... "
if [ -f "$AGENT_DIR/test4.txt" ]; then
    echo "FAIL (decryption succeeded with wrong context)"
    FAIL=$((FAIL + 1))
else
    echo "PASS"
    PASS=$((PASS + 1))
fi

echo ""
echo "=== Verifier results: $PASS passed, $FAIL failed ==="

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
