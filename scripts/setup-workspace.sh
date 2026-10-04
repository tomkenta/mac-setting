#!/bin/bash
# Settings/repositories only. Does not install packages or alter OS services.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="${WORKSPACE_ROOT:-$HOME/src/github.com/tomkenta}"
profile=client
case "${1:-}" in
  "") ;;
  --server) profile=server ;;
  *) echo "Usage: $0 [--server]" >&2; exit 2 ;;
esac
"$SCRIPT_DIR/sync-repos.sh"
if [ "$profile" = server ]; then
  sh "$REPO_ROOT/dotfiles/install.sh" --server
else
  sh "$REPO_ROOT/dotfiles/install.sh"
fi
echo "Workspace ready at $REPO_ROOT (authentication is machine-local)."
