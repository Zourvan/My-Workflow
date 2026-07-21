#!/usr/bin/env bash
# packages/05-go.sh — Go official tarball with SHA256 verification.
set -Eeuo pipefail
GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GI_ROOT
GI_PACKAGE="go"
GI_PACKAGE_DESC="Go programming language (go.dev official release)"
# shellcheck source=../common.sh
source "${GI_ROOT}/common.sh"

gi_install() {
  local arch goarch version tarball url
  arch="$(gi_arch_map)"
  case "$arch" in
    amd64) goarch="linux-amd64" ;;
    arm64) goarch="linux-arm64" ;;
  esac

  version="$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -n1 | tr -d '[:space:]')"
  tarball="${version}.${goarch}.tar.gz"
  url="https://go.dev/dl/${tarball}"

  gi_download "$url" "${GI_TMPDIR}/${tarball}"

  # Verify using official checksum file
  gi_download "https://go.dev/dl/${tarball}.sha256" "${GI_TMPDIR}/${tarball}.sha256"
  local expected actual
  expected="$(awk '{print $1}' "${GI_TMPDIR}/${tarball}.sha256")"
  gi_verify_sha256 "${GI_TMPDIR}/${tarball}" "$expected"

  rm -rf /usr/local/go
  tar -C /usr/local -xzf "${GI_TMPDIR}/${tarball}"
  gi_register_rollback "rm -rf /usr/local/go"

  gi_append_line_once /etc/profile.d/golden-image-go.sh "golden-image-go" \
    'export PATH=$PATH:/usr/local/go/bin'

  GI_INSTALLED_VERSION="$version"
}

gi_uninstall() {
  rm -rf /usr/local/go
  rm -f /etc/profile.d/golden-image-go.sh
}

gi_verify() {
  export PATH="$PATH:/usr/local/go/bin"
  gi_verify_cmd go
}

gi_package_main "${1:-install}"
