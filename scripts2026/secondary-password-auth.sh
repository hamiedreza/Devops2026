#!/bin/bash

HASH_FILE="/etc/second_password.hash"

read -s -p "Enter second password: " PASSWORD
echo

INPUT_HASH=$(echo -n "$PASSWORD" | sha256sum | awk '{print $1}')

STORED_HASH=$(cat "$HASH_FILE")

if [ "$INPUT_HASH" = "$STORED_HASH" ]; then
    echo "Second password is correct. Login successful."
else
    echo "Second password is incorrect. Login denied."
    exit 1
fi
