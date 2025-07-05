#!/bin/bash

if [ $# -ne 1 ]
then
  echo 1>&2 "Usage: $0 GITHUB_USERNAME"
  exit 3
fi

if [[ ! -f ~/.ssh ]]
then
  mkdir ~/.ssh -p
fi

# download the ssh keys
curl https://api.github.com/users/$1/keys | grep '"key"' | sed -E 's/^[[:space:]]*"key": "(.*)",?/\1/' >> ~/.ssh/authorized_keys_tmp

# if file has contents, then replace the authorized keys file
if [ -s ~/.ssh/authorized_keys_tmp ]
then
  rm ~/.ssh/authorized_keys -f
  mv ~/.ssh/authorized_keys_tmp ~/.ssh/authorized_keys
  chmod 0600 ~/.ssh/authorized_keys
  echo "authorized keys file updated"
else
  echo "no keys downloaded, keeping existing authorized keys file"
fi
