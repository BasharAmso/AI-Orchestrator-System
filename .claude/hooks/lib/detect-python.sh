#!/usr/bin/env bash
# Shared Python detection — sourced by all hooks that need Python.
# Sets PYTHON to the first available Python interpreter.
# If no Python is found, prints a warning and sets PYTHON to "false"
# so downstream commands fail gracefully instead of running garbage.
#
# Windows fix: Check known install paths first to bypass Microsoft Store
# app execution aliases (which redirect to the Store instead of running code).

# Check known Windows install paths first
_USER="${USER:-${USERNAME:-$(whoami 2>/dev/null || echo unknown)}}"
for CANDIDATE in \
  "/c/Users/$_USER/AppData/Local/Programs/Python/Python312/python.exe" \
  "/c/Users/$_USER/AppData/Local/Programs/Python/Python311/python.exe" \
  "/c/Users/$_USER/AppData/Local/Programs/Python/Python310/python.exe" \
  "/c/Program Files/Python312/python.exe" \
  "/c/Program Files/Python311/python.exe"; do
  if [ -x "$CANDIDATE" ] && "$CANDIDATE" -c "import sys" 2>/dev/null; then
    PYTHON="$CANDIDATE"
    return 0 2>/dev/null || exit 0
  fi
done

# Fall back to PATH-based detection
if python3 -c "import sys" 2>/dev/null; then
  PYTHON=python3
elif python -c "import sys; assert sys.version_info >= (3, 6)" 2>/dev/null; then
  PYTHON=python
else
  PYTHON=false
  echo "WARNING: No Python interpreter found. Some hook checks will be skipped." >&2
fi
