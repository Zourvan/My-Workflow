#!/usr/bin/env bash
# packages/13-network.sh — HTTP clients, DNS tools, VPN (WireGuard, OpenVPN, Tailscale).
set -Eeuo pipefail
GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GI_ROOT
GI_PACKAGE="network"
GI_PACKAGE_DESC="httpie, xh, grpcurl, doggo, WireGuard, OpenVPN, Tailscale"
# shellcheck source=../common.sh
source "${GI_ROOT}/common.sh"

gi_install_optional() {
  local label="$1"; shift
  if "$@"; then
    gi_success "Optional OK: ${label}"
    return 0
  fi
  gi_warn "Optional skipped: ${label}"
  return 0
}

gi_install_xh() {
  gi_have_cmd xh && return 0
  local tag asset arch json dest bin pattern
  arch="$(gi_arch_map)"
  case "$arch" in
    amd64) pattern="x86_64-unknown-linux" ;;
    arm64) pattern="aarch64-unknown-linux" ;;
    *) return 1 ;;
  esac
  tag="$(gi_github_latest_tag ducaale/xh)"
  [[ -n "$tag" ]] || return 1
  json="$(gi_github_release_json ducaale/xh "$tag")"
  asset="$(grep -oE '"name": "xh-[^"]+"' <<<"$json" \
    | cut -d'"' -f4 | grep -F "$pattern" | head -n1)"
  [[ -n "$asset" ]] || return 1
  dest="${GI_TMPDIR}/${asset}"
  gi_download "https://github.com/ducaale/xh/releases/download/${tag}/${asset}" "$dest"
  case "$asset" in
    *.tar.xz) tar -xJf "$dest" -C "${GI_TMPDIR}" ;;
    *.tar.gz) tar -xzf "$dest" -C "${GI_TMPDIR}" ;;
    *.zip)    unzip -q "$dest" -d "${GI_TMPDIR}" ;;
  esac
  bin="$(find "${GI_TMPDIR}" -type f -name xh | head -n1)"
  [[ -n "$bin" ]] || return 1
  install -m 755 "$bin" /usr/local/bin/xh
  gi_register_rollback "rm -f /usr/local/bin/xh"
}

gi_install_grpcurl() {
  gi_have_cmd grpcurl && return 0
  local tag arch asset
  tag="$(gi_github_latest_tag fullstorydev/grpcurl)"
  arch="$(gi_arch_map)"
  asset="grpcurl_${tag#v}_linux_${arch}.tar.gz"
  if gi_url_ok "https://github.com/fullstorydev/grpcurl/releases/download/${tag}/${asset}"; then
    gi_download "https://github.com/fullstorydev/grpcurl/releases/download/${tag}/${asset}" "${GI_TMPDIR}/${asset}"
    tar -xzf "${GI_TMPDIR}/${asset}" -C "${GI_TMPDIR}"
    install -m 755 "${GI_TMPDIR}/grpcurl" /usr/local/bin/grpcurl
    gi_register_rollback "rm -f /usr/local/bin/grpcurl"
    return 0
  fi
  export PATH="/usr/local/go/bin:/root/go/bin:$PATH"
  if gi_have_cmd go; then
    go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
    install -m 755 "$(go env GOPATH)/bin/grpcurl" /usr/local/bin/grpcurl 2>/dev/null \
      || ln -sf "$(go env GOPATH)/bin/grpcurl" /usr/local/bin/grpcurl
    return 0
  fi
  return 1
}

gi_install_doggo() {
  gi_have_cmd doggo && return 0
  local tag arch tgz json asset
  tag="$(gi_github_latest_tag mr-karan/doggo)"
  arch="$(gi_arch_map)"
  json="$(gi_github_release_json mr-karan/doggo "$tag")"
  tgz="$(grep -oE '"name": "doggo[^"]+\.tar\.gz"' <<<"$json" \
    | cut -d'"' -f4 | grep -i linux | grep -i "$arch" | head -n1)"
  [[ -n "$tgz" ]] || tgz="doggo_${tag#v}_linux_${arch}.tar.gz"
  if ! gi_url_ok "https://github.com/mr-karan/doggo/releases/download/${tag}/${tgz}"; then
    return 1
  fi
  gi_download "https://github.com/mr-karan/doggo/releases/download/${tag}/${tgz}" "${GI_TMPDIR}/${tgz}"
  tar -xzf "${GI_TMPDIR}/${tgz}" -C "${GI_TMPDIR}"
  install -m 755 "${GI_TMPDIR}/doggo" /usr/local/bin/doggo
  gi_register_rollback "rm -f /usr/local/bin/doggo"
}

gi_install_tailscale() {
  gi_have_cmd tailscale && return 0
  local codename
  codename="$(. /etc/os-release && echo "${VERSION_CODENAME:-noble}")"
  local gpg_url="https://pkgs.tailscale.com/stable/ubuntu/${codename}.noarmor.gpg"
  local list_url="https://pkgs.tailscale.com/stable/ubuntu/${codename}.tailscale-keyring.list"
  gi_url_ok "$gpg_url" || return 1
  gi_download "$gpg_url" "${GI_TMPDIR}/tailscale.gpg"
  cp "${GI_TMPDIR}/tailscale.gpg" /usr/share/keyrings/tailscale-archive-keyring.gpg
  gi_download "$list_url" /etc/apt/sources.list.d/tailscale.list
  gi_register_rollback "rm -f /etc/apt/sources.list.d/tailscale.list /usr/share/keyrings/tailscale-archive-keyring.gpg"
  gi_apt_update
  gi_apt_install tailscale
  systemctl enable tailscaled >/dev/null 2>&1 || true
}

gi_install() {
  gi_apt_install wireguard openvpn

  gi_ensure_pipx
  pipx install httpie --force 2>/dev/null || pipx install httpie
  ln -sf /root/.local/bin/http /usr/local/bin/http 2>/dev/null || true
  ln -sf /root/.local/bin/https /usr/local/bin/https 2>/dev/null || true

  gi_install_optional "xh" gi_install_xh
  gi_install_optional "grpcurl" gi_install_grpcurl
  gi_install_optional "doggo" gi_install_doggo
  gi_install_optional "tailscale" gi_install_tailscale

  GI_INSTALLED_VERSION="network-vpn"
}

gi_uninstall() {
  pipx uninstall httpie 2>/dev/null || true
  apt-get remove -y wireguard openvpn tailscale 2>/dev/null || true
  rm -f /usr/local/bin/xh /usr/local/bin/grpcurl /usr/local/bin/doggo /usr/local/bin/http /usr/local/bin/https
}

gi_verify() {
  gi_have_cmd http || gi_have_cmd httpie || { gi_error "httpie missing"; return 1; }
  gi_verify_cmd wg
  gi_have_cmd tailscale || gi_warn "tailscale not installed"
  gi_have_cmd xh || gi_warn "xh not installed"
}

gi_package_main "${1:-install}"
