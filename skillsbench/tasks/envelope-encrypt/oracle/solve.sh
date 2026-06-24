#!/bin/bash
set -e

echo "=== Oracle: envelope-encrypt ==="

KEY_ID="${KMS_KEY_ID}"
if [ -z "$KEY_ID" ]; then
    echo "ERROR: KMS_KEY_ID not set" >&2
    exit 1
fi

OUT_DIR="/tmp/skillsbench-output/encrypt-oracle"
mkdir -p "$OUT_DIR"

# Test 1: Encrypt string to stdout
echo "Test 1: encrypt string to stdout"
envelope-encrypt encrypt --key-id "$KEY_ID" --data "hello kms" --out-file "$OUT_DIR/test1.enc"
LINES=$(wc -l < "$OUT_DIR/test1.enc")
if [ "$LINES" -ne 3 ]; then
    echo "FAIL: test1 expected 3 lines, got $LINES"
    exit 1
fi
echo "  PASS: 3 lines format"

# Test 2: Encrypt file
echo "Test 2: encrypt file"
echo "confidential data" > /tmp/test_secret.txt
envelope-encrypt encrypt --key-id "$KEY_ID" --in-file /tmp/test_secret.txt --out-file "$OUT_DIR/test2.enc"
LINES=$(wc -l < "$OUT_DIR/test2.enc")
if [ "$LINES" -ne 3 ]; then
    echo "FAIL: test2 expected 3 lines, got $LINES"
    exit 1
fi
echo "  PASS: file encrypted"

# Test 3: Encrypt with EncryptionContext
echo "Test 3: encrypt with context"
envelope-encrypt encrypt --key-id "$KEY_ID" \
    --encryption-context '{"tenant":"skillsbench","env":"test"}' \
    --data "context test" \
    --out-file "$OUT_DIR/test3.enc"
LINES=$(wc -l < "$OUT_DIR/test3.enc")
if [ "$LINES" -ne 3 ]; then
    echo "FAIL: test3 expected 3 lines, got $LINES"
    exit 1
fi

# Verify each line is valid base64
while IFS= read -r line; do
    if ! echo "$line" | base64 -d >/dev/null 2>&1; then
        echo "FAIL: test3 line is not valid base64"
        exit 1
    fi
done < "$OUT_DIR/test3.enc"
echo "  PASS: context encryption + base64 validation"

echo "=== Oracle complete, all tests passed ==="
