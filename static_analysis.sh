#!/bin/bash


LOG_DIR="D:/Test/Logs" # add your log file directory here
mkdir -p "$LOG_DIR"

LOG1="$LOG_DIR/malstr_check.log" # these 3 files will keep on overwritting themselves
LOG2="$LOG_DIR/kappa.log"
LOG3="$LOG_DIR/sigcheck.log"

> "$LOG1"
> "$LOG2"
> "$LOG3"

echo "Starting scripts in parallel..."
./malstr_check.sh "$1" > "$LOG1" 2>&1 &
./kappa.sh "$1" > "$LOG2" 2>&1 &
./sigcheck.sh "$1" > "$LOG3" 2>&1 &


wait
echo "All scripts have completed. Logs are available in $LOG_DIR."
