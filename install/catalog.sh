#!/usr/bin/env bash
# install/catalog.sh — unified service registry (dev workstation + platform stack).
# Format: id|category|label|description|tier|script|needs_root

# shellcheck disable=SC2034
CATALOG_VERSION=1

# ── Developer workstation (install/dev/modules) ─────────────────────────────
DEV_CATALOG=(
  "system|base|System packages|apt: zsh git fzf bat ripgrep eza …|dev|modules/system/install.sh|0"
  "oh-my-zsh|shell|Oh My Zsh|Zsh framework|dev|modules/oh-my-zsh/install.sh|0"
  "zsh-plugins|shell|Zsh plugins|autosuggestions, highlighting, powerlevel10k|dev|modules/zsh-plugins/install.sh|0"
  "zoxide|shell|zoxide|Smart directory jumper|dev|modules/zoxide/install.sh|0"
  "zsh-config|config|Zsh config|Deploy zsh/.zshrc → ~/.zshrc|dev|modules/zsh-config/install.sh|0"
  "p10k|config|Powerlevel10k|Deploy p10k/.p10k.zsh|dev|modules/p10k/install.sh|0"
  "neovim|editor|Neovim|Latest Neovim binary|dev|modules/neovim/install.sh|0"
  "neovim-config|editor|Neovim config|Deploy nvim/ → ~/.config/nvim|dev|modules/neovim-config/install.sh|0"
  "tmux|editor|tmux + config|tmux, TPM, Tmux/.tmux.conf|dev|modules/tmux/install.sh|0"
  "lazygit|tools|lazygit|TUI for git|dev|modules/lazygit/install.sh|0"
  "lazydocker|tools|lazydocker|TUI for docker|dev|modules/lazydocker/install.sh|0"
  "superfile|tools|Superfile|TUI file manager (spf)|dev|modules/superfile/install.sh|0"
  "default-shell|shell|Default shell|Set zsh as login shell|dev|modules/default-shell/install.sh|0"
)

# ── Platform / DevOps (install/platform/packages) ─────────────────────────────
PLATFORM_CATALOG=(
  "gi-system|base|Platform base|CLI, locale, chrony, journald|platform|packages/00-system.sh|1"
  "gi-shell|shell|Platform shell|zsh, Oh My Zsh, p10k, zoxide, starship|platform|packages/01-shell.sh|1"
  "gi-git|base|Git + LFS|git, git-lfs, global gitconfig|platform|packages/02-git.sh|1"
  "gi-python|lang|Python 3.13|uv, pipx, poetry, black, ruff, pytest|platform|packages/03-python.sh|1"
  "gi-node|lang|Node.js LTS|NodeSource official repo|platform|packages/04-node.sh|1"
  "gi-go|lang|Go|Official go.dev release + SHA256|platform|packages/05-go.sh|1"
  "gi-rust|lang|Rust|rustup official installer|platform|packages/06-rust.sh|1"
  "gi-docker|devops|Docker|Docker CE, Compose, Buildx, Dive|platform|packages/07-docker.sh|1"
  "gi-kubernetes|devops|Kubernetes|kubectl + Helm|platform|packages/08-kubernetes.sh|1"
  "gi-terraform|devops|Terraform|HashiCorp official repo|platform|packages/09-terraform.sh|1"
  "gi-ansible|devops|Ansible|ansible-core via pipx|platform|packages/10-ansible.sh|1"
  "gi-cloud|cloud|Cloud CLIs|AWS, Azure, Google Cloud SDK|platform|packages/11-cloud.sh|1"
  "gi-security|security|Security|UFW, fail2ban, unattended-upgrades|platform|packages/12-security.sh|1"
  "gi-network|network|Network + VPN|httpie, xh, WireGuard, Tailscale|platform|packages/13-network.sh|1"
  "gi-database|data|Database clients|psql, redis-cli, mysql, sqlite3|platform|packages/14-database.sh|1"
  "gi-monitoring|ops|Monitoring|promtool, amtool|platform|packages/15-monitoring.sh|1"
  "gi-ai|ml|AI / MLOps|Hugging Face CLI|platform|packages/16-ai.sh|1"
  "gi-tui|tools|Platform TUI|LazyGit, LazyDocker, btop, dua|platform|packages/17-tui.sh|1"
  "gi-configs|config|Platform configs|git, zsh, tmux, ssh, vim, aliases|platform|packages/18-configs.sh|1"
)

# ── Presets ───────────────────────────────────────────────────────────────────
PRESET_DEV_MINIMAL=(system oh-my-zsh zsh-plugins zsh-config p10k default-shell)
PRESET_DEV_SHELL=(system oh-my-zsh zsh-plugins zoxide zsh-config p10k default-shell)
PRESET_DEV_IDE=(system neovim neovim-config lazygit superfile zoxide tmux)
PRESET_DEV_FULL=(system oh-my-zsh zsh-plugins zoxide lazygit lazydocker superfile neovim neovim-config zsh-config p10k tmux default-shell)

PRESET_DEVOPS=(gi-system gi-shell gi-git gi-docker gi-kubernetes gi-terraform gi-ansible gi-network gi-tui gi-configs)
PRESET_MLOPS=(gi-system gi-python gi-docker gi-ai gi-cloud gi-monitoring gi-configs)
PRESET_PLATFORM_FULL=(gi-system gi-shell gi-git gi-python gi-node gi-go gi-rust gi-docker gi-kubernetes gi-terraform gi-ansible gi-cloud gi-security gi-network gi-database gi-monitoring gi-ai gi-tui gi-configs)

# Short aliases for --only (map user id → catalog id)
CATALOG_ALIASES=(
  "docker:gi-docker"
  "kubernetes:gi-kubernetes"
  "k8s:gi-kubernetes"
  "terraform:gi-terraform"
  "tf:gi-terraform"
  "python:gi-python"
  "node:gi-node"
  "go:gi-go"
  "rust:gi-rust"
  "ansible:gi-ansible"
  "cloud:gi-cloud"
  "security:gi-security"
  "network:gi-network"
  "database:gi-database"
  "monitoring:gi-monitoring"
  "ai:gi-ai"
  "configs:gi-configs"
  "git:gi-git"
  "shell:gi-shell"
)

catalog_all_entries() {
  printf '%s\n' "${DEV_CATALOG[@]}" "${PLATFORM_CATALOG[@]}"
}

catalog_resolve_id() {
  local want="$1" row id alias pair
  for row in "${CATALOG_ALIASES[@]}"; do
    pair="${row#*:}"
    id="${row%%:*}"
    if [[ "$want" == "$id" ]]; then
      echo "$pair"
      return 0
    fi
  done
  echo "$want"
}

catalog_find_entry() {
  local want="$1"
  want="$(catalog_resolve_id "$want")"
  local row id
  while IFS= read -r row; do
    id="${row%%|*}"
    [[ "$id" == "$want" ]] && { echo "$row"; return 0; }
  done < <(catalog_all_entries)
  return 1
}

catalog_category_label() {
  case "$1" in
    base)    echo "Base & System" ;;
    shell)   echo "Shell" ;;
    editor)  echo "Editor & Terminal" ;;
    config)  echo "Configuration" ;;
    tools)   echo "CLI Tools" ;;
    lang)    echo "Languages" ;;
    devops)  echo "DevOps" ;;
    cloud)   echo "Cloud" ;;
    security) echo "Security" ;;
    network) echo "Network & VPN" ;;
    data)    echo "Database" ;;
    ops)     echo "Monitoring" ;;
    ml)      echo "AI / MLOps" ;;
    *)       echo "$1" ;;
  esac
}
