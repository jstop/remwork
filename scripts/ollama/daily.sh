source /Users/jstein/workspace/ai/remwork/.env
days_ago=$1
day=$(date -v-${days_ago}d '+%Y-%m-%d')
LOG_FILE="$WORKING_DIR/logs/daily/$(date +"%Y.%m.%d.%H.%M.%S").log"
FILENAME="$WORKING_DIR/summaries/$day/merged_file.txt"
$WORKING_DIR/ollama_prompt.sh daily_summary < $FILENAME > "$WORKING_DIR/summaries/$day/summary.txt" 2> "$LOG_FILE"
