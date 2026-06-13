#!/usr/bin/env bash
set -euo pipefail

# statusline アンインストールスクリプト
#
#   curl -fsSL https://raw.githubusercontent.com/ymtdir/statusline/main/uninstall.sh | bash

CLAUDE_DIR="$HOME/.claude"

rm -f "$CLAUDE_DIR/statusline.sh"
echo "🗑 削除: $CLAUDE_DIR/statusline.sh"

# settings.json から statusLine 設定を uv 経由 Python で取り除く
if [ -f "$CLAUDE_DIR/settings.json" ]; then
  if command -v uv >/dev/null 2>&1; then
    uv run --no-project python - "$CLAUDE_DIR/settings.json" <<'PY'
import json, sys
p = sys.argv[1]
d = json.load(open(p))
d.pop("statusLine", None)
json.dump(d, open(p, "w"), indent=2, ensure_ascii=False)
PY
    echo "🗑 settings.json から statusLine 設定を削除しました。"
  else
    echo "⚠ uv が無いため settings.json は手動で編集してください（statusLine を削除）。" >&2
  fi
fi

echo "✅ statusline をアンインストールしました。"
