#!/bin/bash
# Keep machine-local credential helpers out of tracked dotfiles symlinks.
set -euo pipefail
gh auth status >/dev/null
GH_BIN="$(command -v gh)"
LOCAL_CONFIG="$HOME/.config/git/config.local"
mkdir -p "$(dirname "$LOCAL_CONFIG")"
for host in github.com gist.github.com; do
  git config --file "$LOCAL_CONFIG" --replace-all "credential.https://$host.helper" ""
  git config --file "$LOCAL_CONFIG" --add "credential.https://$host.helper" "!$GH_BIN auth git-credential"
done
echo "Git credential helpers configured in $LOCAL_CONFIG (no token copied)."
