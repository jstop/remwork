#!/bin/bash
source /Users/jstein/workspace/ai/remwork/.env

# Check if the state file exists
if [ ! -f $RUN_TOGGLE ]; then
  echo "OFF" > $RUN_TOGGLE
fi

# Read the current state
STATE=$(cat $RUN_TOGGLE)

# Toggle the state
if [ "$STATE" = "OFF" ]; then
  echo "ON" > $RUN_TOGGLE
  say -r 180 "Execution enabled"
else
  echo "OFF" > $RUN_TOGGLE
  say -r 180 "Execution disabled"
fi
