#!/usr/bin/env bash
# packages/08-kubernetes.sh — kubectl, helm (official signed repos / releases).
set -Eeuo pipefail
GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GI_ROOT
GI_PACKAGE="kubernetes"
GI_PACKAGE_DESC="kubectl and Helm for Kubernetes"
# shellcheck source=../common.sh
source "${GI_ROOT}/common.sh"

gi_install_kubectl() {
  if gi_have_cmd kubectl; then return 0; fi

  local arch keyring list
  arch="$(gi_arch_map)"
  keyring=/usr/share/keyrings/kubernetes-archive-keyring.gpg
  list=/etc/apt/sources.list.d/kubernetes.list

  gi_download "https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key" "${GI_TMPDIR}/k8s-release.key"
  gpg --dearmor -o "$keyring" "${GI_TMPDIR}/k8s-release.key"
  echo "deb [signed-by=${keyring}] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" >"$list"
  gi_register_rollback "rm -f ${list} ${keyring}"

  gi_apt_update
  gi_apt_install kubectl
}

gi_install_helm() {
  if gi_have_cmd helm; then return 0; fi

  curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey \
    | gpg --dearmor -o /usr/share/keyrings/helm.gpg
  echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" \
    >/etc/apt/sources.list.d/helm.list
  gi_register_rollback "rm -f /etc/apt/sources.list.d/helm.list /usr/share/keyrings/helm.gpg"
  gi_apt_update
  gi_apt_install helm
}

gi_install() {
  gi_install_kubectl
  gi_install_helm
  GI_INSTALLED_VERSION="$(kubectl version --client --short 2>/dev/null || kubectl version --client 2>/dev/null | head -n1)"
}

gi_uninstall() {
  apt-get remove -y kubectl helm 2>/dev/null || true
  rm -f /etc/apt/sources.list.d/kubernetes.list /etc/apt/sources.list.d/helm.list
  rm -f /usr/share/keyrings/kubernetes-archive-keyring.gpg /usr/share/keyrings/helm.gpg
}

gi_verify() {
  gi_verify_cmd kubectl
  gi_verify_cmd helm
  kubectl config view >/dev/null 2>&1 || true
}

gi_package_main "${1:-install}"
