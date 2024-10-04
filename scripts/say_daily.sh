#!/bin/bash
source /Users/jstein/workspace/ai/remwork/.env
days_ago="${1:-0}"
day=$(date -v-${days_ago}d '+%Y-%m-%d')
#if there is a summary, say it
if [ -f "$PDS_PATH/summaries/$day/summary.txt" ]; then
    say -r 200 -f "$PDS_PATH/summaries/$day/summary.txt"
else
    say -r 180 "No summary for $day"
fi
