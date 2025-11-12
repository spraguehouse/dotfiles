# This file is sourced by zsh in ALL shells (interactive and non-interactive)
# Only put environment variables and essential tools here

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshenv.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# Initialize zoxide (provides 'z' and aliases 'cd' to it)
# Check both Intel and Apple Silicon paths
if command -v /opt/homebrew/bin/zoxide >/dev/null 2>&1; then
  eval "$(/opt/homebrew/bin/zoxide init zsh)"
elif command -v /usr/local/bin/zoxide >/dev/null 2>&1; then
  eval "$(/usr/local/bin/zoxide init zsh)"
fi
