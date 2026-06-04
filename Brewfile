# Brewfile - Mac キッティング用パッケージ定義
#
# 使い方:  brew bundle    (このファイルのあるディレクトリで実行)
# 現況の同期: brew bundle dump --force   で再生成できる
#
# 対象環境: macOS (Apple Silicon / arm64) / Homebrew @ /opt/homebrew

# ---- taps ----
tap "homebrew/bundle"

# =====================================================================
# Homebrew formulae (CLI)
# =====================================================================

# --- shell / 環境管理 ---
brew "fish"            # メインシェル
brew "bash-completion"
brew "anyenv"          # nodenv 等のバージョン管理をまとめる

# --- git まわり ---
brew "git"
brew "gh"              # GitHub CLI
brew "hub"
brew "ghq"             # リポジトリを ~/src 配下に一元管理
brew "tig"

# --- CLI ユーティリティ ---
brew "vim"
brew "tmux"
brew "tree"
brew "wget"
brew "jq"
brew "fzf"
brew "peco"
brew "ripgrep"
brew "colordiff"
brew "gnu-sed"
brew "nkf"
brew "q"

# --- 言語 / ランタイム ---
brew "node"
brew "yarn"
brew "uv"              # Python パッケージ/環境マネージャ

# --- クラウド / インフラ ---
brew "ansible"
brew "awscli"
brew "cloudflared"
brew "hugo"
brew "mas"             # Mac App Store CLI

# --- ビルド依存 (他ツールが要求。明示保持) ---
brew "automake"
brew "libtool"
brew "libpng"
brew "nasm"
brew "pkgconf"
brew "dpkg"

# =====================================================================
# Casks (GUI アプリ)  ※現況を全ミラー
# =====================================================================

# --- エディタ / 開発 / ターミナル ---
cask "visual-studio-code"
cask "cursor"
cask "ghostty"
cask "tabby"
cask "docker-desktop"
cask "postman"
cask "sequel-pro"
cask "charles"
cask "cyberduck"
cask "openinterminal"

# --- AI ツール ---
cask "claude"
cask "codex"
cask "codex-app"
cask "cmux"
cask "chatgpt-atlas"
cask "superwhisper"

# --- 生産性 / ユーティリティ ---
cask "alfred"
cask "rectangle"
cask "karabiner-elements"
cask "bartender"
cask "appcleaner"
cask "cleanshot"
cask "textsniper"
cask "the-unarchiver"
cask "setapp"
cask "toggl-track"

# --- ノート / ドキュメント / デザイン ---
cask "notion"
cask "obsidian"
cask "dynalist"
cask "figma"
cask "libreoffice"
cask "plaud"

# --- ブラウザ ---
cask "google-chrome"
cask "chromium"

# --- コミュニケーション ---
cask "slack"
cask "viber"
cask "zoom"

# --- フォント ---
cask "font-hackgen"

# =====================================================================
# VS Code 拡張
# =====================================================================
vscode "esbenp.prettier-vscode"
vscode "mechatroner.rainbow-csv"
vscode "octref.vetur"
vscode "openai.chatgpt"
vscode "silvenon.mdx"

# =====================================================================
# npm グローバル (任意。corepack 経由で yarn/pnpm を有効化)
# =====================================================================
npm "corepack"
npm "gatsby-cli"
