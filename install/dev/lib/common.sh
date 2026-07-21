#!/usr/bin/env bash
# Shared helpers for setup modules.

set -euo pipefail

SETUP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "$SETUP_ROOT/../.." && pwd)"
TMP_DIR="${TMPDIR:-/tmp}/my-workflow-setup-$$"

mkdir -p "$TMP_DIR"
trap 'rm -rf "$TMP_DIR"' EXIT

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
  echo "❌ Do NOT run this script with sudo"
  exit 1
fi

log()  { printf '→ %s\n' "$*"; }
ok()   { printf '✔ %s\n' "$*"; }
warn() { printf '⚠ %s\n' "$*"; }
die()  { printf '❌ %s\n' "$*" >&2; exit 1; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

clone_if_missing() {
  local url="$1" dest="$2"
  if [ -d "$dest" ]; then
    log "$dest already exists, skipping clone"
    return 0
  fi
  if git clone --depth 1 "$url" "$dest"; then
    ok "Cloned $url"
  else
    warn "Failed to clone $url"
    return 1
  fi
}

detect_arch() {
  case "$(uname -m)" in
    x86_64|amd64) echo "x86_64" ;;
    aarch64|arm64) echo "arm64" ;;
    *) die "Unsupported architecture: $(uname -m)" ;;
  esac
}

github_latest_tag() {
  local repo="$1"
  curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" \
    | grep -m1 '"tag_name"' \
    | cut -d '"' -f 4
}

append_block_if_missing() {
  local marker="$1" file="$2"
  local content="$3"
  touch "$file"
  if grep -Fq "$marker" "$file"; then
    log "Block '$marker' already in $file"
    return 0
  fi
  printf '\n%s\n' "$content" >> "$file"
  ok "Appended '$marker' to $file"
}

backup_file() {
  local file="$1"
  if [ -f "$file" ] || [ -L "$file" ]; then
    local bak="${file}.bak.$(date +%Y%m%d%H%M%S)"
    cp -a "$file" "$bak"
    log "Backup: $bak"
  fi
}

copy_tree() {
  local src="$1" dest="$2"
  [ -d "$src" ] || die "Missing source: $src"
  mkdir -p "$dest"
  if have_cmd rsync; then
    rsync -a --delete --exclude '.git' "$src/" "$dest/"
  else
    find "$dest" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
    cp -a "$src"/. "$dest"/
  fi
}
