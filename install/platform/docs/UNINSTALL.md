# Uninstall Guide

Golden Image supports **per-package rollback** without breaking the base OS.

## Uninstall one package

```bash
sudo ./uninstall.sh docker
sudo ./uninstall.sh terraform
```

Each package registers rollback steps during install (repo lists, binaries, pipx tools).

## Uninstall multiple packages

```bash
sudo ./uninstall.sh docker kubernetes terraform cloud
```

## Uninstall everything (reverse order)

```bash
sudo ./uninstall.sh --all
```

> **Note:** The `system` package does not remove base apt packages (unsafe for OS stability).

## Manual cleanup

| Path | Purpose |
|------|---------|
| `/var/log/golden-image/` | Installation logs |
| `/var/lib/golden-image/state/` | Idempotency markers |
| `/var/lib/golden-image/rollback/` | Generated rollback scripts |
| `golden-image/cache/` | Local download cache |

```bash
sudo rm -rf /var/lib/golden-image/state/*.installed
sudo rm -rf /var/lib/golden-image/rollback/*.sh
```

## Restore configs

Configs are deployed to `/etc/skel`, `/root`, and `$GI_TARGET_HOME`.
Backups are not automatic — snapshot before install on production systems.

## Docker complete removal

```bash
sudo ./uninstall.sh docker
sudo apt purge -y docker-ce docker-ce-cli containerd.io 2>/dev/null || true
sudo rm -rf /var/lib/docker /etc/docker
```

## Verify after uninstall

```bash
sudo ./verify.sh --only docker   # should report FAIL (expected)
sudo ./version.sh
```
