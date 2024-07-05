#!/bin/bash
source /Users/jstein/workspace/ai/remwork/.env

model="phi3:mini"
context="A summary of what the user(Josh) was possibly engaged in was taken from the screen captures."
summary=$(cat)
echo $summary
question="Can you give Josh 3 pieces of advice?\n\n"

/Applications/Ollama.app/Contents/Resources/ollama run --verbose $model """'$context' -------------------- Summary: ------------- $summary ----------------------'$question'---------------------------------------------------------------------------'$followup'"""
