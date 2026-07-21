#!/usr/bin/env bash
# Verify platform services (delegates to install/platform/verify.sh)
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec sudo bash "${ROOT}/install/platform/verify.sh" "$@"
