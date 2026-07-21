#!/usr/bin/env bash
# Install Superfile (spf) + minimal config.
set -euo pipefail
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/common.sh
source "$(cd "$MODULE_DIR/../.." && pwd)/lib/common.sh"

log "Installing Superfile..."
need_cmd curl
need_cmd tar
need_cmd sudo

if ! have_cmd spf; then
  TAG="$(github_latest_tag yorukot/superfile)"
  [ -n "$TAG" ] || die "Could not detect Superfile version"
  VER="${TAG#v}"

  ARCH="$(uname -m)"
  case "$ARCH" in
    x86_64|amd64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) die "Unsupported architecture for Superfile: $ARCH" ;;
  esac

  TAR="superfile-linux-v${VER}-${ARCH}.tar.gz"
  cd "$TMP_DIR"
  log "Downloading Superfile ${TAG} (${ARCH})..."
  curl -fsSL -o "$TAR" \
    "https://github.com/yorukot/superfile/releases/download/${TAG}/${TAR}"
  tar -xzf "$TAR"
  sudo install -m 755 "dist/${TAR%.tar.gz}/spf" /usr/local/bin/spf
  ok "Superfile ${TAG} installed"
else
  ok "Superfile already installed"
fi

mkdir -p "$HOME/.config/superfile"
if [ ! -f "$HOME/.config/superfile/config.toml" ]; then
  cp "$MODULE_DIR/config.toml" "$HOME/.config/superfile/config.toml"
  ok "Wrote ~/.config/superfile/config.toml"
else
  log "Superfile config already exists, leaving as-is"
fi
