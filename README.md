# glftpd-seriematcher
The script collects all matches first and then asks for a confirmation to move all matched directories at once.

    No Match Found:
        If there is no HDR directory for a given season/episode, the corresponding non-HDR directory remains unchanged.
        Likewise, if there is no non-HDR directory for a given season/episode, the HDR directory remains in its original location.

    Match Found:
        When a match is found (i.e., both an HDR directory and a non-HDR directory exist for the same season/episode), the script:
            Collects the non-HDR directory.
            Prompts you to confirm if you want to move all the non-HDR directories to the /glftpd/site/TV-1080P/HDR directory.
            If confirmed, it moves the non-HDR directories to the HDR folder while leaving the HDR directories in their original locations.

Example Scenario:

Given the following directories in /glftpd/site/SERIESECTION:

    You.S04E09.2160p.WEB.h265-WEB123
    You.S04E09.HDR.2160p.WEB.h265-WEB123
    You.S04E10.2160p.WEB.h265-WEB456
    You.S04E10.HDR.2160p.WEB.h265-WEB456

Steps:

    Scan All Directories:
        The script scans all directories and identifies pairs where one has the .HDR tag and the other does not.

    Prepare for Moving:
        For You.S04E09, it identifies:
            Non-HDR directory: You.S04E09.2160p.WEB.h265-WEB123
            HDR directory: You.S04E09.HDR.2160p.WEB.h265-WEB123
        For You.S04E10, it identifies:
            Non-HDR directory: You.S04E10.2160p.WEB.h265-WEB456
            HDR directory: You.S04E10.HDR.2160p.WEB.h265-WEB456

    Confirm and Move:
        The script will prompt you to confirm moving the following non-HDR directories to the HDR directory:
            You.S04E09.2160p.WEB.h265-WEB123
            You.S04E10.2160p.WEB.h265-WEB456
        If confirmed, these directories are moved to /glftpd/site/TV-1080P/HDR.

    No Action Needed:
        If no HDR/non-HDR pairs are found, no directories are moved.
        Both HDR and non-HDR directories stay in their original locations.

Script Summary:

    No Matches: No directories are moved; everything remains as is.
    Matches Found: Non-HDR directories are moved to the HDR folder after confirmation.
This ensures that only the non-HDR directories are moved when a corresponding HDR directory is found, and directories without matching pairs are left untouched.

How It Works:

    The script scans for directories older than 7 days.
    It processes these directories for matching and moving.
    If a matching HDR directory exists, the non-HDR directory is added to the list for moving.
    A confirmation prompt is shown at the end for all moves.

This will ensure that only directories older than 7 days are moved, and everything is confirmed before proceeding.


