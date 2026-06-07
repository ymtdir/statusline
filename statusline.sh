#!/usr/bin/env bash
# statusline.sh — Claude Code ステータスライン
#
# コンテキストウィンドウのトークン消費とセッションコストを 2 行で可視化する。

set -euo pipefail

input=$(cat)

# jq が無い環境向けのフォールバック
if ! command -v jq >/dev/null 2>&1; then
  echo "(jq 未インストールのためステータスライン簡易表示)"
  exit 0
fi

# 1 回の jq 呼び出しでまとめて取り出し、欠落フィールドは // で既定値に落とす。
IFS=$'\t' read -r SESSION_ID COST PCT CTX_SIZE IN_TOK RD_TOK WR_TOK OUT_TOK HAS_USAGE < <(
  printf '%s' "$input" | jq -r '
    .context_window as $cw
    | $cw.current_usage as $u
    | [
        (.session_id // "default"),
        (.cost.total_cost_usd // 0),
        (($cw.used_percentage // 0) | floor),
        ($cw.context_window_size // 200000),
        ($u.input_tokens // 0),
        ($u.cache_read_input_tokens // 0),
        ($u.cache_creation_input_tokens // 0),
        ($u.output_tokens // 0),
        (if $u == null then 0 else 1 end)
      ] | @tsv
  '
)

SESSION_ID=${SESSION_ID:-default}
COST=${COST:-0}
PCT=${PCT:-0}
CTX_SIZE=${CTX_SIZE:-200000}
IN_TOK=${IN_TOK:-0}
RD_TOK=${RD_TOK:-0}
WR_TOK=${WR_TOK:-0}
OUT_TOK=${OUT_TOK:-0}
HAS_USAGE=${HAS_USAGE:-0}

fmt_num() {
  local n=$1 whole frac
  if [ "$n" -ge 1000000 ]; then
    whole=$((n / 1000000)); frac=$(((n % 1000000) / 100000))
    [ "$frac" -eq 0 ] && printf '%dM' "$whole" || printf '%d.%dM' "$whole" "$frac"
  elif [ "$n" -ge 100000 ]; then
    printf '%dk' $((n / 1000))
  elif [ "$n" -ge 1000 ]; then
    whole=$((n / 1000)); frac=$(((n % 1000) / 100))
    [ "$frac" -eq 0 ] && printf '%dk' "$whole" || printf '%d.%dk' "$whole" "$frac"
  else
    printf '%d' "$n"
  fi
}

GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'
DIM=$'\033[2m';    RESET=$'\033[0m'
SEP=" ${DIM}·${RESET} "

if [ "$HAS_USAGE" = "1" ]; then
  [ "$PCT" -gt 100 ] && PCT=100

  if   [ "$PCT" -ge 90 ]; then BAR_COLOR=$RED
  elif [ "$PCT" -ge 70 ]; then BAR_COLOR=$YELLOW
  else                         BAR_COLOR=$GREEN
  fi

  BAR_WIDTH=10
  FILLED=$((PCT * BAR_WIDTH / 100))
  EMPTY=$((BAR_WIDTH - FILLED))
  BAR=""
  [ "$FILLED" -gt 0 ] && { printf -v F "%${FILLED}s"; BAR="${F// /█}"; }
  [ "$EMPTY"  -gt 0 ] && { printf -v E "%${EMPTY}s";  BAR="${BAR}${E// /░}"; }
  GAUGE="${BAR_COLOR}[${BAR}] ${PCT}%${RESET}"
else
  GAUGE="${DIM}コンテキスト計測待ち${RESET}"
fi

# 直近 1 レスポンスのコスト = 累計の差分。
COST_FILE="${TMPDIR:-/tmp}"
COST_FILE="${COST_FILE%/}/claude-statusline-cost-${SESSION_ID}"
RESP_COST=$(awk -v cost="$COST" -v file="$COST_FILE" '
  BEGIN {
    prev = 0; shown = 0;
    if ((getline line < file) > 0) { split(line, a, " "); prev = a[1] + 0; shown = a[2] + 0; }
    close(file);
    delta = cost - prev;
    if (delta < 0) delta = 0;
    if (delta > 0) shown = delta;
    print cost, shown > file;
    close(file);
    printf "%.2f", shown;
  }
')

RESP_FMT=$(printf '$%s' "$RESP_COST")
TOTAL_FMT=$(printf '$%.2f' "$COST")
LINE1="${GAUGE}"
if [ "$HAS_USAGE" = "1" ]; then
  REMAIN=$((CTX_SIZE - IN_TOK - RD_TOK - WR_TOK))
  [ "$REMAIN" -lt 0 ] && REMAIN=0
  LINE1="${LINE1}${SEP}${DIM}残り${RESET} $(fmt_num "$REMAIN")"
fi
LINE1="${LINE1}${SEP}${YELLOW}${RESP_FMT}${RESET} ${DIM}(total: ${TOTAL_FMT})${RESET}"
printf '%s\n' "$LINE1"

if [ "$HAS_USAGE" = "1" ]; then
  DETAIL="in${DIM}(1x)${RESET} $(fmt_num "$IN_TOK")"
  DETAIL="${DETAIL}  cache[rd${DIM}(0.1x)${RESET} $(fmt_num "$RD_TOK")"
  DETAIL="${DETAIL}  wr${DIM}(1.25x)${RESET} $(fmt_num "$WR_TOK")]"
  DETAIL="${DETAIL}  out${DIM}(5x)${RESET} $(fmt_num "$OUT_TOK")"
  printf '%s\n' "$DETAIL"
fi
