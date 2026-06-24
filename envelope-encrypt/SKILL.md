---
name: envelope-encrypt
description: >
  Encrypt files, strings, or secrets using Alibaba Cloud KMS envelope encryption
  (GenerateDataKey + AES-256-GCM). Use this skill whenever the user mentions
  encrypting data with Alibaba Cloud KMS, KMS envelope encryption, or KMS key-based
  encryption -- even if they don't use the exact phrase "envelope encrypt."
  Covers Chinese phrases like KMS加密, 信封加密, 阿里云加密. For decryption,
  use the envelope-decrypt skill. Not for AWS KMS, gpg, bcrypt, or key management.
agent_created: true
---

# Envelope Encrypt

Encrypt data using KMS envelope encryption. The skill downloads a pre-built CLI
binary from GitHub Releases, caches it, and runs it with your parameters.

## How to run

Always use the wrapper script -- it handles platform detection and caching:

```bash
bash scripts/run.sh encrypt [flags]
```

## Input

Specify **exactly one** input source. If neither is provided, the tool exits
with a clear error message asking for one.

`--data "value"` for string input. Prefer this for short secrets, API keys,
passwords, and CI/CD variable values.

`--in-file path` for file input. Use `-` to read from stdin. Prefer this for
files larger than a few KB or when piping from another command.

## Output

By default, the result prints to stdout as three newline-separated base64 lines.
Use `--out-file path` to write to a file instead. The format is:

```
<base64-encrypted-data-key>
<base64-nonce>
<base64-ciphertext>
```

Each line must be valid base64. The encrypted data key (line 1) is the KMS
CiphertextBlob -- it can only be decrypted by KMS using the same CMK.

## Required

`--key-id` -- the KMS CMK ID or alias. This is the key that protects the data key.

## Optional

`--encryption-context '{"key":"value"}'` -- JSON key-value pairs stored in KMS
audit logs. If you use this during encryption, the exact same context must be
provided during decryption, otherwise KMS rejects the request. Use meaningful
keys like `{"app":"billing","env":"prod"}` to track which service encrypted the data.

`--key-spec AES_128` -- data key algorithm. Either `AES_256` (default) or `AES_128`.
When set, the key size is determined by the algorithm (32 or 16 bytes).

`--number-of-bytes 16` -- explicit key length, 1-1024 bytes. This overrides
`--key-spec` when both are set. Use this when you need a specific key size
that doesn't match the standard algorithms.

## Examples

```bash
# Encrypt a string, print result to terminal
bash scripts/run.sh encrypt --key-id alias/my-key --data "my-secret-value"

# Encrypt a file
bash scripts/run.sh encrypt --key-id alias/my-key --in-file config.yaml --out-file config.yaml.enc

# Encrypt with context tracking
bash scripts/run.sh encrypt --key-id alias/my-key \
    --encryption-context '{"tenant":"acme","stage":"production"}' \
    --data "production-api-key"

# Pipe from stdin
echo "sensitive" | bash scripts/run.sh encrypt --key-id alias/my-key --in-file -
```

## After encryption

Verify the output has exactly 3 lines and each is valid base64:

```bash
test $(wc -l < output.enc) -eq 3 && echo "format OK"
```

To decrypt, use the `envelope-decrypt` skill with the same key and,
if applicable, the same `--encryption-context`.

## Credentials

No AKSK needed in most environments. The binary uses Alibaba Cloud's default
credential chain. If you see credential errors, read `references/env_vars.md`
for the full resolution order and troubleshooting.
