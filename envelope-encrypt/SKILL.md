---
name: envelope-encrypt
description: >
  Use Alibaba Cloud KMS envelope encryption (GenerateDataKey + AES-256-GCM).
  Trigger whenever the user needs to encrypt data with Alibaba KMS, protect
  sensitive information before git commit, secure credentials for storage,
  or safeguard config files before transfer. Works with "KMS encrypt," "信封加密,"
  "KMS加密," "envelope encrypt," "保护敏感数据," "加密后提交," "encrypt before
  pushing," "secure this secret." Not for decryption (use envelope-decrypt),
  AWS KMS, gpg, bcrypt, or key creation.
agent_created: true
---

# Envelope Encrypt

Encrypt data with KMS envelope encryption. On first use, the wrapper script
at `scripts/run.sh` downloads a pre-built binary and caches it at
`~/.cache/alibabacloud-kms-skills/`. Subsequent runs use the cached binary.

## Run

```bash
bash scripts/run.sh encrypt [flags]
```

The script `scripts/run.sh` is in the same directory as this SKILL.md.
If `run.sh` is missing, copy it from the skill's `scripts/` directory.

## Flags

| Flag | Required | Description |
|------|----------|-------------|
| `--key-id` | Yes | KMS CMK ID or alias |
| `--data` | One* | Plaintext string |
| `--in-file` | One* | File path or `-` for stdin |
| `--out-file` | No | Output file, stdout if omitted |
| `--encryption-context` | No | JSON key-value pairs (audit trail, decryption enforces match) |
| `--key-spec` | No | `AES_256` (default) or `AES_128` |
| `--number-of-bytes` | No | Key length 1-1024, overrides `--key-spec` |

*Exactly one of `--data` or `--in-file` is required.

## Output

Three newline-separated base64 lines:

1. Encrypted data key (KMS CiphertextBlob)
2. Nonce (12 bytes)
3. Ciphertext (AES-256-GCM)

Only the format is predictable; values change each run because data keys and
nonces are random. To verify: `test $(wc -l < out.enc) -eq 3`.

## Examples

Encrypt a secret string, output to stdout:
```bash
bash scripts/run.sh encrypt --key-id alias/my-key --data "api-key-abc123"
```

Encrypt a file with audit tagging:
```bash
bash scripts/run.sh encrypt --key-id alias/my-key \
    --encryption-context '{"app":"billing","env":"prod"}' \
    --in-file secrets.yaml --out-file secrets.yaml.enc
```

Encrypt stdin from a pipeline:
```bash
echo "password" | bash scripts/run.sh encrypt --key-id alias/my-key --in-file -
```

## Troubleshooting

**Binary download fails** (`curl` or `wget` error):
The script downloads from GitHub Releases. If blocked by firewall:
- Set `HTTPS_PROXY` if behind a proxy
- Manually download the binary from https://github.com/oobujieshi/alibabacloud-kms-skills-cli/releases
  and place it at `~/.cache/alibabacloud-kms-skills/envelope-encrypt-{platform}`

**Credential or region errors**: Read `references/env_vars.md`.

**"either --data or --in-file is required"**: You didn't specify what to encrypt.
Add `--data "value"` or `--in-file path`.

**"mutually exclusive"**: You passed both `--data` and `--in-file`. Choose one.
