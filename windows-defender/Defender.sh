# Windows Defender AV PLUGIN
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
    TARGET_MOUNT_PATH="/malware/$(basename "$SCAN_PATH")"
    MOUNT_OPTION="-v ${SCAN_PATH}:${TARGET_MOUNT_PATH}"
elif [ -d "$SCAN_PATH" ]; then
    MOUNT_OPTION="-v ${SCAN_PATH}:/malware"
    TARGET_MOUNT_PATH="/malware"
else
    echo "Error: Specified path does not exist."
    exit 1
fi

echo "Input path: $1"
echo "Converted path for Docker: $SCAN_PATH"
echo "Running Windows Defender scan..."

DEFENDER_OUTPUT=$(MSYS_NO_PATHCONV=1 docker run --init --rm \
    ${MOUNT_OPTION} \
    malice/windows-defender "$TARGET_MOUNT_PATH")

SCAN_END_TIME=$(date '+%Y-%m-%d %H:%M:%S')

DEFENDER_INFECTED=$(echo "$DEFENDER_OUTPUT" | jq -r '.windows_defender.infected')
VIRUS_TYPE=$(echo "$DEFENDER_OUTPUT" | jq -r '.windows_defender.result')
FILE_NAME=$(basename "$SCAN_PATH")

if [ "$DEFENDER_INFECTED" = "true" ]; then
    json_payload=$(jq -n \
        --arg defender_infected "$DEFENDER_INFECTED" \
        --arg virus_type "$VIRUS_TYPE" \
        --arg file_name "$FILE_NAME" \
        --arg scan_end_time "$SCAN_END_TIME" \
        '{
            "windows_defender": {
                "infected": $defender_infected,
                "virus_type": $virus_type,
                "file_name": $file_name
            },
            "scan_end_time": $scan_end_time
        }')
else
    json_payload=$(jq -n \
        --arg defender_infected "$DEFENDER_INFECTED" \
        --arg scan_end_time "$SCAN_END_TIME" \
        '{
            "windows_defender": {
                "infected": $defender_infected
            },
            "scan_end_time": $scan_end_time
        }')
fi

echo "Scan completed."
echo "JSON Payload:"
echo "$json_payload" | jq '.'

#Example 

# Saket Singh@LAPTOP-QBCATC1O MINGW64 /d/project/SIH2k24/AV-docker-engine/windows-defender (master)
# $ ./Defender.sh "D:/Test/testing.exe"

# Input path: D:/Test/testing.exe
# Converted path for Docker: D:/Test/testing.exe
# Running Windows Defender scan...
# Scan completed.
# JSON Payload:
# {
#   "windows_defender": {
#     "infected": "true",
#     "virus_type": "Virus:DOS/EICAR_Test_File",
#     "file_name": "testing.exe"
#   },
#   "scan_end_time": "2024-11-20 05:20:37"
# }