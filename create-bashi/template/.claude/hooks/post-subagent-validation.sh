#!/usr/bin/env bash
# SubagentStop Hook — validates that CC subagent (Agent tool) returned useful output
# Catches silent failures from parallel exploration subagents
# Exit code 0 = always allow (advisory only, logs warnings)

set -euo pipefail
echo "$(basename "${BASH_SOURCE[0]}")" >> /tmp/bashi-hook-usage.log 2>/dev/null || true

INPUT=$(cat)
# shellcheck source=lib/detect-python.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/detect-python.sh"

VALIDATION=$(echo "$INPUT" | $PYTHON -c "
import sys, json

data = json.load(sys.stdin)

# SubagentStop provides the subagent's result
result = data.get('result', '')
tool_name = data.get('tool_name', 'Agent')

# Check for empty or error results
warnings = []

if not result or not result.strip():
    warnings.append('Subagent returned empty result')

# Check for common error indicators
error_indicators = [
    'error occurred',
    'failed to',
    'could not find',
    'no results found',
    'timed out',
    'permission denied',
    'not found',
]

result_lower = result.lower() if result else ''
for indicator in error_indicators:
    if indicator in result_lower and len(result_lower) < 200:
        # Only flag if the result is short (likely just an error message)
        warnings.append(f'Subagent result may indicate failure: contains \"{indicator}\"')
        break

if warnings:
    for w in warnings:
        print(f'WARNING: {w}')
    print('Consider re-running the exploration or trying an alternative approach.')
else:
    print('OK')
" 2>/dev/null || echo "OK")

if [[ "$VALIDATION" == WARNING* ]]; then
  echo "$VALIDATION" >&2
fi

exit 0
