#!/usr/bin/env bash
# packages/17-tui.sh — LazyGit, LazyDocker, BTop, Dua (TUI utilities).
set -Eeuo pipefail
GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GI_ROOT
GI_PACKAGE="tui"
GI_PACKAGE_DESC="LazyGit, LazyDocker, BTop, Dua TUI tools"
# shellcheck source=../common.sh
source "${GI_ROOT}/common.sh"

gi_install_github_bin() {
  local repo="$1" binary="$2" arch_tag="$3"
  if gi_have_cmd "$binary"; then return 0; fi
  local tag ver tgz
  tag="$(gi_github_latest_tag "$repo")"
  ver="${tag#v}"
  tgz="${binary}_${ver}_Linux_${arch_tag}.tar.gz"
  if ! curl -fsI "https://github.com/${repo}/releases/download/${tag}/${tgz}" | grep -q 200; then
    tgz="${binary^}_${ver}_Linux_${arch_tag}.tar.gz"
  fi
  if ! curl -fsI "https://github.com/${repo}/releases/download/${tag}/${tgz}" | grep -q 200; then
    tgz="$(curl -fsSL "https://api.github.com/repos/${repo}/releases/tags/${tag}" \
      | grep -oE '"name": "[^"]+"' | cut -d'"' -f4 | grep -i linux | grep -i "${arch_tag}" | head -n1)"
  fi
  gi_download "https://github.com/${repo}/releases/download/${tag}/${tgz}" "${GI_TMPDIR}/${tgz}"
  tar -xzf "${GI_TMPDIR}/${tgz}" -C "${GI_TMPDIR}"
  local found
  found="$(find "${GI_TMPDIR}" -type f -name "$binary" | head -n1)"
  install -m 755 "$found" "/usr/local/bin/${binary}"
  gi_register_rollback "rm -f /usr/local/bin/${binary}"
}

gi_install() {
  local arch
  arch="$(gi_arch_map)"
  case "$arch" in amd64) arch="x86_64" ;; esac

  gi_install_github_bin jesseduffield/lazygit lazygit "$arch"
  gi_install_github_bin jesseduffield/lazydocker lazydocker "$arch"

  # btop — apt (already in system) or verify
  gi_apt_install btop 2>/dev/null || true

  # dua — disk usage analyzer
  if ! gi_have_cmd dua; then
    export PATH="/root/.cargo/bin:$PATH"
    if gi_have_cmd cargo; then
      cargo install dua-cli --locked 2>/dev/null \
        && ln -sf /root/.cargo/bin/dua /usr/local/bin/dua
    else
      local tag asset
      tag="$(gi_github_latest_tag Byron/dua-cli)"
      asset="$(curl -fsSL "https://api.github.com/repos/Byron/dua-cli/releases/tags/${tag}" \
        | grep -oE '"name": "dua-[^"]+"' | cut -d'"' -f4 | grep linux | grep "$(gi_arch_map)" | head -n1)"
      if [[ -n "$asset" ]]; then
        gi_download "https://github.com/Byron/dua-cli/releases/download/${tag}/${asset}" "${GI_TMPDIR}/dua.tgz"
        tar -xzf "${GI_TMPDIR}/dua.tgz" -C "${GI_TMPDIR}"
        install -m 755 "$(find "${GI_TMPDIR}" -name dua -type f | head -n1)" /usr/local/bin/dua
      fi
    fi
    gi_register_rollback "rm -f /usr/local/bin/dua"
  fi

  GI_INSTALLED_VERSION="tui-tools"
}

gi_uninstall() {
  rm -f /usr/local/bin/lazygit /usr/local/bin/lazydocker /usr/local/bin/dua
}

gi_verify() {
  gi_verify_cmd lazygit
  gi_verify_cmd lazydocker
  gi_verify_cmd btop
  gi_have_cmd dua || gi_warn "dua not installed"
}

gi_package_main "${1:-install}"
