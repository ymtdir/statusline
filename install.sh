#!/usr/bin/env bash
set -euo pipefail

# statusline インストールスクリプト
#
# 任意の場所で実行する:
#   curl -fsSL https://raw.githubusercontent.com/ymtdir/statusline/main/install.sh | bash
#
# （開発用）ローカルの本体から直接実行する:
#   bash /path/to/statusline/install.sh

REPO="ymtdir/statusline"
BRANCH="main"
TARBALL="https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz"

CLAUDE_DIR="$HOME/.claude"

# uv を確認し、無ければ公式インストーラで導入する
if ! command -v uv >/dev/null 2>&1; then
  echo "⬇ uv が見つからないためインストールします..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
  if ! command -v uv >/dev/null 2>&1; then
    echo "❌ uv のインストールに失敗しました。手動で導入してください（https://docs.astral.sh/uv/）。" >&2
    exit 1
  fi
fi

# スクリプトと同じ場所に本体があればローカル、なければリモートから取得
SRC="${BASH_SOURCE[0]:-}"
CLEANUP_DIR=""
if [ -n "$SRC" ] && [ -f "$SRC" ] && [ -f "$(cd "$(dirname "$SRC")" && pwd)/statusline.sh" ]; then
  SRC_DIR="$(cd "$(dirname "$SRC")" && pwd)"
else
  if ! command -v curl >/dev/null 2>&1; then
    echo "❌ curl が見つかりません。リモート取得に必要です。" >&2
    exit 1
  fi
  SRC_DIR="$(mktemp -d)"
  CLEANUP_DIR="$SRC_DIR"
  echo "⬇ $REPO ($BRANCH) を取得中..."
  curl -fsSL "$TARBALL" | tar -xz -C "$SRC_DIR" --strip-components=1
fi

mkdir -p "$CLAUDE_DIR"

# statusline.sh をコピーして実行権を付与
cp "$SRC_DIR/statusline.sh" "$CLAUDE_DIR/statusline.sh"
chmod +x "$CLAUDE_DIR/statusline.sh"

# settings.json: uv 経由 Python で生成（既存があればマージ、無ければ新規作成）
uv run --no-project python - "$CLAUDE_DIR/settings.json" "$SRC_DIR/settings.json" <<'PY'
import json, os, sys
dst, src = sys.argv[1], sys.argv[2]
a = json.load(open(dst)) if os.path.exists(dst) else {}
b = json.load(open(src))
def merge(x, y):
    for k, v in y.items():
        if isinstance(x.get(k), dict) and isinstance(v, dict):
            merge(x[k], v)
        else:
            x[k] = v
    return x
json.dump(merge(a, b), open(dst, "w"), indent=2, ensure_ascii=False)
PY

[ -n "$CLEANUP_DIR" ] && rm -rf "$CLEANUP_DIR"

echo "✅ statusline を $CLAUDE_DIR に導入しました。"
