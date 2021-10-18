#!/bin/bash

export SCRIPT_START_URL=https://raw.githubusercontent.com/DocMeme/vultr-startup-script/main/setup.sh
export SCRIPT_START_FILE=setup.sh

wget $SCRIPT_START_URL

chmod +x $SCRIPT_START_FILE

# SSH public key for connecting with SSH
export SSH_PUB_KEY=''

# Github private SSH key for authenticating to Github with SSH
export GITHUB_SSH_KEY=''

# Gitlab private SSH key for authenticating to Gitlab with SSH
export GITLAB_SSH_KEY=''

export GIT_CONFIG='[user]
        email = your_email@gmail.com
        name = your_name
[init]
        defaultBranch = main'

# Packages that will be installed when script starts, feel free to change these
export PKGS=(zsh git wget npm ufw fail2ban)

source $SCRIPT_START_FILE

echo "Cleaning up setup.sh file..."
[ -f $SCRIPT_START_FILE* ] && rm -f $SCRIPT_START_FILE*
