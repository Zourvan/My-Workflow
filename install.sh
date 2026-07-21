#!/usr/bin/env bash
# My-Workflow — unified installer (dev workstation + DevOps / MLOps platform)
#
#   ./install.sh                    Interactive menu
#   ./install.sh --dev              Developer full stack
#   ./install.sh --devops           Docker, K8s, Terraform, …
#   ./install.sh --golden           Full Golden Image platform
#   ./install.sh --only neovim,gi-docker
#   ./install.sh --list

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export MW_ROOT="$ROOT"
export MW_INSTALL_ROOT="${ROOT}/install"
export MW_DEV_ROOT="${MW_INSTALL_ROOT}/dev"
export MW_PLATFORM_ROOT="${MW_INSTALL_ROOT}/platform"

exec bash "${MW_INSTALL_ROOT}/engine.sh" "$@"
