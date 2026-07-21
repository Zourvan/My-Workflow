#!/usr/bin/env bash
# packages/01-shell.sh — zsh, oh-my-zsh, powerlevel10k, zoxide, starship.
set -Eeuo pipefail
GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GI_ROOT
GI_PACKAGE="shell"
GI_PACKAGE_DESC="Zsh shell stack with Oh My Zsh, p10k, zoxide, starship"
# shellcheck source=../common.sh
source "${GI_ROOT}/common.sh"

OMZ_DIR="/root/.oh-my-zsh"
TARGET_OMZ="${GI_TARGET_HOME}/.oh-my-zsh"

gi_install() {
  gi_apt_install zsh fonts-powerline

  # Install Oh My Zsh for target user (and root skel pattern)
  if [[ ! -d "$TARGET_OMZ" ]]; then
    local run_user="${GI_TARGET_USER}"
    if [[ "$run_user" != "root" && -n "$run_user" ]]; then
      sudo -u "$run_user" env RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    if [[ ! -d /root/.oh-my-zsh ]]; then
      env RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    gi_register_rollback "rm -rf ${TARGET_OMZ} /root/.oh-my-zsh"
  fi

  local zsh_custom="${TARGET_OMZ}/custom"
  [[ -d "$zsh_custom" ]] || zsh_custom="/root/.oh-my-zsh/custom"
  mkdir -p "${zsh_custom}/plugins" "${zsh_custom}/themes"

  gi_clone_plugin() {
    local url="$1" dest="$2"
    [[ -d "$dest" ]] || git clone --depth 1 "$url" "$dest"
    # Also for root
    local root_dest="${dest/${GI_TARGET_HOME}/\/root}"
    [[ -d "$root_dest" ]] || git clone --depth 1 "$url" "$root_dest" 2>/dev/null || true
  }

  gi_clone_plugin https://github.com/zsh-users/zsh-autosuggestions \
    "${zsh_custom}/plugins/zsh-autosuggestions"
  gi_clone_plugin https://github.com/zsh-users/zsh-syntax-highlighting \
    "${zsh_custom}/plugins/zsh-syntax-highlighting"
  gi_clone_plugin https://github.com/zsh-users/zsh-completions \
    "${zsh_custom}/plugins/zsh-completions"
  gi_clone_plugin https://github.com/romkatv/powerlevel10k \
    "${zsh_custom}/themes/powerlevel10k"

  # zoxide — official installer
  if ! gi_have_cmd zoxide; then
    curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh \
      | env INSTALL_DIR=/usr/local/bin sh
    gi_register_rollback "rm -f /usr/local/bin/zoxide"
  fi

  # starship — official installer with GPG via package repo
  if ! gi_have_cmd starship; then
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b /usr/local/bin
    gi_register_rollback "rm -f /usr/local/bin/starship"
  fi

  # Set zsh as shell for target user if local account
  local zsh_path
  zsh_path="$(command -v zsh)"
  if getent passwd "$GI_TARGET_USER" >/dev/null 2>&1; then
    chsh -s "$zsh_path" "$GI_TARGET_USER" 2>/dev/null || gi_warn "Could not chsh for ${GI_TARGET_USER}"
  fi

  GI_INSTALLED_VERSION="$(zsh --version | head -n1)"
}

gi_uninstall() {
  rm -f /usr/local/bin/zoxide /usr/local/bin/starship
  rm -rf "${TARGET_OMZ}" /root/.oh-my-zsh
}

gi_verify() {
  gi_verify_cmd zsh
  gi_verify_cmd zoxide
  gi_verify_cmd starship
  [[ -d "${TARGET_OMZ}" || -d /root/.oh-my-zsh ]] || { gi_error "Oh My Zsh missing"; return 1; }
}

gi_package_main "${1:-install}"
