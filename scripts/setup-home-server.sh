#!/bin/bash
# macOS を家庭内LAN向けのヘッドレスサーバとして設定する。
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "このスクリプトはmacOS専用です。" >&2
  exit 1
fi

TARGET_USER="${SUDO_USER:-$USER}"
FIREWALL="/usr/libexec/ApplicationFirewall/socketfilterfw"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! id "$TARGET_USER" >/dev/null 2>&1; then
  echo "設定対象ユーザが見つかりません: $TARGET_USER" >&2
  exit 1
fi

echo "==> 管理者権限を確認"
sudo -v

echo "==> SSH（リモートログイン）を有効化"
sudo systemsetup -setremotelogin on

# com.apple.access_ssh が存在すると、そのメンバーだけがSSH接続できる。
# 既存メンバーは削除せず、実行ユーザを追加する。
if ! dscl . -read /Groups/com.apple.access_ssh >/dev/null 2>&1; then
  sudo dseditgroup -o create com.apple.access_ssh
fi
sudo dseditgroup -o edit -a "$TARGET_USER" -t user com.apple.access_ssh

echo "==> 常時稼働と停電復旧を設定"
sudo pmset -a sleep 0
sudo pmset -a womp 1
sudo pmset -a autorestart 1

echo "==> アプリケーションファイアウォールを設定"
sudo "$FIREWALL" --setglobalstate on
sudo "$FIREWALL" --setblockall off
sudo "$FIREWALL" --setallowsigned on
sudo "$FIREWALL" --setallowsignedapp on
sudo "$FIREWALL" --setstealthmode on

echo "==> 外出先アクセス用のTailscaleを準備"
"$SCRIPT_DIR/setup-tailscale.sh"

echo
echo "==> 設定結果"
sudo systemsetup -getremotelogin
sudo "$FIREWALL" --getglobalstate
sudo "$FIREWALL" --getblockall
sudo "$FIREWALL" --getallowsigned
sudo "$FIREWALL" --getstealthmode
pmset -g custom

echo
echo "ホームサーバーの基本設定が完了しました。"
echo "SSH許可ユーザ: $TARGET_USER"
echo "Tailscaleの初回認証を完了し、残りの手動設定は docs/home-server.md を確認してください。"
