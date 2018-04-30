#!/usr/bin/env bash

# Fails if an undefined variable is used
set -u

# Fails if a command returns an error code
#set -e

cd ~/.ssh
eval "$(ssh-agent)"

echo "Available keys:"
for f in `ls | egrep 'id_rsa[^.]*$'`;
do
  echo "  $f"
done
echo

echo "Available configs:"
for f in `ls | egrep 'config-.*$'`;
do
  echo "  $f"
done
echo

# Copy the rigth config ...
if [[ -z "${1+present}" ]]
then
  echo "Lodaing Personal SSH config"
  cp -rf config-personal config
  ssh-add ~/.ssh/id_rsa
else
  echo "Lodaing $1 SSH config"
  cp -rf "config-$1" config
  ssh-add "~/.ssh/id_rsa_$1"
fi


if [ "$(uname)" == "Darwin" ]; then
  sudo launchctl stop com.openssh.sshd
fi


#for f in `ls | egrep 'id_rsa[^.]*$'`;
#do
#  echo "Loading SSH key: ~/.ssh/$f"
#  ssh-add "./$f"
#done
