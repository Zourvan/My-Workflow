#!/usr/bin/env bash
# packages/10-ansible.sh — Ansible via official pip (ansible-core) + apt fallback.
set -Eeuo pipefail
GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GI_ROOT
GI_PACKAGE="ansible"
GI_PACKAGE_DESC="Ansible automation (ansible-core via pipx)"
# shellcheck source=../common.sh
source "${GI_ROOT}/common.sh"

gi_install() {
  gi_apt_install openssh-client sshpass
  gi_ensure_pipx
  pipx install ansible-core --force 2>/dev/null || pipx install ansible-core
  ln -sf /root/.local/bin/ansible /usr/local/bin/ansible 2>/dev/null || true
  ln -sf /root/.local/bin/ansible-playbook /usr/local/bin/ansible-playbook 2>/dev/null || true
  ln -sf /root/.local/bin/ansible-galaxy /usr/local/bin/ansible-galaxy 2>/dev/null || true
  gi_register_rollback "pipx uninstall ansible-core 2>/dev/null || true"
  GI_INSTALLED_VERSION="$(ansible --version | head -n1 2>/dev/null || echo unknown)"
}

gi_uninstall() {
  pipx uninstall ansible-core 2>/dev/null || true
  rm -f /usr/local/bin/ansible /usr/local/bin/ansible-playbook /usr/local/bin/ansible-galaxy
}

gi_verify() {
  gi_verify_cmd ansible
  gi_verify_cmd ansible-playbook
}

gi_package_main "${1:-install}"
