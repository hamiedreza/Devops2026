#!/bin/bash

read -p "Let's see what is your favorite OS: " MY_OS

sleep 2
MY_OS=$(echo "$MY_OS" | tr '[:upper:]' '[:lower:]' | tr -d '[:digit:]' | tr -d '[:blank:]' | tr -d '[:punct:]')

if [ "$MY_OS" = "linux" ]; then
    usleep  20000
    echo "Haha happy to hear that!!"
elif [ "$MY_OS" = "windows" ]; then
     usleep 20000
    echo "shame on you!!"
elif [ "$MY_OS" = "mac" ]; then
     usleep 20000
    echo "bad nist!!"
else
    echo "Not bad!!"
fi

