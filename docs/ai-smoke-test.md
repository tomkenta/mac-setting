# n8n → Claude → ローカル保存：最初の動作テスト

インストールやOS設定とは別の、手動・単発の疎通テスト。定期実行はまだしない。
固定のテスト文章をClaudeに渡し、生成結果をMac miniのローカルディスクに保存する。
Web検索、個人・会社データ、メルカリ操作、通知送信は対象にしない。
LLMへの推論リクエストはAnthropicへ送られる。ローカルLLMではない。

## 1. Mac miniのTermius / ターミナルで一度試す

Claude Codeへのログインを完了したmacOSユーザーで実行する。

```sh
cd ~/mac-setting
git pull --ff-only
bash server/run-ai-smoke.sh
```

`{"status":"ok", "report_path": ...}` が出れば成功。表示されたファイルを読む。
保存先は `~/Library/Application Support/KentaOS/ai-smoke/run-*/report.md`。
実行ごとに新しいディレクトリを作り、過去の結果を上書きしない。
JSON応答と標準エラーも同じ場所に保存する。Git / Obsidian Vaultへは保存しない。

Claude Codeは `--safe-mode` に対応した版が必要。未対応フラグのエラーになったら
`brew upgrade --cask claude-code` で更新し、`claude --version` で確認する。
認証エラーなら同じユーザーで `claude` を起動してログインを確認する。
`--bare` はサブスクリプションのログインを使わないため、このテストでは使用しない。

## 2. n8nにテンプレートを取り込む

Mac miniのChromeで <http://localhost:5678> を開き、新規ワークフローを作成する。
ワークフローのメニューから **Import from File** を選び、
`~/mac-setting/server/n8n/ai-smoke.manual.json` を取り込む。
手元のPCでn8nを開く場合は、従来どおりSSHトンネルを使う。

テンプレートは次の3ノードで構成する。

1. Manual Trigger
2. Run Claude on Mac mini（SSH）
3. Verify saved report（終了コードと保存結果を確認）

SSHノードはMac mini自身の `127.0.0.1:22` へ接続する。Tailscale IPではない。
n8nが同じMac mini上でネイティブに動いている現在の構成を前提にする。
Execute Commandノードの有効化や、n8nの環境変数変更・再起動は不要。

## 3. SSHノードの認証情報を設定

SSHノードを開き、**Credential to connect with** でSSH Passwordの認証情報を作る。

| 項目 | 値 |
| --- | --- |
| Host | `127.0.0.1` |
| Port | `22` |
| Username | Mac miniのユーザー名（`whoami` で確認） |
| Password | Mac miniのログインパスワード |

パスワードはn8nの認証情報画面にだけ入力する。チャットやGitへは貼らない。
この認証情報はユーザー権限で任意コマンドを実行できるため、n8nの管理権限と
暗号化キー・バックアップを保護する。今回は自分だけが使う手動テストに限定する。
定期運用へ進む前に、専用SSH鍵とforced-command等で実行範囲を限定する。

Commandの既定値は `/bin/bash "$HOME/mac-setting/server/run-ai-smoke.sh"`。
別の場所にcloneした場合だけ、実際のパスへ変更する。
ワークフローからプロンプトやシェル引数を動的に受け渡さない。

## 4. Execute workflowを1回だけ押す

最後のノードに `status: ok` と `report_path` が出れば疎通確認は完了。
SSHノードはコマンドが失敗しても終了コードをデータとして返すため、
最後のノードがコードを検査し、失敗を成功扱いにしない。
認証エラー・タイムアウトではログを確認し、自動再試行や連打をしない。

まだスケジュールやWebhookは付けない。この時点での完成範囲は
「n8nからAIを単発実行して保存できる」であり、24時間自律運用ではない。

## 安全措置と制約

- Claudeの組み込みツール・MCPツール・カスタマイズを無効にする。
  ファイルの保存はAIではなく、この固定スクリプトが行う。
- 1ターン、180秒、API費用見積もり上限$0.50で停止する。自動再試行なし。
  費用上限はCLIの制御であり、請求の厳密な上限やサブスクリプションの利用枠を保証しない。
- ロックで同時実行を防ぎ、保存先ディレクトリは700、生成ファイルは600にする。
- OSレベルのサンドボックスではない。管理者ポリシーによるhooks等は
  safe-modeでも適用されることがある。個人用・管理対象外Macでのテストを想定する。
- macOSのキーチェーンやFileVaultがロックされた再起動後は、
  n8nが起動していてもClaudeの認証まで復旧するとは限らない。

## ローカル検証（AIを呼び出さない）

```sh
python3 -m unittest discover -s server/tests -p 'test_ai_smoke.py'
```

参考：[Claudeの非対話実行](https://code.claude.com/docs/en/headless)、
[Claude CLIフラグ](https://code.claude.com/docs/en/cli-reference)、
[n8n SSHノード](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.ssh)。
