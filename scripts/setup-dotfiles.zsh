#!/bin/zsh

brews=(
  "azure-cli"
  "azure-functions-core-tools@4"
  "bash"
  "bicep"
  "go"
  "helm"
  "iterm2"
  "micro"
  "node"
  "powershell"
  "python@3.11"
  "terraform"
  "tree"
  "unnaturalscrollwheels"
)
  
# Make sure Homebrew is installed.
if ! [ -x "$(command -v brew)" ]; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

#
# Install default brews.
#

echo "Checking brew installations. This may take a minute..."

draw_progress_bar() {
  # Argument 1: current progress (integer)
  # Argument 2: total progress (integer)
  local current=${1}
  local total=${2}
  local width=50
  local progress=$((current*100/total))
  local filled=$((progress*width/100))
  local empty=$((width-filled))

  printf "\r["
  printf "%0.s=" $(seq -s ' ' 1 $filled)
  if [ $empty -gt 0 ]; then
    printf ">"
    printf "%0.s " $(seq -s ' ' 2 $empty)
  fi
  printf "] %d%%" $progress
}

totalBrews=${#brews[@]}
brewInstallCounter=0
for brew in "${brews[@]}"; do
  if ! brew list "$brew" &>/dev/null; then
    echo "Installing $brew..."
    brew install --quiet --force "$brew"
  fi
  ((brewInstallCounter++))
  draw_progress_bar brewInstallCounter "$totalBrews"
done

printf "\n"

if ! [ -x "$(command -v git)" ]; then
  echo "Installing git..."
  brew install --quiet --force git
fi

#
# Install latest dotfiles repo.
#

cd ~
rm -rf dotfiles
git clone https://github.com/spraguehouse/dotfiles.git ~/dotfiles

#
# Create dot-file symlinks
# 

symlink() {
  if [ -e ~/$1 ]; then
    echo "Found existing file, creating backup: ~/dotfiles_backups/${1}.bak"
    if [ ! -d ~/dotfiles_backups ]; then mkdir ~/dotfiles_backups; fi
    mv ~/$1 ~/dotfiles_backups/$1.bak
  fi
  ln -sf ~/dotfiles/$1 ~/$1;
}

symlink .profile

symlink .zsh_profile
symlink .zshrc
symlink .bash_aliases
symlink .zsh_prompt

symlink .gitconfig
symlink .gitignore

mkdir -p ~/.zsh && cd ~/.zsh
curl -o git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
curl -o _git https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
cd ~

#symlink .kubecompletion.bash # todo: need a zsh completion 

#
# Set or update Git username/email
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

rm ~/.zcompdump # clear existing autocompletion cache
exec /bin/zsh
