# Envelope Encrypt Grader

Evaluate whether the agent correctly used the envelope-encrypt skill.

## Assertions

For each test case, check the following:

### 1. Correct command invocation
- Does the agent call `bash scripts/run.sh encrypt`?
- Are the required flags present?
- PASS if the command matches the SKILL.md usage pattern

### 2. Input method
- For string input: uses `--data "value"` (not piping or temp files)
- For file input: uses `--in-file path` or `-` for stdin
- PASS if appropriate input method is chosen

### 3. Output handling
- Default: output goes to stdout
- File: `--out-file path` is provided
- PASS if output is correctly directed

### 4. EncryptionContext (when applicable)
- If the prompt mentions environment/tagging/context: uses `--encryption-context`
- JSON is valid
- PASS if context is correctly applied

### 5. Rationale (optional)
- Agent explains why they chose specific flags
- Agent mentions the 3-line base64 output format
- PASS if explanation is reasonable

## Grading Format

```json
{
  "run_id": "eval-name-with_skill",
  "text": "Human-readable explanation of pass/fail",
  "passed": true,
  "evidence": "Specific evidence from the agent output"
}
```
