
#!/bin/bash

# Server Port Connectivity Checker

set -Eeuo pipefail

# Input Arguments
HOST="${1:-}"
PORT="${2:-}"
TIMEOUT=3

# Usage
if [[ -z "$HOST" || -z "$PORT" ]]; then
    echo "Usage: $0 <server_ip|hostname> <port>"
    exit 1
fi

# Validate Port
if [[ ! "$PORT" =~ ^[0-9]+$ ]] || (( PORT < 1 || PORT > 65535 )); then
    echo "Error: Port must be between 1 and 65535."
    exit 1
fi

# Check Netcat
if ! command -v nc >/dev/null 2>&1; then
    echo "Error: Netcat is not installed."
    echo "Install it using: apt install netcat-openbsd"
    exit 1
fi

echo "================================"
echo "Server Connectivity Check"
echo "Target : $HOST"
echo "Port   : $PORT"
echo "================================"

# Test TCP Connection
if nc -z -w "$TIMEOUT" "$HOST" "$PORT" 2>/dev/null; then
    echo "[OPEN] $HOST:$PORT is reachable"
    exit 0
else
    echo "[FAILED] $HOST:$PORT is not reachable"
    exit 1
fi

