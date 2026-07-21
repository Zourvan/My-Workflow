#!/usr/bin/env bash
# packages/18-configs.sh — deploy shell, editor, SSH, tmux configs.
set -Eeuo pipefail
GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GI_ROOT
GI_PACKAGE="configs"
GI_PACKAGE_DESC="Git, SSH, tmux, zsh, bash, vim, aliases configuration"
# shellcheck source=../common.sh
source "${GI_ROOT}/common.sh"

gi_install() {
  gi_deploy_config "${GI_CONFIGS_DIR}/gitconfig" ".gitconfig"
  gi_deploy_config "${GI_CONFIGS_DIR}/zshrc" ".zshrc"
  gi_deploy_config "${GI_CONFIGS_DIR}/bashrc" ".bashrc"
  gi_deploy_config "${GI_CONFIGS_DIR}/vimrc" ".vimrc"
  gi_deploy_config "${GI_CONFIGS_DIR}/tmux.conf" ".tmux.conf"
  gi_deploy_config "${GI_CONFIGS_DIR}/aliases" ".golden-image-aliases"

  # SSH client config (system-wide snippet + user)
  install -m 0644 "${GI_CONFIGS_DIR}/ssh_config" /etc/ssh/ssh_config.d/99-golden-image.conf
  gi_register_rollback "rm -f /etc/ssh/ssh_config.d/99-golden-image.conf"
  gi_deploy_config "${GI_CONFIGS_DIR}/ssh_config" ".ssh/config" 0600

  # Source aliases from zsh/bash
  for rc in /etc/skel/.bashrc /root/.bashrc; do
    gi_append_line_once "$rc" "golden-image-aliases" \
      '[ -f ~/.golden-image-aliases ] && . ~/.golden-image-aliases'
  done
  if [[ -d "$GI_TARGET_HOME" && "$GI_TARGET_USER" != "root" ]]; then
    gi_append_line_once "${GI_TARGET_HOME}/.bashrc" "golden-image-aliases" \
      '[ -f ~/.golden-image-aliases ] && . ~/.golden-image-aliases'
    gi_append_line_once "${GI_TARGET_HOME}/.zshrc" "golden-image-aliases" \
      '[ -f ~/.golden-image-aliases ] && . ~/.golden-image-aliases'
  fi
  gi_append_line_once /root/.zshrc "golden-image-aliases" \
    '[ -f ~/.golden-image-aliases ] && . ~/.golden-image-aliases'

  # tmux TPM
  if [[ ! -d /root/.tmux/plugins/tpm ]]; then
    git clone --depth 1 https://github.com/tmux-plugins/tpm /root/.tmux/plugins/tpm 2>/dev/null || true
    if [[ -d "$GI_TARGET_HOME" && "$GI_TARGET_USER" != "root" ]]; then
      sudo -u "$GI_TARGET_USER" git clone --depth 1 https://github.com/tmux-plugins/tpm \
        "${GI_TARGET_HOME}/.tmux/plugins/tpm" 2>/dev/null || true
    fi
    cp -a /root/.tmux/plugins/tpm /etc/skel/.tmux/plugins/ 2>/dev/null || true
  fi

  GI_INSTALLED_VERSION="configs-v1"
}

gi_uninstall() {
  rm -f /etc/ssh/ssh_config.d/99-golden-image.conf
}

gi_verify() {
  [[ -f /etc/skel/.zshrc ]] || { gi_error "skel zshrc missing"; return 1; }
  [[ -f /etc/skel/.tmux.conf ]] || { gi_error "skel tmux.conf missing"; return 1; }
  [[ -f /etc/ssh/ssh_config.d/99-golden-image.conf ]] || gi_warn "ssh config snippet missing"
  gi_success "Configuration files deployed"
}

gi_package_main "${1:-install}"
