---
layout: post
title: Using WSL for Development
date: 2021-04-06
categories: windows linux wsl vscode git
---

Apparently it's been a while since I've rebuilt my workstations and things have changed quite a bit with the introduction of WSL.  As far as I knew the only way to cleanly isolate different dev environments was to use virtual machines which I never really care for on a laptop.  As I'm finding a lot more of my stuff works on Linux seems to make sense to take advantage of WSL containers.

General idea is that I'd setup my standard Windows tools/environments like normal, but anything that can be offloaded into Linux will be put into it's own container.  With the seamless integration of VSCode and WSL it makes it super easy.

## Windows Setup

There are more tools that I generally use, but this setup is the bare minimum and what I use to get WSL setup.

Tools:
- Chocolatey
- Git
- VS Code
- 7zip
- Microsoft Windows Terminal

1. Install Chocolatey [install page](https://chocolatey.org/install)
2. Open administrative Powershell (close this window when done with this step)
```Powershell
choco install vscode git 7zip microsoft-windows-terminal
```
3. Generate an ssh public/private key
```Powershell
ssh-keygen -t rsa
```
4. Turn on WSL, follow [these instructions](https://docs.microsoft.com/en-us/windows/wsl/install-win10)

## Setup First WSL Container

Now that you've got WSL turned on, it's time to setup your first WSL container instance.  Microsoft recommends installing it by using the Microsoft Store, which is simple enough but really only lets you install one instance of each distro.  Since I plan to have multiple versions of a distro for different environments, I download the image and create a new instance for each environment.

You are welcome to download and use whichever distro makes you happy, I'll be using Ubuntu 20.04 so that's what the file names in the scripts below will use.  Start by downloading the image(s) that you want from [this Microsoft site](https://docs.microsoft.com/en-us/windows/wsl/install-manual), files should be downloaded as an appx file type.

The following script will setup my preferred folder structure for wsl, and extract the image, and create a WSL container instance.  Open up a Powershell window (and be sure to replace `jekyll` with the desired name for your environment):

```Powershell
mkdir c:\wsl
mkdir c:\wsl\data
mkdir c:\wsl\images

7z e ~/downloads/Ubuntu_2004.2020.424.0_x64.appx -o c:\wsl\images\ubuntu_2004
wsl --import jekyll c:\wsl\data\jekyll c:\wsl\images\ubuntu_2004\install.tar.gz
```

Now that we've got a container instance setup, just a final configuration to make life a little easier (not necessarily required).

Drop the following contents into `/etc/wsl.conf`.  It will give you write access to the Windows file system (ordinarily I believe it's read only).

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

Restart the container in powershell window execute `wsl -t jekyll`.  

Final step after you have terminated the instance is to go back in, and move your ssh key from Windows into the Linux container so you have the same one.  It's also possible to just generate another key for each container if you want.

```bash
cp /windir/c/users/{username}/.ssh ~/.ssh -r
chmod 700 ~/.ssh
chmod 644 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/id_rsa
```

Now you are all set to start installing specific tools for your environment, for me it's installing Jekyll into this particular container.

## Git Shortcuts

I personally prefer to do a lot of my git actions in the command-line and not through the UI.  So I like to setup shortcuts and things to reduce how much I need to type (or click), these are setup to work with bash shell.

Add the following lines to `~/.bashrc`

```
alias ac='git add . && git commit -m'
alias status='git status'
alias pull='git pull'
alias push='git push'
alias clone='git clone'
alias checkout='git checkout'
alias add='git add'
alias commit='git commit -m'
alias branch='git checkout -b'
```

Last thing to add to `~/.bashrc` is to enable entering passphrase once a session (instead of each git action).  I never remember the command and always end up looking for it ([source](https://superuser.com/a/1044918)).  But this will just prompt you for the passphrase at the start of the session, and all subsequent git calls won't require the passphrase.

```
eval `ssh-agent -s`
ssh-add ~/.ssh/*_rsa
```

## Lazy Setup

Now that you've gotten this far, I got the lazy way to set this up.  The script is a bit lazy, it's not idempotent, so only run it once.

From the container, execute the following command.  It will download the script and execute the above stuff.

```bash
curl -s https://raw.githubusercontent.com/anlai/blog/draft/_scripts/workstation-setup.sh | bash -s {WINDOWS_USERNAME} {GIT NAME} {GIT EMAIL} {STARTUP PATH (OPTIONAL)}
```

The script can be found here in the repository for this blog. [source](https://github.com/anlai/blog/blob/draft/_scripts/workstation-setup.sh)