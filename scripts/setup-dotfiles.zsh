#!/bin/zsh

# Make sure Homebrew is installed.
if ! [ -x "$(command -v brew)" ]; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! [ -x "$(command -v git)" ]; then
  echo "Installing git..."
  brew install --quiet --force git
fi

#
# Install latest dotfiles repo.
#

if [ -d ~/dotfiles/.git ]; then
  echo "Updating existing dotfiles..."
  git -C ~/dotfiles pull --rebase
else
  echo "Cloning dotfiles..."
  git clone https://github.com/spraguehouse/dotfiles.git ~/dotfiles
fi

#
# Install packages from Brewfile
#

echo "Installing packages from Brewfile..."
brew bundle install --file=~/dotfiles/Brewfile --no-lock

#
# Create dot-file symlinks
#

symlink() {
  ln -sf ~/dotfiles/$1 ~/$1;
}

symlink .profile

symlink .zshenv
symlink .zsh_profile
symlink .zshrc
symlink .bash_aliases
symlink .zsh_prompt
mkdir -p ~/.config && symlink .config/starship.toml

symlink .gitconfig
symlink .gitignore

#
# Create user bin directory and python symlink
#

mkdir -p ~/.local/bin
if command -v python3 &>/dev/null; then
  ln -sf "$(command -v python3)" ~/.local/bin/python
fi

mkdir -p ~/.zsh && cd ~/.zsh
curl -o git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
curl -o _git https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
cd ~

#symlink .kubecompletion.bash # todo: need a zsh completion

#
# Set or update Git username/email
#

GIT_FULLNAME=$(git config --global --get user.name 2>/dev/null)
GIT_EMAIL=$(git config --global --get user.email 2>/dev/null)

if [ -z "$GIT_FULLNAME" ]; then
  echo "Enter Git fullname:"
  read GIT_FULLNAME
  git config --global user.name "$GIT_FULLNAME"
  echo "Success."
fi

if [ -z "$GIT_EMAIL" ]; then
  echo "Enter Git email:"
  read GIT_EMAIL
  git config --global user.email "$GIT_EMAIL"
  echo "Success."
fi

#
# Configure macOS defaults
#

echo ""
echo "Applying macOS defaults..."
bash ~/dotfiles/scripts/macos-defaults.sh

echo ""
echo "Applying AC power settings..."
bash ~/dotfiles/scripts/macos-power.sh

#
# Summary
#

echo ""
echo "Setup complete:"
echo "  - Packages installed via Brewfile"
echo "  - Dotfiles symlinked"
echo "  - Git config verified"
echo "  - macOS defaults applied"
echo "  - AC power settings applied"
echo ""
echo "Run 'mac-drift' to check for package drift at any time."

rm ~/.zcompdump # clear existing autocompletion cache
exec /bin/zsh
