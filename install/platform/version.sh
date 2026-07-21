#!/usr/bin/env bash
# golden-image/version.sh — show framework and tool versions.

set -Eeuo pipefail

GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export GI_ROOT
# shellcheck source=common.sh
source "${GI_ROOT}/common.sh"

gi_detect_os

printf '%bGolden Image Framework%b\n' "$GI_C_BOLD" "$GI_C_RESET"
printf 'Version:    %s\n' "$(cat "$GI_VERSION_FILE" 2>/dev/null || echo unknown)"
printf 'Root:       %s\n' "$GI_ROOT"
printf 'OS:         %s %s (%s)\n' "$GI_OS_ID" "$GI_OS_VERSION" "$GI_OS_CODENAME"
printf 'Arch:       %s\n' "$GI_ARCH"
printf 'Log dir:    %s\n' "$GI_LOG_DIR"
echo

tools=(
  git curl wget zsh docker kubectl helm terraform ansible aws az gcloud
  node npm go rustc cargo python3 pipx uv poetry lazygit lazydocker
  btop http xh grpcurl tailscale wg
)

printf '%-18s %s\n' "TOOL" "VERSION"
printf '%s\n' "----------------------------------------------"
for cmd in "${tools[@]}"; do
  if gi_have_cmd "$cmd"; then
    ver="$(gi_cmd_version "$cmd" 2>/dev/null || echo installed)"
    printf '%-18s %s\n' "$cmd" "$ver"
  fi
done
