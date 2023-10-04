#!/bin/bash

DIRECTORY="/var/log/"

sudo grep -Ril "error" $DIRECTORY #recursive, register independent, list filenames

if [[ $? -ne 0 ]];then
    echo "Files Not Found!"
fi