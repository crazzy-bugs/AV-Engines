#!/bin/bash

if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it first."
    exit 1
fi

if [ -z "$1" ]; then
  echo "Usage: $0 <path-to-file>"
  exit 1
fi

SCAN_PATH=$(realpath -m "$1")  # Get absolute path
SCAN_PATH=$(echo "$SCAN_PATH" | sed 's|^/\([a-zA-Z]\)/|\1:/|')  

# Check if the provided path is a file
if [ -f "$SCAN_PATH" ]; then
    MOUNT_OPTION="-v $(dirname "$SCAN_PATH"):/malware:ro"
    TARGET_PATH="/malware/$(basename "$SCAN_PATH")"
else
    echo "Error: Specified path is not a file or does not exist."
    exit 1
fi

echo "Input file: $1"
echo "Converted path for Docker: $SCAN_PATH"
echo "Running McAfee AV scan..."

MCAFEE_OUTPUT=$(MSYS_NO_PATHCONV=1 docker run --rm \
    ${MOUNT_OPTION} \
    malice/mcafee "$TARGET_PATH")

SCAN_END_TIME=$(date '+%Y-%m-%d %H:%M:%S')

MCAFEE_INFECTED=$(echo "$MCAFEE_OUTPUT" | jq -r '.mcafee.infected')
VIRUS_TYPE=$(echo "$MCAFEE_OUTPUT" | jq -r '.mcafee.result')
FILE_NAME=$(basename "$SCAN_PATH")

# Construct JSON output based on infection status
if [ "$MCAFEE_INFECTED" = "true" ]; then
    json_payload=$(jq -n \
        --arg mcafee_infected "$MCAFEE_INFECTED" \
        --arg virus_type "$VIRUS_TYPE" \
        --arg file_name "$FILE_NAME" \
        --arg scan_end_time "$SCAN_END_TIME" \
        '{
            "mcafee": {
                "infected": $mcafee_infected,
                "virus_type": $virus_type,
                "file_name": $file_name
            },
            "scan_end_time": $scan_end_time
        }')
else
    json_payload=$(jq -n \
        --arg mcafee_infected "$MCAFEE_INFECTED" \
        --arg scan_end_time "$SCAN_END_TIME" \
        '{
            "mcafee": {
                "infected": $mcafee_infected
            },
            "scan_end_time": $scan_end_time
        }')
fi

echo "Scan completed."
echo "JSON Payload:"
echo "$json_payload" | jq '.'
