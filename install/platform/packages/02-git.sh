#!/usr/bin/env bash
# packages/02-git.sh — git, git-lfs, global git configuration.
set -Eeuo pipefail
GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GI_ROOT
GI_PACKAGE="git"
GI_PACKAGE_DESC="Git, Git LFS, and global gitconfig"
# shellcheck source=../common.sh
source "${GI_ROOT}/common.sh"

gi_install() {
  gi_apt_install git git-lfs
  git lfs install --system 2>/dev/null || git lfs install

  gi_deploy_config "${GI_CONFIGS_DIR}/gitconfig" ".gitconfig"

  # Apply gitconfig for target user
  if [[ "$GI_TARGET_USER" != "root" && -d "$GI_TARGET_HOME" ]]; then
    install -m 0644 "${GI_CONFIGS_DIR}/gitconfig" "${GI_TARGET_HOME}/.gitconfig"
    chown "${GI_TARGET_USER}:${GI_TARGET_USER}" "${GI_TARGET_HOME}/.gitconfig"
  fi
  install -m 0644 "${GI_CONFIGS_DIR}/gitconfig" /root/.gitconfig

  GI_INSTALLED_VERSION="$(git --version)"
}

gi_uninstall() {
  git lfs uninstall --system 2>/dev/null || true
}

gi_verify() {
  gi_verify_cmd git
  gi_verify_cmd git-lfs
  git config --global init.defaultBranch >/dev/null || gi_warn "git global config not loaded"
}

gi_package_main "${1:-install}"
