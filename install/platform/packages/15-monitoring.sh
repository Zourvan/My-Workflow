#!/usr/bin/env bash
# packages/15-monitoring.sh — promtool, amtool (Prometheus / Alertmanager CLIs).
set -Eeuo pipefail
GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GI_ROOT
GI_PACKAGE="monitoring"
GI_PACKAGE_DESC="promtool and amtool from official Prometheus/Alertmanager releases"
# shellcheck source=../common.sh
source "${GI_ROOT}/common.sh"

gi_install_binary() {
  local project="$1" binary="$2" tag pattern
  if gi_have_cmd "$binary"; then return 0; fi
  tag="$(gi_github_latest_tag "${project}")"
  pattern="${binary}-.*linux-$(gi_arch_map).*\\.tar\\.gz"
  local asset url
  asset="$(curl -fsSL "https://api.github.com/repos/${project}/releases/tags/${tag}" \
    | grep -oE '"name": "[^"]+"' | cut -d'"' -f4 \
    | grep -E "${binary}.*linux.*$(gi_arch_map)" | head -n1)"
  [[ -n "$asset" ]] || { gi_warn "No ${binary} asset for ${tag}"; return 1; }
  url="https://github.com/${project}/releases/download/${tag}/${asset}"
  gi_download "$url" "${GI_TMPDIR}/${asset}"
  tar -xzf "${GI_TMPDIR}/${asset}" -C "${GI_TMPDIR}"
  local found
  found="$(find "${GI_TMPDIR}" -type f -name "$binary" | head -n1)"
  install -m 755 "$found" "/usr/local/bin/${binary}"
  gi_register_rollback "rm -f /usr/local/bin/${binary}"
}

gi_install() {
  gi_install_binary prometheus/prometheus promtool || true
  gi_install_binary prometheus/alertmanager amtool || true
  GI_INSTALLED_VERSION="monitoring-clis"
}

gi_uninstall() {
  rm -f /usr/local/bin/promtool /usr/local/bin/amtool
}

gi_verify() {
  gi_have_cmd promtool && gi_verify_cmd promtool || gi_warn "promtool not installed"
  gi_have_cmd amtool && gi_verify_cmd amtool || gi_warn "amtool not installed"
  gi_have_cmd promtool || gi_have_cmd amtool || { gi_error "No monitoring tools found"; return 1; }
}

gi_package_main "${1:-install}"
