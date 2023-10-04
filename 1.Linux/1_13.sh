#!/bin/bash

#TODO
# LOG_FILE="~/space_journal.log"
# THESHOLD=90

# show_space() {
# #    df -H | grep -vE '^Filesystem|tmpfs|udev|vagrant' | awk '{ print $5 " " $1 }'
#      df -H | grep -vE '^Filesystem|tmpfs|udev|vagrant' | sed s/%//g | awk '{ if($5 > 2) print $0;}'
# }

# if [[ $# > 0 || $# > 2 ]]; then
#     case $1 in
#         "show")
#             show_space;;
#         "clear")
#             echo "clear space";;
#         "help")
#             echo "print help";;
#         *)
#             echo "Incorrect arguments, choose option 'help' for help";;
#     esac
# else
#     echo "Incorrect arguments, choose option 'help' for help";
# fi