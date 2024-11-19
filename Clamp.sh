#!/bin/bash

if ! command -v jq &> /dev/null; then
    echo "Error: install jq"
    exit 1
fi

if [ -z "$1" ]; then
  echo "Usage: $0 <path-to-scan>"
  exit 1
fi

SCAN_PATH=$(realpath -m "$1")  # Get absolute path
SCAN_PATH=$(echo "$SCAN_PATH" | sed 's|^/\([a-zA-Z]\)/|\1:/|')  # Convert /d/test to D:/test

echo "Input path: $1"
echo "Converted path for Docker: $SCAN_PATH"
echo "Running ClamAV scan..."

SCAN_OUTPUT=$(MSYS_NO_PATHCONV=1 docker run --init --rm \
    -v "${SCAN_PATH}:/scan" \
    clamav/clamav clamscan -r /scan)

echo "ClamAV scan completed."

echo "Extracting scan details..."
scanned_files=$(echo "$SCAN_OUTPUT" | grep -oP 'Scanned files: \K\d+')
infected_files=$(echo "$SCAN_OUTPUT" | grep -oP 'Infected files: \K\d+')
start_date=$(echo "$SCAN_OUTPUT" | grep -oP 'Start Date: \K.*' | xargs)

infected_details=()
while IFS= read -r line; do
    if [[ $line =~ FOUND$ ]]; then
        # Extract the relative file path by removing the "/scan/" prefix
        file_name=$(echo "$line" | sed 's|^/scan/||' | cut -d: -f1)
        file_name=$(echo "$file_name" | xargs)
        virus_type=$(echo "$line" | cut -d: -f2 | sed 's/ FOUND$//' | xargs)
        infected_details+=("{\"file_name\": \"$file_name\", \"virus_type\": \"$virus_type\"}")
    fi
done < <(echo "$SCAN_OUTPUT")

json_base=$(jq -n \
    --arg scannedFiles "$scanned_files" \
    --arg infectedFiles "$infected_files" \
    --arg startTime "$start_date" \
    '{ 
        "scanned_files": $scannedFiles, 
        "infected_files": $infectedFiles, 
        "start_time": $startTime
    }')

if [ ${#infected_details[@]} -gt 0 ]; then
    infected_json=$(printf ",%s" "${infected_details[@]}")
    infected_json="[${infected_json:1}]"  
    json_payload=$(echo "$json_base" | jq --argjson infectedDetails "$infected_json" \
        '. + {"infected_details": $infectedDetails}')
else
    json_payload="$json_base"
fi

echo "JSON payload created."
echo "JSON Payload:"
echo "$json_payload" | jq '.'



