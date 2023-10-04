#!/bin/bash

FILE="$HOME/my_file.txt"
DESTINATION_DIR="/tmp"

if [[ -f $FILE ]]; then
    cp $FILE $DESTINATION_DIR
fi