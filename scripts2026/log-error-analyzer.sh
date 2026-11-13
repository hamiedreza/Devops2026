
#!/bin/bash

# Log Error Analyzer

LOG_FILE="${1:?Usage: $0 <log_file>}"

# Check file existence
if [[ ! -f "$LOG_FILE" ]]; then
    echo "Error: Log file not found!"
    exit 1
fi

# Check read permission
if [[ ! -r "$LOG_FILE" ]]; then
    echo "Error: Permission denied!"
    exit 1
fi

echo "========== LOG ANALYZER =========="

# Count total lines
echo "Total lines:"
wc -l < "$LOG_FILE"

# Count errors
ERROR_COUNT=$(grep -ic "error" "$LOG_FILE" || true)
echo "Error count: $ERROR_COUNT"

# Count warnings
WARNING_COUNT=$(grep -ic "warning" "$LOG_FILE" || true)
echo "Warning count: $WARNING_COUNT"

# Display recent errors
echo
echo "========== RECENT ERRORS =========="

grep -in "error" "$LOG_FILE" | tail -n 5

echo
echo "========== ANALYSIS COMPLETE =========="

