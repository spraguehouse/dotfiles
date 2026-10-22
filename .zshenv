# Sourced by every zsh: interactive, login, and the non-interactive shells that
# agents and scripts run. Only environment and PATH belong here.

# Homebrew (Apple Silicon or Intel)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

export EDITOR="micro"
export LESSCHARSET="utf-8"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export BUN_INSTALL="$HOME/.bun"
export GARDEN_DISABLE_ANALYTICS=true

# One PATH, no duplicates. Agent tools first, then language toolchains.
typeset -U path
path=(
  "$HOME/.t3/bin"
  "$HOME/.ion/bin"
  "$HOME/.grok/bin"
  "$HOME/.local/bin"
  "$BUN_INSTALL/bin"
  "$HOME/.cargo/bin"
  "$HOME/.dotnet/tools"
  /Library/Frameworks/Python.framework/Versions/3.12/bin
  $path
  "$ANDROID_HOME/platform-tools"
  "$ANDROID_HOME/tools"
)

# zoxide replaces cd in every shell, so agents get it too. Falls back to the
# builtin when zoxide is not installed.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi
