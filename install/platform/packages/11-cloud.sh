#!/usr/bin/env bash
# packages/11-cloud.sh — AWS CLI v2, Azure CLI, Google Cloud SDK (official installers).
set -Eeuo pipefail
GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GI_ROOT
GI_PACKAGE="cloud"
GI_PACKAGE_DESC="AWS CLI, Azure CLI, Google Cloud SDK"
# shellcheck source=../common.sh
source "${GI_ROOT}/common.sh"

gi_install_aws() {
  if gi_have_cmd aws; then return 0; fi
  local arch zip
  arch="$(gi_arch_map)"
  case "$arch" in
    amd64) zip="awscli-exe-linux-x86_64.zip" ;;
    arm64) zip="awscli-exe-linux-aarch64.zip" ;;
  esac
  gi_download "https://awscli.amazonaws.com/${zip}" "${GI_TMPDIR}/${zip}"
  unzip -q "${GI_TMPDIR}/${zip}" -d "${GI_TMPDIR}/aws"
  "${GI_TMPDIR}/aws/aws/install" --update
  gi_register_rollback "${GI_TMPDIR}/aws/aws/install --uninstall 2>/dev/null || rm -rf /usr/local/aws-cli /usr/local/bin/aws"
}

gi_install_azure() {
  if gi_have_cmd az; then return 0; fi
  gi_download "https://aka.ms/InstallAzureCLIDeb" "${GI_TMPDIR}/azure_install.sh"
  chmod +x "${GI_TMPDIR}/azure_install.sh"
  bash "${GI_TMPDIR}/azure_install.sh"
  gi_register_rollback "apt-get remove -y azure-cli 2>/dev/null || true"
}

gi_install_gcloud() {
  if gi_have_cmd gcloud; then return 0; fi
  gi_apt_install apt-transport-https ca-certificates gnupg
  gi_download "https://packages.cloud.google.com/apt/doc/apt-key.gpg" "${GI_TMPDIR}/google-cloud.gpg"
  gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg "${GI_TMPDIR}/google-cloud.gpg"
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
    >/etc/apt/sources.list.d/google-cloud-sdk.list
  gi_register_rollback "rm -f /etc/apt/sources.list.d/google-cloud-sdk.list /usr/share/keyrings/cloud.google.gpg"
  gi_apt_update
  gi_apt_install google-cloud-cli
}

gi_install() {
  gi_install_aws
  gi_install_azure
  gi_install_gcloud
  GI_INSTALLED_VERSION="cloud-clis"
}

gi_uninstall() {
  rm -rf /usr/local/aws-cli /usr/local/bin/aws /usr/local/bin/aws_completer
  apt-get remove -y azure-cli google-cloud-cli 2>/dev/null || true
  rm -f /etc/apt/sources.list.d/google-cloud-sdk.list /usr/share/keyrings/cloud.google.gpg
}

gi_verify() {
  gi_verify_cmd aws
  gi_verify_cmd az
  gi_verify_cmd gcloud
}

gi_package_main "${1:-install}"
