#!/usr/bin/env bash
# Install Oh My Zsh plugins + Powerlevel10k theme.
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "Installing Zsh plugins..."
need_cmd git

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  die "Oh My Zsh not found. Install module 'oh-my-zsh' first."
fi

mkdir -p "$ZSH_CUSTOM/plugins" "$ZSH_CUSTOM/themes"

clone_if_missing https://github.com/zsh-users/zsh-autosuggestions \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone_if_missing https://github.com/zsh-users/zsh-completions \
  "$ZSH_CUSTOM/plugins/zsh-completions"
clone_if_missing https://github.com/romkatv/powerlevel10k \
  "$ZSH_CUSTOM/themes/powerlevel10k"

ok "Zsh plugins ready"
