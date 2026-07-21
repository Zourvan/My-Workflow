#!/usr/bin/env bash
# Install Neovim from official GitHub releases.
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "Installing Neovim..."
need_cmd curl
need_cmd tar
need_cmd sudo

if have_cmd nvim; then
  ok "Neovim already installed ($(nvim --version | head -n1))"
  exit 0
fi

NVIM_ARCH="$(detect_arch)"
NVIM_TAR="nvim-linux-${NVIM_ARCH}.tar.gz"
NVIM_DIR="nvim-linux-${NVIM_ARCH}"

cd "$TMP_DIR"
curl -fsSLO "https://github.com/neovim/neovim/releases/latest/download/${NVIM_TAR}"
sudo rm -rf "/opt/${NVIM_DIR}"
sudo tar -C /opt -xzf "$NVIM_TAR"
sudo ln -sf "/opt/${NVIM_DIR}/bin/nvim" /usr/local/bin/nvim
ok "Neovim installed → /usr/local/bin/nvim"
