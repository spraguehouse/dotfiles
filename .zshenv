# This file is sourced by zsh in ALL shells (interactive and non-interactive)
# Only put environment variables and essential tools here

# Initialize zoxide (provides 'z' and aliases 'cd' to it)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
