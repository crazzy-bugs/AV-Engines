#!/bin/bash

if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it first."
    exit 1
fi

if [ -z "$1" ]; then
  echo "Usage: $0 <path-to-scan>"
  exit 1
fi

SCAN_PATH=$(realpath -m "$1")  # Get absolute path
SCAN_PATH=$(echo "$SCAN_PATH" | sed 's|^/\([a-zA-Z]\)/|\1:/|')  

# Check if the provided path is a file or a directory
if [ -f "$SCAN_PATH" ]; then
    MOUNT_OPTION="-v $(dirname "$SCAN_PATH"):/malware:ro"
    TARGET_PATH="/malware/$(basename "$SCAN_PATH")"
elif [ -d "$SCAN_PATH" ]; then
    MOUNT_OPTION="-v ${SCAN_PATH}:/malware:ro"
    TARGET_PATH="/malware/"
else
    echo "Error: Specified path does not exist."
    exit 1
fi

echo "Input path: $1"
echo "Converted path for Docker: $SCAN_PATH"
echo "Running Comodo AV scan..."

COMODO_OUTPUT=$(MSYS_NO_PATHCONV=1 docker run --rm \
    ${MOUNT_OPTION} \
    malice/comodo "$TARGET_PATH")

SCAN_END_TIME=$(date '+%Y-%m-%d %H:%M:%S')

COMODO_INFECTED=$(echo "$COMODO_OUTPUT" | jq -r '.comodo.infected')
VIRUS_TYPE=$(echo "$COMODO_OUTPUT" | jq -r '.comodo.result')
FILE_NAME=$(basename "$SCAN_PATH")

# Construct JSON output based on infection status
if [ "$COMODO_INFECTED" = "true" ]; then
    json_payload=$(jq -n \
        --arg comodo_infected "$COMODO_INFECTED" \
        --arg virus_type "$VIRUS_TYPE" \
        --arg file_name "$FILE_NAME" \
        --arg scan_end_time "$SCAN_END_TIME" \
        '{
            "comodo": {
                "infected": $comodo_infected,
                "virus_type": $virus_type,
                "file_name": $file_name
            },
            "scan_end_time": $scan_end_time
        }')
else
    json_payload=$(jq -n \
        --arg comodo_infected "$COMODO_INFECTED" \
        --arg scan_end_time "$SCAN_END_TIME" \
        '{
            "comodo": {
                "infected": $comodo_infected
            },
            "scan_end_time": $scan_end_time
        }')
fi

echo "Scan completed."
echo "JSON Payload:"
echo "$json_payload" | jq '.'
