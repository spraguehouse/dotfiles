# Interactive zsh only. Environment and PATH live in ~/.zshenv.

HISTSIZE=1000000
SAVEHIST=1000000
setopt INTERACTIVE_COMMENTS

# Local secrets, never committed
if [ -f ~/.config/shell/secrets.env ]; then
  set -a
  source ~/.config/shell/secrets.env
  set +a
fi

if [ -f ~/.bash_aliases ]; then
  source ~/.bash_aliases
fi

# Completion. fpath first, then one compinit.
fpath=(~/.zsh ~/.grok/completions/zsh $fpath)
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
autoload -Uz compinit && compinit -i
autoload -U +X bashcompinit && bashcompinit

if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
fi

if [ -f /opt/homebrew/etc/bash_completion.d/az ]; then
  source /opt/homebrew/etc/bash_completion.d/az
fi

[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
