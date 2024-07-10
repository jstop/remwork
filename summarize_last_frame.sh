#!/bin/bash

source /Users/jstein/workspace/ai/remwork/.env
# WORKING_DIR
# LOG_DIR#VOICE_TOGGLE
# DEBUG_VOICE_TOGGLE
# DB_FILE
RUN_SWITCH=$(cat $WORKING_DIR/.settings/run_switch.txt)
VOICE_STATE=$(cat $VOICE_TOGGLE)
ADVICE_VOICE_STATE=$(cat $ADVICE_VOICE_TOGGLE)
VOICE_DEBUG=$(cat $DEBUG_VOICE_TOGGLE)

if [[ "$RUN_SWITCH" == "OFF" ]]; then
  if [[ "$VOICE_DEBUG" == "ON" ]]; then
    say -r 200 "Run switch is off. Exiting."
  fi
  #exit 0
else
  # Turn the run switch off at the start of a new execution
  # Only 1 execution should run at a time
  echo "OFF" > "$WORKING_DIR/.settings/run_switch.txt"
fi

FRAME_ID_FILE="$WORKING_DIR/tmp/last_frame_id.txt"
LOG_FILE="$WORKING_DIR/logs/$(date +"%Y.%m.%d.%H.%M.%S").log"


# Read the last frameId from the file
if [[ -f "$FRAME_ID_FILE" ]]; then
  LAST_FRAME_ID=$(cat "$FRAME_ID_FILE")
  if [[ "$VOICE_DEBUG" == "VERBOSE" ]]; then
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

if [[ "$VOICE_DEBUG" == "VERBOSE" ]]; then
  say -r 200 "Latest Frame ID: $LATEST_FRAME_ID"
fi

# Compare the frame IDs
if [[ "$LAST_FRAME_ID" == "$LATEST_FRAME_ID" ]]; then
  if [[ "$VOICE_DEBUG" == "ON" ]]; then
      say -r 200 "Frame ID has not changed. Exiting."
  else
    echo "Frame ID has not changed. Exiting." >> "$LOG_FILE"
  fi
  echo "FALSE" > "$WORKING_DIR/tmp/is_running.txt"
  exit 0

else
  # DEBUGGING -----------------------------------------------------------------
  if [[ "$VOICE_DEBUG" == "VERBOSE" ]]; then
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
  if [[ "$VOICE_DEBUG" == "VERBOSE" ]]; then
    say -r 200 "Frame text written to $FILENAME"
  else
    echo "Frame text written to $FILENAME" >> "$LOG_FILE"
  fi

# SUMMARIZE FRAME -----------------------------------------------------------------
  source $WORKING_DIR/bin/activate && python3 $WORKING_DIR/gemini_flash_summarize.py < $FILENAME > "$WORKING_DIR/summaries/$LATEST_FRAME_TIMESTAMP.txt" 2> "$LOG_FILE"

  #$WORKING_DIR/ollama_summarize.sh < $FILENAME > "$WORKING_DIR/summaries/$LATEST_FRAME_TIMESTAMP.txt" 2> "$LOG_FILE"
  #$WORKING_DIR/ollama_advise.sh < "$WORKING_DIR/summaries/$LATEST_FRAME_TIMESTAMP.txt" > "$WORKING_DIR/advice/$LATEST_FRAME_TIMESTAMP.txt" 2> "$LOG_FILE"

  cp "$WORKING_DIR/summaries/$LATEST_FRAME_TIMESTAMP.txt" "$WORKING_DIR/summaries/now.txt"
  #cp "$WORKING_DIR/advice/$LATEST_FRAME_TIMESTAMP.txt" "$WORKING_DIR/advice/now.txt"

  if [ "$VOICEDEBUG" = "ON" ]; then
    say -r 200 "New Summary available"
  fi

  if [ "$VOICE_STATE" = "ON" ]; then
    say -r 140 "At  $(/opt/homebrew/bin/gdate -d "$LATEST_FRAME_TIMESTAMP 4 hours ago" "+%A at %I:%M %p")"
    say -r 180 -f "$WORKING_DIR/summaries/now.txt"
      if [ "$ADVICE_VOICE_STATE" = "ON" ]; then
        say -r 140 "At  $(/opt/homebrew/bin/gdate -d "$LATEST_FRAME_TIMESTAMP 4 hours ago" "+%A at %I:%M %p")"
        say -r 180 -f "$WORKING_DIR/advice/now.txt"
      fi
  fi

  # Allow new execution when this execution completes
  echo "ON" > "$WORKING_DIR/.settings/run_switch.txt"
fi
