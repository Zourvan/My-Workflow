#!/usr/bin/env bash
# packages/12-security.sh — UFW, fail2ban, unattended-upgrades, audit basics.
set -Eeuo pipefail
GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GI_ROOT
GI_PACKAGE="security"
GI_PACKAGE_DESC="UFW firewall, fail2ban, unattended-upgrades"
# shellcheck source=../common.sh
source "${GI_ROOT}/common.sh"

gi_install() {
  gi_apt_install ufw fail2ban unattended-upgrades apt-listchanges

  # UFW defaults (do not enable automatically on golden image — admin enables)
  ufw default deny incoming >/dev/null 2>&1 || true
  ufw default allow outgoing >/dev/null 2>&1 || true
  ufw allow OpenSSH >/dev/null 2>&1 || ufw allow 22/tcp >/dev/null 2>&1 || true

  systemctl enable fail2ban >/dev/null 2>&1 || true
  systemctl start fail2ban >/dev/null 2>&1 || true

  dpkg-reconfigure -f noninteractive unattended-upgrades 2>/dev/null || true

  GI_INSTALLED_VERSION="security-baseline"
}

gi_uninstall() {
  systemctl stop fail2ban 2>/dev/null || true
  apt-get remove -y fail2ban ufw unattended-upgrades 2>/dev/null || true
}

gi_verify() {
  gi_have_cmd ufw || return 1
  gi_have_cmd fail2ban-client || return 1
  systemctl is-enabled fail2ban >/dev/null 2>&1 || gi_warn "fail2ban not enabled"
}

gi_package_main "${1:-install}"
