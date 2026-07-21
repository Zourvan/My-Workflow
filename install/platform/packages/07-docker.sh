#!/usr/bin/env bash
# packages/07-docker.sh — Docker CE, Compose plugin, Buildx, Dive, LazyDocker.
set -Eeuo pipefail
GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GI_ROOT
GI_PACKAGE="docker"
GI_PACKAGE_DESC="Docker CE, Compose v2, Buildx, Dive, LazyDocker"
# shellcheck source=../common.sh
source "${GI_ROOT}/common.sh"

gi_install() {
  gi_need_cmd curl
  gi_need_cmd gpg

  if ! gi_have_cmd docker; then
    install -m 0755 -d /etc/apt/keyrings
    gi_apt_add_keyring "https://download.docker.com/linux/ubuntu/gpg" \
      /etc/apt/keyrings/docker.gpg
    gi_apt_add_repo /etc/apt/sources.list.d/docker.list /etc/apt/keyrings/docker.gpg \
      "https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable"
    gi_register_rollback "rm -f /etc/apt/sources.list.d/docker.list /etc/apt/keyrings/docker.gpg"

    gi_apt_update
    gi_apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  fi

  systemctl enable docker >/dev/null 2>&1 || true
  systemctl start docker >/dev/null 2>&1 || true

  # Add target user to docker group
  if getent passwd "$GI_TARGET_USER" >/dev/null 2>&1 && [[ "$GI_TARGET_USER" != "root" ]]; then
    gi_add_user_to_group "$GI_TARGET_USER" docker
  fi

  # Dive — GitHub release binary
  if ! gi_have_cmd dive; then
    local arch tag asset tgz json
    arch="$(gi_arch_map)"
    tag="$(gi_github_latest_tag wagoodman/dive)"
    json="$(gi_github_release_json wagoodman/dive "$tag")"
    asset="$(grep -oE '"name": "dive_[^"]+\.tar\.gz"' <<<"$json" \
      | cut -d'"' -f4 | grep -E "linux_${arch}" | head -n1)"
    [[ -n "$asset" ]] || die "No dive tar.gz asset for ${arch} (${tag})"
    tgz="${GI_TMPDIR}/${asset}"
    gi_download "https://github.com/wagoodman/dive/releases/download/${tag}/${asset}" "$tgz"
    tar -xzf "$tgz" -C "${GI_TMPDIR}"
    install -m 755 "${GI_TMPDIR}/dive" /usr/local/bin/dive
    gi_register_rollback "rm -f /usr/local/bin/dive"
  fi

  # LazyDocker
  if ! gi_have_cmd lazydocker; then
    local arch tag ver tgz
    arch="$(gi_arch_map)"
    case "$arch" in amd64) arch="x86_64" ;; esac
    tag="$(gi_github_latest_tag jesseduffield/lazydocker)"
    ver="${tag#v}"
    tgz="lazydocker_${ver}_Linux_${arch}.tar.gz"
    gi_download "https://github.com/jesseduffield/lazydocker/releases/download/${tag}/${tgz}" "${GI_TMPDIR}/${tgz}"
    tar -xzf "${GI_TMPDIR}/${tgz}" -C "${GI_TMPDIR}" lazydocker
    install -m 755 "${GI_TMPDIR}/lazydocker" /usr/local/bin/lazydocker
    gi_register_rollback "rm -f /usr/local/bin/lazydocker"
  fi

  GI_INSTALLED_VERSION="$(docker --version 2>/dev/null || echo unknown)"
}

gi_uninstall() {
  systemctl stop docker 2>/dev/null || true
  apt-get remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
  rm -f /usr/local/bin/dive /usr/local/bin/lazydocker
}

gi_verify() {
  gi_verify_cmd docker
  docker compose version >/dev/null 2>&1 || { gi_error "docker compose plugin missing"; return 1; }
  docker buildx version >/dev/null 2>&1 || gi_warn "buildx not available"
  gi_have_cmd dive || gi_warn "dive not installed"
  gi_have_cmd lazydocker || gi_warn "lazydocker not installed"
  systemctl is-active docker >/dev/null 2>&1 || gi_warn "docker service not active"
}

gi_package_main "${1:-install}"
