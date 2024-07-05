#!/bin/bash
source /Users/jstein/workspace/ai/remwork/.env

# Function to get yesterday's date in the format YYYY-MM-DD
get_yesterday_date() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        date -v-1d '+%Y-%m-%d'
    else
        # Linux
        date -d 'yesterday' '+%Y-%m-%d'
    fi
}

# Function to merge two files
merge_files() {
    local file1=$1
    local file2=$2
    local output=$3
    cat "$file1" "$file2" > "$output"
}

# Recursive function to merge files using a binary tree algorithm
merge_files_recursive() {
    local target_dir=$1
    local files=("${@:2}")
    local merge_dir="$target_dir/merged_$(date +%Y-%m-%d)"
    mkdir -p "$merge_dir"

    if [ ${#files[@]} -le 1 ]; then
        echo "Final merged file: ${files[0]}"
        mkdir -p $WORKING_DIR/summaries/daily
        cp "${files[0]}" "$WORKING_DIR/daily/$(date +%Y-%m-%d).txt"
        return 0
    fi

    local new_files=()
    local i=0
    while [ $i -lt ${#files[@]} ]; do
        if [ $((i + 1)) -lt ${#files[@]} ]; then
            local output_file="$merge_dir/merged_$i.txt"
            merge_files "${files[$i]}" "${files[$((i + 1))]}" "$output_file"
            new_files+=("$output_file")
        else
            new_files+=("${files[$i]}")
        fi
        ((i += 2))
    done

    merge_files_recursive "$merge_dir" "${new_files[@]}"
}

# Check if the user provided a directory argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Get the target directory from the command line argument
target_dir=$1

# Check if the directory exists
if [ ! -d "$target_dir" ]; then
    echo "Directory not found: $target_dir"
    exit 1
fi

# Get yesterday's date
yesterday=$(get_yesterday_date)

# Find files from yesterday in the target directory
matching_files=$(ls "$target_dir" | grep "${yesterday}T")

# Check if there are matching files
if [ -z "$matching_files" ]; then
    echo "No files found for $yesterday in $target_dir"
    exit 1
fi

# Convert matching_files to an array with full paths
files=()
for file in $matching_files; do
    files+=("$target_dir/$file")
done

# Run the recursive binary tree merge function
merge_files_recursive "$target_dir" "${files[@]}"
