#!/usr/bin/env bash
set -e

echo "========================================="
echo " FULL DEV IDE SETUP (ZSH + NVIM + TOOLCHAIN) v0.3 spf removed"
echo "========================================="

if [ "$EUID" -eq 0 ]; then
  echo "❌ Do NOT run this script with sudo"
  exit 1
fi

# --------------------------------------------------
# 1. Base system
# --------------------------------------------------

echo "[1/11] Installing system packages..."

sudo apt update
sudo apt install -y \
  zsh git curl wget fzf bat fd-find ripgrep lsof \
  build-essential python3 python3-pip \
  unzip ninja-build cmake gettext fonts-powerline eza btop

# --------------------------------------------------
# 2. Oh My Zsh
# --------------------------------------------------

echo "[2/11] Installing Oh My Zsh..."

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# --------------------------------------------------
# 3. Zsh plugins + theme
# --------------------------------------------------

echo "[3/11] Installing Zsh plugins..."

mkdir -p "$ZSH_CUSTOM/plugins"

clone_if_missing() {
  if [ ! -d "$2" ]; then
    if git clone "$1" "$2" 2>/dev/null; then
      echo "Cloned $1 successfully"
    else
      echo "Warning: Failed to clone $1 (network issue or repo unavailable)"
    fi
  else
    echo "$2 already exists, skipping clone"
  fi
}

clone_if_missing https://github.com/zsh-users/zsh-autosuggestions \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

clone_if_missing https://github.com/zsh-users/zsh-completions \
  "$ZSH_CUSTOM/plugins/zsh-completions"

clone_if_missing https://github.com/romkatv/powerlevel10k \
  "$ZSH_CUSTOM/themes/powerlevel10k"

# --------------------------------------------------
# 4. zoxide (smart cd)
# --------------------------------------------------

echo "[4/11] Installing zoxide..."

if ! command -v zoxide >/dev/null 2>&1; then
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# --------------------------------------------------
# 5. lazygit
# --------------------------------------------------

echo "[5/11] Installing lazygit..."

if ! command -v lazygit >/dev/null 2>&1; then
  LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep tag_name | cut -d '"' -f 4)

  curl -Lo lazygit.tar.gz \
    "https://github.com/jesseduffield/lazygit/releases/download/${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION#v}_Linux_x86_64.tar.gz"

  tar -xzf lazygit.tar.gz lazygit
  sudo install lazygit /usr/local/bin
  rm lazygit lazygit.tar.gz
fi

# --------------------------------------------------
# 6. lazydocker
# --------------------------------------------------

echo "[6/11] Installing lazydocker..."

if ! command -v lazydocker >/dev/null 2>&1; then
  LAZYDOCKER_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazydocker/releases/latest | grep tag_name | cut -d '"' -f 4)

  curl -Lo lazydocker.tar.gz \
    "https://github.com/jesseduffield/lazydocker/releases/download/${LAZYDOCKER_VERSION}/lazydocker_${LAZYDOCKER_VERSION#v}_Linux_x86_64.tar.gz"

  tar -xzf lazydocker.tar.gz lazydocker
  sudo install lazydocker /usr/local/bin
  rm lazydocker lazydocker.tar.gz
fi

# --------------------------------------------------
# 7. Superfile
# --------------------------------------------------

echo "[7/11] Installing Superfile..."

if ! command -v spf >/dev/null 2>&1; then
  SUPERFILE_VERSION=$(curl -s https://api.github.com/repos/MHNightCat/superfile/releases/latest | grep tag_name | cut -d '"' -f 4)
  echo "Downloading Superfile version $SUPERFILE_VERSION..."
  curl -LO "https://github.com/MHNightCat/superfile/releases/download/${SUPERFILE_VERSION}/superfile_${SUPERFILE_VERSION#v}_Linux_x86_64.tar.gz"
  tar -xzf "superfile_${SUPERFILE_VERSION#v}_Linux_x86_64.tar.gz"
  sudo install spf /usr/local/bin
  rm spf "superfile_${SUPERFILE_VERSION#v}_Linux_x86_64.tar.gz"
fi

mkdir -p "$HOME/.config/superfile"

cat > "$HOME/.config/superfile/config.toml" <<'EOF'
[ui]
show_hidden = true
show_icons = true
border = "rounded"
EOF

if command -v spf >/dev/null 2>&1; then
  spf --fix-config-file >/dev/null 2>&1 || true
fi

# --------------------------------------------------
# 8. Neovim (latest)
# --------------------------------------------------

echo "[8/11] Installing Neovim..."

if ! command -v nvim >/dev/null 2>&1; then
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
  tar -xzf nvim-linux64.tar.gz
  sudo mv nvim-linux64 /opt/nvim
  sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
  rm nvim-linux64.tar.gz
fi

# --------------------------------------------------
# 9. Neovim full IDE config
# --------------------------------------------------

echo "[9/11] Installing Neovim IDE config..."

mkdir -p "$HOME/.config/nvim/lua/config"
mkdir -p "$HOME/.config/nvim/lua/plugins"

# init.lua
cat > "$HOME/.config/nvim/init.lua" <<'EOF'
require("config.options")
require("config.keymaps")
require("config.lazy")
EOF

# options
cat > "$HOME/.config/nvim/lua/config/options.lua" <<'EOF'
vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 100
vim.opt.cursorline = true
EOF

# keymaps (tool integration)
cat > "$HOME/.config/nvim/lua/config/keymaps.lua" <<'EOF'
local map = vim.keymap.set

map("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
map("n", "<leader>lg", "<cmd>LazyGit<cr>")
map("n", "<leader>e", "<cmd>Neotree toggle<cr>")
map("n", "<leader>t", "<cmd>ToggleTerm<cr>")

map("n", "<leader>sf", function()
  os.execute("spf .")
end)

map("n", "<leader>z", function()
  os.execute("zsh -ic 'z && nvim .'")
end)
EOF

# lazy bootstrap
cat > "$HOME/.config/nvim/lua/config/lazy.lua" <<'EOF'
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git","clone","--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")
EOF

# PLUGINS: CORE IDE STACK
cat > "$HOME/.config/nvim/lua/plugins/init.lua" <<'EOF'
return {
  -- UI
  { "nvim-neo-tree/neo-tree.nvim", dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" } },

  -- Telescope
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- LSP
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig" },

  -- Autocomplete
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },

  -- Git
  { "lewis6991/gitsigns.nvim" },
  { "kdheepak/lazygit.nvim" },

  -- Terminal
  { "akinsho/toggleterm.nvim", version = "*" },

  -- Debugging (DAP)
  { "mfussenegger/nvim-dap" },

  -- Formatting
  { "stevearc/conform.nvim" },
}
EOF

# --------------------------------------------------
# 10. Zsh config (safe append)
# --------------------------------------------------

echo "[10/11] Configuring Zsh..."

ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"

append_if_missing() {
  grep -q "$1" "$ZSHRC" || echo "$2" >> "$ZSHRC"
}

append_if_missing "ZSH CORE" '
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  docker
  docker-compose
  sudo
  extract
  colored-man-pages
  command-not-found
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
)

source $ZSH/oh-my-zsh.sh
'

append_if_missing "ZOXIDE" '
eval "$(zoxide init --cmd cd zsh)"
eval "$(zoxide init zsh)"
alias cd="z"
alias cdi="zi"
'

append_if_missing "TOOLS" '
alias lg="lazygit"
alias sf="spf"
alias ff="spf ."
export EDITOR="nvim"
alias v="nvim"
'

append_if_missing "FZF SAFE" '
# =========================================
# FZF (Ubuntu-safe)
# =========================================

if command -v fdfind >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND="fdfind --type f --hidden --exclude .git"
else
  export FZF_DEFAULT_COMMAND="find . -type f"
fi

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

if [ -f /usr/share/doc/fzf/examples/completion.zsh ]; then
  source /usr/share/doc/fzf/examples/completion.zsh
fi
'

append_if_missing "ALIASES - GENERAL" '
# =========================================
# ALIASES - GENERAL
# =========================================

alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'
'

append_if_missing "GIT" '
# =========================================
# GIT
# =========================================

alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
'

append_if_missing "DOCKER" '
# =========================================
# DOCKER
# =========================================

alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dimg='docker images'
alias dlog='docker logs -f'
alias dexec='docker exec -it'

alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
'

append_if_missing "NETWORK" '
# =========================================
# NETWORK
# =========================================

alias ports='ss -tulpen'
alias myip='curl -s ifconfig.me'
alias listen='lsof -i -P -n'
'

append_if_missing "PROMPT" '
# =========================================
# PROMPT
# =========================================

export PROMPT='%F{cyan}%n@%m%f %F{yellow}%~%f %# '
'

append_if_missing "PATH" '
# =========================================
# PATH
# =========================================

export PATH="$HOME/.local/bin:$PATH"
'

append_if_missing "FZF-SPF" '
ffz() {
  local file
  file=$(fzf --preview="bat {}") || return
  [ -n "$file" ] && spf "$(dirname "$file")"
}
'

append_if_missing "NVIM INTEGRATION" '
spfedit() {
  local file
  file=$(spf --pick 2>/dev/null || true)
  [ -n "$file" ] && nvim "$file"
}
alias sfe="spfedit"
'

append_if_missing "CHPWD" '
chpwd() {
  eza --icons --group-directories-first
}
'
# --------------------------------------------------
# 11. Set Zsh as default shell and switch session
# --------------------------------------------------

echo "[*] Checking default shell..."

ZSH_PATH="$(command -v zsh)"

if [ -z "$ZSH_PATH" ]; then
  echo "❌ Zsh not found"
elif [ "$(getent passwd $USER | cut -d: -f7)" != "$ZSH_PATH" ]; then
  echo "[*] Setting Zsh as default shell..."

  if chsh -s "$ZSH_PATH" < /dev/tty 2>&1; then
    echo "✔ Default shell changed to Zsh"
    echo "⚠️ You need to log out OR restart terminal"
  else
    echo "⚠️ Could not change shell (permission or policy restriction)"
    echo -e "\033[33m[Manual Step] It looks like your account is managed externally (e.g. LDAP/AD) and may not exist in local /etc/passwd.\033[0m"
    echo -e "\033[33m[Manual Step] Open your Linux terminal and run this command manually:\033[0m"
    echo -e "\033[33m# Auto-switch to zsh for interactive shells"
    echo -e "\033[33mcase \$- in"
    echo -e "\033[33m  *i*)"
    echo -e "\033[33m    if command -v zsh >/dev/null 2>&1 && [ -z \"\$ZSH_VERSION\" ]; then"
    echo -e "\033[33m      exec zsh"
    echo -e "\033[33m    fi"
    echo -e "\033[33m  ;;"
    echo -e "\033[33mesac"
    echo -e "\033[33m[Manual Step] After shell is updated, fully log out and sign in again.\033[0m"
  fi
else
  echo "✔ Zsh already set as default shell"
fi

echo "[*] Switching current session to Zsh..."
exec zsh

# --------------------------------------------------
# 12. Finish
# --------------------------------------------------

echo "[11/11] Done!"
echo "Run: exec zsh"
echo "Then inside nvim: :Lazy sync"
echo "========================================="
