#!/bin/bash

read -p "Enter directory name: " DIR

if [[ -d $DIR ]]; then
    echo "Files in directory $DIR:"
    ls $DIR
else
    echo "Directory Not Found"
fi