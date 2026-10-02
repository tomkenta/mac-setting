#!/bin/bash
# One manual AI smoke test; no installs or macOS setting changes.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PYTHON="$HOME/.local/share/kenta-os/python/bin/python"
if [ ! -x "$PYTHON" ]; then
  echo "Server Python is missing. Complete setup-server.sh first." >&2
  exit 1
fi

# SSH commands don't necessarily load .zprofile or the interactive shell PATH.
export PATH="$HOME/.local/bin:/opt/homebrew/opt/node@24/bin:/opt/homebrew/bin:/usr/local/opt/node@24/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
exec "$PYTHON" "$SCRIPT_DIR/ai_smoke.py"
