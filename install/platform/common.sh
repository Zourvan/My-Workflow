#!/usr/bin/env bash
# golden-image/common.sh — shared library for enterprise Golden Image automation.
# ShellCheck: source this file; do not execute directly.
#
# Features: structured logging, retries, timeouts, GPG/checksum verification,
# idempotent install markers, rollback hooks, colored output, progress tracking.

set -Eeuo pipefail

# ---------------------------------------------------------------------------
# Paths (GI_ROOT set by caller or derived from this file)
# ---------------------------------------------------------------------------
if [[ -z "${GI_ROOT:-}" ]]; then
  GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
GI_PACKAGES_DIR="${GI_ROOT}/packages"
GI_CONFIGS_DIR="${GI_ROOT}/configs"
GI_CACHE_DIR="${GI_ROOT}/cache"
GI_DOCS_DIR="${GI_ROOT}/docs"
GI_LOG_DIR="${GI_LOG_DIR:-/var/log/golden-image}"
GI_STATE_DIR="${GI_STATE_DIR:-/var/lib/golden-image/state}"
GI_ROLLBACK_DIR="${GI_ROLLBACK_DIR:-/var/lib/golden-image/rollback}"
GI_VERSION_FILE="${GI_ROOT}/VERSION"

GI_TARGET_USER="${SUDO_USER:-${GI_TARGET_USER:-root}}"
GI_TARGET_HOME="$(getent passwd "$GI_TARGET_USER" 2>/dev/null | cut -d: -f6 || echo "/root")"
GI_ARCH="$(uname -m)"
GI_OS_ID=""
GI_OS_VERSION=""
GI_OS_CODENAME=""

# Retry / timeout defaults
GI_RETRY_ATTEMPTS="${GI_RETRY_ATTEMPTS:-3}"
GI_RETRY_DELAY="${GI_RETRY_DELAY:-5}"
GI_CMD_TIMEOUT="${GI_CMD_TIMEOUT:-600}"

# Current package context (set by gi_package_init)
GI_PACKAGE="${GI_PACKAGE:-unknown}"
GI_PACKAGE_DESC="${GI_PACKAGE_DESC:-}"

# Colors (disabled when not a TTY)
if [[ -t 1 ]]; then
  GI_C_RESET=$'\033[0m'
  GI_C_RED=$'\033[0;31m'
  GI_C_GREEN=$'\033[0;32m'
  GI_C_YELLOW=$'\033[0;33m'
  GI_C_BLUE=$'\033[0;34m'
  GI_C_CYAN=$'\033[0;36m'
  GI_C_BOLD=$'\033[1m'
else
  GI_C_RESET="" GI_C_RED="" GI_C_GREEN="" GI_C_YELLOW=""
  GI_C_BLUE="" GI_C_CYAN="" GI_C_BOLD=""
fi

# ---------------------------------------------------------------------------
# Bootstrap directories
# ---------------------------------------------------------------------------
gi_ensure_dirs() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    mkdir -p "${GI_ROOT}/logs" "${GI_CACHE_DIR}"
    return 0
  fi
  mkdir -p "$GI_LOG_DIR" "$GI_STATE_DIR" "$GI_ROLLBACK_DIR" "$GI_CACHE_DIR"
  chmod 755 "$GI_LOG_DIR" "$GI_STATE_DIR" "$GI_ROLLBACK_DIR" 2>/dev/null || true
}

gi_detect_os() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    GI_OS_ID="${ID:-unknown}"
    GI_OS_VERSION="${VERSION_ID:-unknown}"
    GI_OS_CODENAME="${VERSION_CODENAME:-unknown}"
  fi
}

gi_require_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    gi_error "This script must be run as root (sudo ./install.sh)"
    exit 1
  fi
}

gi_require_ubuntu() {
  gi_detect_os
  if [[ "$GI_OS_ID" != "ubuntu" ]]; then
    gi_warn "Expected Ubuntu; detected ${GI_OS_ID}. Continuing anyway."
  fi
}

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
gi_timestamp() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

gi_log_write() {
  local level="$1"; shift
  local msg="$*"
  local master pkg_log line
  line="[$(gi_timestamp)] [${level}] [${GI_PACKAGE}] ${msg}"
  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    master="${GI_LOG_DIR}/install.log"
    pkg_log="${GI_LOG_DIR}/${GI_PACKAGE}.log"
    gi_ensure_dirs
    printf '%s\n' "$line" >>"$master"
    printf '%s\n' "$line" >>"$pkg_log"
  else
    mkdir -p "${GI_ROOT}/logs"
    printf '%s\n' "$line" >>"${GI_ROOT}/logs/install.log"
  fi
}

gi_info()    { printf '%b→ %s%b\n' "$GI_C_BLUE" "$*" "$GI_C_RESET";    gi_log_write "INFO" "$@"; }
gi_success() { printf '%b✔ %s%b\n' "$GI_C_GREEN" "$*" "$GI_C_RESET";  gi_log_write "OK" "$@"; }
gi_warn()    { printf '%b⚠ %s%b\n' "$GI_C_YELLOW" "$*" "$GI_C_RESET"; gi_log_write "WARN" "$@"; }
gi_error()   { printf '%b✖ %s%b\n' "$GI_C_RED" "$*" "$GI_C_RESET";    gi_log_write "ERROR" "$@"; }

# ---------------------------------------------------------------------------
# Error handling / cleanup
# ---------------------------------------------------------------------------
gi_cleanup_tmp() {
  [[ -n "${GI_TMPDIR:-}" && -d "${GI_TMPDIR:-}" ]] && rm -rf "$GI_TMPDIR"
}

gi_on_err() {
  local exit_code=$?
  [[ "$exit_code" -eq 0 ]] && exit 0
  local line="${BASH_LINENO[0]:-?}"
  gi_error "Command failed (exit ${exit_code}) at ${BASH_SOURCE[1]:-?}:${line}: ${BASH_COMMAND:-?}"
  gi_cleanup_tmp
  exit "$exit_code"
}

gi_trap_setup() {
  trap 'gi_on_err' ERR
  trap 'gi_cleanup_tmp' EXIT
}

# ---------------------------------------------------------------------------
# Retry / timeout
# ---------------------------------------------------------------------------
gi_retry() {
  local attempt=1 max="$GI_RETRY_ATTEMPTS" delay="$GI_RETRY_DELAY"
  while true; do
    if "$@"; then
      return 0
    fi
    if (( attempt >= max )); then
      gi_error "Command failed after ${max} attempts: $*"
      return 1
    fi
    gi_warn "Retry ${attempt}/${max} in ${delay}s: $*"
    sleep "$delay"
    attempt=$((attempt + 1))
  done
}

gi_timeout() {
  local seconds="$1"; shift
  if command -v timeout >/dev/null 2>&1; then
    timeout --foreground "$seconds" "$@"
  else
    "$@"
  fi
}

# ---------------------------------------------------------------------------
# Progress (simple bar for package batches)
# ---------------------------------------------------------------------------
gi_progress_start() {
  GI_PROGRESS_TOTAL="${1:-1}"
  GI_PROGRESS_CURRENT=0
}

gi_progress_step() {
  local label="${1:-}"
  GI_PROGRESS_CURRENT=$((GI_PROGRESS_CURRENT + 1))
  local pct=$((GI_PROGRESS_CURRENT * 100 / GI_PROGRESS_TOTAL))
  local filled=$((pct / 5))
  local bar=""
  local i
  for ((i=0; i<20; i++)); do
    bar+=$([[ $i -lt $filled ]] && echo -n '█' || echo -n '░')
  done
  printf '%b[%3d%%] %s %s (%d/%d)%b\n' \
    "$GI_C_CYAN" "$pct" "$bar" "$label" "$GI_PROGRESS_CURRENT" "$GI_PROGRESS_TOTAL" "$GI_C_RESET"
}

# ---------------------------------------------------------------------------
# Command helpers
# ---------------------------------------------------------------------------
gi_have_cmd() { command -v "$1" >/dev/null 2>&1; }

gi_need_cmd() {
  gi_have_cmd "$1" || { gi_error "Required command not found: $1"; return 1; }
}

gi_cmd_version() {
  local cmd="$1"
  gi_have_cmd "$cmd" || return 1
  "$cmd" --version 2>/dev/null | head -n1 || "$cmd" -version 2>/dev/null | head -n1 || true
}

gi_arch_map() {
  case "$GI_ARCH" in
    x86_64|amd64) echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    *) gi_error "Unsupported architecture: $GI_ARCH"; return 1 ;;
  esac
}

gi_github_latest_tag() {
  local repo="$1"
  gi_retry curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" \
    | grep -m1 '"tag_name"' | cut -d '"' -f 4
}

# ---------------------------------------------------------------------------
# APT helpers (signed repos only)
# ---------------------------------------------------------------------------
gi_apt_update() {
  gi_retry gi_timeout 300 apt-get update -qq
}

gi_apt_install() {
  local pkgs=("$@")
  DEBIAN_FRONTEND=noninteractive gi_retry gi_timeout 600 \
    apt-get install -y -qq --no-install-recommends "${pkgs[@]}"
}

gi_apt_add_keyring() {
  # Usage: gi_apt_add_keyring <key_url> <signed-by_path>
  local key_url="$1" key_path="$2"
  gi_need_cmd curl
  gi_need_cmd gpg
  mkdir -p "$(dirname "$key_path")"
  gi_retry curl -fsSL "$key_url" | gpg --dearmor -o "$key_path"
  chmod 644 "$key_path"
}

gi_apt_add_repo() {
  # Usage: gi_apt_add_repo <list_file> <signed-by_path> <repo_line>
  local list_file="$1" signed_by="$2" repo_line="$3"
  printf 'deb [signed-by=%s] %s\n' "$signed_by" "$repo_line" >"$list_file"
  chmod 644 "$list_file"
}

# ---------------------------------------------------------------------------
# Checksum / GPG verification
# ---------------------------------------------------------------------------
gi_verify_sha256() {
  local file="$1" expected="$2"
  local actual
  actual="$(sha256sum "$file" | awk '{print $1}')"
  if [[ "$actual" != "$expected" ]]; then
    gi_error "SHA256 mismatch for $(basename "$file")"
    gi_error "  expected: $expected"
    gi_error "  actual:   $actual"
    return 1
  fi
  gi_success "SHA256 verified: $(basename "$file")"
}

gi_download() {
  # gi_download <url> <dest>
  local url="$1" dest="$2"
  gi_need_cmd curl
  gi_retry curl -fsSL --connect-timeout 30 --max-time "$GI_CMD_TIMEOUT" -o "$dest" "$url"
}

gi_download_github_release() {
  # gi_download_github_release <repo> <asset_pattern> <dest_dir>
  # asset_pattern is a grep pattern matched against release asset names
  local repo="$1" pattern="$2" dest_dir="$3"
  local tag json url asset
  tag="$(gi_github_latest_tag "$repo")"
  json="$(curl -fsSL "https://api.github.com/repos/${repo}/releases/tags/${tag}")"
  asset="$(echo "$json" | grep -oE '"name": "[^"]+"' | cut -d'"' -f4 | grep -E "$pattern" | head -n1)"
  [[ -n "$asset" ]] || { gi_error "No release asset matching /${pattern}/ for ${repo} ${tag}"; return 1; }
  url="https://github.com/${repo}/releases/download/${tag}/${asset}"
  mkdir -p "$dest_dir"
  gi_info "Downloading ${asset} (${tag})..."
  gi_download "$url" "${dest_dir}/${asset}"
  printf '%s\n' "${dest_dir}/${asset}"
}

gi_install_bin_from_tgz() {
  # gi_install_bin_from_tgz <tgz> <binary_inside> <dest_path>
  local tgz="$1" bin_name="$2" dest="$3"
  local tmp="${GI_TMPDIR:-/tmp/gi-extract-$$}"
  mkdir -p "$tmp"
  tar -xzf "$tgz" -C "$tmp"
  local found
  found="$(find "$tmp" -type f -name "$bin_name" | head -n1)"
  [[ -n "$found" ]] || { gi_error "Binary ${bin_name} not found in archive"; return 1; }
  install -m 755 "$found" "$dest"
}

# ---------------------------------------------------------------------------
# State / idempotency / rollback
# ---------------------------------------------------------------------------
gi_state_file() { echo "${GI_STATE_DIR}/${GI_PACKAGE}.installed"; }

gi_is_installed() {
  [[ -f "$(gi_state_file)" ]]
}

gi_mark_installed() {
  local version="${1:-unknown}"
  gi_ensure_dirs
  printf 'version=%s\ninstalled_at=%s\n' "$version" "$(gi_timestamp)" >"$(gi_state_file)"
}

gi_mark_uninstalled() {
  rm -f "$(gi_state_file)"
}

gi_register_rollback() {
  # Append rollback commands to package rollback script
  local cmd="$1"
  gi_ensure_dirs
  local rb="${GI_ROLLBACK_DIR}/${GI_PACKAGE}.sh"
  if [[ ! -f "$rb" ]]; then
    printf '#!/usr/bin/env bash\nset -euo pipefail\n' >"$rb"
    chmod 755 "$rb"
  fi
  printf '%s\n' "$cmd" >>"$rb"
}

gi_run_rollback() {
  local pkg="$1"
  local rb="${GI_ROLLBACK_DIR}/${pkg}.sh"
  if [[ -f "$rb" ]]; then
    gi_info "Running rollback for ${pkg}..."
    bash "$rb"
    rm -f "$rb" "$(gi_state_file)"
    gi_success "Rollback complete: ${pkg}"
  else
    gi_warn "No rollback script for ${pkg}"
  fi
}

# ---------------------------------------------------------------------------
# User / config deployment
# ---------------------------------------------------------------------------
gi_deploy_config() {
  # Deploy config to /etc/skel, root, and target user home
  local src="$1" dest_rel="$2" mode="${3:-0644}"
  local dest_name="${dest_rel##*/}"
  local skel="/etc/skel/${dest_rel}"
  local root_dest="/root/${dest_rel}"
  local user_dest="${GI_TARGET_HOME}/${dest_rel}"

  [[ -f "$src" ]] || { gi_error "Config missing: $src"; return 1; }

  mkdir -p "$(dirname "$skel")" "$(dirname "$root_dest")"
  if [[ "$(dirname "$dest_rel")" == ".ssh" ]]; then
    chmod 700 "$(dirname "$skel")" "$(dirname "$root_dest")" 2>/dev/null || true
  fi
  install -m "$mode" "$src" "$skel"
  install -m "$mode" "$src" "$root_dest"

  if [[ -d "$GI_TARGET_HOME" && "$GI_TARGET_USER" != "root" ]]; then
    mkdir -p "$(dirname "$user_dest")"
    if [[ "$(dirname "$dest_rel")" == ".ssh" ]]; then
      chmod 700 "$(dirname "$user_dest")"
      chown "${GI_TARGET_USER}:${GI_TARGET_USER}" "$(dirname "$user_dest")"
    fi
    install -m "$mode" "$src" "$user_dest"
    chown "${GI_TARGET_USER}:${GI_TARGET_USER}" "$user_dest" 2>/dev/null || true
  fi
  gi_success "Deployed config ${dest_name}"
}

gi_append_line_once() {
  local file="$1" marker="$2" line="$3"
  [[ -f "$file" ]] || touch "$file"
  if ! grep -Fq "$marker" "$file" 2>/dev/null; then
    printf '\n# %s\n%s\n' "$marker" "$line" >>"$file"
  fi
}

gi_user_in_group() {
  local user="$1" group="$2"
  id -nG "$user" 2>/dev/null | tr ' ' '\n' | grep -qx "$group"
}

gi_add_user_to_group() {
  local user="$1" group="$2"
  if gi_user_in_group "$user" "$group"; then
    gi_info "User ${user} already in group ${group}"
  else
    usermod -aG "$group" "$user"
    gi_register_rollback "gpasswd -d ${user} ${group} 2>/dev/null || true"
    gi_success "Added ${user} to group ${group}"
  fi
}

# ---------------------------------------------------------------------------
# Package module interface
# ---------------------------------------------------------------------------
gi_package_init() {
  GI_TMPDIR="$(mktemp -d "${GI_CACHE_DIR}/tmp.${GI_PACKAGE}.XXXXXX")"
  gi_ensure_dirs
  gi_detect_os
}

gi_package_skip_if_installed() {
  if gi_is_installed && [[ "${GI_FORCE_REINSTALL:-0}" != "1" ]]; then
    gi_info "Package '${GI_PACKAGE}' already installed — skipping (set GI_FORCE_REINSTALL=1 to reinstall)"
    return 0
  fi
  return 1
}

gi_verify_cmd() {
  local cmd="$1" min_version="${2:-}"
  if ! gi_have_cmd "$cmd"; then
    gi_error "Verify failed: ${cmd} not in PATH"
    return 1
  fi
  local ver
  ver="$(gi_cmd_version "$cmd" || true)"
  gi_success "Verify OK: ${cmd} → ${ver}"
  if [[ -n "$min_version" && -n "$ver" ]]; then
    gi_info "Minimum expected: ${min_version}"
  fi
  return 0
}

gi_package_main() {
  local action="${1:-install}"
  gi_package_init

  case "$action" in
    install)
      if gi_package_skip_if_installed; then return 0; fi
      gi_info "Installing ${GI_PACKAGE}: ${GI_PACKAGE_DESC}"
      gi_install
      gi_mark_installed "${GI_INSTALLED_VERSION:-}"
      gi_success "Installed ${GI_PACKAGE}"
      ;;
    uninstall)
      gi_info "Uninstalling ${GI_PACKAGE}..."
      if declare -f gi_uninstall >/dev/null; then
        gi_uninstall
      fi
      gi_run_rollback "$GI_PACKAGE"
      gi_mark_uninstalled
      gi_success "Uninstalled ${GI_PACKAGE}"
      ;;
    verify)
      gi_info "Verifying ${GI_PACKAGE}..."
      gi_verify
      ;;
    upgrade)
      gi_info "Upgrading ${GI_PACKAGE}..."
      GI_FORCE_REINSTALL=1
      if declare -f gi_upgrade >/dev/null; then
        gi_upgrade
      else
        gi_uninstall 2>/dev/null || true
        gi_mark_uninstalled
        gi_install
      fi
      gi_mark_installed "${GI_INSTALLED_VERSION:-}"
      gi_success "Upgraded ${GI_PACKAGE}"
      ;;
    *)
      gi_error "Unknown action: ${action} (use install|uninstall|verify|upgrade)"
      return 1
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Python helpers (uv / pipx — official installers)
# ---------------------------------------------------------------------------
gi_ensure_uv() {
  if gi_have_cmd uv; then return 0; fi
  gi_need_cmd curl
  gi_retry curl -fsSL https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/usr/local/bin" sh
  gi_register_rollback "rm -f /usr/local/bin/uv /usr/local/bin/uvx"
}

gi_ensure_pipx() {
  if gi_have_cmd pipx; then return 0; fi
  gi_apt_install python3-pip python3-venv
  gi_retry python3 -m pip install --break-system-packages pipx 2>/dev/null \
    || gi_retry python3 -m pip install pipx
  gi_retry pipx ensurepath
  gi_register_rollback "pipx uninstall --all 2>/dev/null || true"
}

# ---------------------------------------------------------------------------
# Locale / timezone / system tuning (used by 00-system)
# ---------------------------------------------------------------------------
gi_configure_locale() {
  gi_apt_install locales
  locale-gen en_US.UTF-8 2>/dev/null || true
  update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 2>/dev/null || true
}

gi_configure_timezone() {
  local tz="${GI_TIMEZONE:-UTC}"
  timedatectl set-timezone "$tz" 2>/dev/null || ln -sf "/usr/share/zoneinfo/${tz}" /etc/localtime
  gi_success "Timezone: ${tz}"
}

gi_configure_chrony() {
  gi_apt_install chrony
  systemctl enable chrony >/dev/null 2>&1 || true
  systemctl restart chrony >/dev/null 2>&1 || true
}

gi_configure_journald() {
  mkdir -p /etc/systemd/journald.conf.d
  cat >/etc/systemd/journald.conf.d/golden-image.conf <<'EOF'
[Journal]
Storage=persistent
SystemMaxUse=500M
RuntimeMaxUse=100M
Compress=yes
EOF
  systemctl restart systemd-journald 2>/dev/null || true
  gi_register_rollback "rm -f /etc/systemd/journald.conf.d/golden-image.conf"
}

gi_configure_logrotate() {
  cat >/etc/logrotate.d/golden-image <<EOF
${GI_LOG_DIR}/*.log {
    weekly
    rotate 8
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root adm
}
EOF
}

gi_configure_bash_completion() {
  gi_apt_install bash-completion
}

# Only run bootstrap when executed directly (not sourced for tests)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  gi_info "common.sh is a library — source it from install.sh or package scripts."
fi
