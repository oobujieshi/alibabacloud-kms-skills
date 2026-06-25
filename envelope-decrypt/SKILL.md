---
name: envelope-decrypt
description: >
  Use Alibaba Cloud KMS to decrypt envelope-encrypted data (KMS Decrypt +
  AES-256-GCM). Trigger whenever the user needs to recover plaintext from
  KMS-encrypted files, restore protected configuration, decode sealed secrets
  in CI/CD, or access encrypted credentials. Works with "KMS decrypt," "信封解密,"
  "KMS解密," "envelope decrypt," "恢复加密文件," "decrypt sealed secret,"
  "解码KMS密文." Not for encryption (use envelope-encrypt), AWS KMS, gpg,
  RSA, or TLS.
agent_created: true
---

# Envelope Decrypt

Decrypt data produced by `envelope-encrypt`. On first use, the wrapper script
at `scripts/run.sh` downloads a pre-built binary and caches it at
`~/.cache/alibabacloud-kms-skills/`. Subsequent runs use the cached binary.

## Run

```bash
bash scripts/run.sh decrypt [flags]
```

The script `scripts/run.sh` is in the same directory as this SKILL.md.
If `run.sh` is missing, copy it from the skill's `scripts/` directory.

## Flags

| Flag | Required | Description |
|------|----------|-------------|
| `--data` | One* | 3-line base64 ciphertext string |
| `--in-file` | One* | File path or `-` for stdin |
| `--out-file` | No | Output file, stdout if omitted |
| `--encryption-context` | No | Must match the value used during encryption |

*Exactly one of `--data` or `--in-file` is required.

## Input format

Three newline-separated base64 lines, as produced by `envelope-encrypt`:

1. Encrypted data key (KMS CiphertextBlob)
2. Nonce (12 bytes)
3. Ciphertext (AES-256-GCM)

Fewer or more than 3 lines causes an error with an explanation.

## Examples

Decrypt a file to stdout:
```bash
bash scripts/run.sh decrypt --in-file config.yaml.enc
```

Decrypt with encryption context:
```bash
bash scripts/run.sh decrypt \
    --encryption-context '{"app":"billing","env":"prod"}' \
    --in-file config.yaml.enc
```

Pipe from stdin, write to file:
```bash
cat config.yaml.enc | bash scripts/run.sh decrypt --in-file - --out-file config.yaml
```

## Troubleshooting

**Binary download fails** (`curl` or `wget` error):
The script downloads from GitHub Releases. If blocked by firewall:
- Set `HTTPS_PROXY` if behind a proxy
- Manually download the binary from https://github.com/oobujieshi/alibabacloud-kms-skills-cli/releases
  and place it at `~/.cache/alibabacloud-kms-skills/envelope-decrypt-{platform}`

**Decryption rejected by KMS**:
1. `--encryption-context` must **exactly match** what was used during encryption.
   Even one character difference (extra space, different quote style) fails.
2. The original CMK must still exist and be enabled.
3. Credentials must have `kms:Decrypt` permission.

**"invalid envelope format"**: Input must be exactly 3 lines of base64.
Check that the file wasn't corrupted or truncated.

**Credential or region errors**: Read `references/env_vars.md`.
