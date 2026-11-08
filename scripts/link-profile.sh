#!/bin/bash
# link-profile.sh - Choose this machine's dotfiles profile and link it.
#
# Usage: link-profile.sh [profile]
#
# The profile comes from the argument, else the profile already linked, else a
# prompt. It is linked at ~/.config/dotfiles/profile, where the core dotfiles
# look for it. Any secret the profile needs that ~/.config/shell/secrets.env
# lacks is reported by name.

set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
PROFILES_DIR="$DOTFILES_DIR/profiles"
PROFILE_LINK="$HOME/.config/dotfiles/profile"
SECRETS_FILE="$HOME/.config/shell/secrets.env"

available_profiles() {
  local dir
  for dir in "$PROFILES_DIR"/*/; do
    basename "$dir"
  done
}

profile="${1:-}"

if [[ -z "$profile" && -L "$PROFILE_LINK" ]]; then
  profile=$(basename "$(readlink "$PROFILE_LINK")")
fi

if [[ -z "$profile" ]]; then
  printf 'Profiles: %s\n' "$(available_profiles | tr '\n' ' ')"
  printf 'Which profile is this machine? '
  read -r profile </dev/tty
fi

if [[ ! -d "$PROFILES_DIR/$profile" ]]; then
  printf 'Unknown profile "%s". Profiles: %s\n' "$profile" "$(available_profiles | tr '\n' ' ')" >&2
  exit 1
fi

mkdir -p "$(dirname "$PROFILE_LINK")"
ln -sfn "$PROFILES_DIR/$profile" "$PROFILE_LINK"
printf 'Dotfiles profile: %s\n' "$profile"

example="$PROFILES_DIR/$profile/secrets.example"
if [[ -f "$example" ]]; then
  mkdir -p "$(dirname "$SECRETS_FILE")"
  touch "$SECRETS_FILE"
  chmod 600 "$SECRETS_FILE"
  missing=()
  while IFS= read -r line; do
    [[ "$line" =~ ^([A-Z_][A-Z0-9_]*)= ]] || continue
    key="${BASH_REMATCH[1]}"
    grep -Eq "^(export )?$key=.+" "$SECRETS_FILE" || missing+=("$key")
  done <"$example"
  if [[ ${#missing[@]} -gt 0 ]]; then
    printf 'Add these to %s: %s\n' "$SECRETS_FILE" "${missing[*]}"
  fi
fi
