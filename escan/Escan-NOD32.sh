#Eset NOD32 AV PLUGIN

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
echo "Running eScan AV scan..."

ESCAN_OUTPUT=$(MSYS_NO_PATHCONV=1 docker run --rm \
    ${MOUNT_OPTION} \
    malice/escan "$TARGET_PATH")

SCAN_END_TIME=$(date '+%Y-%m-%d %H:%M:%S')

ESCAN_INFECTED=$(echo "$ESCAN_OUTPUT" | jq -r '.escan.infected')
VIRUS_TYPE=$(echo "$ESCAN_OUTPUT" | jq -r '.escan.result')
FILE_NAME=$(basename "$SCAN_PATH")

# Construct JSON output based on infection status
if [ "$ESCAN_INFECTED" = "true" ]; then
    json_payload=$(jq -n \
        --arg escan_infected "$ESCAN_INFECTED" \
        --arg virus_type "$VIRUS_TYPE" \
        --arg file_name "$FILE_NAME" \
        --arg scan_end_time "$SCAN_END_TIME" \
        '{
            "escan": {
                "infected": $escan_infected,
                "virus_type": $virus_type,
                "file_name": $file_name
            },
            "scan_end_time": $scan_end_time
        }')
else
    json_payload=$(jq -n \
        --arg escan_infected "$ESCAN_INFECTED" \
        --arg scan_end_time "$SCAN_END_TIME" \
        '{
            "escan": {
                "infected": $escan_infected
            },
            "scan_end_time": $scan_end_time
        }')
fi

echo "Scan completed."
echo "JSON Payload:"
echo "$json_payload" | jq '.'

#example output

# Saket Singh@LAPTOP-QBCATC1O MINGW64 /d/project/SIH2k24/AV-docker-engine/escan (master)
# $ ./Escan-NOD32.sh "D:/Test/testing.exe"
# Input file: D:/Test/testing.exe
# Converted path for Docker: D:/Test/testing.exe
# Running eScan AV scan...
# Scan completed.
# JSON Payload:
# {
#   "escan": {
#     "infected": "false"
#   },
#   "scan_end_time": "2024-11-20 05:15:16"
# }