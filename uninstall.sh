#!/usr/bin/env bash
# Rollback platform services (delegates to install/platform/uninstall.sh)
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec sudo bash "${ROOT}/install/platform/uninstall.sh" "$@"
