#!/usr/bin/env bash
# Install lazygit.
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "Installing lazygit..."
need_cmd curl
need_cmd tar
need_cmd sudo

if have_cmd lazygit; then
  ok "lazygit already installed"
  exit 0
fi

ARCH="$(detect_arch)"
case "$ARCH" in
  x86_64) LG_ARCH="x86_64" ;;
  arm64)  LG_ARCH="arm64" ;;
esac

TAG="$(github_latest_tag jesseduffield/lazygit)"
[ -n "$TAG" ] || die "Could not detect lazygit version"

VER="${TAG#v}"
TAR="lazygit_${VER}_Linux_${LG_ARCH}.tar.gz"
cd "$TMP_DIR"
curl -fsSLO "https://github.com/jesseduffield/lazygit/releases/download/${TAG}/${TAR}"
tar -xzf "$TAR" lazygit
sudo install -m 755 lazygit /usr/local/bin/lazygit
ok "lazygit ${TAG} installed"
