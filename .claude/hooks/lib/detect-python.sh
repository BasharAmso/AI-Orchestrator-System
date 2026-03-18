#!/usr/bin/env bash
# Shared Python detection — sourced by all hooks that need Python.
# Sets PYTHON to the first available Python interpreter.
# If no Python is found, prints a warning and sets PYTHON to "false"
# so downstream commands fail gracefully instead of running garbage.

if python3 -c "import sys" 2>/dev/null; then
  PYTHON=python3
elif python -c "import sys" 2>/dev/null; then
  PYTHON=python
else
  PYTHON=false
  echo "WARNING: No Python interpreter found. Some hook checks will be skipped." >&2
fi
