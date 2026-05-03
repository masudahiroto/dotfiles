#!/bin/sh
set -eu

repo_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

log() {
  printf '%s\n' "$*"
}

have() {
  command -v "$1" >/dev/null 2>&1
}

run_make() {
  target="$1"

  if ! have make; then
    log "make is required."
    return 1
  fi

  make -C "$repo_dir" "$target"
}

run_make install
