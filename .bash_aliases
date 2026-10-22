#
# az*
alias azoj="az config set core.output=jsonc >/dev/null 2>&1; echo 'az cli default output set to: jsonc'"
alias azoy="az config set core.output=yamlc >/dev/null 2>&1; echo 'az cli default output set to: yamlc'"
alias azot="az config set core.output=table >/dev/null 2>&1; echo 'az cli default output set to: table'"

#
# aw*
alias awc='arrange-windows code --grid'

#
# cd(n) - cd is aliased to zoxide's 'z' via zoxide init --cmd cd in .bashrc
alias cd1="cd .."
alias cd2="cd ../../"
alias cd3="cd ../../../"
alias cd4="cd ../../../../"
alias cd5="cd ../../../../../"

# cc: Claude Code without permission prompts
alias cc='claude --dangerously-skip-permissions'

# d*
alias d='docker'
alias dc='d container'
alias dcl='dps'
alias dcll='dps -a'
alias di='d image'
alias dil='d image ls'
alias dill='d image ls -a'
alias dps='d ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'

# dotfiles-update
if [[ $OSTYPE == 'darwin'* ]]; then
  alias dotfiles-update='cd ~ && curl -L https://raw.githubusercontent.com/spraguehouse/dotfiles/main/scripts/setup-dotfiles.zsh -o setup-dotfiles.zsh && source setup-dotfiles.zsh'
else
  alias dotfiles-update='cd ~ && curl -L https://raw.githubusercontent.com/spraguehouse/dotfiles/main/scripts/setup-dotfiles.bash -o setup-dotfiles.bash && source setup-dotfiles.bash'
fi

# flushdns
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

# g* (git)
alias gl='git lg'
alias gls='git lg -15'
alias gp='git push --follow-tags origin main'
gmm() {
  local branch
  branch=$(git symbolic-ref --short HEAD)
  if [[ "$branch" == "main" ]]; then
    echo "Already on main, nothing to merge."
    return 1
  fi
  echo "Merging $branch into main..."
  git fetch &&
    git pull &&
    git rebase origin/main &&
    git checkout main &&
    git pull &&
    git merge "$branch" --no-ff &&
    git push &&
    git checkout "$branch" &&
    git rebase origin/main &&
    git push --force-with-lease &&
    echo "Done. $branch merged into main."
}

#
# k*
alias k='kubectl'
alias ks='echo -e "context: $(k config current-context)\nnamespace: $(k config view --minify --output jsonpath={..namespace})"'
alias kc='kubechoose'
alias kns='f(){ k config set-context --current --namespace="$@"; unset -f f; }; f'
alias kga='kubectl get all,cm,secret,ing'
# `complete` is a bash builtin. ~/.zshrc sources this aliases file too, so
# check the RUNNING interpreter rather than $SHELL (login-shell metadata can be
# inherited or stale in child processes).
if [[ -n ${BASH_VERSION:-} ]]; then
  # Homebrew installs kubectl's completion function here. Source it before
  # registering the `k` alias completion; zsh never enters this branch.
  for kubectl_completion in \
    /opt/homebrew/etc/bash_completion.d/kubectl \
    /usr/local/etc/bash_completion.d/kubectl; do
    if [[ -r $kubectl_completion ]]; then
      source "$kubectl_completion"
      break
    fi
  done
  if declare -F __start_kubectl >/dev/null 2>&1; then
    complete -F __start_kubectl k
  fi
fi

#
# l*
if [[ $OSTYPE == 'darwin'* ]]; then
  alias l="ls -cl -hp --color=always"
else alias l="ls -cl -hp --time-style=long-iso --group-directories-first --color=always"; fi
alias ll="l -a"

# mk
alias mk='minikube'

# open
if [[ $OSTYPE != 'darwin'* ]]; then alias open="xdg-open"; fi

# path
alias path='echo -e ${PATH//:/\\n}'

## ssha
alias ssha='eval $(ssh-agent) && ssh-add'

# start
start() {
  nohup $1 &>/dev/null &
  disown
}

# tmux
alias t='tmux'
alias ta='tmux attach'
alias tl='tmux list-sessions'

# tree
alias tree='tree -I ".git|node_modules"'

# uuidgen
if [[ $OSTYPE == 'darwin'* ]]; then alias uuidgen='uuidgen | tr A-F a-f'; fi

# mac* - macOS configuration management
alias mac-drift='brew bundle check --file=~/dotfiles/Brewfile'
alias mac-sync='brew bundle install --file=~/dotfiles/Brewfile'

