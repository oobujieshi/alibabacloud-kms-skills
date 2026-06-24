---
name: envelope-encrypt
description: Alibaba Cloud KMS envelope encryption tool. Downloads the latest binary from GitHub Releases and executes it. No AKSK required - uses default credential chain. Encrypts data using GenerateDataKey + AES-256-GCM. Accepts --data (string) or --in-file (file/stdin), outputs to stdout by default.
agent_created: true
---

# Envelope Encrypt

KMS envelope encryption via pre-built binary from [alibabacloud-kms-skills-cli](https://github.com/oobujieshi/alibabacloud-kms-skills-cli) releases.

## How It Works

The wrapper script `scripts/run.sh` auto-detects the platform, downloads the
correct binary from GitHub Releases (cached to `~/.cache/`), then executes it.

To invoke encryption, run:

```bash
bash scripts/run.sh encrypt --key-id <cmk-id> [flags...]
```

## Command Reference

```bash
envelope-encrypt encrypt [flags]

Flags:
  --key-id string           KMS CMK ID or alias (required)
  --data string             Plaintext string to encrypt
  --in-file string          Input file path, '-' for stdin
  --out-file string         Output file path, stdout if omitted
  --encryption-context string  JSON key-value pairs
  --key-spec string         AES_256 or AES_128
  --number-of-bytes int     Data key length in bytes (default 32)
```

## Usage Examples

```bash
# Encrypt a string - output to stdout
bash scripts/run.sh encrypt --key-id <cmk-id> --data "secret"

# Encrypt a file
bash scripts/run.sh encrypt --key-id <cmk-id> --in-file plain.txt --out-file encrypted.enc

# With EncryptionContext
bash scripts/run.sh encrypt --key-id <cmk-id> \
    --encryption-context '{"app":"myapp"}' \
    --data "secret"
```

## Credentials

No AKSK needed. Default credential chain:
ENV vars -> `~/.aliyun/config.json` -> ECS RAM role

## Environment Variables

| Variable | Description |
|----------|-------------|
| `REGION_ID` | KMS region (auto from ECS metadata) |
| `ENDPOINT_TYPE` | `Vpc` (default) or `Public` |

## Output Format

3-line base64: encrypted_data_key / nonce / ciphertext

Use `envelope-decrypt` to decrypt.
