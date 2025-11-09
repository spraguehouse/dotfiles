if [ -f ~/.bash_aliases ]; then
  source ~/.bash_aliases
fi

if [ -f ~/.bash_prompt ]; then
  source ~/.bash_prompt
fi

if [ -f ~/.gitcompletion.bash ]; then
  source ~/.gitcompletion.bash
fi

if [ -f ~/.kubecompletion.bash ]; then
  source ~/.kubecompletion.bash
fi

if [ -f /usr/bin/kubectl ] || [ -f /usr/local/bin/kubectl ]; then
  kubectl completion bash | bash
fi
