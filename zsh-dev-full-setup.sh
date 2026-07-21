#!/usr/bin/env bash
# Legacy wrapper → unified root installer (developer full stack)
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$ROOT/install.sh" --dev "$@"
