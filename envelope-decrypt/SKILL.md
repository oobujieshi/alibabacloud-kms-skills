---
name: envelope-decrypt
description: >
  Decrypt data that was encrypted with Alibaba Cloud KMS envelope encryption
  (KMS Decrypt + AES-256-GCM). Use this skill whenever the user mentions
  decrypting KMS-encrypted data, envelope decryption, or recovering plaintext
  from KMS-protected files -- even if they don't use the exact phrase
  "envelope decrypt." Covers Chinese phrases like KMS解密, 信封解密, 阿里云解密.
  For encryption, use the envelope-encrypt skill. Not for AWS KMS, gpg, RSA, or
  TLS decryption.
agent_created: true
---

# Envelope Decrypt

Decrypt data that was encrypted with KMS envelope encryption. The skill downloads
a pre-built CLI binary from GitHub Releases, caches it, and runs it with your parameters.

## How to run

Always use the wrapper script:

```bash
bash scripts/run.sh decrypt [flags]
```

## Input

Specify **exactly one** input source. If neither is provided, the tool exits
with a clear error message.

`--data "value"` for a 3-line base64 ciphertext string. Use this when you have
the encrypted output inline or stored as a shell variable.

`--in-file path` for a file containing the 3-line base64 ciphertext. Use `-` to
read from stdin. Prefer this for files or when piping from another command.

## Output

By default, the plaintext prints to stdout. Use `--out-file path` to write to a
file instead.

## Optional

`--encryption-context '{"key":"value"}'` -- must **exactly match** the value
used during encryption. If the context doesn't match, KMS rejects the decryption
request. This is a security feature -- it prevents data encrypted in one context
from being decrypted in another.

## Input format

The input must be exactly 3 lines, each base64-encoded, as produced by the
`envelope-encrypt` skill:

```
<base64-encrypted-data-key>
<base64-nonce>
<base64-ciphertext>
```

If the input has fewer or more than 3 lines, the tool exits with an error
message describing the expected format.

## Examples

```bash
# Decrypt a file, print to terminal
bash scripts/run.sh decrypt --in-file config.yaml.enc

# Decrypt with encryption context
bash scripts/run.sh decrypt \
    --encryption-context '{"tenant":"acme","stage":"production"}' \
    --in-file config.yaml.enc

# Decrypt inline string
ENCRYPTED="$(cat config.yaml.enc)"
bash scripts/run.sh decrypt --data "$ENCRYPTED"

# Pipe from stdin, write to file
cat config.yaml.enc | bash scripts/run.sh decrypt --in-file - --out-file config.yaml
```

## Verification

Always verify the decrypted output is what you expect. If decryption fails with
a KMS error, check:

1. The `--encryption-context` matches the value used during encryption
2. The CMK used for encryption still exists and is enabled
3. The credentials have `kms:Decrypt` permission

## Credentials

No AKSK needed in most environments. The binary uses Alibaba Cloud's default
credential chain. If you see credential errors, read `references/env_vars.md`
for the full resolution order and troubleshooting.
