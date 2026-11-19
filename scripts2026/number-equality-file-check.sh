#!/bin/bash

read -p "Please enter number1: " NUMBER1
read -p "Please enter number2: " NUMBER2

if [ "$NUMBER1" -eq "$NUMBER2" ]; then

    if [ -f /var/log/messages ]; then
        echo "NUMBER1 is equal to NUMBER2 and messages file exists"
    else
        echo "NUMBER1 is equal to NUMBER2 but messages file does not exist"
    fi

else
    echo "NUMBER1 is not equal to NUMBER2"
fi
