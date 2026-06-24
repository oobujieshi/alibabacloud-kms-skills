---
task_id: envelope-decrypt
domain: security
subdomain: encryption
difficulty: medium
timeout: 120
requires_credentials: true
required_env:
  - ALIBABA_CLOUD_ACCESS_KEY_ID
  - ALIBABA_CLOUD_ACCESS_KEY_SECRET
  - REGION_ID
  - KMS_KEY_ID
---

# Task: KMS Envelope Decryption

Decrypt data that was encrypted with KMS envelope encryption.

## Setup

The environment has:
- A KMS CMK available at key ID from `$KMS_KEY_ID` environment variable
- The `envelope-encrypt` and `envelope-decrypt` tools installed at `/usr/local/bin/`
- Pre-encrypted files from the oracle run at `/tmp/skillsbench-output/encrypt-oracle/`

## Task

1. Decrypt the file `/tmp/skillsbench-output/encrypt-oracle/test1.enc` and verify the output is "hello kms"
2. Decrypt the file `/tmp/skillsbench-output/encrypt-oracle/test2.enc` and verify the file content is recovered
3. Decrypt `/tmp/skillsbench-output/encrypt-oracle/test3.enc` with encryption context `{"tenant":"skillsbench","env":"test"}`
4. Attempt to decrypt test3.enc without context — expect failure

## Expected Output

- Decrypted plaintext matches original for tests 1-3
- Test 4 fails with a KMS error (encryption context mismatch)
