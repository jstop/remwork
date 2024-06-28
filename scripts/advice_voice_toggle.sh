#!/bin/bash
source /Users/jstein/workspace/ai/remwork/.env

# Check if the state file exists
if [ ! -f $ADVICE_VOICE_TOGGLE ]; then
  echo "OFF" > $ADVICE_VOICE_TOGGLE
fi

# Read the current state
STATE=$(cat $ADVICE_VOICE_TOGGLE)

# Toggle the state
if [ "$STATE" = "OFF" ]; then
  echo "ON" > $ADVICE_VOICE_TOGGLE
  say -r 180 "Speach enabled"
else
  echo "OFF" > $ADVICE_VOICE_TOGGLE
  say -r 180 "I'll be quite now"
fi
