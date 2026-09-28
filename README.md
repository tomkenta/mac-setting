# Mac 用の環境構築自動化設定ファイル

このリポジトリは、用途ごとに2つのセットアップを提供する。

- `setup.sh`: 普段使いのクライアントMac
- `setup-server.sh`: 24時間稼働するMac miniサーバー

## Mac miniサーバー

```sh
git clone https://github.com/tomkenta/mac-setting.git
cd mac-setting
./setup-server.sh
```

サーバー用セットアップは、クライアント用の`Brewfile`を参照しない。専用の
`Brewfile.server`だけを使い、次を構成する。

- SSH（リモートログイン）と画面共有
- macOSファイアウォールとサーバー向け電源設定
- Tailscale
- n8n（ユーザー権限のLaunchDaemonとして常時起動）
- Claude CodeとCodex CLI
- Python 3.12環境、uv、LangGraph

n8nはインターネットやLANへ直接公開せず、`127.0.0.1:5678`だけで待ち受ける。
外出先からはTailscale経由のSSHトンネルを使う。

```sh
ssh -L 5678:127.0.0.1:5678 <user>@<tailscale-hostname>
```

接続中に手元のブラウザで <http://127.0.0.1:5678> を開く。セットアップ後の確認は
次で行う。

```sh
./server/healthcheck.sh
```

画面共有は、Tailscale接続後にFinderの「移動 > サーバへ接続」から
`vnc://<tailscale-hostname>`を開く。LangGraph用Python環境は次で有効化する。

```sh
source "$HOME/.local/share/kenta-os/python/bin/activate"
```

Tailscale、Claude Code、Codexは初回のみ対話的なログインが必要。FileVaultが有効な
Macは、停電からの再起動後にローカルでのロック解除が必要になる場合がある。

## クライアントMac

```
git clone https://github.com/tomkenta/mac-setting.git
cd mac-setting
./setup.sh
```

`./setup.sh` will take 30mins - 1 hours. Do something else

ex.
1. System Settings > Keyboard > modifier key > swap caps and control
2. System Settings > Accessibility > Keyboard > Trackpad option > enable dragging > without drag lock  

others,. do others related to your job

## 構成と設計方針

このリポジトリ (`mac-setting`) は **Mac キッティングのオーケストレーション**。
個人の portable な設定は別リポジトリ **[dotfiles](https://github.com/tomkenta/dotfiles)** が持ち、
`setup.sh` が symlink で配置する。

- `mac-setting`: `setup.sh`（手順）/ `Brewfile`（アプリ・CLI）/ アプリ別設定（`vscode/` `alfred/` `RectangleConfig.json`）
- `dotfiles`: `.gitconfig` / fish / karabiner / git hooks など。個人設定の単一の源。

### セキュリティ設計（要点）
- **編集・push は個人マシンから。会社PCは clone/pull（参照）のみ。**
  会社環境でのコミットは identity（社用メール・社内ホスト名）の焼き付きや機密の巻き込みを招くため。
- **identity をホスト名から自動生成させない** — dotfiles `.gitconfig` の `useConfigOnly = true`。
  未設定のまま commit するとエラーになり、`名前@ホスト名` の混入を防ぐ。
- **全 repo で gitleaks スキャン** — dotfiles の `core.hooksPath` → pre-commit / pre-push で実行。
- **機密の "具体値" はどの repo にも置かない** — gitleaks の具体ルール（前職ドメイン等）は
  `~/.gitleaks.toml`（`$HOME` 直下・非追跡）にのみ書き、追跡ファイル（`setup.sh` 等）には
  汎用パターンのみ記載する。

## directory structure
```
└->$ tree -L 1
.
├── Applications (local applications)
├── Box (need to install box-drive, this is where backup local files)
├── Desktop (We don't use , don't wanna mess here)
├── Documents 
├── Downloads
├── Library
├── Movies
├── Music
├── Pictures
├── Public
├── code
└── work

(DONT PUT files in home directory except dotfiles))
```
## System Settings
Basically it can be configured in automation script , but some of them still should be set in GUI

- Touch ID
register your fingerprint

tick
[] unlock your mac
[] password auto fill


## Alfred
begin setup -> activate powerpack ( search activation code there ) -> open alfred preference -> advanced -> Syncing -> set preference folder -> setting file "alfred/Alfred.alfredpreferences"

turn off spotlight hotkey （spotlight -> turn off the shortcut)
change hotkey to cmd + space

see for backup and retrieve setting https://www.alfredapp.com/help/advanced/sync/



## rectangle
open -> import the RectangleConfig.json

## google japanese ime
System Settings > Keyboard > input source > + > Google Hiragana > OK
you can now change by ctrl + space

## karabiner-element
open is just ( .config/karabiner will work soon)

--- outdated
function key > use F1, F2 as function key
simple 

simple modification
caps / ctrl swap

complex > add rule > import more from network > serach japanese > import  For Japanese （日本語環境向けの設定） (rev 5)
add
- コマンドキーを単体で押したときに、英数・かなキーを送信する。（左コマンドキーは英数、右コマンドキーはかな） (rev 3)
- escキーを押したときに、英数キーも送信する（vim用）
- Ctrl+[を押したときに、escキーと英数キーを送信する
---


once open ( swap ctrl / caps will be removed)
      
## google chrome 
open -> google account login -> import bookmarks -> import extensions

- import bookmarks 

import exported html from cloud strage ( job , personal)
or 
connected with google account ( personal) 

### import exported html from cloud strage ( job , personal)
see https://support.google.com/chrome/answer/96816?hl=ja

### connected with google account ( personal) 
just login with your google account and turn on sync

- import extension

sign in with google account to restore extensions, or install manually:

- [ActivityWatch Web Watcher](https://chromewebstore.google.com/detail/activitywatch-web-watcher/nglaklhklhcoonedhgnpgddginnjdadi)
- [BlockSite: Block Websites & Stay Focused](https://chromewebstore.google.com/detail/block-site-website-blocke/eiimnmioipafcokbfikbljfdeojpcgbh)
- [Buffer](https://chromewebstore.google.com/detail/buffer/noojglkidnpfjbincgijbaiedldjfbhh)
- [Claude](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn)
- [Codex](https://chromewebstore.google.com/detail/codex/hehggadaopoacecdllhhajmbjkdcmajg)
- [Copy Title and Url as Markdown Style](https://chromewebstore.google.com/detail/copy-title-and-url-as-mar/fpmbiocnfbjpajgeaicmnjnnokmkehil)
- [GoFullPage - Full Page Screen Capture](https://chromewebstore.google.com/detail/gofullpage-full-page-scre/fdpohaocaechififmbbbbbknoalclacl)
- [Google Docs Offline](https://chromewebstore.google.com/detail/google-docs-offline/ghbmnnjooekpmoecnnnilnnbdlolhkhi)
- [Grammarly](https://chromewebstore.google.com/detail/grammarly-for-chrome/kbfnbcaeplbcioakkpcpgfkobkghlhen)
- [LastPass: Free Password Manager](https://chromewebstore.google.com/detail/lastpass-free-password-ma/hdokiejnpimakedhajhdlcegeplioahd)
- [Notion Boost](https://chromewebstore.google.com/detail/notion-boost/eciepnnimnjaojlkcpdpcgbfkpcagahd)
- [Save to Notion](https://chromewebstore.google.com/detail/save-to-notion/ldmmifpegigmeammaeckplhnjbbpccmm)
- [TabCopy](https://chromewebstore.google.com/detail/tabcopy/micdllihgoppmejpecmkilggmaagfdmb)
- [Vimium](https://chromewebstore.google.com/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb)

## ActivityWatch
ActivityWatch はアプリ使用時間・Web 閲覧を自動で記録するローカルタイムトラッカー。
`brew install --cask activitywatch` でインストール済み（Brewfile 管理）。

Chrome での Web 閲覧を記録するには上の **ActivityWatch Web Watcher** 拡張をインストールし、
ActivityWatch アプリを起動した状態で使用する。

## scroll
https://ryanhanson.dev/scroll  > open > System Settings > Privacy & Security > Accessibility > tick it

tap scroll on nav bar > scroll with one finger > hold 
> launch on login

enter license key: Scroll menu bar icon > Enter License Key

## Cloud Storage Link
(BOX)
box share ( can cask)
