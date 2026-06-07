#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${HOME}/.claude"
mkdir -p "$DEST"

ln -sfn "$REPO/statusline.sh" "$DEST/statusline.sh"
ln -sfn "$REPO/settings.json" "$DEST/settings.json"

chmod +x "$REPO/statusline.sh"
echo "linked: ~/.claude/statusline.sh"
echo "linked: ~/.claude/settings.json"
echo "chmod +x applied to $REPO/statusline.sh"

echo "✓ done"
