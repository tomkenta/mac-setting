#!/bin/bash
# Explicit synchronization only. Never reset, stash, or auto-commit user work.
set -euo pipefail
REPO_ROOT="${WORKSPACE_ROOT:-$HOME/src/github.com/tomkenta}"
mkdir -p "$REPO_ROOT"
failed=0
for name in mac-setting dotfiles external_brain x-posting; do
  target="$REPO_ROOT/$name"
  url="https://github.com/tomkenta/$name.git"
  if [ ! -e "$target" ]; then
    if git clone "$url" "$target"; then
      echo "OK cloned $name"
    else
      echo "ERROR clone $name (check GitHub authentication)" >&2
      failed=1
    fi
    continue
  fi
  if [ -L "$target" ] || [ ! -d "$target/.git" ]; then
    echo "ERROR $name is not an independent checkout" >&2
    failed=1
    continue
  fi
  origin="$(git -C "$target" remote get-url origin)"
  if [ "$origin" != "$url" ] && [ "$origin" != "git@github.com:tomkenta/$name.git" ]; then
    echo "ERROR unexpected origin for $name" >&2
    failed=1
    continue
  fi
  if [ -n "$(git -C "$target" status --porcelain --untracked-files=all)" ]; then
    echo "SKIP $name: uncommitted changes; leave untouched" >&2
    failed=1
    continue
  fi
  if ! git -C "$target" symbolic-ref -q HEAD >/dev/null ||
     ! git -C "$target" rev-parse --verify '@{upstream}' >/dev/null 2>&1; then
    echo "SKIP $name: detached HEAD or no upstream" >&2
    failed=1
    continue
  fi
  if git -C "$target" pull --ff-only; then
    echo "OK synced $name"
  else
    echo "ERROR sync $name: resolve authentication/divergence explicitly" >&2
    failed=1
  fi
done
exit "$failed"
