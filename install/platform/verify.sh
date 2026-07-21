#!/usr/bin/env bash
# golden-image/verify.sh — verification framework for Golden Image packages.
#
# Usage:
#   sudo ./verify.sh
#   sudo ./verify.sh --only docker,python
#   sudo ./verify.sh --json

set -Eeuo pipefail

GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export GI_ROOT
# shellcheck source=common.sh
source "${GI_ROOT}/common.sh"

gi_ensure_dirs

GI_VERIFY_PACKAGES=(
  "00-system" "01-shell" "02-git" "03-python" "04-node" "05-go" "06-rust"
  "07-docker" "08-kubernetes" "09-terraform" "10-ansible"
  "12-security" "13-network" "14-database" "15-monitoring" "16-ai" "17-tui"
  "18-configs"
)

GI_JSON=0
GI_ONLY=""
GI_FAIL=0
GI_PASS=0

gi_package_short_name() { basename "$1" | sed 's/^[0-9]*-//'; }

gi_run_verify() {
  local script="${GI_PACKAGES_DIR}/$1.sh"
  [[ -f "$script" ]] || { gi_warn "No script: $1"; return 1; }
  bash "$script" verify
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --json) GI_JSON=1; shift ;;
      --only) GI_ONLY="$2"; shift 2 ;;
      --only=*) GI_ONLY="${1#*=}"; shift ;;
      *) shift ;;
    esac
  done

  local -a list=()
  if [[ -n "$GI_ONLY" ]]; then
    local raw="${GI_ONLY//,/ }" token p short
    for token in $raw; do
      for p in "${GI_VERIFY_PACKAGES[@]}"; do
        short="$(gi_package_short_name "$p")"
        [[ "$token" == "$short" || "$token" == "$p" ]] && list+=("$p")
      done
    done
  else
    list=("${GI_VERIFY_PACKAGES[@]}")
  fi

  echo "========================================="
  echo " Golden Image Verification"
  echo "========================================="

  local p short result
  for p in "${list[@]}"; do
    short="$(gi_package_short_name "$p")"
    if gi_run_verify "$p"; then
      GI_PASS=$((GI_PASS + 1))
      [[ "$GI_JSON" -eq 0 ]] && gi_success "PASS: ${short}"
    else
      GI_FAIL=$((GI_FAIL + 1))
      [[ "$GI_JSON" -eq 0 ]] && gi_error "FAIL: ${short}"
    fi
  done

  echo "-----------------------------------------"
  echo "Passed: ${GI_PASS}  Failed: ${GI_FAIL}"

  if [[ "$GI_JSON" -eq 1 ]]; then
    printf '{"passed":%d,"failed":%d}\n' "$GI_PASS" "$GI_FAIL"
  fi

  [[ "$GI_FAIL" -eq 0 ]]
}

main "$@"
