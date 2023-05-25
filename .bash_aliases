#
# az*
alias azoj="az config set core.output=jsonc >/dev/null 2>&1; echo 'az cli default output set to: jsonc'"
alias azoy="az config set core.output=yamlc >/dev/null 2>&1; echo 'az cli default output set to: yamlc'"
alias azot="az config set core.output=table >/dev/null 2>&1; echo 'az cli default output set to: table'"

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
alias dcll='dps -a'
alias di='d image'
alias dil='d image ls'
alias dill='d image ls -a'
alias dps='d ps --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}"'

# dotfiles-update
if [[ $OSTYPE == 'darwin'* ]]; then alias dotfiles-update='cd ~ && curl -L https://raw.githubusercontent.com/spraguehouse/dotfiles/main/scripts/setup-dotfiles.zsh -o setup-dotfiles.zsh && source setup-dotfiles.zsh'
else alias dotfiles-update='cd ~ && curl -L https://raw.githubusercontent.com/spraguehouse/dotfiles/main/scripts/setup-dotfiles.bash -o setup-dotfiles.bash && source setup-dotfiles.bash'
fi

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

