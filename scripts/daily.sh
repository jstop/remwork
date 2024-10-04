#!/bin/bash

# Directory containing the timestamped files
source /Users/jstein/workspace/ai/remwork/.env
DEBUG=ON
days="${1:-0}"
speach_enabled="${2:-false}"

day=$(date -v-${days}d '+%Y-%m-%d')
if [[ "$DEBUG" == "ON" ]]; then
    echo "Creating directory: $day"
fi

source_dir="$PDS_PATH/summaries"
sub_dir="$source_dir/$day"
if [[ "$DEBUG" == "ON" ]]; then
    echo "Creating subdirectory: $sub_dir"
fi
mkdir -p "$sub_dir"

merged_file="$sub_dir/merged_file.txt"

# # Check if there are any files for the given date
files=("$source_dir"/$day*.txt)
if [ ${#files[@]} -eq 0 ] || [ ! -e "${files[0]}" ]; then
    if [[ "$DEBUG" == "ON" ]]; then
        echo "No data found for $day"
    fi
    exit 0
fi

# Process files
for file in "${files[@]}"; do
    filename=$(basename "$file")
    timestamp="${filename%.txt}"
    time_part="${filename:11:8}"

    # Use a try-catch equivalent in bash
    if ! formatted_time=$(date -j -f "%H:%M:%S" "$time_part" +"%I:%M:%S %p" 2>/dev/null); then
        echo "Warning: Could not format time for $filename. Using original timestamp."
        formatted_time="$time_part"
    fi

    echo "Timestamp: $formatted_time" >> "$merged_file"
    echo "Content of $filename:" >> "$merged_file"
    cat "$file" >> "$merged_file"
    echo "======================" >> "$merged_file"
    mv "$file" "$sub_dir"
done

# Generate summary
SUMMARY_FILE="$PDS_PATH/summaries/$day/summary.txt"
GOAL_FILE="$PDS_PATH/summaries/$day/goals.txt"
if [ -s "$merged_file" ]; then
    source $PYTHON_PATH/bin/activate
    if ! python3 $WORKING_DIR/scripts/gemini/prompt.py -f "$merged_file" -p daily_merge > "$SUMMARY_FILE"; then
        echo "Error: Failed to generate summary"
        exit 1
    fi
    if ! python3 $WORKING_DIR/scripts/gemini/prompt.py -f "$merged_file" -p goals > "$GOAL_FILE"; then
        echo "Error: Failed to generate summary"
        exit 1
    fi

    if [[ "$speech_enabled" == "true" ]]; then
        say -r 200 -f "$SUMMARY_FILE"
        say -r 200 -f "$GOAL_FILE"
    fi
else
    if [[ "$DEBUG" == "ON" ]]; then
        echo "No content to summarize for $day"
    fi
fi

#echo "Processing completed for $day"

# Iterate over each file in the source directory
#for file in "$source_dir"/$day*.txt; do
#    # Extract date from filename (assuming filenames are in YYYY-MM-DDTHH:MM:SS.sss.txt format)
#    filename=$(basename "$file")
#    timestamp="${filename%.txt}"
#    time_part="${filename:11:8}"
#    formatted_time=$(date -j -f "%H:%M:%S" "$time_part" +"%I:%M:%S %p")
#
#    # Create subdirectory based on date if not already exists
#
#    # Merge contents into a single file with AM/PM timestamps
#    echo "Timestamp: $formatted_time" >> "$merged_file"
#    echo "Content of $filename:" >> "$merged_file"
#    cat "$file" >> "$merged_file"
#    echo "======================" >> "$merged_file"
#    mv "$file" "$sub_dir"
#done

# Write summary to file
#SUMMARY_FILE="$PDS_PATH/summaries/$day/summary.txt"
#source $PDS_PATH/bin/activate && python3 $PDS_PATH/gemini_flash_prompt.py -f $WORKING_DIR/summaries/$day/merged_file.txt -p daily_merge > $SUMMARY_FILE
#if [[ "$2" == "true" ]]; then
#    say -r 200 -f "$SUMMARY_FILE"
#fi
