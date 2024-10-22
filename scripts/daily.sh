#!/bin/bash

# Directory containing the timestamped files
source_dir=$1
days=$2

day=$(date -v-${days}d '+%Y-%m-%d')
# Iterate over each file in the source directory
for file in "$source_dir"/$day*.txt; do
    # Extract date from filename (assuming filenames are in YYYY-MM-DDTHH:MM:SS.sss.txt format)
    filename=$(basename "$file")
    timestamp="${filename%.txt}"
    date_part="${timestamp:0:10}"  # Extract YYYY-MM-DD part
    time_part="${filename:11:8}"
    formatted_time=$(date -j -f "%H:%M:%S" "$time_part" +"%I:%M:%S %p")

    # Create subdirectory based on date if not already exists
    sub_dir="$source_dir/$date_part"
    mkdir -p "$sub_dir"

    # Merge contents into a single file with AM/PM timestamps
    merged_file="$sub_dir/merged_file.txt"
    echo "Timestamp: $formatted_time" >> "$merged_file"
    echo "Content of $filename:" >> "$merged_file"
    cat "$file" >> "$merged_file"
    echo "======================" >> "$merged_file"
done
