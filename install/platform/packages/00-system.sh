#!/usr/bin/env bash
# packages/00-system.sh — base system packages, locale, chrony, journald.
set -Eeuo pipefail
GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GI_ROOT
GI_PACKAGE="system"
GI_PACKAGE_DESC="Base CLI tools, locale, timezone, chrony, journald"
# shellcheck source=../common.sh
source "${GI_ROOT}/common.sh"

gi_install() {
  gi_apt_update
  gi_apt_install \
    curl wget git git-lfs nano tmux screen tree jq yq \
    fzf ripgrep fd-find bat eza htop btop iftop iotop ncdu rsync \
    zip unzip p7zip-full zstd pv file dnsutils net-tools iproute2 \
    tcpdump nmap mtr-tiny iperf3 traceroute openssl socat ncat lsof \
    strace ltrace sysstat bash-completion chrony locales \
    hyperfine

  # Ubuntu maps fd-find → fdfind; provide fd symlink
  if gi_have_cmd fdfind && ! gi_have_cmd fd; then
    ln -sf "$(command -v fdfind)" /usr/local/bin/fd
    gi_register_rollback "rm -f /usr/local/bin/fd"
  fi
  if gi_have_cmd batcat && ! gi_have_cmd bat; then
    ln -sf "$(command -v batcat)" /usr/local/bin/bat
    gi_register_rollback "rm -f /usr/local/bin/bat"
  fi

  gi_configure_locale
  gi_configure_timezone
  gi_configure_chrony
  gi_configure_journald
  gi_configure_logrotate
  gi_configure_bash_completion

  GI_INSTALLED_VERSION="$(lsb_release -ds 2>/dev/null || echo "${GI_OS_VERSION}")"
}

gi_uninstall() {
  gi_warn "System base packages are not removed (unsafe for golden image rollback)"
}

gi_verify() {
  local cmds=(curl wget git jq fzf rg fd bat eza htop chronyc)
  local c
  for c in "${cmds[@]}"; do
    gi_verify_cmd "$c" || return 1
  done
  timedatectl status >/dev/null 2>&1 || { gi_error "timedatectl failed"; return 1; }
  systemctl is-active chrony >/dev/null 2>&1 || gi_warn "chrony not active"
  gi_success "System verification passed"
}

gi_package_main "${1:-install}"
