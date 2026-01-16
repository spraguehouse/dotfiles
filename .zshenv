# This file is sourced by zsh in ALL shells (interactive and non-interactive)
# Only put environment variables and essential tools here

# Homebrew - set up PATH early (Apple Silicon vs Intel Macs)
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshenv.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# Initialize zoxide and replace 'cd' with it (--cmd cd creates cd/cdi functions)
# When zoxide is not installed, 'cd' falls back to builtin
# Supports multiple installation locations: Homebrew (macOS), apt (Linux), cargo (manual install)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# Garden Analytics
export GARDEN_DISABLE_ANALYTICS=true