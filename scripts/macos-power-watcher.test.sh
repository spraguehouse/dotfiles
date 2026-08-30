#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WATCHER="$SCRIPT_DIR/macos-power-watcher.sh"
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

make_mocks() {
  local source="$1"
  local pmset_exit="${2:-0}"

  cat >"$TEMP_DIR/pmset" <<EOF
#!/bin/bash
if [[ "\$1 \$2" == "-g batt" ]]; then
  printf "Now drawing from '%s'\n" "$source"
  exit 0
fi
printf '%s\n' "\$*" >>"$TEMP_DIR/calls"
exit $pmset_exit
EOF
  chmod +x "$TEMP_DIR/pmset"

  cat >"$TEMP_DIR/sleep" <<'EOF'
#!/bin/bash
exit 0
EOF
  chmod +x "$TEMP_DIR/sleep"
}

assert_call() {
  local expected="$1"
  local actual
  actual=$(cat "$TEMP_DIR/calls")
  if [[ "$actual" != "$expected" ]]; then
    printf 'Expected call %q, got %q\n' "$expected" "$actual" >&2
    exit 1
  fi
}

: >"$TEMP_DIR/calls"
make_mocks "AC Power"
MACOS_POWER_PMSET_BIN="$TEMP_DIR/pmset" "$WATCHER" --once >/dev/null
assert_call "-a disablesleep 1"

: >"$TEMP_DIR/calls"
make_mocks "Battery Power"
MACOS_POWER_PMSET_BIN="$TEMP_DIR/pmset" "$WATCHER" --once >/dev/null
assert_call "-a disablesleep 0"

: >"$TEMP_DIR/calls"
make_mocks "Unknown Power"
MACOS_POWER_PMSET_BIN="$TEMP_DIR/pmset" "$WATCHER" --once >/dev/null 2>&1
assert_call "-a disablesleep 0"

: >"$TEMP_DIR/calls"
make_mocks "AC Power" 1
if MACOS_POWER_PMSET_BIN="$TEMP_DIR/pmset" "$WATCHER" --once >/dev/null 2>&1; then
  echo "Expected a pmset write failure to fail the watcher." >&2
  exit 1
fi

bash -n "$WATCHER"
plutil -lint "$SCRIPT_DIR/local.macos-power-watcher.plist" >/dev/null

echo "macos power watcher tests passed"
