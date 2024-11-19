#!/bin/bash

# Ensure the path is provided as argument
if [ -z "$1" ]; then
  echo "Usage: $0 <path-to-scan>"
  exit 1
fi

SCAN_PATH="$1"  # Path provided as argument

# Output file names for each script (simplified naming)
OUTPUT_FILE_CLAMP="clam_output.json"
OUTPUT_FILE_DEFENDER="defender_output.json"
OUTPUT_FILE_COMODO="comodo_output.json"
OUTPUT_FILE_MCAFEE="mcafee_output.json"
OUTPUT_FILE_NOD32="nod32_output.json"

# Run each AV scan script in the background, outputting results to respective files
./@Clamp.sh "$SCAN_PATH" > "$OUTPUT_FILE_CLAMP" &
PID_CLAMP=$!

./@Defender.sh "$SCAN_PATH" > "$OUTPUT_FILE_DEFENDER" &
PID_DEFENDER=$!

./@Comodo.sh "$SCAN_PATH" > "$OUTPUT_FILE_COMODO" &
PID_COMODO=$!

./@Mcafee.sh "$SCAN_PATH" > "$OUTPUT_FILE_MCAFEE" &
PID_MCAFEE=$!

./@Escan-NOD32.sh "$SCAN_PATH" > "$OUTPUT_FILE_NOD32" &
PID_NOD32=$!

# Wait for all background processes to finish
wait $PID_CLAMP
wait $PID_DEFENDER
wait $PID_COMODO
wait $PID_MCAFEE
wait $PID_NOD32

# Combine all output files into one JSON file
echo "[" > final_output.json
cat "$OUTPUT_FILE_CLAMP" >> final_output.json
echo "," >> final_output.json
cat "$OUTPUT_FILE_DEFENDER" >> final_output.json
echo "," >> final_output.json
cat "$OUTPUT_FILE_COMODO" >> final_output.json
echo "," >> final_output.json
cat "$OUTPUT_FILE_MCAFEE" >> final_output.json
echo "," >> final_output.json
cat "$OUTPUT_FILE_NOD32" >> final_output.json
echo "]" >> final_output.json

# Clean up intermediate output files after merging
rm "$OUTPUT_FILE_CLAMP" "$OUTPUT_FILE_DEFENDER" "$OUTPUT_FILE_COMODO" "$OUTPUT_FILE_MCAFEE" "$OUTPUT_FILE_NOD32"

# Print the combined output (for debugging or logging purposes)
cat final_output.json

# Optionally, send the final combined JSON to an API endpoint
# curl -X POST -H "Content-Type: application/json" -d @final_output.json <api-endpoint-url>
