---
name: envelope-encrypt
description: >
  Use Alibaba Cloud KMS to encrypt data via envelope encryption (GenerateDataKey + AES-256-GCM).
  Trigger when the user wants to encrypt files, strings, plaintext, secrets, or configuration
  with an Alibaba KMS customer master key. Covers 加密, 信封加密, KMS加密 in Chinese, and
  "envelope encrypt", "encrypt with KMS key", "protect data with KMS" in English.
  For decryption use envelope-decrypt instead. Not for key management, gpg, bcrypt, or AWS KMS.
agent_created: true
---

# Envelope Encrypt

KMS envelope encryption that downloads a pre-built binary from GitHub Releases,
caches it, then executes it. No AKSK needed — uses the default credential chain.

## How it works

Run `scripts/run.sh` to execute encryption. The wrapper:

1. Detects the current platform (linux/darwin/windows + amd64/arm64)
2. Downloads the matching binary from GitHub Releases if not cached  
3. Caches it at `~/.cache/alibabacloud-kms-skills/`
4. Runs it with the provided arguments

The binary is built from source at `github.com/oobujieshi/alibabacloud-kms-skills-cli`
by GitHub Actions for every release tag.

## Usage

```bash
bash scripts/run.sh encrypt [flags]
```

### Required

`--key-id` — KMS CMK ID or alias

### Input (exactly one)

`--data "hello world"` — encrypt a string directly
`--in-file path/to/file` — encrypt a file, `-` for stdin

### Output (optional)

`--out-file path` — write ciphertext to file; omit for stdout

### Optional

`--encryption-context '{"app":"myapp"}'` — KMS encryption context (JSON)
`--key-spec AES_128` — data key spec: `AES_256` (default) or `AES_128`
`--number-of-bytes 16` — data key length, 1-1024 (default 32)

### Examples

```bash
# Encrypt a string, print to stdout
bash scripts/run.sh encrypt --key-id <cmk-id> --data "secret message"

# Encrypt a file, write to output file
bash scripts/run.sh encrypt --key-id <cmk-id> --in-file plain.txt --out-file encrypted.enc

# With encryption context
bash scripts/run.sh encrypt --key-id <cmk-id> \
    --encryption-context '{"stage":"prod","app":"billing"}' \
    --data "secret"
```

## Output format

Three lines, each base64-encoded:

1. Encrypted data key (KMS CiphertextBlob)
2. Nonce (12 bytes)
3. Ciphertext (AES-256-GCM)

## Credentials

No credentials needed in most environments. Resolution order:

- `REGION_ID` environment variable, or auto-detected from ECS metadata
- Default credential chain: env vars → `~/.aliyun/config.json` → ECS RAM role
- `ENDPOINT_TYPE=Vpc` (default) for intranet, `Public` for internet

## Verifying encryption (roundtrip)

Always verify the output is correct 3-line base64 format, then test decryption:
```bash
# Encrypt
bash scripts/run.sh encrypt --key-id <cmk-id> --data "check" --out-file /tmp/test.enc

# Verify format: exactly 3 lines, each valid base64
test $(wc -l < /tmp/test.enc) -eq 3 && echo "format ok"

# Decrypt to confirm roundtrip
bash ../envelope-decrypt/scripts/run.sh decrypt --in-file /tmp/test.enc
```

## Decryption

Use the companion `envelope-decrypt` skill. If `--encryption-context` was
specified during encryption, the same value must be provided during decryption.
