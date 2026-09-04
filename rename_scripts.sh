#!/bin/bash

for i in script{1..20}; do
    if [ -f "$i" ]; then
        mv "$i" "$i.sh"
    fi
done
