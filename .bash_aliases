#
# cd(n)
alias cd1="cd .."
alias cd2="cd ../../"
alias cd3="cd ../../../"
alias cd4="cd ../../../../"
alias cd5="cd ../../../../../"

# d*
alias d='docker'
alias dc='d container'
alias dcl='dps'
alias dcll='d container ls -a'
alias di='d image'
alias dil='d image ls'
alias dill='d image ls -a'
alias dps='d ps --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}"'

#
# k*
alias k='kubectl'
alias ks='echo -e "context: $(k config current-context)\nnamespace: $(k config view --minify --output jsonpath={..namespace})"'
alias kc='f (){ export KUBECONFIG=~/.kube/"$@".yaml; unset -f f; }; f'
alias kns='f(){ k config set-context --current --namespace="$@"; unset -f f; }; f'
if [[ $SHELL != '/bin/zsh'* ]]; then complete -F __start_kubectl k; fi

#
# l*
if [[ $OSTYPE == 'darwin'* ]]; then alias l="ls -cl -hp --color=always"
else alias l="ls -cl -hp --time-style=long-iso --group-directories-first --color=always"; fi
alias ll="l -a"

# open
if [[ $OSTYPE != 'darwin'* ]]; then alias open="xdg-open"; fi

# p
alias p='python'

# path
alias path='echo -e ${PATH//:/\\n}'

# start
start() { nohup $1 &> /dev/null & disown; }

# tree
alias tree='tree -I ".git|node_modules"'

