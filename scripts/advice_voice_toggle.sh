#!/bin/bash
source /Users/jstein/workspace/ai/remwork/.env

# Check if the state file exists
if [ ! -f $GOAL_VOICE_TOGGLE ]; then
  echo "OFF" > $GOAL_VOICE_TOGGLE
fi

# Read the current state
STATE=$(cat $GOAL_VOICE_TOGGLE)

# Toggle the state
if [ "$STATE" = "OFF" ]; then
  echo "ON" > $GOAL_VOICE_TOGGLE
  say -r 180 "GOAL Speach enabled"
else
  echo "OFF" > $GOAL_VOICE_TOGGLE
  say -r 180 "I'll be quite now"
fi
