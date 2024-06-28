#!/bin/bash
source /Users/jstein/workspace/ai/remwork/.env

# Check if the state file exists
if [ ! -f $VOICE_TOGGLE ]; then
  echo "OFF" > $VOICE_TOGGLE
fi

# Read the current state
STATE=$(cat $VOICE_TOGGLE)

# Toggle the state
if [ "$STATE" = "OFF" ]; then
  echo "ON" > $VOICE_TOGGLE
  say -r 180 "Speach enabled"
else
  echo "OFF" > $VOICE_TOGGLE
  say -r 180 "I'll be quite now"
fi
