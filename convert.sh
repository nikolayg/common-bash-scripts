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
folder=${folder:="${HOME}/Videos/Conversion"}
quality=${quality:="original"}
nicity=${nicity:="15"} # −20 is the highest priority and 19 is lowest

crf=18
w=1280
ab=128k

if [ ${quality} = "high" ]; then
  crf=19
  w=1280
  ab=128k
fi

if [ ${quality} = "med" ]; then
  crf=23
  w=960
  ab=64k
fi

if [ ${quality} = "low" ]; then
  crf=24
  w=720
  ab=64k
fi

# Download subtitles ...
nice -n ${nicity} bash ./subtitles.sh "${folder}"

# Set up folder
cd "${folder}"
mkdir -p ./original

OIFS="$IFS"
IFS=$'\n'

# Process video
for file in `find . -type f | egrep -i '\.(m4v|mkv|mp4|avi|mov|wmv|flv)$' | egrep -v '\/original' | egrep -v '\-conv\.(mp4)$'`  
do
    echo -e "\n========> Processing File \"$file\""
    newFile=`echo "${file}" | sed -e 's/\.[^\.]*$//g'`

    # For Original quality do not rescale
    convResult=1
    if [ ${quality} = "original" ]; then
        nice -n ${nicity} ffmpeg -nostats -loglevel panic -y -i "${file}" -vcodec h264 -acodec mp3 -crf ${crf} "${newFile}-conv.mp4"
        convResult=$?
    fi

    # If non-original quality or if original fails - try to resize
    if [ ${convResult} -ne 0 ]; then
        for i in $(seq ${w} -5 600)
        do
            nice -n ${nicity} ffmpeg -nostats -loglevel panic -y -i "${file}" -vcodec h264 -acodec mp3 -crf ${crf} -vf scale=${i}:-2 "${newFile}-conv.mp4"
            convResult=$?

            if [ ${convResult} -eq 0 ]; then
                echo -e "Succeeded with width of $i px"
                break
            else
                echo -e "Failed with width of $i px"
            fi
        done
    fi


    # Postprocess on success - rename subtitles accordingly and move original
    if [ ${convResult} -eq 0 ]; then
        mv "${file}" ./original

        # If subtitles exist - rename them appropriately...
        if [ -e "${newFile}.srt" ]; then
            cp "${newFile}.srt" ./original
            mv "${newFile}.srt" "${newFile}-conv.srt"
        fi 
    else
        echo -e "Failed converting with ${quality} quality"
    fi
done

# Process Audio
for file in `find . -type f | egrep '\.(mp3|flac|wav|ogg|wma)$' | egrep -v 'BBC The English' | egrep -v '\/original' | egrep -v '\-conv\.(mp3)$'`  
do
    echo -e "\n========> Processing File \"$file\""
    newFile=`echo "${file}" | sed -e 's/\.[^\.]*$//g'`
    nice -n ${nicity} ffmpeg -nostats -loglevel panic -y -i "${file}" -acodec libmp3lame -ac 2 -ab ${ab} -ar 44100 "${newFile}-conv.mp3"
    mv "${file}" ./original
done


# Remove hidden files
echo -e "\n========> Remove all hidden files ..."
find . -type f -name ".*" -delete

# Sanitize file names
for file in `find . -type f`  
do
    echo -e "\n========> Renaming File \"$file\""
    fn=`basename "$file"`
    ext="${fn##*.}"
    name="${fn%.*}"
    fpath=`echo "${file%/*}"`
    newName=`echo $name | sed s/%[0-9]*/\ /g | sed s/[[:punct:]]/-/g | sed 's/[[:blank:]]\+/\ /g'`
    mv ${file} "${fpath}/${newName}.${ext}"
done

IFS="$OIFS"


