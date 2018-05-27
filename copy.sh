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
src=${src:="${HOME}/Videos/Conversion"}
dest=${dest:="/media/nikolay/Nik"}
method=${method:="cp"}
autofix=${autofix:="no"}

# fsck -a /dev/sda1

if [ ${autofix} = "yes" ]; then 
    echo "Checking and Fixing file system ..."
    mount=`df | egrep "${dest}\$" | awk '{print $1}'`

    if [ ! -z ${mount} ]; then 
        # sudo dosfsck -w -r -l -a -v -t ${mount}
        sudo dosfsck -w -l -a -v -t ${mount}
    fi
fi

echo "Start file copying ..."

# With plain copy or rsync?
if [ ${method} = "cp" ]; then
    cp -ruv "${src}/"* "${dest}"
else
    rsync -crv "${src}/" "${dest}"
fi

