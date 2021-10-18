#!/bin/bash

tabs 4
clear

ROOT_UID=0
EXITCODE=1

HOMEDIR=/root
USER_HOME="$HOMEDIR"
SSHDIR=".ssh"

USER_SSH_DIR="$HOMEDIR/$SSHDIR"
SSH_PUB_KEY=${SSH_PUB_KEY}

GITHUB_SSH_KEY=${GITHUB_SSH_KEY}
GITLAB_SSH_KEY=${GITLAB_SSH_KEY}

GIT_CONFIG_FILE=${GIT_CONFIG}

CONFIG_FILE="# Specify SSH key for each Git website

## Github
Host github.com
    User git
    IdentityFile $USER_SSH_DIR/id_github

## Gitlab
Host gitlab.com
    User git
    IdentityFile $USER_SSH_DIR/id_gitlab"

ERRORS=0

install_pkgs=()

for i in "${PKGS[@]}"
do
    install_pkgs+=("$i")
done

check_errs()
{
	if [ "${1}" -ne "0" ]; then
		echo "ERROR # ${1} : ${2}"
		(( ERRORS+=1 ))
		if [ "$#" -eq 3 ]; then
			echo "Cleaning file from failed script attempt..."
			rm -f ${3}
			check_errs $? "Failed to remove file - ${3}"
		fi
		exit ${1}
	fi
}

if [ $UID -ne $ROOT_UID ]
then
	echo "You must be root to run this correctly, quitting...";
	exit $EXITCODE
else
	echo "Startup Script Running..."
fi

echo $GIT_CONFIG_FILE > "$USER_HOME/.gitconfig"
check_errs $? "Failed to create config file $USER_HOME/.gitconfig"

mkdir -p $USER_SSH_DIR
check_errs $? "Failed to create directory $USER_SSH_DIR"

chmod 700 $USER_SSH_DIR
check_errs $? "Failed to change permissions on directory $USER_SSH_DIR"

echo $SSH_PUB_KEY > "$USER_SSH_DIR/authorized_keys"
check_errs $? "Failed to create file $USER_SSH_DIR/authorized_keys"

chmod 700 "$USER_SSH_DIR/authorized_keys"
check_errs $? "Failed to change permissions on file $USER_SSH_DIR/authorized_keys"

echo $CONFIG_FILE > "$USER_SSH_DIR/config"
check_errs $? "Failed to create config file $USER_SSH_DIR/config"

chmod 700 "$USER_SSH_DIR/config"
check_errs $? "Failed to change permissions on file $USER_SSH_DIR/config" 

echo $GITHUB_SSH_KEY > "$USER_SSH_DIR/id_github"
check_errs $? "Failed to create Github key file $USER_SSH_DIR/id_github"

chmod 700 "$USER_SSH_DIR/id_github"
check_errs $? "Failed to change permissions on file $USER_SSH_DIR/id_github"

echo $GITLAB_SSH_KEY > "$USER_SSH_DIR/id_gitlab"
check_errs $? "Failed to create Gitlab key file $USER_SSH_DIR/id_gitlab"

chmod 700 "$USER_SSH_DIR/id_gitlab"
check_errs $? "Failed to change permissions on file $USER_SSH_DIR/id_gitlab"

if [ "${ERRORS}" -eq "0" ]
then
	echo "\nSSH setup was successful!\n"
elif [ "${ERRORS}" < "8" ]
then
	echo "\nSSH setup was successful, although with some problems.\n"
fi

if command -v "apt-get" > /dev/null 2>&1
then
	apt-get -y update
	check_errs $? "Failed to apt-get update"
	apt-get -y upgrade
	check_errs $? "Failed to apt-get upgrade
fi"

for i in "${install_pkgs[@]}"; do
	if command -v "$i" > /dev/null 2>&1
	then
		printf "%s\n" "$i already installed"
	else
		if sudo apt install -y "$i" || sudo pacman -S "$i" || sudo yum install -y "$i"
		then
			printf "%s\n" "$i has been installed"
		else
			printf "%s\n" "It appears your operating system does not have a package manager compatible with this user script. The script will have to end here." && exit 1
		fi
	fi
done

#ufw allow from {your-ip} to any port 22
#check_errs $? "Failed to configure ufw #1"

ufw allow 22
check_errs $? "Failed to configure ufw #1"

ufw allow 80
check_errs $? "Failed to configure ufw #2"

ufw allow 443
check_errs $? "Failed to configure ufw #3"

ufw allow 9252
check_errs $? "Failed to configure ufw #4"

echo "WARNING: You still NEED TO ENABLE UFW!!!"

# Install Docker
curl -sSL https://get.docker.com/ | sh
check_errs $? "Failed to install docker"

echo "Script finished.\n"
echo "Afterwards, you can use:\ngit clone https://DocMemes/Dotfiles.git\nif you'd like to switch to using Z-Shell, my repo comes with an install script to set everything up for you."

if [ "${ERRORS}" -eq 0 ]
then
	echo "Setup completed successfully. Have fun!"
else
	echo "Setup wasn't completely successful, but it should have taken care of most of these things for you."
fi

