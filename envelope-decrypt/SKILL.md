---
name: envelope-decrypt
description: Alibaba Cloud KMS envelope decryption tool. Downloads the latest binary from GitHub Releases and executes it. No AKSK required - uses default credential chain. Decrypts data using KMS Decrypt + AES-256-GCM. Accepts --data (string) or --in-file (file/stdin), outputs to stdout by default.
agent_created: true
---

# Envelope Decrypt

KMS envelope decryption via pre-built binary from [alibabacloud-kms-skills-cli](https://github.com/oobujieshi/alibabacloud-kms-skills-cli) releases.

## How It Works

The wrapper script `scripts/run.sh` auto-detects the platform, downloads the
correct binary from GitHub Releases (cached to `~/.cache/`), then executes it.

To invoke decryption, run:

```bash
bash scripts/run.sh decrypt --in-file <input> [flags...]
```

## Command Reference

```bash
envelope-decrypt decrypt [flags]

Flags:
  --data string             Ciphertext string (3-line base64 format)
  --in-file string          Input ciphertext file, '-' for stdin
  --out-file string         Output file, stdout if omitted
  --encryption-context string  JSON key-value pairs (must match encrypt)
```

## Usage Examples

```bash
# Decrypt a file - output to stdout
bash scripts/run.sh decrypt --in-file encrypted.enc

# Decrypt a string
bash scripts/run.sh decrypt --data "$(cat encrypted.enc)"

# With EncryptionContext (must match encrypt)
bash scripts/run.sh decrypt \
    --encryption-context '{"app":"myapp"}' \
    --in-file encrypted.enc
```

## Credentials

No AKSK needed. Default credential chain:
ENV vars -> `~/.aliyun/config.json` -> ECS RAM role

## Environment Variables

| Variable | Description |
|----------|-------------|
| `REGION_ID` | KMS region (auto from ECS metadata) |
| `ENDPOINT_TYPE` | `Vpc` (default) or `Public` |

## Input Format

3-line base64 (produced by `envelope-encrypt`):
encrypted_data_key / nonce / ciphertext
