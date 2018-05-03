#!/usr/bin/env bash

# Display commands and their args before running them
# set -x

# Verbose mode
# set -v

# Fails if an undefined variable is used
set -u

### How to set it up ... 
chmod u+x ./OpenSubtitlesDownload/OpenSubtitlesDownload.py 

# Convert VTT to SRT
find "$1" -type f | egrep -i "vtt$" | egrep -v '\/original' | while read -r file
do
    echo ${file}
    fileNoExt=`echo "${file}" | sed -e 's/\.vtt$//g' | sed -e 's/\.en$//g'`
    ffmpeg -nostats -loglevel panic -y -i "${file}" "${fileNoExt}.srt" && rm "${file}"
done

# Download From Open Subtitles
find "$1" -type f | egrep -i "m4v|mkv|mp4|avi|mov|wmv|flv" | egrep -v '\/original' | while read -r file
do
    fileNoExt=`echo "${file}" | sed -e 's/\.[^\.]*$//g'`
    if [ ! -f "${fileNoExt}.srt" ]; then
        echo -e "\n========> Subtitles for \"${file}\" \n"
        ./OpenSubtitlesDownload.py  -g cli -a "${file}"
    fi
done
