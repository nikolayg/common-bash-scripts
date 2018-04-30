#!/usr/bin/env bash

# Display commands and their args before running them
# set -x

# Verbose mode
# set -v

# Fails if an undefined variable is used
set -u

# Fails if a command returns an error code
# set -e

# Install ffmpeg and dependencies if not installed        
if [ "$(uname)" == "Darwin" ]; then
    brew list ffmpeg &>/dev/null || brew install ffmpeg --with-libvpx --with-libx264 || true
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    which ffmpeg || sudo apt-get install -y ffmpeg
else
    echo "Unknown platform :("
    exit 1
fi


# Read the passed vars
while [ $# -gt 0 ]; do
   if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
   fi
  shift
done

# Default values
folder=${folder:="/home/nikolay/Videos/Conversion"}
quailty=${quailty:="low"}

crf=24
w=720
ab=64k
if [ "quality" = "high" ]; then
  crf=18
  w=1280
  ab=128k
fi

if [ "quality" = "med" ]; then
  crf=22
  w=960
  ab=64k
fi

# Download subtitles ...
nice -n 15 bash ./subtitles.sh "${folder}"

# Set up folder
cd "${folder}"
mkdir -p ./original

OIFS="$IFS"
IFS=$'\n'

# Process video
for file in `find . -type f | egrep '\.(m4v|mkv|mp4|avi|mov|wmv)$'  | egrep -v '\/original' | egrep -v '\-conv\.(mp4)$'`  
do
    echo "file = $file"
    newFile=`echo "${file}" | sed -e 's/\.[^\.]*$//g'`
    for i in $(seq ${w} -5 600)
    do
        nice -n 15 ffmpeg -loglevel panic -y -i "${file}" -vcodec h264 -acodec mp3 -crf ${crf} -vf scale=${i}:-1 "${newFile}-conv.mp4"
        if [ $? -eq 0 ]; then
            echo "SUCCESS"
            mv "${file}" ./original

            # If subtitles exist - rename them appropriately...
            if [ -e "${newFile}.srt" ]; then
                cp "${newFile}.srt" ./original
                mv "${newFile}.srt" "${newFile}-conv.srt"
            fi 
            break
        else
            echo "FAIL"
        fi
    done
done

# Process Audio
for file in `find . -type f | egrep '\.(mp3|flac|wav|ogg|wma)$' | egrep -v 'BBC The English' | egrep -v '\/original' | egrep -v '\-conv\.(mp3)$'`  
do
    echo "file = $file"
    newFile=`echo "${file}" | sed -e 's/\.[^\.]*$//g'`
    nice -n 15 ffmpeg -loglevel panic -y -i "${file}" -acodec libmp3lame -ac 2 -ab ${ab} -ar 44100 "${newFile}-conv.mp3"
    mv "${file}" ./original
done


IFS="$OIFS"


