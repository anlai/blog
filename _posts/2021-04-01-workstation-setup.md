---
layout: post
title: Workstation Setup
date: 2021-04-01
categories: windows linux wsl vscode git
---

Lately I've been finding myself having to setup computers for doing my development work.  I hate having to do the same setup steps over and over manually, but what I hate even more is having to look up the same instructions from all these different sources all the time.

I'm sure I'll eventually get things a little more scripted, but this post will just look up getting my workstation setup with some of the shortcuts and what not listed out.  What I decided recently was to start breaking down my dev environments into WSL containers (for Linux capable workloads) all Windows based like .NET dev just stay in the primary isntall of Windows.  I've also moved away from installing local isntances of database engines in favor of just cloud hosting those pieces where needed.

These are the tools that I install (and some utilities)
- Chocolatey
- Git
- VS Code
- 7zip
- Microsoft Windows Terminal
- Jekyll

## Windows Setup

The Windows setup is relatively straight forward I try to get the bare minimum in here.

1. Install Chocolatey [install page](https://chocolatey.org/install)
2. Open administrative Powershell (close this window when done with this step)
```Powershell
choco install vscode git 7zip microsoft-windows-terminal
```
3. Generate an ssh public/private key (make sure to put a passphrase)
```Powershell
ssh-keygen -t rsa
```

## WSL Setup

Setup WSL2, follow [these instructions](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

Once you have WSL2 installed and setup, we want to set it up so that it'll be easy to spin up new WSL containers whenever you need a fresh instance.  The default method for doing it is by using the Microsoft Store and install the distro you want, that's great and easy but it doesn't make it easy to get fresh clean containers whenever you want a new one.  There are instructions out there to export and import your existing container but that just makes a copy.

Instead of using the Microsoft Store, I prefer to use the manual download option and download the distros you want to use.  [Here is the list of download links](https://docs.microsoft.com/en-us/windows/wsl/install-manual).  Download the one(s) you want to use.

The following script assumes you download Ubuntu 20.04 to the downloads folder and will be creating a WSL container called "jekyll".

```Powershell
mkdir c:\wsl
mkdir c:\wsl\data
mkdir c:\wsl\images

7z e ~/downloads/Ubuntu_2004.2020.424.0_x64.appx -o c:\wsl\images\ubuntu_2004
wsl --import jekyll c:\wsl\data\jekyll c:\wsl\images\ubuntu_2004\install.tar.gz
```

Next step is to open up a bash shell to the new container (I prefer Windows Terminal).  We just have a few things to do to configure the WSL container: get access to Windows file system and share the ssh key.

/etc/wsl.conf [source](https://docs.microsoft.com/en-us/windows/wsl/wsl-config)
```
# Enable extra metadata options by default
[automount]
enabled = true
root = /windir/
options = "metadata,umask=22,fmask=11"
mountFsTab = false

# Enable DNS – even though these are turned on by default, we'll specify here just to be explicit.
[network]
generateHosts = true
generateResolvConf = true
```
Restart the container in powershell window execute `wsl -t jekyll`.  Then go back into the container and get the ssh key moved so you can use it.

```bash
cp /windir/c/users/{username}/.ssh ~/.ssh -r
chmod 700 ~/.ssh
chmod 644 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/id_rsa
```

Finally the last step for you is to setup whatever development environment you need in those containers.  If you need to restart from scratch you just need to run `wsl --unregister jekyll` then run the setup all over for the container.

## Git Shortcuts

I personally prefer to do a lot of my git actions in the command-line and not through the UI.  So I like to setup shortcuts and things to reduce how much I need to type (or click), these are setup to work with bash shell.

Add the following lines to `~/.bashrc`

```
alias ac='git add . && git commit -v'
alias status='git status'
alias pull='git pull'
alias push='git push'
alias clone='git clone'
alias checkout='git checkout`
alias add='git add'
alias commit='git commit -v'
alias branch='git checkout -b'
```

Last thing to add to `~/.bashrc` is to enable entering passphrase once a session (instead of each git action).

```
exec ssh-agent bash
ssh-add
```