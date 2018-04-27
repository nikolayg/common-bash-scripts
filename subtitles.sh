#!/usr/bin/env bash

# Display commands and their args before running them
set -x

# Verbose mode
# set -v

# Fails if an undefined variable is used
set -u

### How to set it up ... 
chmod u+x ./OpenSubtitlesDownload/OpenSubtitlesDownload.py 

find "$1" -type f | egrep -i "mp4|avi|mkv|flv|wmv|mov" | while read -r file
do
     ./OpenSubtitlesDownload.py  -g cli -a "${file}"
done
