#!/bin/bash
# Tailscale Standalone版をインストールし、初回認証を開始する。
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "このスクリプトはmacOS専用です。" >&2
  exit 1
fi

if [[ -d "/Applications/Tailscale.app" ]]; then
  echo "==> Tailscaleはインストール済みです"
else
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrewが必要です。先にリポジトリ直下の ./setup.sh を実行してください。" >&2
    exit 1
  fi

  echo "==> Tailscale Standalone版をインストール"
  brew install --cask tailscale-app
fi

echo "==> Tailscaleを起動"
open -a Tailscale

cat <<'MESSAGE'

Tailscaleアプリで次の手動操作を行ってください。
  1. 自分のアカウントでサインインする
  2. VPN構成とシステム拡張を許可する
  3. 外出先で使う端末にもTailscaleをインストールし、同じtailnetへ接続する

macOSの通常のSSHをTailscale経由で使います。Tailscale SSHは有効化しません。
接続方法と確認手順は docs/home-server.md を参照してください。
MESSAGE
