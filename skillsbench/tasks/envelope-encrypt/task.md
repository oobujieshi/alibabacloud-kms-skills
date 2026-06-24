---
task_id: envelope-encrypt
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

# Task: KMS Envelope Encryption

Encrypt plaintext data using Alibaba Cloud KMS envelope encryption.

## Setup

The environment has:
- A KMS CMK available at key ID from `$KMS_KEY_ID` environment variable
- The `envelope-encrypt` tool installed at `/usr/local/bin/envelope-encrypt`
- A test plaintext file at `/tmp/test_secret.txt` containing "confidential data"

## Task

1. Encrypt the string "hello kms" using the KMS CMK, output to stdout
2. Encrypt the file `/tmp/test_secret.txt` to `/tmp/test_secret.enc`
3. Encrypt with encryption context: `{"tenant":"skillsbench","env":"test"}` on string "context test"
4. Verify all outputs are in the correct 3-line base64 format

## Expected Output

- Encrypted data in the 3-line base64 envelope format
- Each output has exactly 3 non-empty lines when base64-decoded newlines are counted
- The encryption context variant includes the context in KMS audit logs
