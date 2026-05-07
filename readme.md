#  README.md

#  Full Dev Environment (Ubuntu ZSH + Neovim IDE Stack)

This repository provides a **fully automated development environment setup script** for Ubuntu that transforms a fresh system into a modern terminal-based IDE environment.

It includes:

- Zsh + Oh My Zsh shell
- Powerlevel10k prompt
- Neovim (fully configured IDE)
- LSP + autocomplete + debugging
- fuzzy finder (fzf)
- smart navigation (zoxide)
- file manager (Superfile)
- Git UI (lazygit)
- Docker UI (lazydocker)
- integrated workflows between all tools

---

#  Features Overview

##  Shell (Zsh)
- Oh My Zsh framework
- Powerlevel10k theme
- autosuggestions + syntax highlighting
- modern aliases and productivity shortcuts

##  Navigation
- **zoxide** â†’ smarter `cd`
- fuzzy directory switching
- Superfile file manager

##   Neovim IDE
Fully configured IDE experience with:

- LSP (language intelligence)
- Autocomplete (nvim-cmp)
- Treesitter (advanced syntax parsing)
- Telescope (fuzzy search)
- Neo-tree (file explorer)
- ToggleTerm (embedded terminal)
- Debugging (DAP)
- Formatting tools

##  Developer Tools
- lazygit (Git TUI)
- lazydocker (Docker TUI)
- fzf (fuzzy finder)
- ripgrep (fast search)
- bat (syntax highlighting cat replacement)

---

# Libraries and Packages Used

This repository installs and configures the following tools, packages, and plugins:

- **System packages**: `zsh`, `git`, `curl`, `wget`, `fzf`, `bat`, `fd-find`, `ripgrep`, `lsof`, `build-essential`, `python3`, `python3-pip`, `unzip`, `eza` , `btop` , `ninja-build`, `cmake`, `gettext`, `fonts-powerline`
- **Zsh shell components**: `oh-my-zsh`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions`, `powerlevel10k`
- **External utilities**: `zoxide`, `lazygit`, `lazydocker`, `Superfile`, `Neovim`
- **Neovim plugins**:
  - `nvim-neo-tree/neo-tree.nvim`
  - `nvim-lua/plenary.nvim`
  - `nvim-tree/nvim-web-devicons`
  - `MunifTanjim/nui.nvim`
  - `nvim-telescope/telescope.nvim`
  - `nvim-treesitter/nvim-treesitter`
  - `williamboman/mason.nvim`
  - `williamboman/mason-lspconfig.nvim`
  - `neovim/nvim-lspconfig`
  - `hrsh7th/nvim-cmp`
  - `hrsh7th/cmp-nvim-lsp`
  - `lewis6991/gitsigns.nvim`
  - `kdheepak/lazygit.nvim`
  - `akinsho/toggleterm.nvim`
  - `mfussenegger/nvim-dap`
  - `stevearc/conform.nvim`

---

#  Installation

## 1. Use the setup script in this repo

The setup entrypoint for this project is:

```bash
curl -fsSL https://raw.githubusercontent.com/Zourvan/My-Workflow/main/zsh-dev-full-setup.sh | bash
```

If you just cloned the repository, run:

```bash
chmod +x zsh-dev-full-setup.sh
./zsh-dev-full-setup.sh
```

> **Important Note:** Do not run the script with `sudo`, as it applies settings for the root user and may cause errors. Run it as your regular user.

> **LDAP/AD Note:** If your user is managed externally (LDAP/AD), `chsh` may fail with a message like `user does not exist in /etc/passwd`. In that case, run `chsh -s $(command -v zsh)` manually (or ask your admin to set your login shell), then log out and sign in again.

## 2. Restart shell

```bash
exec zsh
```

## 3. Setup Neovim plugins

Open Neovim:

```bash
nvim
```

Then run:

```vim
:Lazy sync
```

---

#   Neovim Key Features

## Core Keybindings

|Key|Action|
|---|---|
|`<leader>ff`|Find files (Telescope)|
|`<leader>fg`|Live grep search|
|`<leader>e`|File explorer (Neo-tree)|
|`<leader>lg`|Open lazygit|
|`<leader>t`|Toggle terminal|

---

## External Tool Integration

|Key|Action|
|---|---|
|`<leader>sf`|Open Superfile|
|`<leader>z`|Jump project via zoxide + open Neovim|

---

# ­ Navigation Tools

## zoxide (smart cd replacement)

Instead of:

```bash
cd long/path/to/project
```

Use:

```bash
z project
```

Or interactive:

```bash
zi
```

---

## Superfile (spf)

File manager:

```bash
spf .
```

Alias:

```bash
sf
```

Open file in editor:

```bash
sfe
```

---

## fzf (fuzzy finder)

Fuzzy search files:

```bash
ffz
```

---

#  Git Workflow

## lazygit

Start UI:

```bash
lazygit
```

Alias:

```bash
lg
```

## lazydocker

Start UI:

```bash
lazydocker
```

---

#  Neovim IDE Stack

## Installed plugins

### Core IDE

- nvim-lspconfig
- mason.nvim (LSP installer)
- nvim-cmp (autocomplete)

### Syntax

- treesitter

### Navigation

- telescope.nvim
- neo-tree.nvim

### Git

- gitsigns.nvim
- lazygit.nvim

### Productivity

- toggleterm.nvim
- conform.nvim (formatting)
- nvim-dap (debugging)

---

#   Language Support

Out of the box:

- Python
- JavaScript / TypeScript
- Lua
- Bash

You can extend via:

```vim
:Mason
```

---

# Debugging (DAP)

Supports:

- breakpoints
- step over / into / out
- variable inspection

---

#  Environment Aliases

## File tools

```bash
sf     # Superfile
spf .  # open file manager
```

## Editor

```bash
nvim
v
```

## Git

```bash
lg
```

## Navigation

```bash
z <dir>
zi
```

---

#  Workflow Examples

## Open project fast

```bash
z my-project
nvim .
```

or:

```bash
spf .
```

---

## Search codebase

```bash
ffz
```

or inside Neovim:

```
<leader>fg
```

---

## Git workflow

```bash
lg
```

inside Neovim:

```
<leader>lg
```

---

## Edit file quickly

```bash
sfe
```

---

# © Architecture

This setup is designed as a **layered terminal IDE**:

```
ZSH (shell layer)
zoxide (navigation layer)
fzf (search layer)
Superfile (file UI layer)
```

