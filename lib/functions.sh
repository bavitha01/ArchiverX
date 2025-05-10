#!/bin/bash

# Function to check if a directory exists and is readable
check_readable() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        echo "Error: Directory $dir does not exist."
        return 1
    fi
    if [ ! -r "$dir" ]; then
        echo "Error: Directory $dir is not readable."
        return 1
    fi
    return 0
}

# Function to check if a directory exists and is writable
check_directory() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        echo "Error: Directory $dir does not exist."
        return 1
    fi
    if [ ! -w "$dir" ]; then
        echo "Warning: Directory $dir is not writable. Will attempt to create archive in user's home directory."
        return 2
    fi
    return 0
}

# Function to check available disk space
check_disk_space() {
    local dir=$1
    local required_space=$(du -s "$dir" 2>/dev/null | awk '{print $1}')
    if [ -z "$required_space" ]; then
        echo "Error: Could not determine required space for $dir"
        return 1
    fi
    local available_space=$(df -k "$dir" 2>/dev/null | awk 'NR==2 {print $4}')
    if [ -z "$available_space" ]; then
        echo "Error: Could not determine available space for $dir"
        return 1
    fi
    
    if [ "$available_space" -lt "$required_space" ]; then
        echo "Error: Insufficient disk space. Required: ${required_space}KB, Available: ${available_space}KB"
        return 1
    fi
    return 0
}

# Function to log messages with timestamp
log_message() {
    local message=$1
    local log_file=$2
    local log_dir=$(dirname "$log_file")
    
    # Create log directory if it doesn't exist
    mkdir -p "$log_dir"
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$log_file"
}

# Function to rotate log files
rotate_logs() {
    local log_file=$1
    local max_size=$2
    local max_files=$3
    local log_dir=$(dirname "$log_file")
    
    # Create log directory if it doesn't exist
    mkdir -p "$log_dir"
    
    if [ -f "$log_file" ] && [ $(stat -f%z "$log_file" 2>/dev/null || stat -c%s "$log_file") -gt "$max_size" ]; then
        for ((i=max_files-1; i>=1; i--)); do
            if [ -f "${log_file}.$i" ]; then
                mv "${log_file}.$i" "${log_file}.$((i+1))"
            fi
        done
        mv "$log_file" "${log_file}.1"
        touch "$log_file"
    fi
}

# Function to calculate directory size
get_dir_size() {
    local dir=$1
    du -sh "$dir" 2>/dev/null | awk '{print $1}' || echo "0"
}

# Function to count files in directory
count_files() {
    local dir=$1
    find "$dir" -type f 2>/dev/null | wc -l || echo "0"
}

# Function to verify archive integrity
verify_archive() {
    local archive=$1
    if ! tar -tzf "$archive" >/dev/null 2>&1; then
        echo "Error: Archive $archive is corrupted"
        return 1
    fi
    return 0
}

# Function to clean old archives
cleanup_old_archives() {
    local archive_dir=$1
    local max_age=$2  # in days
    
    # Create archive directory if it doesn't exist
    mkdir -p "$archive_dir"
    
    find "$archive_dir" -name "*.tar.gz" -type f -mtime +$max_age -delete 2>/dev/null
    log_message "Cleaned up archives older than $max_age days" "$archive_dir/archive_log.txt"
}

# Function to get user's home directory
get_home_dir() {
    echo "$HOME"
} 