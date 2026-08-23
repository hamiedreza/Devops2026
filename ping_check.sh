#!/bin/bash
IP="192.168.93.149"   

for i in {1..4}; do
    VAR=$(echo "$IP" | cut -d '.' -f$i)

    if [ -z "$VAR" ] || [ "$VAR" -lt 0 ] || [ "$VAR" -gt 255 ]; then
        echo "Your IP is not correct ....."
        exit 1
    fi
done

echo "Your IP is correct!"

