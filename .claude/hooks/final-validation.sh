#!/usr/bin/env bash
# Final Validation - runs at session Stop phase
# Checks that the framework is internally consistent
# Always exits 0 - this is a reporting hook, not a blocker

set -uo pipefail
BASHI_TMP="${TMPDIR:-${TMP:-${TEMP:-/tmp}}}"
echo "$(basename "${BASH_SOURCE[0]}")" >> "$BASHI_TMP/bashi-hook-usage.log" 2>/dev/null || true

FRAMEWORK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLAUDE_DIR="$FRAMEWORK_ROOT/.claude"

echo "=== bashi Framework Validation ==="
echo "Framework root: $FRAMEWORK_ROOT"
echo ""

ALL_GOOD=true

REQUIRED_DIRS=(
  "$CLAUDE_DIR/agents"
  "$CLAUDE_DIR/commands"
  "$CLAUDE_DIR/rules"
  "$CLAUDE_DIR/skills"
  "$CLAUDE_DIR/hooks"
  "$CLAUDE_DIR/project"
)

for dir in "${REQUIRED_DIRS[@]}"; do
  if [ ! -d "$dir" ]; then
    echo "MISSING DIR: $dir" >&2
    ALL_GOOD=false
  fi
done

REQUIRED_FILES=(
  "$CLAUDE_DIR/CLAUDE.md"
  "$CLAUDE_DIR/settings.json"
  "$CLAUDE_DIR/agents/orchestrator.md"
  "$CLAUDE_DIR/rules/context-policy.md"
  "$CLAUDE_DIR/rules/orchestration-routing.md"
  "$CLAUDE_DIR/rules/knowledge-policy.md"
  "$CLAUDE_DIR/rules/event-hooks.md"
  "$CLAUDE_DIR/project/STATE.md"
  "$CLAUDE_DIR/project/EVENTS.md"
  "$FRAMEWORK_ROOT/.claudeignore"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "MISSING FILE: $file" >&2
    ALL_GOOD=false
  fi
done

PHANTOM_AGENTS=("clarity-editor" "beginner-advocate" "visionary-book" "flow-auditor")
for agent in "${PHANTOM_AGENTS[@]}"; do
  if grep -r "$agent" "$CLAUDE_DIR" --include="*.md" -l 2>/dev/null | grep -q .; then
    echo "Stale reference found: '$agent' is referenced in framework files but this agent no longer exists. Run /doctor to check." >&2
    ALL_GOOD=false
  fi
done

if grep -rE "C:\\\\Users\\\\[a-zA-Z0-9_.-]+" "$CLAUDE_DIR" --include="*.md" -l 2>/dev/null | grep -q .; then
  echo "Hardcoded path found: A personal file path (C:\Users\...) is still in framework files. Replace with a relative path or variable." >&2
  ALL_GOOD=false
fi

if grep -rE "(^|[^a-zA-Z])/Users/[a-zA-Z0-9_.-]+" "$CLAUDE_DIR" --include="*.md" -l 2>/dev/null | grep -q .; then
  echo "Hardcoded path found: A personal file path (/Users/...) is still in framework files. Replace with a relative path or variable." >&2
  ALL_GOOD=false
fi

if grep -rE "(^|[^a-zA-Z])/home/[a-zA-Z0-9_.-]+" "$CLAUDE_DIR" --include="*.md" -l 2>/dev/null | grep -q .; then
  echo "Hardcoded path found: A personal file path (/home/...) is still in framework files. Replace with a relative path or variable." >&2
  ALL_GOOD=false
fi

if [ "$ALL_GOOD" = true ]; then
  echo "All validation checks passed."
else
  echo "Validation completed with warnings - review items above."
fi

STATE_FILE="$CLAUDE_DIR/project/STATE.md"
PARSER="$CLAUDE_DIR/hooks/lib/parse_state.py"
if [ -f "$STATE_FILE" ]; then
  source "$(dirname "${BASH_SOURCE[0]}")/lib/detect-python.sh"
  if [ -f "$PARSER" ]; then
    ACTIVE_ID=$($PYTHON "$PARSER" "$STATE_FILE" active_id 2>/dev/null || echo "-")
  else
    ACTIVE_ID=$(grep '| ID |' "$STATE_FILE" 2>/dev/null | head -1 | sed 's/.*| ID | *//;s/ *|.*//')
  fi
  if [ -n "$ACTIVE_ID" ] && [ "$ACTIVE_ID" != "-" ]; then
    echo ""
    echo "Reminder: Active task ($ACTIVE_ID) detected. Run /save before ending this session to preserve progress."
  fi
fi

exit 0