#!/usr/bin/env bash

# Display commands and their args before running them
# set -x

# Verbose mode
# set -v

# Fails if an undefined variable is used
set -u

# OR clone if it does not exist from https://github.com/r0oth3x49/udemy-dl
cd ~/Dev/udemy-dl

python udemy-dl.py https://www.udemy.com/wtfmandarin-survival-chinese-free -q 1024 -o ~/Videos/Conversion/