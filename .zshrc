if [ -f ~/.bash_aliases ]; then
  source ~/.bash_aliases
fi

autoload -Uz compinit && compinit -i
autoload -U +X bashcompinit && bashcompinit

if [ -d ~/.zsh ]; then
  if [ -f ~/.zsh/.git-completion.bash ]; then
    zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
  fi
  fpath=(~/.zsh $fpath)
fi

if [ -f ~/.kubecompletion.zsh ]; then
  source ~/.kubecompletion.zsh
fi

if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
fi


if [ -f /opt/homebrew/etc/bash_completion.d/az ]; then
  source /opt/homebrew/etc/bash_completion.d/az
fi

# Note: zoxide is initialized in .zshenv so it works in all shells (including non-interactive)

setopt INTERACTIVE_COMMENTS

export PATH="${PATH}:${HOME}/.local/bin"
export PATH="$HOME/.dotnet/tools:$PATH"
export PATH="$HOME/.claude/bin:$PATH"

# bun completions
[ -s "/Users/jsprague/.bun/_bun" ] && source "/Users/jsprague/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Claude ecosystem initialization
[ -f ~/.claude/init.sh ] && source ~/.claude/init.sh

# Initialize Starship prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi