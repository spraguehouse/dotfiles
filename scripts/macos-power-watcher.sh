#!/bin/bash
# Keep macOS fully awake while AC power is connected. SleepDisabled is a
# system-wide switch, so this watcher must clear it as soon as AC is removed.

set -u

POLL_SECONDS=${MACOS_POWER_POLL_SECONDS:-2}
PMSET_BIN=${MACOS_POWER_PMSET_BIN:-/usr/bin/pmset}
DATE_BIN=${MACOS_POWER_DATE_BIN:-/bin/date}
SLEEP_BIN=${MACOS_POWER_SLEEP_BIN:-/bin/sleep}
last_source=""

log() {
  printf '%s macos-power-watcher: %s\n' "$($DATE_BIN -u '+%Y-%m-%dT%H:%M:%SZ')" "$*"
}

power_source() {
  local status
  if ! status=$($PMSET_BIN -g batt 2>&1); then
    log "failed to read power source: $status" >&2
    printf '%s\n' "unknown"
    return
  fi

  case "$status" in
    *"Now drawing from 'AC Power'"*) printf '%s\n' "ac" ;;
    *"Now drawing from 'Battery Power'"*) printf '%s\n' "battery" ;;
    *)
      log "unrecognized power source; using safe battery behavior" >&2
      printf '%s\n' "unknown"
      ;;
  esac
}

apply_source() {
  local source="$1"
  local value=0
  local output
  if [[ "$source" == "ac" ]]; then
    value=1
  fi

  if ! output=$($PMSET_BIN -a disablesleep "$value" 2>&1); then
    log "failed to set disablesleep=$value for source=$source: $output" >&2
    return 1
  fi
  log "applied source=$source disablesleep=$value"
}

run_once() {
  local source
  source=$(power_source)
  apply_source "$source"
}

if [[ "${1:-}" == "--once" ]]; then
  run_once
  exit $?
fi

if [[ $# -ne 0 ]]; then
  printf 'Usage: %s [--once]\n' "$0" >&2
  exit 2
fi

log "started poll_seconds=$POLL_SECONDS"
while true; do
  source=$(power_source)
  if [[ "$source" != "$last_source" ]]; then
    if apply_source "$source"; then
      last_source="$source"
    fi
  fi
  $SLEEP_BIN "$POLL_SECONDS"
done
