#!/usr/bin/env bash
# packages/04-node.sh — Node.js LTS via NodeSource signed repository.
set -Eeuo pipefail
GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GI_ROOT
GI_PACKAGE="node"
GI_PACKAGE_DESC="Node.js LTS (NodeSource official repository)"
# shellcheck source=../common.sh
source "${GI_ROOT}/common.sh"

gi_install() {
  gi_need_cmd curl
  gi_need_cmd gpg

  local keyring="/usr/share/keyrings/nodesource.gpg"
  local list="/etc/apt/sources.list.d/nodesource.list"
  local codename
  codename="$(. /etc/os-release && echo "${VERSION_CODENAME:-noble}")"

  if [[ ! -f "$list" ]]; then
    gi_apt_add_keyring "https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key" "$keyring"
    gi_apt_add_repo "$list" "$keyring" \
      "https://deb.nodesource.com/node_22.x nodistro main"
    gi_register_rollback "rm -f ${list} ${keyring}"
  fi

  gi_apt_update
  gi_apt_install nodejs
  GI_INSTALLED_VERSION="$(node --version 2>/dev/null || echo unknown)"
}

gi_uninstall() {
  apt-get remove -y nodejs 2>/dev/null || true
  rm -f /etc/apt/sources.list.d/nodesource.list /usr/share/keyrings/nodesource.gpg
}

gi_verify() {
  gi_verify_cmd node
  gi_verify_cmd npm
}

gi_package_main "${1:-install}"
