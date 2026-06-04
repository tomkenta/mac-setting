# mac-setting — Mac キッティング自動化

新しい Mac を最短で普段の作業環境にするための自動構築設定。

対象環境: **macOS (Apple Silicon / arm64)** / Homebrew は `/opt/homebrew`。

---

## クイックスタート

```sh
# 1. setting.sh を取得して実行 (Homebrew導入 → リポジトリ取得 → brew bundle → ansible)
curl -fsSL -O https://raw.githubusercontent.com/tomkenta/mac-setting/master/setting.sh
chmod +x ./setting.sh
./setting.sh
```

> `brew bundle` のアプリ群インストールで 30分〜1時間ほどかかる。
> その間に下記「GUIで手動設定する項目」を進めると効率的。

リポジトリは ghq root に合わせて `~/src/github.com/tomkenta/mac-setting` に取得される。

### 何が起きるか (setting.sh)
1. Homebrew をインストール
2. `brew shellenv` で PATH を通す (Apple Silicon: `/opt/homebrew`)
3. このリポジトリを `~/src/github.com/tomkenta/mac-setting` に clone
4. `brew bundle` で CLI / GUIアプリ / VS Code拡張を一括インストール（→ `Brewfile`）
5. `ansible-playbook` で macOS設定・dotfiles・tmux・fisher を適用（→ `localhost.yml`）

### 部分的に再実行したいとき
```sh
cd ~/src/github.com/tomkenta/mac-setting
brew bundle                                   # アプリだけ追加インストール
ansible-playbook -i inventory/localhost localhost.yml --tags dotfiles   # dotfilesだけ等
```

---

## ディレクトリ構成

```
mac-setting/
├── Brewfile          # CLI / cask / VS Code拡張 の定義 (インストールの単一の真実)
├── setting.sh        # ブートストラップスクリプト
├── localhost.yml     # ansible エントリ (roles: osx, dotfiles, vscode, tmux, fisherman)
├── group_vars/       # dotfiles のリンク対象定義
├── roles/
│   ├── osx/          # macOSの defaults 設定
│   ├── dotfiles/     # dotfilesリポジトリの取得とシンボリックリンク
│   ├── vscode/       # settings/keybindings 配置・拡張インストール
│   ├── tmux/         # tpm 等のプラグイン取得
│   └── fisherman/    # fish プラグインマネージャ fisher の導入
├── RectangleConfig.json
└── alfred/           # Alfred 設定 (同期フォルダとして指定)
```

dotfiles 本体は別リポジトリ: `~/src/github.com/tomkenta/dotfiles`

---

## GUIで手動設定する項目

自動化できない（あるいは GUI が確実な）もの。

### システム設定
- **Touch ID**: 指紋を登録（Mac のロック解除 / パスワード自動入力）
- **キーボード > 修飾キー**: Caps Lock ⇄ Control を入れ替え
  （Karabiner でも対応するが、ログイン画面用に OS 側でも設定）
- **トラックパッド > ドラッグ**: 3本指ドラッグ等は「アクセシビリティ > ポインタ制御 > トラックパッドオプション」
- **コントロールセンター > バッテリー**: 「割合(%)を表示」をON（macOS 11以降は defaults で効かない）

### Alfred (Powerpack)
1. アクティベーションコードでPowerpackを有効化
2. Preferences > Advanced > Syncing で同期フォルダに `alfred/Alfred.alfredpreferences` を指定
3. Spotlight のホットキー(⌘Space)をOFFにし、Alfred のホットキーを ⌘Space に変更
   - 参考: https://www.alfredapp.com/help/advanced/sync/

### Rectangle
- 起動 → `RectangleConfig.json` をインポート

### 日本語入力 (Google 日本語入力 / ライブ変換)
- システム設定 > キーボード > 入力ソース で追加。`ctrl + space` で切替

### Karabiner-Elements
- 起動すると `~/.config/karabiner/`（dotfilesからリンク）の設定が読まれる
- 主な設定: Caps/Ctrl入れ替え、左右⌘単押しで英数/かな、Esc/Ctrl+[ で英数も送出（vim用）

### Google Chrome
- Googleアカウントでログイン → ブックマーク/拡張を同期
- よく使う拡張:
  - Google Search Keyboard Shortcuts（検索結果を j/k で移動）
  - Copy Title and Url as Markdown Style
  - GoFullPage（フルページスクショ）
  - Proxy SwitchyOmega（プロキシ管理）
  - Vimium（j/k は Google検索では除外）
  - Grammarly / Block Site / daily.dev

### クラウドストレージ
- Box / Dropbox を入れて共有・バックアップ先をリンク

---

## メンテナンス

現在のマシンの状態を Brewfile に書き戻すには:

```sh
cd ~/src/github.com/tomkenta/mac-setting
brew bundle dump --force --file=Brewfile     # ※カテゴリのコメントは消えるので注意
```

差分だけ取り込みたい場合は `brew bundle dump` を別ファイルに出して手で反映する。
