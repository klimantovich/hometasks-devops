#!/bin/bash

read -p "Enter file name: " FILE

if [[ -f $FILE ]]; then
    #sed
    sed -i 's/error/warning/g' $FILE
else
    echo "File Not Found"
fi