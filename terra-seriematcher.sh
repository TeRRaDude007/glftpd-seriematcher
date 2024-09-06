#!/bin/bash
##################################################
### TeRRaDuDe SERiE MATCHER on DIR TAGS v2.0 #####
##################################################
#
#  Scan All Directories:
#        The script scans all directories and identifies pairs where one has the HDR tag and the other does not.
#
#  Prepare for Moving:
#        For You.S04E09, it identifies:
#            Non-HDR directory: You.S04E09.2160p.WEB.h265-WEB123
#            HDR directory: You.S04E09.HDR.2160p.WEB.h265-WEB123
#        For You.S04E10, it identifies:
#            Non-HDR directory: You.S04E10.2160p.WEB.h265-WEB456
#            HDR directory: You.S04E10.HDR.2160p.WEB.h265-WEB456
#
#  Confirm and Move:
#       The script will prompt you to confirm moving the following non-HDR directories to the HDR directory:
#            You.S04E09.2160p.WEB.h265-WEB123
#            You.S04E10.2160p.WEB.h265-WEB456
#       If confirmed, these directories are moved to /glftpd/site/SETiONS/DIRTOMOVETO.
#
#  No Action Needed:
#       If no HDR/non-HDR pairs are found, no directories are moved.
#       Both HDR and non-HDR directories stay in their original locations.
#
#  Script Summary:
#
#    No Matches: No directories are moved; everything remains as is.
#    Matches Found: Non-HDR directories are moved to the HDR folder after confirmation.
#
#
########### Changelog ##########################
#
# 1.x BETA Some idea...
# 1.0 Matches if (DV).HDR is presents next to normal release in 2160P 
# 1.1 Added: skip section to avoid some tags
# 2.0 Added: Now only moves +7 days old series
#
#################################################
#############    CONFIG SETUP    ################
#################################################

# Source and destination directories
SRC_DIR="/glftpd/site/SERIESECTION"
DEST_DIR="$SRC_DIR/DIRTOMOVETO"

#################################################
###### END OF CONFIG ## DONT EDIT BELOW #########
#################################################

# Ensure the HDR destination directory exists
mkdir -m777 -p "$DEST_DIR"

# Function to extract the base name (up to season and episode number)
extract_season_episode() {
    local dir_name="$1"
    echo "$dir_name" | sed -E 's/^(.*S[0-9]{2}E[0-9]{2}).*$/\1/'
}

# Tags to skip
SKIP_TAGS="\.DV.2160P|\.PROPER|\.REPACK"

# Function to check if a directory contains any of the skip tags
contains_skip_tags() {
    local dir_name="$1"
    echo "$dir_name" | grep -qE "$SKIP_TAGS"
}

# Use associative arrays to store directories based on season/episode
declare -A non_hdr_dirs
declare -A hdr_dirs
declare -a to_move_list  # Array to store non-HDR directories to be moved

# Scan all directories in the source folder that are older than 7 days
for dir in $(find "$SRC_DIR" -maxdepth 1 -type d -mtime +7); do
    # Skip the source directory itself
    if [ "$dir" == "$SRC_DIR" ]; then
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
    echo "The following non-HDR directories, older than 7 days, are ready to be moved to $DEST_DIR:"
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
#EOF
