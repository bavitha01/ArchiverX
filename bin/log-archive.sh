#!/bin/bash

# Get the absolute path of the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source the functions library
source "$PROJECT_ROOT/lib/functions.sh"

# Default values
ARCHIVE_DIR="$PROJECT_ROOT/archived_logs"
MAX_LOG_SIZE=10485760  # 10MB
MAX_LOG_FILES=5
MAX_ARCHIVE_AGE=30  # days
COMPRESSION_LEVEL=6

# Parse command line arguments
while getopts "d:l:f:a:c:nh" opt; do
    case $opt in
        d) ARCHIVE_DIR="$OPTARG";;
        l) MAX_LOG_SIZE="$OPTARG";;
        f) MAX_LOG_FILES="$OPTARG";;
        a) MAX_ARCHIVE_AGE="$OPTARG";;
        c) COMPRESSION_LEVEL="$OPTARG";;
        n) DRY_RUN=true;;
        h) show_help; exit 0;;
        ?) show_help; exit 1;;
    esac
done

shift $((OPTIND-1))

# Check if the log directory is provided
if [ -z "$1" ]; then
    echo "Error: Log directory not specified"
    show_help
    exit 1
fi

LOG_DIR="$1"

# Show help function
show_help() {
    echo "Usage: $0 [options] <log-directory>"
    echo "Options:"
    echo "  -d <dir>    Archive directory (default: $ARCHIVE_DIR)"
    echo "  -l <size>   Max log file size in bytes (default: $MAX_LOG_SIZE)"
    echo "  -f <num>    Max number of log files (default: $MAX_LOG_FILES)"
    echo "  -a <days>   Max age of archives in days (default: $MAX_ARCHIVE_AGE)"
    echo "  -c <level>  Compression level (1-9, default: $COMPRESSION_LEVEL)"
    echo "  -n          Dry run (don't create archives)"
    echo "  -h          Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -d /backup/logs -c 9 /var/log"
}

# Main archiving function
archive_logs() {
    local log_dir=$1
    local archive_dir=$2
    
    # Check if directory is readable
    if ! check_readable "$log_dir"; then
        exit 1
    fi
    
    # Check directory and permissions
    local dir_check_result
    check_directory "$log_dir"
    dir_check_result=$?
    
    if [ $dir_check_result -eq 2 ]; then
        # Directory is not writable, use home directory
        local home_dir=$(get_home_dir)
        archive_dir="$home_dir/archiverx_archives"
        echo "Using alternative archive directory: $archive_dir"
    elif [ $dir_check_result -eq 1 ]; then
        exit 1
    fi
    
    # Check disk space
    if ! check_disk_space "$log_dir"; then
        exit 1
    fi
    
    # Create archive directory if it doesn't exist
    mkdir -p "$archive_dir"
    
    # Create timestamp
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local archive_file="logs_archive_$timestamp.tar.gz"
    
    # Count files before archiving
    local file_count=$(count_files "$log_dir")
    local dir_size=$(get_dir_size "$log_dir")
    
    if [ "$DRY_RUN" = true ]; then
        echo "Dry run - would archive:"
        echo "  Directory: $log_dir"
        echo "  Files: $file_count"
        echo "  Size: $dir_size"
        echo "  Archive: $archive_dir/$archive_file"
        return 0
    fi
    
    # Create the archive with specified compression level
    if ! tar -czf "$archive_dir/$archive_file" --use-compress-program="gzip -$COMPRESSION_LEVEL" -C "$log_dir" . 2>/dev/null; then
        log_message "Failed to create archive $archive_file" "$archive_dir/archive_log.txt"
        echo "Error: Failed to create archive. Check permissions and disk space."
        exit 1
    fi
    
    # Verify archive integrity
    if ! verify_archive "$archive_dir/$archive_file"; then
        log_message "Archive verification failed for $archive_file" "$archive_dir/archive_log.txt"
        echo "Error: Archive verification failed. The archive may be corrupted."
        exit 1
    fi
    
    # Log the operation
    log_message "Successfully archived $file_count files ($dir_size) to $archive_file" "$archive_dir/archive_log.txt"
    
    # Rotate logs if needed
    rotate_logs "$archive_dir/archive_log.txt" "$MAX_LOG_SIZE" "$MAX_LOG_FILES"
    
    # Cleanup old archives
    cleanup_old_archives "$archive_dir" "$MAX_ARCHIVE_AGE"
    
    echo "Logs have been archived to $archive_dir/$archive_file"
    echo "Total files archived: $file_count"
    echo "Total size: $dir_size"
}

# Execute the main function
archive_logs "$LOG_DIR" "$ARCHIVE_DIR"