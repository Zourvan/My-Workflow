#!/usr/bin/env bash
# Upgrade platform services (delegates to install/platform/update.sh)
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec sudo bash "${ROOT}/install/platform/update.sh" "$@"
