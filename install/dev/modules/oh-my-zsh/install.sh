#!/usr/bin/env bash
# Install Oh My Zsh (unattended).
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "Installing Oh My Zsh..."
need_cmd curl
need_cmd zsh || warn "zsh not found yet — install 'system' first"

if [ -d "$HOME/.oh-my-zsh" ]; then
  ok "Oh My Zsh already installed"
  exit 0
fi

RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

ok "Oh My Zsh installed"
