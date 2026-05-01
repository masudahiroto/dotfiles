#!/bin/sh
set -eu

repo_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

log() {
  printf '%s\n' "$*"
}

have() {
  command -v "$1" >/dev/null 2>&1
}

install_apt_packages() {
  packages=""

  if ! have stow; then
    packages="$packages stow"
  fi

  if ! have envsubst; then
    packages="$packages gettext-base"
  fi

  if [ -z "$packages" ]; then
    return 0
  fi

  if have apt-get && have sudo; then
    log "Installing required packages:$packages"
    sudo apt-get update
    sudo apt-get install -y $packages
    return 0
  fi

  log "Missing required packages:$packages"
  return 1
}

run_make() {
  target="$1"

  if ! have make; then
    log "make is required."
    return 1
  fi

  make -C "$repo_dir" "$target"
}

install_apt_packages
run_make install
