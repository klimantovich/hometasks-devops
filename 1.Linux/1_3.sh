#!/bin/bash

DIR_NAME="my_new_dir"

if [[ ! -d ./$DIR_NAME ]]; then
    mkdir ./$DIR_NAME
fi
cd ./$DIR_NAME || exit