#!/usr/bin/env bash

# Display commands and their args before running them
# set -x

# Verbose mode
# set -v

# Fails if an undefined variable is used
set -u

# Read the passed vars
while [ $# -gt 0 ]; do
   if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
   fi
  shift
done

# Default values
url=${url:=https://rss.art19.com/tim-ferriss-show}
ext=${ext:=mp3}

# Do the download
curl "${url}" | grep -E "http.*\.${ext}" | sed "s/.*\(http.*\.${ext}\).*/\1/" | xargs wget

# based on https://askubuntu.com/questions/226773/how-to-read-mp3-tags-in-shell
for f in *.mp3
do
    title=`ffprobe -loglevel error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 "$f"`
    fileTitle=`echo ${title} | sed 's/[^a-zA-Z0-9 \-]//g'`
    fileName="${fileTitle}.mp3"
    mv "${f}" "${fileName}"
done