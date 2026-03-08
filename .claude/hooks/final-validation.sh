#!/usr/bin/env bash
# Final Validation — runs at session Stop phase
# Checks that the framework is internally consistent
# Always exits 0 — this is a reporting hook, not a blocker
# Note: BASH_SOURCE path resolution may behave unexpectedly under Git Bash
# on Windows — this script is designed for Linux/Mac deployment environments

set -euo pipefail

FRAMEWORK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLAUDE_DIR="$FRAMEWORK_ROOT/.claude"

echo "=== AI-Builder-System Framework Validation ==="
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
    echo "PHANTOM AGENT REFERENCE: $agent still referenced in files" >&2
    ALL_GOOD=false
  fi
done

if grep -rE "C:\\\\Users\\\\[a-zA-Z]+" "$CLAUDE_DIR" --include="*.md" -l 2>/dev/null | grep -q .; then
  echo "HARDCODED PATH: Personal Windows path still exists in framework files" >&2
  ALL_GOOD=false
fi

if [ "$ALL_GOOD" = true ]; then
  echo "All validation checks passed."
else
  echo "Validation completed with warnings — review items above."
fi

exit 0
