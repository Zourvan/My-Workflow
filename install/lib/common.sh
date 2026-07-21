#!/usr/bin/env bash
# install/lib/common.sh — shared helpers for unified installer.

set -euo pipefail

MW_ROOT="${MW_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
MW_INSTALL_ROOT="${MW_INSTALL_ROOT:-${MW_ROOT}/install}"
MW_DEV_ROOT="${MW_DEV_ROOT:-${MW_INSTALL_ROOT}/dev}"
MW_PLATFORM_ROOT="${MW_PLATFORM_ROOT:-${MW_INSTALL_ROOT}/platform}"

if [[ -t 1 ]]; then
  C_RESET=$'\033[0m' C_RED=$'\033[0;31m' C_GREEN=$'\033[0;32m'
  C_YELLOW=$'\033[0;33m' C_BLUE=$'\033[0;34m' C_CYAN=$'\033[0;36m' C_BOLD=$'\033[1m'
else
  C_RESET="" C_RED="" C_GREEN="" C_YELLOW="" C_BLUE="" C_CYAN="" C_BOLD=""
fi

info()  { printf '%b→ %s%b\n' "$C_BLUE" "$*" "$C_RESET"; }
ok()    { printf '%b✔ %s%b\n' "$C_GREEN" "$*" "$C_RESET"; }
warn()  { printf '%b⚠ %s%b\n' "$C_YELLOW" "$*" "$C_RESET"; }
die()   { printf '%b✖ %s%b\n' "$C_RED" "$*" "$C_RESET" >&2; exit 1; }

have_cmd() { command -v "$1" >/dev/null 2>&1; }

need_tty() {
  [[ -t 0 ]] || die "Interactive mode requires a TTY. Use --help for CLI flags."
}

needs_sudo() {
  [[ "${EUID:-$(id -u)}" -ne 0 ]]
}

banner() {
  echo "========================================="
  printf '%b My-Workflow Unified Installer%b\n' "$C_BOLD" "$C_RESET"
  echo " Dev workstation + DevOps / MLOps platform"
  echo "========================================="
}
