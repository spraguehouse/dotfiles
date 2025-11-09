if [ -f ~/.bash_aliases ]; then
  source ~/.bash_aliases
fi

if [ -f ~/.zsh_prompt ]; then
  source ~/.zsh_prompt
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
