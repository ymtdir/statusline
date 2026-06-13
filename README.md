# statusline

Claude Code 向けの簡易ステータスライン。標準入力で受け取った JSON を解析し、2 行でコンテキストウィンドウの使用状況と直近コスト／累計を表示する。

## セットアップ

任意の場所で実行する。`settings.json` の生成・マージに `uv` を使うため、未インストールの場合は自動で導入する。

```bash
curl -fsSL https://raw.githubusercontent.com/ymtdir/statusline/main/install.sh | bash
```

`statusline.sh` を `~/.claude/statusline.sh` にコピーして実行権を付与し、`settings.json` を（既存があればマージ、なければコピーで）`~/.claude/settings.json` に反映する。

## 更新

同じコマンドを再実行する。

```bash
curl -fsSL https://raw.githubusercontent.com/ymtdir/statusline/main/install.sh | bash
```

## 削除

```bash
curl -fsSL https://raw.githubusercontent.com/ymtdir/statusline/main/uninstall.sh | bash
```

`~/.claude/statusline.sh` を削除し、`settings.json` から `statusLine` 設定を取り除く（`uv` 経由）。

## 前提

- `uv` — `settings.json` の生成・マージに使用（未導入なら `install.sh` が自動導入）
- `bash` — `statusline.sh` の実行に使用
- `jq` — ステータスライン実行時の JSON 解析（未インストール時は簡易表示にフォールバック）
- `awk` — 多くの環境で標準搭載

`jq` のインストール例（macOS, Homebrew）:

```bash
brew install jq
```

## 動作確認（モック入力）

```bash
echo '{"session_id":"test","cost":{"total_cost_usd":0.42},"context_window":{"used_percentage":67,"context_window_size":1000000,"current_usage":{"input_tokens":8500,"cache_read_input_tokens":120000,"cache_creation_input_tokens":5000,"output_tokens":1200}}}' | "$HOME/.claude/statusline.sh"
```

## 含まれるもの

| ファイル        | 役割                                                       |
| --------------- | ---------------------------------------------------------- |
| `statusline.sh` | ステータスライン本体（stdin から JSON を受け取る）         |
| `settings.json` | Claude Code に登録する最小の `statusLine` 設定（マージ元） |
| `install.sh`    | uv ベースの導入スクリプト                                  |
| `uninstall.sh`  | 削除スクリプト                                             |

## トラブルシューティング

- 実行時に「(jq 未インストールのためステータスライン簡易表示)」と表示されたら `jq` が PATH 上にない。Homebrew 等でインストールする。
- ターミナルの色表示が不要な場合は、`statusline.sh` 内の ANSI カラー定義（`GREEN` など）を削除または調整する。

ライセンス: リポジトリの `LICENSE` を参照。
