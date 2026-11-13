
#!/bin/bash

# Production Ready - Cleanup Old Files

set -Eeuo pipefail

# Configuration
LOG_FILE="/var/log/cleanup-old-files.log"
LOCK_FILE="/run/lock/cleanup-old-files.lock"

# Input Arguments
TARGET_DIR="${1:-}"
AGE_DAYS="${2:-}"
MODE="${3:---dry-run}"

# Logging Function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Root Permission Check
if [[ "$EUID" -ne 0 ]]; then
    echo "Error: Run this script as root."
    exit 1
fi

# Argument Validation
if [[ -z "$TARGET_DIR" || -z "$AGE_DAYS" ]]; then
    echo "Usage: $0 <directory> <days> [--dry-run|--delete]"
    exit 1
fi

if [[ ! "$TARGET_DIR" = /* ]]; then
    echo "Error: Target directory must be an absolute path."
    exit 1
fi

if [[ ! "$AGE_DAYS" =~ ^[1-9][0-9]*$ ]] || (( AGE_DAYS > 36500 )); then
    echo "Error: Days must be between 1 and 36500."
    exit 1
fi

if [[ "$MODE" != "--dry-run" && "$MODE" != "--delete" ]]; then
    echo "Error: Invalid mode."
    exit 1
fi

# Directory Validation
if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: Directory does not exist."
    exit 1
fi

TARGET_DIR="$(realpath -e -- "$TARGET_DIR")"

if [[ "$TARGET_DIR" == "/" ]]; then
    echo "Error: Root directory is not allowed."
    exit 1
fi

# Initialize Logging
touch "$LOG_FILE"
chmod 640 "$LOG_FILE"

# Prevent Concurrent Execution
exec 9>"$LOCK_FILE"

if ! flock -n 9; then
    log "ERROR: Another cleanup process is running."
    exit 1
fi

# Temporary File
TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

# Calculate Age
AGE_MINUTES=$((AGE_DAYS * 1440))

log "========================================"
log "Cleanup Started"
log "Target: $TARGET_DIR"
log "Age: More than $AGE_DAYS days"
log "Mode: $MODE"

# Find Old Files
if ! find "$TARGET_DIR" -xdev -type f \
    -mmin "+$AGE_MINUTES" -print0 > "$TMP_FILE"; then
    log "ERROR: Failed to scan target directory."
    exit 1
fi

TOTAL_FILES=0
DELETED_FILES=0
ERRORS=0

# Process Files
while IFS= read -r -d '' FILE; do

    TOTAL_FILES=$((TOTAL_FILES + 1))

    printf -v DISPLAY_FILE '%q' "$FILE"

    if [[ "$MODE" == "--dry-run" ]]; then
        log "DRY-RUN: Would delete $DISPLAY_FILE"

    else
        if rm -f -- "$FILE"; then
            DELETED_FILES=$((DELETED_FILES + 1))
            log "DELETED: $DISPLAY_FILE"
        else
            ERRORS=$((ERRORS + 1))
            log "ERROR: Failed to delete $DISPLAY_FILE"
        fi
    fi

done < "$TMP_FILE"

# Final Report
log "----------------------------------------"
log "Total Files Found: $TOTAL_FILES"

if [[ "$MODE" == "--delete" ]]; then
    log "Deleted Files: $DELETED_FILES"
    log "Errors: $ERRORS"
else
    log "Dry Run completed. No files were deleted."
fi

log "Cleanup Finished"
log "========================================"

if (( ERRORS > 0 )); then
    exit 1
fi

exit 0

