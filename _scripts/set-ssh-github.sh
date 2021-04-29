#!/bin/bash

if [ $# -ne 1 ] 
then
  echo 1>&2 "Usage: $0 GITHUB_USERNAME"
  exit 3
fi

curl https://api.github.com/users/$1/keys | grep '"key"' | sed 's/^.*\(ssh-rsa .*\)\"$/\1/' >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys