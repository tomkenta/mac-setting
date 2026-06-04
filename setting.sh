#!/bin/bash
set -euo pipefail

## このリポジトリの配置先 (ghq root = ~/src に統一)
REPO_PATH=~/src/github.com/tomkenta/mac-setting

## 1. Homebrew をインストール
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

## 2. PATH を通す (Apple Silicon は /opt/homebrew)
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
fi

## 3. このリポジトリを取得 (既にあればスキップ)
if [ ! -d "${REPO_PATH}" ]; then
  git clone https://github.com/tomkenta/mac-setting.git "${REPO_PATH}"
fi
cd "${REPO_PATH}"

## 4. Brewfile で各種アプリ/CLI/VS Code拡張をインストール
brew bundle --file="${REPO_PATH}/Brewfile"

## 5. macOS設定・dotfiles・tmux・fisher 等を ansible で適用
ansible-playbook -i inventory/localhost localhost.yml
