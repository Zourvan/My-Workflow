#!/usr/bin/env bash
# golden-image/uninstall.sh — rollback / remove packages.
#
# Usage:
#   sudo ./uninstall.sh docker
#   sudo ./uninstall.sh --all
#   sudo ./uninstall.sh docker terraform python

set -Eeuo pipefail

GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export GI_ROOT
# shellcheck source=common.sh
source "${GI_ROOT}/common.sh"

gi_trap_setup
gi_require_root
gi_ensure_dirs

# Reverse install order for safe teardown
GI_PACKAGE_ORDER=(
  "18-configs" "17-tui" "16-ai" "15-monitoring" "14-database"
  "13-network" "12-security" "11-cloud" "10-ansible" "09-terraform"
  "08-kubernetes" "07-docker" "06-rust" "05-go" "04-node" "03-python"
  "02-git" "01-shell" "00-system"
)

gi_package_short_name() {
  basename "$1" | sed 's/^[0-9]*-//'
}

gi_run_package() {
  local script_name="$1"
  local action="${2:-install}"
  local script="${GI_PACKAGES_DIR}/${script_name}.sh"
  [[ -f "$script" ]] || { gi_error "Missing package script: $script"; return 1; }
  chmod +x "$script"
  bash "$script" "$action"
}

gi_resolve_filter() {
  local raw="${1//,/ }"
  local token
  for token in $raw; do
    local found=0 p short
    for p in "${GI_PACKAGE_ORDER[@]}" "00-system" "01-shell" "02-git" "03-python" \
      "04-node" "05-go" "06-rust" "07-docker" "08-kubernetes" "09-terraform" \
      "10-ansible" "11-cloud" "12-security" "13-network" "14-database" \
      "15-monitoring" "16-ai" "17-tui" "18-configs"; do
      short="$(gi_package_short_name "$p")"
      if [[ "$token" == "$short" || "$token" == "$p" ]]; then
        echo "$p"
        found=1
        break
      fi
    done
    [[ "$found" -eq 1 ]] || { gi_error "Unknown package: $token"; return 1; }
  done
}

gi_usage() {
  cat <<EOF
Golden Image uninstall / rollback

Usage:
  sudo ./uninstall.sh <package> [package...]
  sudo ./uninstall.sh --all

Package names: system, shell, git, python, node, go, rust, docker,
               kubernetes, terraform, ansible, cloud, security, network,
               database, monitoring, ai, tui, configs
EOF
}

main() {
  [[ $# -gt 0 ]] || { gi_usage; exit 1; }

  if [[ "$1" == "--all" ]]; then
    local p
    for p in "${GI_PACKAGE_ORDER[@]}"; do
      gi_run_package "$p" uninstall || gi_warn "Uninstall failed: $p"
    done
    gi_success "All packages processed for uninstall"
    exit 0
  fi

  local token resolved=()
  for token in "$@"; do
    mapfile -t one < <(gi_resolve_filter "$token")
    resolved+=("${one[@]}")
  done

  local script_name
  for script_name in "${resolved[@]}"; do
    gi_run_package "$script_name" uninstall || gi_warn "Uninstall failed: $script_name"
  done
}

main "$@"
