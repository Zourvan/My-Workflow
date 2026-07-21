#!/usr/bin/env bash
# Set Zsh as the login shell (optional session switch).
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "Checking default shell..."

ZSH_PATH="$(command -v zsh || true)"
if [ -z "$ZSH_PATH" ]; then
  die "zsh not found — install module 'system' first"
fi

CURRENT="$(getent passwd "$USER" | cut -d: -f7 || true)"
if [ "$CURRENT" = "$ZSH_PATH" ]; then
  ok "Zsh already set as default shell"
else
  log "Setting Zsh as default shell..."
  if [ -t 0 ] && chsh -s "$ZSH_PATH"; then
    ok "Default shell changed to Zsh (log out / restart terminal to apply)"
  else
    warn "Could not change shell (permission or managed account)"
    cat <<'EOF'
[Manual] Add this to ~/.bashrc so interactive bash sessions switch to zsh:

case $- in
  *i*)
    if command -v zsh >/dev/null 2>&1 && [ -z "$ZSH_VERSION" ]; then
      exec zsh
    fi
  ;;
esac
EOF
  fi
fi

if [ "${SWITCH_TO_ZSH:-0}" = "1" ] && [ -t 0 ] && [ -z "${ZSH_VERSION:-}" ]; then
  log "Switching current session to Zsh..."
  exec zsh
fi
