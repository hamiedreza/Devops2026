#!/bin/bash
# This code is written by hamiedreza
# SCN4

read -s -p "Enter a username: " user
echo

if egrep -i "^$user:" /etc/passwd > /dev/null
then
    echo "$user IS EXIST"
else
    echo "$user NOT EXIST"
fi
