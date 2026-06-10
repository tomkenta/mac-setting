#!/bin/bash
# Mac キッティング自動化スクリプト (Apple Silicon)
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES=~/src/github.com/tomkenta/dotfiles

echo "==> [1/7] Homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

echo "==> [2/7] brew bundle (失敗したパッケージはスキップ)"
export HOMEBREW_CASK_OPTS="--appdir=~/Applications"
brew bundle --file="$REPO_DIR/Brewfile" || true

echo "==> [3/7] dotfiles"
[ -d "$DOTFILES" ] || git clone https://github.com/tomkenta/dotfiles.git "$DOTFILES"

for f in \
  .zprofile \
  .zshrc \
  .bash_profile \
  .bashrc \
  .vimrc \
  .tmux.conf \
  .gitconfig \
  .gitattributes \
  .gitignore_global; do
  ln -sf "$DOTFILES/$f" ~/"$f"
done

# ~/.config は丸ごとリンクせず必要なサブディレクトリのみリンク
# (丸ごとリンクすると他ツールの設定を壊す & git repo が汚れる)
mkdir -p ~/.config
ln -sfn "$DOTFILES/.config/fish"      ~/.config/fish
ln -sfn "$DOTFILES/.config/karabiner" ~/.config/karabiner
ln -sfn "$DOTFILES/.config/ghostty"   ~/.config/ghostty

# Claude Code の自作スクリプト（個別ファイルのみリンク。~/.claude はツール管理ディレクトリ）
mkdir -p ~/.claude
ln -sf "$DOTFILES/.claude/statusline.sh"         ~/.claude/statusline.sh
ln -sf "$DOTFILES/.claude/statusline-command.sh" ~/.claude/statusline-command.sh

echo "==> [4/7] VS Code 設定"
VSCODE_USER=~/Library/Application\ Support/Code/User
mkdir -p "$VSCODE_USER"
cp "$REPO_DIR/vscode/settings.json"    "$VSCODE_USER/settings.json"
cp "$REPO_DIR/vscode/keybindings.json" "$VSCODE_USER/keybindings.json"

echo "==> [5/7] tmux プラグイン"
TMUX_PLUGINS=~/.tmux/plugins
mkdir -p "$TMUX_PLUGINS"
for repo in tpm tmux-battery tmux-cpu tmux-resurrect; do
  [ -d "$TMUX_PLUGINS/$repo" ] || \
    git clone "https://github.com/tmux-plugins/$repo.git" "$TMUX_PLUGINS/$repo"
done

echo "==> [6/7] fisher"
mkdir -p "$DOTFILES/.config/fish/functions"
[ -f "$DOTFILES/.config/fish/functions/fisher.fish" ] || \
  curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish \
    -o "$DOTFILES/.config/fish/functions/fisher.fish"

echo "==> [7/7] macOS defaults"
defaults write NSGlobalDomain InitialKeyRepeat         -int 15
defaults write NSGlobalDomain KeyRepeat                -int 2
defaults write NSGlobalDomain AppleKeyboardUIMode      -int 3
defaults write com.apple.dock autohide                 -bool true
defaults write com.apple.dock static-only              -bool true
defaults write com.apple.dock wvous-br-corner          -int 5
defaults write com.apple.dock wvous-br-modifier        -int 0
defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1
killall Dock 2>/dev/null || true

echo ""
echo "セットアップ完了。"
echo "次の手動設定:"
echo "  - git ユーザ設定: git config --global user.name \"<名前>\" && git config --global user.email \"<メール>\""
echo "  - 秘密情報: ~/.zshrc.local を作成し export BUFFER_API_KEY=... 等を記載"
echo "  - Touch ID / Alfred Powerpack / Rectangle インポート / Google Chrome ログイン"
