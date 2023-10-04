#!/bin/bash

read -p "Enter file name: " FILE

if [[ -f $FILE ]]; then
    echo "File $FILE content:"
    cat $FILE
else
    echo "File Not Found"
fi