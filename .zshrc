if [ -f .bash_aliases ]; then
  source .bash_aliases
fi

if [ -f .zsh_prompt ]; then
  source .zsh_prompt
fi

autoload -Uz compinit && compinit
autoload -U +X bashcompinit && bashcompinit

if [ -d ~/.zsh ]; then
  if [ -f ~/.zsh/.git-completion.bash ]; then
    zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
  fi
  fpath=(~/.zsh $fpath)
fi

if [ -f .kubecompletion.zsh ]; then
  source .kubecompletion.zsh
fi

if [ -f /usr/bin/kubectl ] || [ -f /usr/local/bin/kubectl ]; then
  kubectl completion bash | bash
fi


if [ -f /opt/homebrew/etc/bash_completion.d/az ]; then
  source /opt/homebrew/etc/bash_completion.d/az
fi
