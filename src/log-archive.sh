#!/bin/bash

# Check if the log directory is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <log-directory>"
  exit 1
fi

# Assign the log directory to a variable
LOG_DIR=$1

# Check if the directory exists
if [ ! -d "$LOG_DIR" ]; then
  echo "Error: Directory $LOG_DIR does not exist."
  exit 1
fi

# Create a timestamp for the archive
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Define the archive directory and filename
ARCHIVE_DIR="archived_logs"
ARCHIVE_FILE="logs_archive_$TIMESTAMP.tar.gz"

# Create the archive directory if it doesn't exist
mkdir -p "$ARCHIVE_DIR"

# Compress the logs into a tar.gz file
tar -czf "$ARCHIVE_DIR/$ARCHIVE_FILE" -C "$LOG_DIR" .

# Log the date and time of the archive
echo "Logs archived on $(date)" >> "$ARCHIVE_DIR/archive_log.txt"

echo "Logs have been archived to $ARCHIVE_DIR/$ARCHIVE_FILE"