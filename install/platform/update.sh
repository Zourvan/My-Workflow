#!/usr/bin/env bash
# golden-image/update.sh — upgrade all or selected packages.
#
# Usage:
#   sudo ./update.sh
#   sudo ./update.sh --only docker,python,kubernetes

set -Eeuo pipefail

GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export GI_ROOT
# shellcheck source=common.sh
source "${GI_ROOT}/common.sh"

gi_trap_setup
gi_require_root
gi_ensure_dirs

GI_PACKAGE_ORDER=(
  "00-system" "01-shell" "02-git" "03-python" "04-node" "05-go" "06-rust"
  "07-docker" "08-kubernetes" "09-terraform" "10-ansible"
  "12-security" "13-network" "14-database" "15-monitoring" "16-ai" "17-tui"
)

gi_package_short_name() { basename "$1" | sed 's/^[0-9]*-//'; }

gi_run_package() {
  local script="${GI_PACKAGES_DIR}/$1.sh"
  [[ -f "$script" ]] || return 1
  chmod +x "$script"
  bash "$script" upgrade
}

gi_resolve_filter() {
  local raw="${1//,/ }" token
  for token in $raw; do
    local p short found=0
    for p in "${GI_PACKAGE_ORDER[@]}"; do
      short="$(gi_package_short_name "$p")"
      if [[ "$token" == "$short" || "$token" == "$p" ]]; then echo "$p"; found=1; break; fi
    done
    [[ "$found" -eq 1 ]] || { gi_error "Unknown package: $token"; return 1; }
  done
}

main() {
  local -a run_list=()
  if [[ "${1:-}" == "--only" && -n "${2:-}" ]]; then
    mapfile -t run_list < <(gi_resolve_filter "$2")
  elif [[ "${1:-}" == "--only="* ]]; then
    mapfile -t run_list < <(gi_resolve_filter "${1#--only=}")
  else
    run_list=("${GI_PACKAGE_ORDER[@]}")
  fi

  echo "========================================="
  echo " Golden Image Upgrade"
  echo "========================================="

  gi_apt_update
  local p
  for p in "${run_list[@]}"; do
    gi_info "Upgrading $(gi_package_short_name "$p")..."
    gi_run_package "$p" || gi_warn "Upgrade failed: $p"
  done

  gi_success "Upgrade pass complete — run ./verify.sh"
}

main "$@"
