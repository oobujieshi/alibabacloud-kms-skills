# Envelope Decrypt Grader

Evaluate whether the agent correctly used the envelope-decrypt skill.

## Assertions

### 1. Correct command invocation
- Does the agent call `bash scripts/run.sh decrypt`?
- PASS if the command matches the SKILL.md usage pattern

### 2. Input handling
- For file: uses `--in-file path` or `-` for stdin
- For inline string: uses `--data "value"`
- PASS if appropriate method chosen

### 3. Output
- Default stdout or `--out-file path`
- PASS if output correctly directed

### 4. EncryptionContext (when applicable)
- If ciphertext was encrypted with context: agent MUST use same `--encryption-context`
- Without context: agent should NOT add `--encryption-context`
- PASS if context handling is correct

### 5. Format validation
- Agent mentions 3-line base64 format requirement
- If input validation fails, agent explains the error clearly
- PASS if format awareness is demonstrated

### 6. Wrong context failure (negative case)
- When decrypting with wrong `--encryption-context`, agent recognizes KMS error
- PASS if agent correctly identifies and reports the failure

## Grading Format

```json
{
  "run_id": "eval-name-with_skill",
  "text": "Human-readable explanation",
  "passed": true,
  "evidence": "Specific evidence from agent output"
}
```
