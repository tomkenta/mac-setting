#!/bin/bash
# Shared tools only; no macOS settings, services, or n8n restarts.
set -euo pipefail
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
else
  echo "Homebrew is required; run the appropriate OS setup first." >&2
  exit 1
fi
export PATH="$(brew --prefix)/opt/node@24/bin:$PATH"
brew bundle --file="$REPO_DIR/Brewfile.common"
