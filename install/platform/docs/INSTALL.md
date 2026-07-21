# Installation Guide

## 1. Prepare the base VM

1. Install **Ubuntu Server 26.04 LTS** (or 24.04 LTS).
2. Create a local admin user (e.g. `devops`) with sudo access.
3. Ensure network connectivity and run system updates:

```bash
sudo apt update && sudo apt upgrade -y
```

## 2. Clone and install

```bash
git clone <repository-url>
cd My-Workflow/golden-image   # or golden-image if standalone repo
sudo ./install.sh
```

Installation takes 15–45 minutes depending on network and selected packages.

## 3. Verify

```bash
sudo ./verify.sh
sudo ./version.sh
```

## 4. Post-install (Golden Image capture)

Before capturing the template:

```bash
# Clear machine-specific state
sudo truncate -s 0 /var/log/golden-image/*.log
sudo rm -f /var/lib/golden-image/state/*.installed
history -c

# Optional: cloud-init / machine-id reset for templates
sudo cloud-init clean --logs 2>/dev/null || true
sudo rm -f /etc/machine-id
sudo systemd-machine-id-setup
```

## 5. Selective profiles

### Minimal shell workstation

```bash
sudo ./install.sh --only system,shell,git,configs
```

### DevOps engineer

```bash
sudo ./install.sh --only system,shell,git,docker,kubernetes,terraform,ansible,network,configs
```

### MLOps / AI lab

```bash
sudo ./install.sh --only system,python,docker,ai,cloud,monitoring,configs
```

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `GI_TARGET_USER` | `$SUDO_USER` or `root` | User receiving dotfile configs |
| `GI_FORCE_REINSTALL=1` | off | Force reinstall even if state marker exists |
| `GI_TIMEZONE` | `UTC` | System timezone |
| `GI_RETRY_ATTEMPTS` | `3` | Network retry count |
| `GI_CMD_TIMEOUT` | `600` | Command timeout (seconds) |

## Troubleshooting

| Issue | Action |
|-------|--------|
| Package failed | Check `/var/log/golden-image/<package>.log` |
| Docker permission denied | Confirm user in `docker` group; re-login |
| Python 3.13 missing | Package falls back to `uv python install 3.13` |
| Partial install | Re-run `sudo ./install.sh` (idempotent) |

See master log: `/var/log/golden-image/install.log`
