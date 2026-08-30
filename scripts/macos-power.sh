#!/bin/bash
# macos-power.sh - Install AC-only always-awake power management for macOS.
#
# The display can lock and turn off on its normal timer. While AC power is
# connected, a root LaunchDaemon blocks all system sleep, including lid-close
# sleep. On battery, the daemon clears that global block so normal lid and idle
# sleep resume.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WATCHER_SOURCE="$SCRIPT_DIR/macos-power-watcher.sh"
PLIST_SOURCE="$SCRIPT_DIR/local.macos-power-watcher.plist"
WATCHER_DEST="/usr/local/libexec/macos-power-watcher"
PLIST_DEST="/Library/LaunchDaemons/local.macos-power-watcher.plist"
LAUNCHD_LABEL="local.macos-power-watcher"

log() {
  printf '%s\n' "$*"
}

ac_setting() {
  local key="$1"
  pmset -g custom | awk -v key="$key" '
    /^AC Power:/ { in_ac=1; next }
    /^[^[:space:]]/ { in_ac=0 }
    in_ac && $1 == key { print $2; exit }
  '
}

current_power_source() {
  local status
  status=$(pmset -g batt)
  case "$status" in
    *"Now drawing from 'AC Power'"*) printf '%s\n' "ac" ;;
    *"Now drawing from 'Battery Power'"*) printf '%s\n' "battery" ;;
    *) printf '%s\n' "unknown" ;;
  esac
}

current_sleep_disabled() {
  local value
  value=$(pmset -g | awk '$1 == "SleepDisabled" || $1 == "disablesleep" { print $2; exit }')
  printf '%s\n' "${value:-0}"
}

profile_needs_update() {
  local pair key want have
  for pair in \
    sleep=0 \
    standby=0 \
    disksleep=0 \
    displaysleep=5 \
    powernap=0 \
    womp=1 \
    tcpkeepalive=1
  do
    key=${pair%%=*}
    want=${pair#*=}
    have=$(ac_setting "$key")
    if [[ "$have" != "$want" ]]; then
      return 0
    fi
  done
  return 1
}

files_need_install() {
  [[ -f "$WATCHER_DEST" ]] || return 0
  [[ -f "$PLIST_DEST" ]] || return 0
  cmp -s "$WATCHER_SOURCE" "$WATCHER_DEST" || return 0
  cmp -s "$PLIST_SOURCE" "$PLIST_DEST" || return 0
  return 1
}

daemon_is_loaded() {
  launchctl print "system/$LAUNCHD_LABEL" >/dev/null 2>&1
}

uninstall() {
  log "Removing the macOS power watcher..."
  sudo -v
  if daemon_is_loaded; then
    sudo launchctl bootout "system/$LAUNCHD_LABEL"
  fi
  sudo rm -f "$PLIST_DEST" "$WATCHER_DEST"
  sudo pmset -a disablesleep 0
  log "Power watcher removed. Normal sleep is enabled."
}

if [[ "${1:-}" == "--uninstall" ]]; then
  uninstall
  exit 0
fi

if [[ $# -ne 0 ]]; then
  printf 'Usage: %s [--uninstall]\n' "$0" >&2
  exit 2
fi

[[ $(uname -s) == "Darwin" ]] || {
  log "Skipping macOS power setup on $(uname -s)."
  exit 0
}

[[ -f "$WATCHER_SOURCE" ]] || {
  printf 'Missing watcher source: %s\n' "$WATCHER_SOURCE" >&2
  exit 1
}
[[ -f "$PLIST_SOURCE" ]] || {
  printf 'Missing LaunchDaemon plist: %s\n' "$PLIST_SOURCE" >&2
  exit 1
}
plutil -lint "$PLIST_SOURCE" >/dev/null
bash -n "$WATCHER_SOURCE"

needs_profile=false
needs_files=false
needs_daemon=false
needs_state=false

if profile_needs_update; then
  needs_profile=true
fi
if files_need_install; then
  needs_files=true
fi
if ! daemon_is_loaded; then
  needs_daemon=true
fi

source=$(current_power_source)
expected_sleep_disabled=0
if [[ "$source" == "ac" ]]; then
  expected_sleep_disabled=1
fi
if [[ $(current_sleep_disabled) != "$expected_sleep_disabled" ]]; then
  needs_state=true
fi

if ! $needs_profile && ! $needs_files && ! $needs_daemon && ! $needs_state; then
  log "macOS power settings and watcher are already correct."
  exit 0
fi

sudo -v

if $needs_profile; then
  log "Updating AC power settings..."
  sudo pmset -c \
    sleep 0 \
    standby 0 \
    disksleep 0 \
    displaysleep 5 \
    powernap 0 \
    womp 1 \
    tcpkeepalive 1
  log "AC power settings updated."
fi

if $needs_files; then
  log "Installing the power-source watcher..."
  sudo mkdir -p "$(dirname "$WATCHER_DEST")"
  sudo install -o root -g wheel -m 0755 "$WATCHER_SOURCE" "$WATCHER_DEST"
  sudo install -o root -g wheel -m 0644 "$PLIST_SOURCE" "$PLIST_DEST"
fi

# Apply the safe state before changing launchd. This closes the window where a
# battery-powered Mac could retain a stale global sleep block during an update.
sudo "$WATCHER_DEST" --once

if daemon_is_loaded && $needs_files; then
  sudo launchctl bootout "system/$LAUNCHD_LABEL"
  needs_daemon=true
fi
if $needs_daemon; then
  log "Starting the power-source watcher..."
  sudo launchctl bootstrap system "$PLIST_DEST"
  sudo launchctl enable "system/$LAUNCHD_LABEL"
else
  sudo launchctl kickstart -k "system/$LAUNCHD_LABEL"
fi

source=$(current_power_source)
sleep_disabled=$(current_sleep_disabled)
if [[ "$source" == "ac" && "$sleep_disabled" != "1" ]]; then
  printf 'Power watcher verification failed: AC power must set SleepDisabled 1.\n' >&2
  exit 1
fi
if [[ "$source" != "ac" && "$sleep_disabled" != "0" ]]; then
  printf 'Power watcher verification failed: battery or unknown power must clear SleepDisabled.\n' >&2
  exit 1
fi

log "macOS power setup complete."
log "  Plugged in: system stays awake; display sleeps after 5 minutes."
log "  On battery: normal idle and lid-close sleep remain enabled."
