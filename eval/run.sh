#!/bin/bash
set -e
PASS=0; FAIL=0; TOTAL=0

log_pass() { echo "  [PASS] $1"; PASS=$((PASS+1)); TOTAL=$((TOTAL+1)); }
log_fail() { echo "  [FAIL] $1 - $2"; FAIL=$((FAIL+1)); TOTAL=$((TOTAL+1)); }

echo "============================================"
echo "  KMS Skills Evaluation"
echo "============================================"

# --- Smoke Tests (no KMS credentials required) ---
echo ""
echo "--- Smoke: binary exists and executes ---"

for tool in envelope-encrypt envelope-decrypt; do
    TOTAL=$((TOTAL+1))
    if ! which $tool >/dev/null 2>&1; then
        log_fail "$tool" "binary not found"
    elif ! $tool --help >/dev/null 2>&1; then
        log_fail "$tool" "--help failed"
    else
        log_pass "$tool --help works"
    fi
done

echo ""
echo "--- Smoke: subcommand registration ---"

ENCRYPT_HELP=$(envelope-encrypt encrypt --help 2>&1)
DECRYPT_HELP=$(envelope-decrypt decrypt --help 2>&1)

for flag in "--key-id" "--data" "--in-file" "--out-file" "--encryption-context" "--key-spec" "--number-of-bytes"; do
    TOTAL=$((TOTAL+1))
    if echo "$ENCRYPT_HELP" | grep -q "$flag"; then
        log_pass "encrypt has flag $flag"
    else
        log_fail "encrypt flag $flag" "not found in --help"
    fi
done

for flag in "--data" "--in-file" "--out-file" "--encryption-context"; do
    TOTAL=$((TOTAL+1))
    if echo "$DECRYPT_HELP" | grep -q "$flag"; then
        log_pass "decrypt has flag $flag"
    else
        log_fail "decrypt flag $flag" "not found in --help"
    fi
done

echo ""
echo "--- Smoke: default credential chain ---"

TOTAL=$((TOTAL+1))
CRED_ERR=$(envelope-encrypt encrypt --key-id test-key --data "test" --out-file - 2>&1 || true)
if echo "$CRED_ERR" | grep -qE "credential|region|NoCredential|ECS metadata"; then
    log_pass "credential error message correct (no AKSK configured)"
else
    log_fail "credential error" "unexpected: $CRED_ERR"
fi

echo ""
echo "--- Smoke: argument validation ---"

# Missing required key-id
TOTAL=$((TOTAL+1))
if envelope-encrypt encrypt 2>&1 | grep -q "required flag.*key-id"; then
    log_pass "encrypt requires --key-id"
else
    log_fail "encrypt requires --key-id" "did not reject"
fi

# Encrypt: --in-file and --data conflict
TOTAL=$((TOTAL+1))
CONFLICT=$(envelope-encrypt encrypt --key-id x --in-file /tmp/x --data "x" 2>&1 || true)
if echo "$CONFLICT" | grep -qi "mutually exclusive"; then
    log_pass "encrypt rejects --in-file + --data"
else
    log_fail "encrypt mutually exclusive" "did not reject: $CONFLICT"
fi

# Encrypt: missing input
TOTAL=$((TOTAL+1))
MISSING=$(envelope-encrypt encrypt --key-id x 2>&1 || true)
if echo "$MISSING" | grep -qi "either --data or --in-file"; then
    log_pass "encrypt rejects missing input"
else
    log_fail "encrypt missing input" "did not reject: $MISSING"
fi

# Decrypt: --in-file and --data conflict
TOTAL=$((TOTAL+1))
CONFLICT=$(envelope-decrypt decrypt --in-file /tmp/x --data "x" 2>&1 || true)
if echo "$CONFLICT" | grep -qi "mutually exclusive"; then
    log_pass "decrypt rejects --in-file + --data"
else
    log_fail "decrypt mutually exclusive" "did not reject: $CONFLICT"
fi

# Decrypt: invalid format
TOTAL=$((TOTAL+1))
FORMAT=$(echo "only_one_line" | envelope-decrypt decrypt --in-file - 2>&1 || true)
if echo "$FORMAT" | grep -qi "invalid envelope format"; then
    log_pass "decrypt rejects invalid 3-line format"
else
    log_fail "decrypt invalid format" "did not reject: $FORMAT"
fi

echo ""
echo "--- Smoke: encryption context JSON parsing ---"
TOTAL=$((TOTAL+1))
CTX_ERR=$(envelope-encrypt encrypt --key-id x --data x --encryption-context "badjson" 2>&1 || true)
if echo "$CTX_ERR" | grep -qi "parse.*encryption"; then
    log_pass "encrypt rejects invalid JSON context"
else
    log_fail "invalid JSON context" "did not reject: $CTX_ERR"
fi

TOTAL=$((TOTAL+1))
CTX_OK=$(envelope-encrypt encrypt --key-id x --data x --encryption-context '{"key":"value"}' 2>&1 || true)
if echo "$CTX_OK" | grep -q "credential\|region\|NoCredential"; then
    log_pass "encrypt accepts valid JSON context (fails on credential, as expected)"
else
    log_fail "valid JSON context" "unexpected: $CTX_OK"
fi

# --- KMS Integration Tests (if credentials available) ---
echo ""
echo "--- KMS Integration (requires credentials) ---"

if [ -n "${ALIBABA_CLOUD_ACCESS_KEY_ID}" ] && [ -n "${ALIBABA_CLOUD_ACCESS_KEY_SECRET}" ]; then
    KEY_ID="${KMS_KEY_ID}"
    if [ -z "$KEY_ID" ]; then
        echo "  [SKIP] KMS_KEY_ID not set"
    else
        export REGION_ID="${REGION_ID:-cn-hangzhou}"

        # Roundtrip test
        echo "  Running encrypt/decrypt roundtrip..."
        TOTAL=$((TOTAL+1))
        CIPHER=$(envelope-encrypt encrypt --key-id "$KEY_ID" --data "skillsbench-roundtrip-test" 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$CIPHER" ]; then
            PLAIN=$(echo "$CIPHER" | envelope-decrypt decrypt --data - 2>/dev/null)
            if [ "$PLAIN" = "skillsbench-roundtrip-test" ]; then
                log_pass "roundtrip: encrypt+decrypt matches"
            else
                log_fail "roundtrip" "plaintext mismatch: expected 'skillsbench-roundtrip-test'"
            fi
        else
            log_fail "roundtrip" "encryption failed: $CIPHER"
        fi

        # Encryption context roundtrip
        echo "  Running encryption context roundtrip..."
        TOTAL=$((TOTAL+1))
        CIPHER=$(envelope-encrypt encrypt --key-id "$KEY_ID" \
            --encryption-context '{"tenant":"eval","stage":"test"}' \
            --data "context-test" 2>/dev/null)
        if [ $? -eq 0 ]; then
            PLAIN=$(echo "$CIPHER" | envelope-decrypt decrypt \
                --encryption-context '{"tenant":"eval","stage":"test"}' \
                --data - 2>/dev/null)
            if [ "$PLAIN" = "context-test" ]; then
                log_pass "context roundtrip: matches"
            else
                log_fail "context roundtrip" "mismatch"
            fi

            # Wrong context
            TOTAL=$((TOTAL+1))
            WRONG=$(echo "$CIPHER" | envelope-decrypt decrypt \
                --encryption-context '{"tenant":"wrong"}' \
                --data - 2>&1 || true)
            if echo "$WRONG" | grep -qi "error\|fail"; then
                log_pass "context: wrong context correctly rejected"
            else
                log_fail "wrong context" "should have failed but got: $WRONG"
            fi
        else
            log_fail "context roundtrip" "encrypt failed"
        fi

        # File roundtrip
        echo "  Running file roundtrip..."
        echo "file-roundtrip-data" > /tmp/eval-plain.txt
        TOTAL=$((TOTAL+1))
        envelope-encrypt encrypt --key-id "$KEY_ID" --in-file /tmp/eval-plain.txt --out-file /tmp/eval-cipher.enc 2>/dev/null
        if [ $? -eq 0 ]; then
            envelope-decrypt decrypt --in-file /tmp/eval-cipher.enc --out-file /tmp/eval-plain-out.txt 2>/dev/null
            if diff -q /tmp/eval-plain.txt /tmp/eval-plain-out.txt >/dev/null 2>&1; then
                log_pass "file roundtrip: matches"
            else
                log_fail "file roundtrip" "content mismatch"
            fi
        else
            log_fail "file roundtrip" "encrypt failed"
        fi
    fi
else
    echo "  [SKIP] No KMS credentials (set ALIBABA_CLOUD_ACCESS_KEY_ID/SECRET + KMS_KEY_ID)"
fi

echo ""
echo "============================================"
echo "  Results: $PASS/$TOTAL passed, $FAIL failed"
echo "============================================"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
