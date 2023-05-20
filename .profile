export HISTSIZE=1000000
export HISTFILESIZE=1000000000

export EDITOR="micro"
export LESSCHARSET="utf-8"

if [ -d "$HOME/.bin" ]; then
  export PATH="$HOME/.bin:$PATH"
fi
if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "/home/linuxbrew" ]; then
  export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
  export HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
  export HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
  export MANPATH="/home/linuxbrew/.linuxbrew/share/man:$MANPATH"
  export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:$INFOPATH"
fi
if [ -d "/opt/homebrew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ -f .env ]; then
  source .env
fi

if [ -e "${HOME}/.iterm2_shell_integration.bash" ]; then
  source "${HOME}/.iterm2_shell_integration.bash"
fi
