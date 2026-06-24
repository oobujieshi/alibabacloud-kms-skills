#!/bin/bash
set -e

echo "=== Oracle: envelope-decrypt ==="

KEY_ID="${KMS_KEY_ID}"
if [ -z "$KEY_ID" ]; then
    echo "ERROR: KMS_KEY_ID not set" >&2
    exit 1
fi

OUT_DIR="/tmp/skillsbench-output/decrypt-oracle"
ENC_DIR="/tmp/skillsbench-output/encrypt-oracle"
mkdir -p "$OUT_DIR"

# Test 1: Decrypt file
echo "Test 1: decrypt file"
RESULT=$(envelope-decrypt decrypt --in-file "$ENC_DIR/test1.enc" --out-file "$OUT_DIR/test1.txt" && cat "$OUT_DIR/test1.txt")
if [ "$RESULT" != "hello kms" ]; then
    echo "FAIL: expected 'hello kms', got '$RESULT'"
    exit 1
fi
echo "  PASS: decrypted to 'hello kms'"

# Test 2: Decrypt file from file
echo "Test 2: decrypt file-to-file"
envelope-decrypt decrypt --in-file "$ENC_DIR/test2.enc" --out-file "$OUT_DIR/test2.txt"
if ! grep -q "confidential data" "$OUT_DIR/test2.txt"; then
    echo "FAIL: test2 content mismatch"
    exit 1
fi
echo "  PASS: file content recovered"

# Test 3: Decrypt with EncryptionContext
echo "Test 3: decrypt with context"
envelope-decrypt decrypt \
    --encryption-context '{"tenant":"skillsbench","env":"test"}' \
    --in-file "$ENC_DIR/test3.enc" \
    --out-file "$OUT_DIR/test3.txt"
RESULT=$(cat "$OUT_DIR/test3.txt")
if [ "$RESULT" != "context test" ]; then
    echo "FAIL: expected 'context test', got '$RESULT'"
    exit 1
fi
echo "  PASS: context decryption matches"

# Test 4: Decrypt with wrong context should fail
echo "Test 4: decrypt with wrong context (should fail)"
set +e
envelope-decrypt decrypt \
    --encryption-context '{"tenant":"wrong"}' \
    --in-file "$ENC_DIR/test3.enc" \
    --out-file "$OUT_DIR/test4.txt" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "FAIL: expected failure with wrong context, but succeeded"
    exit 1
fi
set -e
echo "  PASS: correctly rejected with wrong context"

echo "=== Oracle complete, all tests passed ==="
