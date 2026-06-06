# mac-setting — Mac キッティング自動化

新しい Mac を最短で普段の作業環境にするための自動構築設定。

対象環境: **macOS (Apple Silicon / arm64)** / Homebrew は `/opt/homebrew`。

---

## クイックスタート

```sh
# setup.sh を取得して実行
curl -fsSL -O https://raw.githubusercontent.com/tomkenta/mac-setting/master/setup.sh
chmod +x ./setup.sh
./setup.sh
```

> `brew bundle` のアプリ群インストールで 30分〜1時間ほどかかる。
> その間に下記「GUIで手動設定する項目」を進めると効率的。

リポジトリは `~/src/github.com/tomkenta/mac-setting` に clone される。

### setup.sh がやること

| ステップ | 内容 |
|---------|------|
| 1 | Homebrew インストール |
| 2 | `brew bundle` — CLI / cask / VS Code 拡張を一括インストール |
| 3 | dotfiles clone + symlink（`~/.gitconfig` 等） |
| 4 | VS Code の settings.json / keybindings.json を配置 |
| 5 | tmux プラグイン (tpm, battery, cpu, resurrect) を clone |
| 6 | fisher (fish プラグインマネージャ) をダウンロード |
| 7 | macOS defaults (キーリピート / Dock / トラックパッド等) を適用 |

### 部分的に再実行したいとき

```sh
cd ~/src/github.com/tomkenta/mac-setting
brew bundle                  # アプリだけ追加
./setup.sh                   # 全体を再実行 (冪等)
```

---

## ディレクトリ構成

```
mac-setting/
├── setup.sh             # ブートストラップスクリプト (全工程)
├── Brewfile             # CLI / cask / VS Code 拡張の定義
├── vscode/
│   ├── settings.json
│   └── keybindings.json
├── RectangleConfig.json
└── alfred/              # Alfred 設定 (同期フォルダとして指定)
```

dotfiles 本体は別リポジトリ: `~/src/github.com/tomkenta/dotfiles`

---

## GUIで手動設定する項目

### システム設定
- **Touch ID**: 指紋を登録（Mac のロック解除 / パスワード自動入力）
- **キーボード > 修飾キー**: Caps Lock ⇄ Control を入れ替え
- **トラックパッド > ドラッグ**: アクセシビリティ > ポインタ制御 > トラックパッドオプション
- **コントロールセンター > バッテリー**: 「割合(%)を表示」をON（macOS 11以降は defaults で効かない）

### Alfred (Powerpack)
1. アクティベーションコードで有効化
2. Preferences > Advanced > Syncing → `alfred/Alfred.alfredpreferences` を指定
3. Spotlight のホットキー (⌘Space) をOFF → Alfred に割り当て
   - 参考: https://www.alfredapp.com/help/advanced/sync/

### Rectangle
- 起動 → `RectangleConfig.json` をインポート

### 日本語入力 (Google 日本語入力)
- システム設定 > キーボード > 入力ソース で追加。`ctrl + space` で切替

### Karabiner-Elements
- 起動すると `~/.config/karabiner/`（dotfiles からリンク）の設定が読まれる
- 主な設定: Caps/Ctrl 入れ替え、左右⌘単押しで英数/かな、Esc で英数も送出（vim 用）

### Google Chrome
- Google アカウントでログイン → ブックマーク/拡張を同期
- よく使う拡張: Google Search Keyboard Shortcuts / Copy Title and Url as Markdown Style /
  GoFullPage / Proxy SwitchyOmega / Vimium / Grammarly / daily.dev

### クラウドストレージ
- Box / Dropbox でバックアップ先をリンク

---

## メンテナンス

現在のマシンの状態を Brewfile に書き戻すには:

```sh
cd ~/src/github.com/tomkenta/mac-setting
brew bundle dump --force --file=Brewfile.new   # カテゴリコメントが消えるため別ファイルに出して比較
```
