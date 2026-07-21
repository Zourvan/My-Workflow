#!/usr/bin/env bash
# install/engine.sh — service selection, presets, and execution engine.

set -euo pipefail

# shellcheck source=lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
# shellcheck source=catalog.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/catalog.sh"

declare -a SELECTED_IDS=()

catalog_entry_field() {
  # field: 1=id 2=category 3=label 4=desc 5=tier 6=script 7=needs_root
  local entry="$1" n="$2"
  echo "$entry" | cut -d'|' -f"$n"
}

catalog_print_table() {
  local filter_tier="${1:-all}"
  local i=1 row id cat label desc tier
  printf '\n%-4s %-16s %-12s %-22s %s\n' "#" "ID" "CATEGORY" "SERVICE" "DESCRIPTION"
  printf '%s\n' "--------------------------------------------------------------------------------"
  while IFS= read -r row; do
    id="$(catalog_entry_field "$row" 1)"
    cat="$(catalog_entry_field "$row" 2)"
    label="$(catalog_entry_field "$row" 3)"
    desc="$(catalog_entry_field "$row" 4)"
    tier="$(catalog_entry_field "$row" 5)"
  [[ "$filter_tier" != "all" && "$tier" != "$filter_tier" ]] && continue
    printf '%-4s %-16s %-12s %-22s %s\n' "$i" "$id" "$(catalog_category_label "$cat")" "$label" "$desc"
    i=$((i + 1))
  done < <(catalog_all_entries)
  echo
}

catalog_id_by_index() {
  local n="$1" filter_tier="${2:-all}" i=1 row id tier
  while IFS= read -r row; do
    tier="$(catalog_entry_field "$row" 5)"
    [[ "$filter_tier" != "all" && "$tier" != "$filter_tier" ]] && continue
    if [[ "$i" -eq "$n" ]]; then
      catalog_entry_field "$row" 1
      return 0
    fi
    i=$((i + 1))
  done < <(catalog_all_entries)
  return 1
}

resolve_selection_tokens() {
  local raw="${1//,/ }" token resolved=() id
  for token in $raw; do
    case "$token" in
      all|ALL)
        catalog_all_entries | while IFS= read -r row; do catalog_entry_field "$row" 1; done
        return 0
        ;;
      dev-all)
        printf '%s\n' "${PRESET_DEV_FULL[@]}"
        return 0
        ;;
      platform-all|golden-all)
        printf '%s\n' "${PRESET_PLATFORM_FULL[@]}"
        return 0
        ;;
      ''|*[!0-9]*)
        id="$(catalog_resolve_id "$token")"
        catalog_find_entry "$id" >/dev/null || die "Unknown service: $token"
        resolved+=("$id")
        ;;
      *)
        id="$(catalog_id_by_index "$token" "${MW_FILTER_TIER:-all}")" \
          || die "Invalid selection number: $token"
        resolved+=("$id")
        ;;
    esac
  done

  # Deduplicate preserving catalog order
  local row want out=()
  while IFS= read -r row; do
    id="$(catalog_entry_field "$row" 1)"
    for want in "${resolved[@]}"; do
      [[ "$want" == "$id" ]] && { out+=("$id"); break; }
    done
  done < <(catalog_all_entries)
  printf '%s\n' "${out[@]}"
}

dedupe_ordered() {
  resolve_selection_tokens "$1"
}

run_service() {
  local id="$1"
  local entry script tier needs_root base action=install
  entry="$(catalog_find_entry "$id")" || die "Service not in catalog: $id"
  script="$(catalog_entry_field "$entry" 6)"
  tier="$(catalog_entry_field "$entry" 5)"
  needs_root="$(catalog_entry_field "$entry" 7)"

  case "$tier" in
    dev)    base="$MW_DEV_ROOT" ;;
    platform) base="$MW_PLATFORM_ROOT" ;;
    *) die "Unknown tier: $tier" ;;
  esac

  local path="${base}/${script}"
  [[ -f "$path" ]] || die "Missing script: $path"
  chmod +x "$path"

  info "Running: $id ($tier)"
  if [[ "$needs_root" == "1" ]]; then
    if needs_sudo; then
      sudo bash "$path" "$action"
    else
      bash "$path" "$action"
    fi
  else
    bash "$path"
  fi
}

run_services() {
  local -a ids=("$@")
  local total="${#ids[@]}" n=0 id needs_any_root=0 entry

  [[ "$total" -gt 0 ]] || die "No services selected"

  for id in "${ids[@]}"; do
    entry="$(catalog_find_entry "$id")"
    [[ "$(catalog_entry_field "$entry" 7)" == "1" ]] && needs_any_root=1
  done

  if [[ "$needs_any_root" -eq 1 ]] && needs_sudo && ! sudo -n true 2>/dev/null; then
    warn "Some services require root — you may be prompted for sudo"
  fi

  banner
  printf 'Installing %d service(s): %s\n\n' "$total" "${ids[*]}"

  for id in "${ids[@]}"; do
    n=$((n + 1))
    echo "[$n/$total] ── $id ──"
    run_service "$id"
    echo
  done

  echo "========================================="
  ok "Installation complete"
  echo " Dev:    exec zsh  |  nvim → :Lazy sync"
  echo " Platform: sudo ./verify.sh"
  echo "========================================="
}

# ── Interactive menus ─────────────────────────────────────────────────────────

menu_profiles() {
  banner
  cat <<'EOF'

Choose a profile:

  1) Developer minimal     — shell + dotfiles (fast)
  2) Developer full        — shell + editor + CLI tools
  3) Developer IDE         — Neovim stack + lazygit + superfile
  4) DevOps lab            — Docker, K8s, Terraform, Ansible
  5) MLOps lab             — Python, Docker, AI, cloud CLIs
  6) Golden Image (full)   — complete platform stack
  7) Custom selection      — pick services one by one
  8) List all services
  9) Exit

EOF
  local choice
  printf 'Your choice [1-9]: '
  read -r choice

  case "$choice" in
    1) run_services "${PRESET_DEV_MINIMAL[@]}" ;;
    2) run_services "${PRESET_DEV_FULL[@]}" ;;
    3) run_services "${PRESET_DEV_IDE[@]}" ;;
    4) run_services "${PRESET_DEVOPS[@]}" ;;
    5) run_services "${PRESET_MLOPS[@]}" ;;
    6) run_services "${PRESET_PLATFORM_FULL[@]}" ;;
    7) menu_custom ;;
    8) catalog_print_table all; menu_profiles ;;
    9) info "Cancelled"; exit 0 ;;
    *) warn "Invalid choice"; menu_profiles ;;
  esac
}

menu_custom() {
  catalog_print_table all
  cat <<'EOF'
Enter service IDs or numbers (space-separated).
Presets: dev-all | platform-all | all
Examples:  1 3 8   |   neovim gi-docker gi-python
EOF
  local choice
  printf '\nYour selection: '
  read -r choice
  mapfile -t ids < <(dedupe_ordered "$choice")
  run_services "${ids[@]}"
}

engine_usage() {
  cat <<EOF
My-Workflow unified installer

Usage:
  ./install.sh                         Interactive profile menu
  ./install.sh --list                  List all services
  ./install.sh --list-dev              Developer services only
  ./install.sh --list-platform         Platform / DevOps services only

Presets:
  ./install.sh --minimal               Dev shell minimal
  ./install.sh --dev                   Dev workstation full
  ./install.sh --ide                   Dev IDE stack
  ./install.sh --devops                DevOps lab
  ./install.sh --mlops                 MLOps lab
  ./install.sh --golden                Full platform (Golden Image)
  ./install.sh --all                   Everything (dev + platform)

Selection:
  ./install.sh --only neovim,gi-docker,gi-python
  ./install.sh --only system,gi-kubernetes,terraform

Management (platform):
  ./verify.sh                          Verify installations
  ./update.sh                          Upgrade platform packages
  ./uninstall.sh gi-docker             Rollback a platform service

Environment:
  GI_TARGET_USER=devops                Target user for config deployment
  GI_FORCE_REINSTALL=1                 Force reinstall platform packages
EOF
}

engine_main() {
  export MW_ROOT MW_INSTALL_ROOT MW_DEV_ROOT MW_PLATFORM_ROOT

  case "${1:-}" in
    ""|menu)
      need_tty
      menu_profiles
      ;;
    -h|--help) engine_usage ;;
    --list) catalog_print_table all ;;
    --list-dev)
      MW_FILTER_TIER=dev
      catalog_print_table dev
      ;;
    --list-platform)
      MW_FILTER_TIER=platform
      catalog_print_table platform
      ;;
    --minimal) run_services "${PRESET_DEV_MINIMAL[@]}" ;;
    --dev|--dev-full) run_services "${PRESET_DEV_FULL[@]}" ;;
    --ide) run_services "${PRESET_DEV_IDE[@]}" ;;
    --shell) run_services "${PRESET_DEV_SHELL[@]}" ;;
    --devops) run_services "${PRESET_DEVOPS[@]}" ;;
    --mlops) run_services "${PRESET_MLOPS[@]}" ;;
    --golden|--platform) run_services "${PRESET_PLATFORM_FULL[@]}" ;;
    --all)
      mapfile -t all_ids < <(catalog_all_entries | while IFS= read -r row; do catalog_entry_field "$row" 1; done)
      run_services "${all_ids[@]}"
      ;;
    --only|--only=*)
      local raw
      if [[ "${1:-}" == --only=* ]]; then
        raw="${1#--only=}"
      else
        shift
        raw="${*:-}"
      fi
      mapfile -t ids < <(dedupe_ordered "${raw//,/ }")
      run_services "${ids[@]}"
      ;;
    *)
      mapfile -t ids < <(dedupe_ordered "${*/ /}")
      run_services "${ids[@]}"
      ;;
  esac
}

# Only run when executed directly (not sourced for tests)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  engine_main "$@"
fi
