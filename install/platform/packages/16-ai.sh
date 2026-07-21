#!/usr/bin/env bash
# packages/16-ai.sh — Hugging Face CLI and related Python tooling.
set -Eeuo pipefail
GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GI_ROOT
GI_PACKAGE="ai"
GI_PACKAGE_DESC="Hugging Face CLI (huggingface_hub)"
# shellcheck source=../common.sh
source "${GI_ROOT}/common.sh"

gi_install() {
  gi_ensure_pipx
  gi_ensure_uv

  pipx install huggingface_hub --force 2>/dev/null || pipx install "huggingface_hub[cli]"
  ln -sf /root/.local/bin/huggingface-cli /usr/local/bin/huggingface-cli 2>/dev/null || true
  ln -sf /root/.local/bin/hf /usr/local/bin/hf 2>/dev/null || true

  gi_register_rollback "pipx uninstall huggingface_hub 2>/dev/null || true"
  GI_INSTALLED_VERSION="$(hf --version 2>/dev/null || huggingface-cli --version 2>/dev/null || echo hf-cli)"
}

gi_uninstall() {
  pipx uninstall huggingface_hub 2>/dev/null || true
  rm -f /usr/local/bin/huggingface-cli /usr/local/bin/hf
}

gi_verify() {
  gi_have_cmd hf || gi_have_cmd huggingface-cli || { gi_error "Hugging Face CLI missing"; return 1; }
  gi_success "Hugging Face CLI OK"
}

gi_package_main "${1:-install}"
