#!/bin/bash
#say $(whoami)
VOICE_DEBUG=0
if [[ "$VOICE_DEBUG" == "1" ]]; then
  say -r 200 "Starting Summarize Last Frame"
fi

WORKING_DIR="/Users/jstein/workspace/ai/remwork"

# File that stores the last frameId
FRAME_ID_FILE="$WORKING_DIR/tmp/last_frame_id.txt"
LOG_FILE="$WORKING_DIR/tmp/$(date +"%Y.%m.%d.%H.%M.%S").log"

# Database connection details
DB_FILE="/Users/jstein/Library/Containers/today.jason.rem/Data/Library/Application Support/today.jason.rem/db.sqlite3"

# Read the last frameId from the file
if [[ -f "$FRAME_ID_FILE" ]]; then
  LAST_FRAME_ID=$(cat "$FRAME_ID_FILE")
  if [[ "$VOICE_DEBUG" == "1" ]]; then
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
if [[ "$VOICE_DEBUG" == "1" ]]; then
  say -r 200 "Latest Frame ID: $LATEST_FRAME_ID"
else
  echo "Latest Frame ID: $LATEST_FRAME_ID" >> $LOG_FILE
fi

# Compare the frame IDs
if [[ "$LAST_FRAME_ID" == "$LATEST_FRAME_ID" ]]; then
  if [[ "$VOICE_DEBUG" == "1" ]]; then
      say -r 200 "Frame ID has not changed. Exiting."
  else
    echo "Frame ID has not changed. Exiting." >> "$LOG_FILE"
  fi
  exit 0
else
  if [[ "$VOICE_DEBUG" == "1" ]]; then
    say -r 200 "Frame ID has changed. New frame ID: $LATEST_FRAME_ID"
  fi
  echo "$LATEST_FRAME_ID" > "$FRAME_ID_FILE"
  # Add your additional processing here if needed
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

  if [[ "$VOICE_DEBUG" == "1" ]]; then
    say -r 200 "Frame text written to $FILENAME"
  else
    echo "Frame text written to $FILENAME" >> "$LOG_FILE"
  fi

  # Add your additional processing here if needed
  # Summarize the frame text
  #say -r 200 "Summarizing last frame..."
  #say -r 200 "Reading $FILENAME..."
  $WORKING_DIR/ollama_summarize.sh < $FILENAME > "$WORKING_DIR/summaries/$LATEST_FRAME_ID.txt" 2> "$LOG_FILE"
  #say -r 200 "Summarized frame saved to $WORKING_DIR/summaries/$LATEST_FRAME_ID.txt"
  cp "$WORKING_DIR/summaries/$LATEST_FRAME_ID.txt" "$WORKING_DIR/summaries/now.txt"
fi

say -r 200 -f "$WORKING_DIR/summaries/now.txt" > $LOG_FILE 2>&1
