#
# az*
alias azoj="az config set core.output=jsonc >/dev/null 2>&1; echo 'az cli default output set to: jsonc'"
alias azoy="az config set core.output=yamlc >/dev/null 2>&1; echo 'az cli default output set to: yamlc'"
alias azot="az config set core.output=table >/dev/null 2>&1; echo 'az cli default output set to: table'"

#
# aw*
alias awjb='arrange-windows "JetBrains Rider"'

#
# cd(n)
alias cd="z"
alias cd1="cd .."
alias cd2="cd ../../"
alias cd3="cd ../../../"
alias cd4="cd ../../../../"
alias cd5="cd ../../../../../"

# cc
alias cc='claude'
alias ccy='claude --dangerously-skip-permissions'

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
if [[ $OSTYPE == 'darwin'* ]]; then alias dotfiles-update='cd ~ && curl -L https://raw.githubusercontent.com/spraguehouse/dotfiles/main/scripts/setup-dotfiles.zsh -o setup-dotfiles.zsh && source setup-dotfiles.zsh'
else alias dotfiles-update='cd ~ && curl -L https://raw.githubusercontent.com/spraguehouse/dotfiles/main/scripts/setup-dotfiles.bash -o setup-dotfiles.bash && source setup-dotfiles.bash'
fi

# flushdns
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

# gp
alias gp='git push --follow-tags origin main'

#
# k*
alias k='kubectl'
alias ks='echo -e "context: $(k config current-context)\nnamespace: $(k config view --minify --output jsonpath={..namespace})"'
alias kc='kubechoose'
alias kns='f(){ k config set-context --current --namespace="$@"; unset -f f; }; f'
alias kga='kubectl get all,cm,secret,ing'
if [[ $SHELL != '/bin/zsh'* ]]; then complete -F __start_kubectl k; fi

#
# l*
if [[ $OSTYPE == 'darwin'* ]]; then alias l="ls -cl -hp --color=always"
else alias l="ls -cl -hp --time-style=long-iso --group-directories-first --color=always"; fi
alias ll="l -a"

# ma-observe (multi-agent observability)
alias ma-observe='f(){ if [ "$1" = "start" ]; then ~/.claude/observability/start.sh; elif [ "$1" = "stop" ]; then ~/.claude/observability/stop.sh; elif [ "$1" = "logs" ]; then tail -f ~/.claude/observability/server.log; elif [ "$1" = "dashboard" ]; then open http://localhost:5173; else echo "Usage: ma-observe [start|stop|logs|dashboard]"; fi; unset -f f; }; f'

# mk
alias mk='minikube'

# open
if [[ $OSTYPE != 'darwin'* ]]; then alias open="xdg-open"; fi

# p
alias p='python'

# path
alias path='echo -e ${PATH//:/\\n}'

## ssha
alias ssha='eval $(ssh-agent) && ssh-add'

# start
start() { nohup $1 &> /dev/null & disown; }

# sv*
alias sv='standard-version'
alias svp='sv; git push --follow-tags origin main'

# tree
alias tree='tree -I ".git|node_modules"'

# uuidgen
if [[ $OSTYPE == 'darwin'* ]]; then alias uuidgen='uuidgen | tr A-F a-f'; fi
