#!/bin/bash

if ! [ -x "$(command -v git)" ]; then
  if [ -x "$(command -v apt-get)" ]; then
    apt-get update
    apt-get install git -y
  fi
  if ! [ -x "$(command -v git)" ]; then
    printf "\nThis script requires git!\n"
    exit 1
  fi
fi

#
#

if [ -d ~/dotfiles ]; then
  echo "Directory ~/dotfiles exists."
  cd ~/dotfiles
  if [ -d .git ]; then
    echo "Directory ~/dotfiles is a git repository. Pulling latest changes..."
    git stash -u && git pull && git stash pop || { echo "Pulling changes failed. Exiting script."; exit 1; }
  else
    echo "Directory ~/dotfiles is not a git repository. Removing directory and cloning..."
    cd ~
    rm -rf dotfiles
    git clone https://github.com/spraguehouse/dotfiles.git ~/dotfiles || { echo "Cloning repository failed. Exiting script."; exit 1; }
  fi
else
  echo "Directory ~/dotfiles does not exist. Cloning repository..."
  git clone https://github.com/spraguehouse/dotfiles.git ~/dotfiles || { echo "Cloning repository failed. Exiting script."; exit 1; }
fi

#
#

symlink() {
  if [ -e ~/$1 ]; then
    echo "Found existing file, creating backup: ~/dotfiles_backups/${1}.bak"
    if [ ! -d ~/dotfiles_backups ]; then mkdir ~/dotfiles_backups; fi
    mv ~/$1 ~/dotfiles_backups/$1.bak
  fi
  ln -sf ~/dotfiles/$1 ~/$1;
}

#
#

symlink .profile

symlink .bash_profile
symlink .bashrc
symlink .bash_aliases
symlink .bash_prompt

symlink .gitconfig
symlink .gitignore
symlink .gitcompletion.bash

symlink .kubecompletion.bash

#
#

YELLOW='\033[1;33m'
RESET='\033[0m'
GIT_FULLNAME=$(git config --system --get user.name)
GIT_EMAIL=$(git config --system --get user.email)

if [ -n "$GIT_FULLNAME" ]; then
  echo -e "${YELLOW}Warning: Git fullname is already set to $GIT_FULLNAME. Do you want to change it? [y/N]${RESET}"
  read CHANGE
  if [[ "$CHANGE" =~ ^[Yy]$ ]]; then
    echo "Enter new Git fullname:"
    read GIT_FULLNAME
    echo "Requesting root permissions to set git config at system level..."
    sudo git config --system user.name "$GIT_FULLNAME"
    echo "Success."
  fi
else
  echo "Enter Git fullname:"
  read GIT_FULLNAME
  echo "Requesting root permissions to set git config at system level..."
  sudo git config --system user.name "$GIT_FULLNAME"
  echo "Success."
fi

if [ -n "$GIT_EMAIL" ]; then
  echo -e "${YELLOW}Warning: Git email is already set to $GIT_EMAIL. Do you want to change it? [y/N]${RESET}"
  read CHANGE
  if [[ "$CHANGE" =~ ^[Yy]$ ]]; then
    echo "Enter new Git email:"
    read GIT_EMAIL
    echo "Requesting root permissions to set git config at system level..."
    sudo git config --system user.email "$GIT_EMAIL"
    echo "Success."
  fi
else
  echo "Enter Git email:"
  read GIT_EMAIL
  echo "Requesting root permissions to set git config at system level..."
  sudo git config --system user.email "$GIT_EMAIL"
  echo "Success."
fi

#
#

exec $BASH
