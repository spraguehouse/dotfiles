#!/bin/bash
# macos-power.sh - AC power management for always-on operation
# Only affects AC power (-c flag). Battery and lid-close behavior untouched.
# Checks current values first to avoid unnecessary sudo prompts.

set -euo pipefail

declare -A desired=(
  [sleep]=0
  [standby]=0
  [disksleep]=0
  [displaysleep]=5
  [powernap]=0
)

current=$(pmset -g custom)
needs_change=false

for key in "${!desired[@]}"; do
  want="${desired[$key]}"
  # Extract current AC value for this key
  have=$(echo "$current" | awk -v k="$key" '/AC Power/{found=1} found && $1==k{print $2; exit}')
  if [[ "$have" != "$want" ]]; then
    needs_change=true
    break
  fi
done

if $needs_change; then
  echo "Updating AC power settings..."
  sudo pmset -c sleep 0          # never sleep on AC
  sudo pmset -c standby 0        # no deep sleep on AC
  sudo pmset -c disksleep 0      # no disk sleep on AC
  sudo pmset -c displaysleep 5   # display off after 5 min on AC
  sudo pmset -c powernap 0       # no Power Nap on AC
  echo "AC power settings updated."
else
  echo "AC power settings already correct, skipping."
fi
