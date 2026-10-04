# mac-setting

## 1. 目的

クライアントMac（MacBook Air）とサーバーMac（Mac mini）に、共通のAI作業ツールと用途別の環境を構築する。

アプリ・CLIの導入とmacOSの設定をこのリポジトリで管理し、シェル・Git・AI指示などの個人設定は [dotfiles](https://github.com/tomkenta/dotfiles) に任せる。

## 2. 対象・対象外

| 対象 | 管理するもの |
|---|---|
| 共通 | Git・gh・ghq・tmux・Node.js 24・uv・シェル補助ツール・Claude/Codex CLI・Claude・Chrome・Tailscale |
| クライアントMac | クライアント用アプリ、VS Code設定、tmuxプラグイン、キーボード・Dock・トラックパッド設定 |
| サーバーMac | SSH・画面共有・ファイアウォール・電源設定、n8n常駐、Python 3.12・LangGraph |
| 作業リポジトリ | mac-setting・dotfiles・external_brain・x-postingの明示的な取得・更新 |

対象端末はmacOSの個人用Mac。クライアントの一括セットアップはApple Silicon前提、サーバーもApple Silicon向けに設計している。Intelでの一括セットアップは保証しない。

管理しないもの:

- dotfilesの設定内容（別リポジトリで管理）
- パスワード・APIキー・ブラウザのログイン状態の同期
- GitHub・Tailscale・Claude・Codexなどの本人認証
- リポジトリの自動定期同期、未コミット変更の端末間転送
- 業務自動化の内容、n8nの本番ワークフロー、AIの24時間自律稼働の保証

## 3. 構成

### パッケージと端末別設定

```text
Brewfile.common ─┬─ Brewfile        ← setup.sh（クライアント）
                └─ Brewfile.server ← setup-server.sh（サーバー）

setup.sh
  └─ scripts/setup-workspace.sh
       ├─ scripts/sync-repos.sh
       └─ dotfiles/install.sh

setup-server.sh
  └─ OS・パッケージ・n8n・Pythonを設定
     作業リポジトリ／dotfilesは別途 setup-workspace.sh --server
```

| ファイル | 責務 |
|---|---|
| `Brewfile.common` | 両端末で使う共通パッケージ |
| `Brewfile` / `Brewfile.server` | 共通パッケージを読み込み、端末固有のパッケージを追加 |
| `setup.sh` | クライアントの一括セットアップ |
| `setup-server.sh` | サーバーの一括セットアップ |
| `scripts/install-work-tools.sh` | 共通パッケージのみ導入。OS設定やn8n再起動はしない |
| `scripts/setup-git-auth.sh` | GitHub認証helperを端末ローカルのGit設定に登録 |
| `scripts/sync-repos.sh` | 4リポジトリをclone／pull。設定適用はしない |
| `scripts/setup-workspace.sh` | リポジトリ同期後、dotfilesのinstall.shを呼ぶ |
| `server/healthcheck.sh` | サーバーのサービスと主要依存を確認 |

作業リポジトリの標準配置は `~/src/github.com/tomkenta/{mac-setting,dotfiles,external_brain,x-posting}`。
ワークスペース関連スクリプトは環境変数 `WORKSPACE_ROOT` で配置先を変更できる。

### dotfilesとの分担

mac-settingは「ツールを入れる・OSを設定する・設定適用を呼ぶ」担当。
dotfilesは「管理対象の個人設定をホームへ配置する」担当で、パッケージ導入は行わない。

`setup-workspace.sh` は、取得したdotfilesの `install.sh` を直接実行する。
`--server` を指定すると、dotfilesもサーバープロファイルで適用する。

## 4. 使い方

### 前提条件

- macOSの初期セットアップと管理者アカウントの作成が済んでいること。
- インターネット接続とGitが使えること。Gitが未導入なら `xcode-select --install` でCommand Line Toolsを導入する。
- サーバーでは、実行するTerminal等へ「システム設定 → プライバシーとセキュリティ → フルディスクアクセス」を許可すること。SSHの有効化に必要。
- privateリポジトリ取得にはGitHub認証が必要。

まず、このリポジトリを標準配置へ取得する。

```sh
mkdir -p ~/src/github.com/tomkenta
git clone https://github.com/tomkenta/mac-setting.git ~/src/github.com/tomkenta/mac-setting
cd ~/src/github.com/tomkenta/mac-setting
```

取得済みならcloneを繰り返さず、既存のディレクトリへ移動する。

### 初回セットアップ：クライアントMac

`setup.sh` は途中でprivateリポジトリも取得するため、先にHomebrew・共通ツールとGitHub認証を準備する。
Homebrew未導入の場合は [公式手順](https://brew.sh/) で導入し、案内されるshellenvを実行する。

```sh
./scripts/install-work-tools.sh
gh auth login
./scripts/setup-git-auth.sh
./setup.sh
```

最後に、各アプリのログイン、TailscaleのVPN・システム拡張許可、Touch ID、Alfredのライセンス・設定フォルダ指定、Rectangleの設定インポートなどを手動で行う。

### 初回セットアップ：サーバーMac

```sh
./setup-server.sh
gh auth login
./scripts/setup-git-auth.sh
./scripts/setup-workspace.sh --server
./server/healthcheck.sh
```

TailscaleへログインしてVPN・システム拡張を許可し、Claude/Codexにもログインする。
ブラウザ拡張・リモート操作の接続許可とサービスへのログインは端末ごとに行う。

n8nはChromeで <http://localhost:5678> を開き、初回のownerアカウントを作成する。
別端末からはTailscale接続後にSSHトンネルを使う。

```sh
ssh -L 5678:127.0.0.1:5678 <user>@<tailscale-hostname>
```

トンネル接続中、手元のChromeで <http://localhost:5678> を開く。
画面共有はFinderの「移動 → サーバへ接続」で `vnc://<tailscale-hostname>` を指定する。

### 既存環境への再適用

必要な部分だけ実行する。一括セットアップはOS設定やサービスにも影響する。

| やりたいこと | コマンド（mac-setting内で実行） |
|---|---|
| 共通ツールだけ導入・更新 | `./scripts/install-work-tools.sh` |
| リポジトリを同期して設定適用：クライアント | `./scripts/setup-workspace.sh` |
| リポジトリを同期して設定適用：サーバー | `./scripts/setup-workspace.sh --server` |
| 同期せずdotfilesだけ再適用：クライアント | `sh ../dotfiles/install.sh` |
| 同期せずdotfilesだけ再適用：サーバー | `sh ../dotfiles/install.sh --server` |

上記のdotfiles直接実行は標準配置の場合。取得先を変更した場合は実際のパスを指定する。

### 更新

```sh
./scripts/sync-repos.sh
```

未取得ならclone、取得済みなら `git pull --ff-only` を実行する。パッケージの更新やdotfilesの再適用は別操作。
dotfilesのリンク済みファイルはpull後の内容が参照されるため、更新は稼働中の設定にも影響し得る。Codexのマージ設定や新しいリンクの追加には再適用が必要。

同期前に各リポジトリの変更を確認する。ノートを含め同じファイルの端末間同時編集を避ける。
未コミットの内容は同期されない。

### 状態確認

```sh
git status --short
brew bundle check --file=Brewfile.common
# クライアントのパッケージ
brew bundle check --file=Brewfile
# サーバーのパッケージ・サービス
brew bundle check --file=Brewfile.server
./server/healthcheck.sh
```

自分の端末に対応するチェックだけ実行する。パッケージチェックはログインやブラウザ接続の確認にはならない。
サーバーの追加手順は [ホームサーバー手順](docs/home-server.md)、任意の単発AI試験は [動作テスト](docs/ai-smoke-test.md) を参照する。

## 5. 注意事項

### 上書き・サービスへの影響

- クライアントはVS Codeの設定リンクとmacOS defaultsを変更し、Dockを再起動する。
- dotfilesの管理対象ファイルは置き換える。詳細は [dotfiles README](https://github.com/tomkenta/dotfiles#readme) を確認し、既存設定を退避してから適用する。
- サーバーはSSH・画面共有・ファイアウォール・電源設定を変更する。画面共有を再起動するため、接続が切れる可能性がある。
- サーバーの再実行ではn8nの依存をrebuildし、LaunchDaemon設定を上書きしてn8nを再起動する。データと既存の空でない暗号化キーは保持する。バックアップの代わりにはならない。

n8nデータは `~/Library/Application Support/KentaOS/n8n`、ログは `~/Library/Logs/KentaOS`、
Python環境は `~/.local/share/kenta-os/python` に置く。n8nは `127.0.0.1:5678` のみで待ち受け、直接外部公開しない。

### 認証・端末ローカル設定

Git identityは `~/.config/git/config.local`、シェルの秘密情報は `~/.config/zsh/.zshrc.local` に置き、Gitへ登録しない。
Git identity未設定ではdotfilesの `useConfigOnly=true` によりcommitを拒否する。
認証helper登録には `scripts/setup-git-auth.sh` を使う。`gh auth setup-git` はリンクされた管理対象設定を書き換える場合がある。

Tailscale・GitHub・AIツール・ブラウザの認証は手動。FileVault有効時は、再起動後に現地でのロック解除が必要になる場合がある。

### 再実行時の挙動・既知の制約

- 完全な冪等性や同一バージョンの再現は保証しない。パッケージは更新され得る。
- 同期は未コミット変更（未追跡ファイルを含む）、detached HEAD、upstream未設定、想定外origin、非独立checkoutを検出すると、そのリポジトリを変更せず失敗扱いにする。他のリポジトリの同期は続くため、処理全体は一括ロールバックされない。
- originの許容形式は `https://github.com/tomkenta/<repo>.git` と `git@github.com:tomkenta/<repo>.git` のみ。`ssh://git@github.com/...` は現状拒否する。
- 同期が一つでも失敗すると、`setup-workspace.sh` はdotfiles適用前に止まる。設定だけ適用したい場合はdotfilesを直接実行する。
- `setup.sh` はbrew bundleの失敗後も続行する。`setup-server.sh` は最後のhealthcheck失敗でも完了表示する。完了メッセージだけで成功判定せず、個別チェックを確認する。
- 自動バックアップ・ロールバックはない。会社PCへの適用は対象外とし、機密情報をリポジトリへ持ち込まない。
