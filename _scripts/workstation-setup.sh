#!/bin/bash

if [ $# -ne 3 ] && [ $# -ne 4]; then
  echo 1>&2 "Usage: $0 WINDOWS_USERNAME NAME EMAIL STARTUP_PATH(optional)"
  exit 3
fi

echo ""
echo "Writing /etc/wsl.conf"
echo '# Enable extra metadata options by default' >> /etc/wsl.conf
echo '[automount]' >> /etc/wsl.conf
echo 'enabled = true' >> /etc/wsl.conf
echo 'root = /windir/' >> /etc/wsl.conf
echo 'options = "metadata,umask=22,fmask=11"' >> /etc/wsl.conf
echo 'mountFsTab = false' >> /etc/wsl.conf
echo '' >> /etc/wsl.conf
echo '# Enable DNS – even though these are turned on by default, well specify here just to be explicit.' >> /etc/wsl.conf
echo '[network]' >> /etc/wsl.conf
echo 'generateHosts = true' >> /etc/wsl.conf
echo 'generateResolvConf = true' >> /etc/wsl.conf

echo ""
echo "Importing ssh key"
cp /mnt/c/users/$1/.ssh ~/.ssh -r
chmod 700 ~/.ssh
chmod 644 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/id_rsa

echo ""
echo "Writing git alias'"
echo "alias ac='git add . && git commit -m'" >> ~/.bashrc
echo "alias status='git status'" >> ~/.bashrc
echo "alias pull='git pull'" >> ~/.bashrc
echo "alias push='git push'" >> ~/.bashrc
echo "alias clone='git clone'" >> ~/.bashrc
echo "alias checkout='git checkout'" >> ~/.bashrc
echo "alias add='git add'" >> ~/.bashrc
echo "alias commit='git commit -m'" >> ~/.bashrc
echo "alias branch='git checkout -b'" >> ~/.bashrc

echo "" >> ~/.bashrc

echo ""
echo "Writing ssh cred setup'"
echo "eval `ssh-agent -s`" >> ~/.bashrc
echo "ssh-add ~/.ssh/*_rsa" >> ~/.bashrc

echo ""
echo "Setting git user info"
git config --global user.name $2
git config --global user.email $3

if [ -z "$4" ]
  then
    echo "Not setting startup directory"
  else
    echo ""
    echo "Setting startup directory to $4"
    echo "cd $4" >> ~/.bashrc
fi