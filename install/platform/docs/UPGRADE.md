# Upgrade Guide

## Full upgrade pass

Updates apt packages and re-runs upgrade hooks for all Golden Image modules:

```bash
cd golden-image
sudo ./update.sh
sudo ./verify.sh
```

## Upgrade specific packages

```bash
sudo ./update.sh --only docker,python,kubernetes,terraform
```

## Force reinstall (vendor binary refresh)

When a module installs from GitHub releases or vendor repos:

```bash
sudo GI_FORCE_REINSTALL=1 ./install.sh --only go,rust,tui
```

## apt-based components

System packages are upgraded via:

```bash
sudo apt update && sudo apt upgrade -y
```

Included in `update.sh` automatically.

## Version pinning

To pin a tool version, edit the corresponding `packages/NN-name.sh` script
(e.g. Kubernetes apt repo version, NodeSource major version) and re-run install.

Document changes in `CHANGELOG.md`.

## CI / automated upgrades

```bash
#!/usr/bin/env bash
set -euo pipefail
cd /opt/golden-image
git pull --ff-only
sudo ./update.sh
sudo ./verify.sh --json
```

Exit code non-zero if verification fails.
