#!/usr/bin/env bash
# packages/13-network.sh — HTTP clients, DNS tools, VPN (WireGuard, OpenVPN, Tailscale).
set -Eeuo pipefail
GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GI_ROOT
GI_PACKAGE="network"
GI_PACKAGE_DESC="httpie, xh, grpcurl, doggo, WireGuard, OpenVPN, Tailscale"
# shellcheck source=../common.sh
source "${GI_ROOT}/common.sh"

gi_install() {
  gi_apt_install wireguard openvpn

  gi_ensure_pipx
  pipx install httpie --force 2>/dev/null || pipx install httpie
  ln -sf /root/.local/bin/http /usr/local/bin/http 2>/dev/null || true
  ln -sf /root/.local/bin/https /usr/local/bin/https 2>/dev/null || true

  # xh — GitHub release
  if ! gi_have_cmd xh; then
    local tag asset arch
    arch="$(gi_arch_map)"
    tag="$(gi_github_latest_tag duist/xh)"
    asset="$(curl -fsSL "https://api.github.com/repos/duist/xh/releases/tags/${tag}" \
      | grep -oE '"name": "xh-[^"]+"' | grep "$arch" | head -n1 | cut -d'"' -f4 || true)"
    if [[ -z "$asset" ]]; then
      asset="$(curl -fsSL "https://api.github.com/repos/duist/xh/releases/tags/${tag}" \
        | grep -oE '"name": "xh-[^"]+"' | grep "$arch" | head -n1 | cut -d'"' -f4)"
    fi
    if [[ -n "$asset" ]]; then
      local dest="${GI_TMPDIR}/${asset}"
      gi_download "https://github.com/duist/xh/releases/download/${tag}/${asset}" "$dest"
      if [[ "$asset" == *.tar.gz ]]; then
        tar -xzf "$dest" -C "${GI_TMPDIR}"
      elif [[ "$asset" == *.zip ]]; then
        unzip -q "$dest" -d "${GI_TMPDIR}"
      else
        install -m 755 "$dest" /usr/local/bin/xh
      fi
      gi_have_cmd xh || install -m 755 "$(find "${GI_TMPDIR}" -name xh -type f | head -n1)" /usr/local/bin/xh
      gi_register_rollback "rm -f /usr/local/bin/xh"
    fi
  fi

  # grpcurl
  if ! gi_have_cmd grpcurl; then
    local tag arch asset
    tag="$(gi_github_latest_tag fullstorydev/grpcurl)"
    arch="$(gi_arch_map)"
    asset="grpcurl_${tag#v}_linux_${arch}.tar.gz"
    if curl -fsI "https://github.com/fullstorydev/grpcurl/releases/download/${tag}/${asset}" | grep -q 200; then
      gi_download "https://github.com/fullstorydev/grpcurl/releases/download/${tag}/${asset}" "${GI_TMPDIR}/${asset}"
      tar -xzf "${GI_TMPDIR}/${asset}" -C "${GI_TMPDIR}"
      install -m 755 "${GI_TMPDIR}/grpcurl" /usr/local/bin/grpcurl
      gi_register_rollback "rm -f /usr/local/bin/grpcurl"
    else
      go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest 2>/dev/null \
        && ln -sf /root/go/bin/grpcurl /usr/local/bin/grpcurl 2>/dev/null || gi_warn "grpcurl install skipped"
    fi
  fi

  # doggo — DNS client
  if ! gi_have_cmd doggo; then
    local tag arch tgz
    tag="$(gi_github_latest_tag mr-karan/doggo)"
    arch="$(gi_arch_map)"
    tgz="doggo_${tag#v}_linux_${arch}.tar.gz"
    if curl -fsI "https://github.com/mr-karan/doggo/releases/download/${tag}/${tgz}" | grep -q 200; then
      gi_download "https://github.com/mr-karan/doggo/releases/download/${tag}/${tgz}" "${GI_TMPDIR}/${tgz}"
      tar -xzf "${GI_TMPDIR}/${tgz}" -C "${GI_TMPDIR}"
      install -m 755 "${GI_TMPDIR}/doggo" /usr/local/bin/doggo
      gi_register_rollback "rm -f /usr/local/bin/doggo"
    fi
  fi

  # Tailscale — official repository
  if ! gi_have_cmd tailscale; then
    gi_download "https://pkgs.tailscale.com/stable/ubuntu/$(. /etc/os-release && echo "$VERSION_CODENAME").noarmor.gpg" \
      "${GI_TMPDIR}/tailscale.gpg"
    cp "${GI_TMPDIR}/tailscale.gpg" /usr/share/keyrings/tailscale-archive-keyring.gpg
    gi_download "https://pkgs.tailscale.com/stable/ubuntu/$(. /etc/os-release && echo "$VERSION_CODENAME").tailscale-keyring.list" \
      /etc/apt/sources.list.d/tailscale.list
    gi_register_rollback "rm -f /etc/apt/sources.list.d/tailscale.list /usr/share/keyrings/tailscale-archive-keyring.gpg"
    gi_apt_update
    gi_apt_install tailscale
    systemctl enable tailscaled >/dev/null 2>&1 || true
  fi

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
}

gi_package_main "${1:-install}"
