#!/bin/bash

# Source and destination directories
SRC_DIR="/glftpd/site/TV-1080P"
DEST_DIR="$SRC_DIR/HDR"

# Ensure the HDR destination directory exists
mkdir -p "$DEST_DIR"

# Function to extract the base name (up to season and episode number)
extract_season_episode() {
    local dir_name="$1"
    echo "$dir_name" | sed -E 's/^(.*S[0-9]{2}E[0-9]{2}).*$/\1/'
}

# Tags to skip
SKIP_TAGS=("DV" "PROPER")

# Function to check if a directory contains any of the skip tags
contains_skip_tags() {
    local dir_name="$1"
    for tag in "${SKIP_TAGS[@]}"; do
        if [[ "$dir_name" == *".$tag"* ]]; then
            return 0
        fi
    done
    return 1
}

# Use associative arrays to store directories based on season/episode
declare -A non_hdr_dirs
declare -A hdr_dirs
declare -a to_move_list  # Array to store non-HDR directories to be moved

# Scan all directories in the source folder
for dir in "$SRC_DIR"/*; do
    # Ensure we're working with a directory
    if [ ! -d "$dir" ]; then
        continue
    fi

    # Get the directory name
    dir_name=$(basename "$dir")

    # Skip directories containing any of the skip tags
    if contains_skip_tags "$dir_name"; then
        echo "Skipping directory with skip tags: $dir_name"
        continue
    fi

    # Extract season and episode number
    base_name=$(extract_season_episode "$dir_name")

    # Check if the directory contains .HDR
    if [[ "$dir_name" == *".HDR"* ]]; then
        hdr_dirs["$base_name"]="$dir_name"
    else
        non_hdr_dirs["$base_name"]="$dir_name"
    fi
done

# Compare directories with the same season/episode base name
for base_name in "${!hdr_dirs[@]}"; do
    if [[ -n "${non_hdr_dirs[$base_name]}" ]]; then
        # If a matching HDR directory exists for this non-HDR base name, prepare to move the non-HDR directory
        echo "Match found for $base_name with HDR in one directory:"
        echo " - Non-HDR directory: ${non_hdr_dirs[$base_name]}"
        echo " - HDR directory: ${hdr_dirs[$base_name]}"
        to_move_list+=("${non_hdr_dirs[$base_name]}")
    fi
done

# After collecting all moves, confirm them all at once
if [ ${#to_move_list[@]} -gt 0 ]; then
    echo
    echo "The following non-HDR directories are ready to be moved to $DEST_DIR:"
    for non_hdr_dir in "${to_move_list[@]}"; do
        echo " - $non_hdr_dir"
    done
    echo
    read -p "Do you want to move all these non-HDR directories? (y/n): " confirm_all
    if [[ "$confirm_all" == "y" ]]; then
        for non_hdr_dir in "${to_move_list[@]}"; do
            echo "Moving non-HDR directory: $non_hdr_dir"
            mv "$SRC_DIR/$non_hdr_dir" "$DEST_DIR"
        done
        echo "All selected non-HDR directories have been moved."
    else
        echo "No directories were moved."
    fi
else
    echo "No matches found to move."
fi

