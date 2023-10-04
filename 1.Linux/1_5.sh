#!/bin/bash

FILE="my_file.txt"
FILE_PATH=$HOME/$FILE

if [[ -f $FILE_PATH ]]; then
    rm $FILE_PATH
fi