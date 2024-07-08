#!/bin/bash
source /Users/jstein/workspace/ai/remwork/.env

prompt_file=$1
model="phi3:mini"
question=$(cat $WORKING_DIR/prompts/$prompt_file.txt)
context="Summaries of screen captures were created throughout the day yesterday and were compiled into a single file."
summary=$(cat )
followup=""
/Applications/Ollama.app/Contents/Resources/ollama run --verbose $model """'$context' -------------------- Summary: ------------- $summary ----------------------'$question'---------------------------------------------------------------------------'$followup'"""
