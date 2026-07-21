#!/usr/bin/env bash
# packages/09-terraform.sh — HashiCorp Terraform official repository.
set -Eeuo pipefail
GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GI_ROOT
GI_PACKAGE="terraform"
GI_PACKAGE_DESC="HashiCorp Terraform (official apt repository)"
# shellcheck source=../common.sh
source "${GI_ROOT}/common.sh"

gi_install() {
  if ! gi_have_cmd terraform; then
    install -m 0755 -d /etc/apt/keyrings
    gi_download "https://apt.releases.hashicorp.com/gpg" "${GI_TMPDIR}/hashicorp.gpg"
    gpg --dearmor -o /etc/apt/keyrings/hashicorp.gpg "${GI_TMPDIR}/hashicorp.gpg"
    local codename
    codename="$(. /etc/os-release && echo "${VERSION_CODENAME:-noble}")"
    echo "deb [signed-by=/etc/apt/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com ${codename} main" \
      >/etc/apt/sources.list.d/hashicorp.list
    gi_register_rollback "rm -f /etc/apt/sources.list.d/hashicorp.list /etc/apt/keyrings/hashicorp.gpg"
    gi_apt_update
    gi_apt_install terraform
  fi
  GI_INSTALLED_VERSION="$(terraform version | head -n1)"
}

gi_uninstall() {
  apt-get remove -y terraform 2>/dev/null || true
  rm -f /etc/apt/sources.list.d/hashicorp.list /etc/apt/keyrings/hashicorp.gpg
}

gi_verify() {
  gi_verify_cmd terraform
  terraform -help >/dev/null
}

gi_package_main "${1:-install}"
