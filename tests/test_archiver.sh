#!/bin/bash

# Source the functions library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/functions.sh"

# Test directory setup
TEST_DIR="test_logs"
ARCHIVE_DIR="test_archives"
LOG_FILE="test.log"

setup() {
    # Create test directory and files
    mkdir -p "$TEST_DIR"
    mkdir -p "$ARCHIVE_DIR"
    
    # Create some test log files
    for i in {1..5}; do
        echo "Test log content $i" > "$TEST_DIR/log$i.log"
    done
}

cleanup() {
    # Remove test directories
    rm -rf "$TEST_DIR"
    rm -rf "$ARCHIVE_DIR"
}

test_directory_check() {
    echo "Testing directory check..."
    if ! check_directory "$TEST_DIR"; then
        echo "FAIL: Directory check failed"
        return 1
    fi
    echo "PASS: Directory check passed"
}

test_disk_space_check() {
    echo "Testing disk space check..."
    if ! check_disk_space "$TEST_DIR"; then
        echo "FAIL: Disk space check failed"
        return 1
    fi
    echo "PASS: Disk space check passed"
}

test_log_rotation() {
    echo "Testing log rotation..."
    # Create a large log file
    dd if=/dev/zero of="$LOG_FILE" bs=1M count=11 2>/dev/null
    
    rotate_logs "$LOG_FILE" 10485760 3
    
    if [ ! -f "${LOG_FILE}.1" ]; then
        echo "FAIL: Log rotation failed"
        return 1
    fi
    echo "PASS: Log rotation passed"
}

test_archive_verification() {
    echo "Testing archive verification..."
    # Create a test archive
    tar -czf test.tar.gz "$TEST_DIR"
    
    if ! verify_archive "test.tar.gz"; then
        echo "FAIL: Archive verification failed"
        return 1
    fi
    echo "PASS: Archive verification passed"
    
    rm test.tar.gz
}

run_tests() {
    echo "Starting tests..."
    
    setup
    
    test_directory_check
    test_disk_space_check
    test_log_rotation
    test_archive_verification
    
    cleanup
    
    echo "All tests completed"
}

# Run the tests
run_tests 