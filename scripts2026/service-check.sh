
#!/bin/bash

# Linux Systemd Service Status Checker

set -uo pipefail

# Check Systemctl
if ! command -v systemctl >/dev/null 2>&1; then
    echo "Error: systemctl is not available."
    exit 1
fi

# Validate Arguments
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <service1> [service2] [service3] ..."
    exit 1
fi

# Counters
TOTAL=0
ACTIVE=0
INACTIVE=0
FAILED=0
NOT_FOUND=0

echo "========================================"
echo "Linux Service Status Checker"
echo "Hostname: $(hostname)"
echo "========================================"

# Check Services
for SERVICE in "$@"; do

    TOTAL=$((TOTAL + 1))

    LOAD_STATE=$(systemctl show "$SERVICE" \
        --property=LoadState --value 2>/dev/null || true)

    if [[ "$LOAD_STATE" == "not-found" || -z "$LOAD_STATE" ]]; then
        STATUS="NOT-FOUND"
        NOT_FOUND=$((NOT_FOUND + 1))

    else
        STATUS=$(systemctl is-active "$SERVICE" 2>/dev/null || true)

        case "$STATUS" in
            active)
                ACTIVE=$((ACTIVE + 1))
                STATUS="ACTIVE"
                ;;
            failed)
                FAILED=$((FAILED + 1))
                STATUS="FAILED"
                ;;
            *)
                INACTIVE=$((INACTIVE + 1))
                STATUS="INACTIVE"
                ;;
        esac
    fi

    printf "%-20s : %s\n" "$SERVICE" "$STATUS"

done

# Final Report
echo "========================================"
echo "Total Services : $TOTAL"
echo "Active         : $ACTIVE"
echo "Inactive       : $INACTIVE"
echo "Failed         : $FAILED"
echo "Not Found      : $NOT_FOUND"
echo "========================================"

# Exit Status
if (( INACTIVE > 0 || FAILED > 0 || NOT_FOUND > 0 )); then
    exit 1
fi

exit 0

