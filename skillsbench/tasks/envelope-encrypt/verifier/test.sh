#!/bin/bash
set -e

echo "=== Verifier: envelope-encrypt ==="

REF_DIR="/tmp/skillsbench-output/encrypt-oracle"
AGENT_DIR="/tmp/skillsbench-output/encrypt-agent"
PASS=0
FAIL=0

for testfile in test1.enc test2.enc test3.enc; do
    echo -n "Verifying $testfile ... "

    REF="$REF_DIR/$testfile"
    AGENT="$AGENT_DIR/$testfile"

    if [ ! -f "$AGENT" ]; then
        echo "FAIL (file not found)"
        FAIL=$((FAIL + 1))
        continue
    fi

    # Check 3-line format
    REF_LINES=$(wc -l < "$REF")
    AGENT_LINES=$(wc -l < "$AGENT")
    if [ "$AGENT_LINES" -ne 3 ]; then
        echo "FAIL (expected 3 lines, got $AGENT_LINES)"
        FAIL=$((FAIL + 1))
        continue
    fi

    # Check all lines are valid base64
    B64_OK=1
    while IFS= read -r line; do
        if ! echo "$line" | base64 -d >/dev/null 2>&1; then
            B64_OK=0
            break
        fi
    done < "$AGENT"
    if [ "$B64_OK" -ne 1 ]; then
        echo "FAIL (invalid base64)"
        FAIL=$((FAIL + 1))
        continue
    fi

    # For test3, verify it differs from oracle (different nonce)
    if [ "$testfile" = "test3.enc" ]; then
        if diff -q "$REF" "$AGENT" >/dev/null 2>&1; then
            echo "FAIL (should differ due to random nonce, but identical)"
            FAIL=$((FAIL + 1))
            continue
        fi
    fi

    echo "PASS"
    PASS=$((PASS + 1))
done

echo ""
echo "=== Verifier results: $PASS passed, $FAIL failed ==="

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
