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

# Initialize zoxide and replace 'cd' with it (--cmd cd creates cd/cdi functions)
# When zoxide is not installed, 'cd' falls back to builtin
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init bash --cmd cd)"
fi
