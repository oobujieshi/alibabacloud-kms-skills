---
name: envelope-decrypt
description: >
  Use Alibaba Cloud KMS to decrypt data that was encrypted with envelope encryption
  (KMS Decrypt + AES-256-GCM). Trigger when the user wants to decrypt envelope-encrypted
  files, 3-line base64 ciphertext, or recover plaintext from KMS-protected data.
  Covers 解密, 信封解密, KMS解密 in Chinese, and "envelope decrypt", "decrypt with KMS",
  "recover KMS-encrypted data" in English. For encryption use envelope-encrypt instead.
  Not for key management, gpg, RSA, TLS, or AWS KMS.
agent_created: true
---

# Envelope Decrypt

KMS envelope decryption that downloads a pre-built binary from GitHub Releases,
caches it, then executes it. No AKSK needed — uses the default credential chain.

## How it works

Run `scripts/run.sh` to execute decryption. The wrapper:

1. Detects the current platform (linux/darwin/windows + amd64/arm64)
2. Downloads the matching binary from GitHub Releases if not cached
3. Caches it at `~/.cache/alibabacloud-kms-skills/`
4. Runs it with the provided arguments

The binary is built from source at `github.com/oobujieshi/alibabacloud-kms-skills-cli`
by GitHub Actions for every release tag.

## Usage

```bash
bash scripts/run.sh decrypt [flags]
```

### Input (exactly one)

`--data "base64\nbase64\nbase64"` — decrypt a 3-line ciphertext string directly
`--in-file path/to/encrypted.enc` — decrypt a file, `-` for stdin

### Output (optional)

`--out-file path` — write plaintext to file; omit for stdout

### Optional

`--encryption-context '{"app":"myapp"}'` — must match the value used during encryption

### Examples

```bash
# Decrypt a file, print to stdout
bash scripts/run.sh decrypt --in-file encrypted.enc

# Decrypt a string
bash scripts/run.sh decrypt --data "$(cat encrypted.enc)"

# With encryption context (must match encryption)
bash scripts/run.sh decrypt \
    --encryption-context '{"stage":"prod"}' \
    --in-file encrypted.enc
```

## Input format

Expected 3-line base64 format produced by `envelope-encrypt`:

1. Encrypted data key (KMS CiphertextBlob)
2. Nonce (12 bytes)
3. Ciphertext (AES-256-GCM)

## Credentials

No credentials needed in most environments. Resolution order:

- `REGION_ID` environment variable, or auto-detected from ECS metadata
- Default credential chain: env vars → `~/.aliyun/config.json` → ECS RAM role
- `ENDPOINT_TYPE=Vpc` (default) for intranet, `Public` for internet
