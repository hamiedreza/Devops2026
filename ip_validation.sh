#!/bin/bash

read -p "Enter your first number: " var1
 read -p "Enter your second number: " var2

 var3=`echo "scale=5; $var2/$var1" | bc`
 var4=`echo "$var2 * $var1" | bc`

 echo "Dividing is $var3 and multiplying is $var4"
