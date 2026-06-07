# Claude Code 用 statusline

このリポジトリは、Claude Code 向けの簡易ステータスラインを提供します。標準入力で受け取った JSON を解析し、2 行でコンテキストウィンドウの使用状況と直近コスト／累計を表示します。

同梱ファイル:

- `statusline.sh` — ステータスライン本体（stdin から JSON を受け取ります）
- `settings.json` — Claude Code に登録する最小の `statusLine` 設定例
- `install.sh` — `~/.claude` へシンボリックリンクを張り、実行権を付与する補助スクリプト

前提（実行環境）:

- `bash`（スクリプト実行に使用）
- `jq`（JSON 解析。未インストール時は簡易表示にフォールバックします）
- `awk`（多くの環境で標準搭載されています）

`jq` のインストール例（macOS, Homebrew）:

```bash
brew install jq
```

ローカルにインストールする手順（リポジトリのルートで実行）:

```bash
# スクリプトに実行権を付与
chmod +x statusline.sh

# ~/.claude ディレクトリへシンボリックリンクを作る
mkdir -p "$HOME/.claude"
ln -sfn "$PWD/statusline.sh" "$HOME/.claude/statusline.sh"
# settings.json を置き換えると既存設定を上書きします。必要なら手動マージしてください
ln -sfn "$PWD/settings.json" "$HOME/.claude/settings.json"

# ~/.claude に置いた実行ファイルにも実行権を付与
chmod +x "$HOME/.claude/statusline.sh"

# 代わりに付属の install.sh を使うこともできます
./install.sh
```

動作確認（モック入力）:

```bash
echo '{"session_id":"test","cost":{"total_cost_usd":0.42},"context_window":{"used_percentage":67,"context_window_size":1000000,"current_usage":{"input_tokens":8500,"cache_read_input_tokens":120000,"cache_creation_input_tokens":5000,"output_tokens":1200}}}' | ./statusline.sh
```

`~/.claude` にインストールした場合は次のようにも実行できます:

```bash
echo '{"session_id":"test","cost":{"total_cost_usd":0.42},"context_window":{"used_percentage":67,"context_window_size":1000000,"current_usage":{"input_tokens":8500,"cache_read_input_tokens":120000,"cache_creation_input_tokens":5000,"output_tokens":1200}}}' | "$HOME/.claude/statusline.sh"
```

トラブルシューティング:

- 実行時に「(jq 未インストールのためステータスライン簡易表示)」と表示されたら `jq` が PATH 上にありません。Homebrew 等でインストールしてください。
- ターミナルの色表示が不要な場合は、`statusline.sh` 内の ANSI カラー定義（`GREEN` など）を削除または調整してください。
- `settings.json` をリンクする際は既存の設定を上書きしないよう注意してください。必要なら `settings.json` を手動でマージしてください。

アンインストール例:

```bash
rm -f "$HOME/.claude/statusline.sh"
# 注意: settings.json をリンクしている場合は元に戻すかバックアップを復元してください
```

ライセンス: リポジトリの `LICENSE` を参照してください。

不明点や追加してほしい使い方（例: systemd / launchd 用のラッパー、他端末での色非表示対応など）があれば教えてください。
