#!/bin/bash
source /Users/jstein/workspace/ai/remwork/.env
days_ago="${1:-0}"
echo "say_daily.sh: $days_ago"
day=$(date -v-${days_ago}d '+%Y-%m-%d')
say -r 200 -f "$WORKING_DIR/summaries/$day/summary.txt"
