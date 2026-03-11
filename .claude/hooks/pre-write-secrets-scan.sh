#!/usr/bin/env bash
# Pre-Write Secrets Scan — blocks writes containing API keys, tokens, or credentials
# Enforces: "Never write secrets, API keys, or credentials to files or logs"
# Exit code 2 = block, Exit code 0 = allow

set -euo pipefail

INPUT=$(cat)

# Extract file path and content to scan
PYTHON=$(python3 -c "import sys" 2>/dev/null && echo python3 || echo python)
PARSED=$(echo "$INPUT" | $PYTHON -c "
import sys, json
data = json.load(sys.stdin)
file_path = data.get('file_path', data.get('path', ''))
# Write tool uses 'content', Edit uses 'new_string'
text = data.get('content', '') or data.get('new_string', '')
print(file_path)
print('---SPLIT---')
print(text)
" 2>/dev/null || echo "")

FILE_PATH="${PARSED%%---SPLIT---*}"
FILE_PATH=$(echo "$FILE_PATH" | tr -d '[:space:]')
CONTENT="${PARSED#*---SPLIT---}"

# Skip hook files to avoid self-blocking on pattern strings
if echo "$FILE_PATH" | grep -qE "(\.claude[/\\\\]hooks[/\\\\]|\.claude\\\\hooks\\\\)"; then
  exit 0
fi

if [ -z "$CONTENT" ]; then
  exit 0
fi

# Use Python for robust regex matching on multiline content
FOUND=$(echo "$CONTENT" | $PYTHON -c "
import sys, re

patterns = [
    (r'sk-[a-zA-Z0-9]{20,}', 'OpenAI API key'),
    (r'sk_(live|test)_[a-zA-Z0-9]{20,}', 'Stripe secret key'),
    (r'ghp_[a-zA-Z0-9]{36,}', 'GitHub personal access token'),
    (r'gho_[a-zA-Z0-9]{36,}', 'GitHub OAuth token'),
    (r'ghs_[a-zA-Z0-9]{36,}', 'GitHub server token'),
    (r'github_pat_[a-zA-Z0-9_]{20,}', 'GitHub fine-grained PAT'),
    (r'glpat-[a-zA-Z0-9_\-]{20,}', 'GitLab PAT'),
    (r'xox[bp]-[0-9]{10,}-[a-zA-Z0-9]{20,}', 'Slack token'),
    (r'AKIA[0-9A-Z]{16}', 'AWS access key ID'),
    (r'-----BEGIN (?:RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----', 'Private key'),
    (r'Bearer [a-zA-Z0-9_\-\.]{20,}', 'Bearer token'),
    (r'password\s*=\s*[\"\\'][^\"\\']{8,}[\"\\']', 'Hardcoded password'),
    (r'AWS_SECRET_ACCESS_KEY\s*=\s*[\"\\'][^\"\\']+[\"\\']', 'AWS secret key'),
    (r'PRIVATE_KEY\s*=\s*[\"\\'][^\"\\']+[\"\\']', 'Private key assignment'),
    (r'sk-ant-api[a-zA-Z0-9_-]{20,}', 'Anthropic API key'),
    (r'(postgres|mysql|mongodb|redis)://[^:]+:[^@]+@', 'Database connection string with credentials'),
    (r'hooks\.slack\.com/services/T[A-Z0-9]+/B[A-Z0-9]+/[a-zA-Z0-9]+', 'Slack webhook URL'),
    (r'amzn\.mws\.[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}', 'AWS MWS token'),
]

text = sys.stdin.read()
for pat, name in patterns:
    if re.search(pat, text):
        print(name)
        sys.exit(0)
print('')
" 2>/dev/null || echo "")

if [ -n "$FOUND" ]; then
  echo "BLOCKED by pre-write-secrets-scan: Possible $FOUND detected in content for $FILE_PATH" >&2
  echo "If this is a false positive, remove the secret-like pattern or write the file manually." >&2
  exit 2
fi

exit 0
