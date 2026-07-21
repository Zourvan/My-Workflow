#!/usr/bin/env bash
# Install lazydocker.
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "Installing lazydocker..."
need_cmd curl
need_cmd tar
need_cmd sudo

if have_cmd lazydocker; then
  ok "lazydocker already installed"
  exit 0
fi

ARCH="$(detect_arch)"
case "$ARCH" in
  x86_64) LD_ARCH="x86_64" ;;
  arm64)  LD_ARCH="arm64" ;;
esac

TAG="$(github_latest_tag jesseduffield/lazydocker)"
[ -n "$TAG" ] || die "Could not detect lazydocker version"

VER="${TAG#v}"
TAR="lazydocker_${VER}_Linux_${LD_ARCH}.tar.gz"
cd "$TMP_DIR"
curl -fsSLO "https://github.com/jesseduffield/lazydocker/releases/download/${TAG}/${TAR}"
tar -xzf "$TAR" lazydocker
sudo install -m 755 lazydocker /usr/local/bin/lazydocker
ok "lazydocker ${TAG} installed"
