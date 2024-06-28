#!/bin/bash
source /Users/jstein/workspace/ai/remwork/.env

# Check if the state file exists
if [ ! -f $DEBUG_VOICE_TOGGLE ]; then
  echo "OFF" > $DEBUG_VOICE_TOGGLE
fi

# Read the current state
STATE=$(cat $DEBUG_VOICE_TOGGLE)

# Toggle the state
if [ "$STATE" = "OFF" ]; then
  echo "ON" > $DEBUG_VOICE_TOGGLE
  say -r 180 "Debugging speach enabled"
else
  echo "OFF" > $DEBUG_VOICE_TOGGLE
  say -r 180 "Debugger will be quite now"
fi
