#!/bin/bash

# Install required dependencies
if [ -x "$(command -v apt-get)" ]; then
  echo "Checking and installing dependencies via apt..."

  # Update package list
  apt-get update

  # Install git if missing
  if ! [ -x "$(command -v git)" ]; then
    echo "Installing git..."
    apt-get install git -y
  fi

  # Install zoxide if missing (use official installer - more reliable than apt)
  if ! [ -x "$(command -v zoxide)" ]; then
    echo "Installing zoxide via official installer..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    # Ensure ~/.local/bin is on PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
  fi

  # Install Azure CLI if missing
  if ! [ -x "$(command -v az)" ]; then
    echo "Azure CLI not found. Install manually from: https://aka.ms/InstallAzureCLIDeb"
  fi
fi

# Verify git is installed
if ! [ -x "$(command -v git)" ]; then
  printf "\nThis script requires git!\n"
  exit 1
fi

#
#

if [ -d ~/dotfiles ]; then
  echo "Directory ~/dotfiles exists."
  cd ~/dotfiles
  if [ -d .git ]; then
    echo "Directory ~/dotfiles is a git repository. Pulling latest changes..."
    git stash -u
    git pull || { echo "Pulling changes failed. Exiting script."; exit 1; }
    git stash pop 2>/dev/null || true  # OK if nothing was stashed
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
GIT_FULLNAME=$(git config --global --get user.name)
GIT_EMAIL=$(git config --global --get user.email)

if [ -n "$GIT_FULLNAME" ]; then
  echo -e "${YELLOW}Warning: Git fullname is already set to $GIT_FULLNAME. Do you want to change it? [y/N]${RESET}"
  read CHANGE
  if [[ "$CHANGE" =~ ^[Yy]$ ]]; then
    echo "Enter new Git fullname:"
    read GIT_FULLNAME
    git config --global user.name "$GIT_FULLNAME"
    echo "Success."
  fi
else
  echo "Enter Git fullname:"
  read GIT_FULLNAME
  git config --global user.name "$GIT_FULLNAME"
  echo "Success."
fi

if [ -n "$GIT_EMAIL" ]; then
  echo -e "${YELLOW}Warning: Git email is already set to $GIT_EMAIL. Do you want to change it? [y/N]${RESET}"
  read CHANGE
  if [[ "$CHANGE" =~ ^[Yy]$ ]]; then
    echo "Enter new Git email:"
    read GIT_EMAIL
    git config --global user.email "$GIT_EMAIL"
    echo "Success."
  fi
else
  echo "Enter Git email:"
  read GIT_EMAIL
  git config --global user.email "$GIT_EMAIL"
  echo "Success."
fi

#
# Restart shell (optional, skippable for SSH safety)
#

if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  echo -e "${YELLOW}Warning: You are connected via SSH. Restarting the shell could disconnect you.${RESET}"
  echo "Do you want to restart bash now? [y/N]"
  read RESTART_SHELL
  if [[ "$RESTART_SHELL" =~ ^[Yy]$ ]]; then
    echo "Restarting bash..."
    exec $BASH
  else
    echo "Setup complete! Run 'source ~/.bashrc' or start a new terminal to apply changes."
  fi
else
  echo "Setup complete! Restarting bash..."
  exec $BASH
fi
