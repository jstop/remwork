#!/bin/bash

source /Users/jstein/workspace/ai/remwork/.env
# WORKING_DIR
# LOG_DIR#VOICE_TOGGLE
# DEBUG_VOICE_TOGGLE
# DB_FILE

VOICE_STATE=$(cat $VOICE_TOGGLE)
VOICE_DEBUG=$(cat $DEBUG_VOICE_TOGGLE)

FRAME_ID_FILE="$WORKING_DIR/tmp/last_frame_id.txt"
LOG_FILE="$WORKING_DIR/logs/$(date +"%Y.%m.%d.%H.%M.%S").log"


# Read the last frameId from the file
if [[ -f "$FRAME_ID_FILE" ]]; then
  LAST_FRAME_ID=$(cat "$FRAME_ID_FILE")
  if [[ "$VOICE_DEBUG" == "ON" ]]; then
    say -r 200 "Last frame ID: $LAST_FRAME_ID"
  else
    echo "Last frame ID: $LAST_FRAME_ID" >> $LOG_FILE
  fi
else
  say -r 200 "Frame ID file not found."
  LAST_FRAME_ID=10
fi


# Query the database for the latest frameId
LATEST_FRAME_ID=$(sqlite3 "$DB_FILE" "SELECT frameId FROM allText ORDER BY frameId DESC LIMIT 1;")
LATEST_FRAME_TIMESTAMP=$(sqlite3 "$DB_FILE" "SELECT timestamp FROM frames WHERE id = $LATEST_FRAME_ID;")

if [[ "$VOICE_DEBUG" == "ON" ]]; then
  say -r 200 "Latest Frame ID: $LATEST_FRAME_ID"
fi

# Compare the frame IDs
if [[ "$LAST_FRAME_ID" == "$LATEST_FRAME_ID" ]]; then
  if [[ "$VOICE_DEBUG" == "ON" ]]; then
      say -r 200 "Frame ID has not changed. Exiting."
  else
    echo "Frame ID has not changed. Exiting." >> "$LOG_FILE"
  fi
  exit 0

else
  # DEBUGGING -----------------------------------------------------------------
  if [[ "$VOICE_DEBUG" == "ON" ]]; then
    say -r 200 "Frame ID has changed. New frame ID: $LATEST_FRAME_ID"
  fi
  echo "$LATEST_FRAME_ID" > "$FRAME_ID_FILE"

# WRITE FRAME TO FILE -----------------------------------------------------------------
  FILENAME="$WORKING_DIR/tmp/last_frame.txt"
  sqlite3 "$DB_FILE" <<EOF
.mode csv
.headers on
.output $FILENAME
SELECT text FROM allText
ORDER BY frameId DESC
LIMIT 1;
.output stdout
EOF

  # DEBUGGING -----------------------------------------------------------------
  if [[ "$VOICE_DEBUG" == "ON" ]]; then
    say -r 200 "Frame text written to $FILENAME"
  else
    echo "Frame text written to $FILENAME" >> "$LOG_FILE"
  fi

# SUMMARIZE FRAME -----------------------------------------------------------------
  $WORKING_DIR/ollama_summarize.sh < $FILENAME > "$WORKING_DIR/summaries/$LATEST_FRAME_TIMESTAMP.txt" 2> "$LOG_FILE"

  cp "$WORKING_DIR/summaries/$LATEST_FRAME_TIMESTAMP.txt" "$WORKING_DIR/summaries/now.txt"

  if [ "$DEBUG_STATE" = "ON" ]; then
    say -r 200 "New Summary available"
  fi


  if [ "$VOICE_STATE" = "ON" ]; then
    say -r 140 "At  $(/opt/homebrew/bin/gdate -d "$LATEST_FRAME_TIMESTAMP 4 hours ago" "+%A at %I:%M %p")"
    say -r 180 -f "$WORKING_DIR/summaries/now.txt"
  fi
fi
