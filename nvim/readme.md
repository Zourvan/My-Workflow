# Neovim setup guide

This folder contains [`init.lua`](./init.lua): a **VS Code–style** Neovim config built on **lazy.nvim** — file tree, buffer tabs, status line, Treesitter, Telescope fuzzy search, integrated terminal, and Tokyo Night theme.

Config layout: `init.lua` plus `lua/config/` and `lua/plugins/` (lazy.nvim spec-per-file). Copy or symlink the **whole** `nvim/` folder to your Neovim config directory — not `init.lua` alone.

It pairs with the Zsh stack in [`../zsh/.zshrc`](../zsh/.zshrc), which sets `EDITOR=nvim` and aliases like `v` → `nvim`.

---

## Quick start

| Step | What to do |
|------|------------|
| 1 | Install Neovim (0.11+ recommended), **git**, and **tree-sitter** CLI (see below) |
| 2 | Install a **C compiler** for parser builds (see below) |
| 3 | Install **zsh** if you use the built-in terminal / shell options (Unix) |
| 4 | Copy or symlink the entire `nvim/` folder to `~/.config/nvim/` |
| 5 | Open Neovim once; **lazy.nvim** clones itself on first launch |
| 6 | Run `:Lazy sync` to install all plugins |
| 7 | Run `:TSUpdate` and `:checkhealth nvim-treesitter` if Treesitter was not built on sync |

---

## Install this config

Neovim loads config from `~/.config/nvim/` (Linux/macOS) or `%LOCALAPPDATA%\nvim\` (Windows).

**Copy:**

```bash
rm -rf ~/.config/nvim
cp -r "/path/to/My Workflow/nvim" ~/.config/nvim
```

**Symlink** (updates in the repo apply automatically):

```bash
ln -sfn "/path/to/My Workflow/nvim" ~/.config/nvim
```

**Windows (PowerShell)** — example using this repo path:

```powershell
$src = "D:\MD\Project\My Workflow\nvim"
$dst = "$env:LOCALAPPDATA\nvim"
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $dst
Copy-Item -Recurse $src $dst
```

First launch:

```bash
nvim
```

Inside Neovim:

```vim
:Lazy sync
```

---

## Requirements

| Dependency | Used for |
|------------|----------|
| **Neovim** 0.11+ (recommended for nvim-treesitter 1.0) | Runtime |
| **git** | lazy.nvim bootstrap and plugin clones |
| **tree-sitter-cli** (0.26.1+) | Building parsers (`nvim-treesitter` 1.0) |
| **zsh** | `vim.opt.shell`, ToggleTerm default shell (Unix; Windows uses PowerShell) |
| **C compiler / build tools** | Treesitter parser builds (platform packages vary) |
| **ripgrep** (`rg`) | Telescope `live_grep` (recommended; install if grep is empty) |
| **Nerd Font** (terminal) | Icons in nvim-tree, lualine, bufferline |

`init.lua` sets the editor shell to **zsh**. On Windows without WSL, change `vim.opt.shell` and ToggleTerm’s `shell` to your preferred shell (e.g. PowerShell) or use Neovim from WSL with this file unchanged.

### Installing tree-sitter and build tools

**nvim-treesitter 1.0** needs the **`tree-sitter`** command on your `PATH` when lazy.nvim runs the plugin `build` (`:TSUpdate`) or when parsers are installed. If it is missing, you may see:

```text
Error during "tree-sitter build": ENOENT: no such file or directory: 'tree-sitter'
```

Install these **on the machine where you run Neovim** (your dev box or CI image), then open a **new** terminal so `PATH` is refreshed.

#### 1. tree-sitter CLI (required)

Version **0.26.1+**. Verify with `tree-sitter --version`.

**Linux (Debian/Ubuntu)** — if your package manager has no suitable package, use Rust’s cargo:

```bash
sudo apt install build-essential
cargo install tree-sitter-cli --locked
tree-sitter --version
```

**Arch Linux:**

```bash
sudo pacman -S tree-sitter
tree-sitter --version
```

**macOS:**

```bash
brew install tree-sitter
tree-sitter --version
```

**Windows (PowerShell)** — use one of:

```powershell
scoop install tree-sitter
# or
choco install tree-sitter
# or (Rust toolchain required)
cargo install tree-sitter-cli --locked

tree-sitter --version
```

#### 2. C compiler (required to compile parsers)

| Platform | Install |
|----------|---------|
| Linux (Debian/Ubuntu) | `sudo apt install build-essential` |
| Arch Linux | `gcc` is usually already present; otherwise `sudo pacman -S base-devel` |
| macOS | Xcode Command Line Tools: `xcode-select --install` |
| Windows | [Visual Studio Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/) with **Desktop development with C++**, or MinGW-w64 |

#### 3. After installing

Inside Neovim:

```vim
:Lazy sync
:TSUpdate
:checkhealth nvim-treesitter
```

**Windows without WSL:** install `tree-sitter` and a C toolchain on Windows itself, or run Neovim inside WSL and install the Linux packages there. Parser builds do not run on a machine that only has the config copied but not these tools.

---

## What’s included

### Editor defaults

- **Leader:** `<Space>`
- Line numbers + relative numbers, mouse support, 2-space tabs, smart indent
- No line wrap; smart case search; sign column on
- Splits open below / right; `scrolloff = 8`; `updatetime = 50`
- Transparent Normal/NonText background (terminal wallpaper shows through)

### Plugins (via lazy.nvim)

| Plugin | Role |
|--------|------|
| [folke/lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager (auto-installed on first run) |
| [nvimdev/dashboard-nvim](https://github.com/nvimdev/dashboard-nvim) | Startup screen (hyper theme) |
| [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim) | Colorscheme: `tokyonight-night` |
| [nvim-tree/nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | Side file explorer (width 30) |
| [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Status line |
| [akinsho/bufferline.nvim](https://github.com/akinsho/bufferline.nvim) | Buffer tabs |
| [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Parsers + syntax (`vim.treesitter.start`) |
| [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy find / grep / buffers / help |
| [akinsho/toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | Horizontal terminal (zsh) |
| [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Auto-close brackets/quotes |

**Treesitter parsers** installed by default: `lua`, `javascript`, `typescript`, `python`, `json`, `bash`, `html`, `css`.

---

## Keybindings

Leader is **Space**.

### File & search

| Key | Mode | Action |
|-----|------|--------|
| `<leader>e` | Normal | Toggle file tree (nvim-tree) |
| `<leader>ff` | Normal | Find files (Telescope) |
| `<leader>fg` | Normal | Live grep (Telescope) |
| `<leader>fb` | Normal | Open buffers (Telescope) |
| `<leader>fh` | Normal | Help tags (Telescope) |

### Windows & session

| Key | Mode | Action |
|-----|------|--------|
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | Normal | Move to left / down / up / right window |
| `<C-s>` | Normal | Save (`:w`) |
| `<leader>q` | Normal | Quit current window (`:q`) |
| `<C-q>` | Normal | Quit all (`:qa!`) |
| `<Esc>` | Normal | Clear search highlight |

### Terminal

| Key | Mode | Action |
|-----|------|--------|
| `<C-\>` | Normal | Toggle terminal (ToggleTerm, horizontal, zsh, insert mode) |

Bufferline and lualine use their plugin defaults (click tabs, status segments) — customize in `init.lua` under each plugin’s `config` block.

---

## lazy.nvim commands

| Command | Purpose |
|---------|---------|
| `:Lazy` | Plugin UI |
| `:Lazy sync` | Install / update plugins |
| `:Lazy clean` | Remove unused plugins |
| `:Lazy reload` | Reload a plugin (from Lazy UI) |

Treesitter:

| Command | Purpose |
|---------|---------|
| `:TSUpdate` | Update / install parsers (also runs via plugin `build`) |
| `:TSInstall <lang>` | Install one parser |
| `:TSBufToggle highlight` | Toggle buffer highlighting |

---

## Customization

Entry point: [`init.lua`](./init.lua). Options and keymaps: `lua/config/`. Each plugin: `lua/plugins/<name>.lua`.

Common edits:

- **Colorscheme** — `lua/plugins/theme.lua`
- **File tree width** — `lua/plugins/nvim-tree.lua`
- **Treesitter languages** — `lua/plugins/treesitter.lua`
- **Terminal** — `lua/plugins/toggleterm.lua`
- **Shell** — `lua/config/options.lua` and ToggleTerm `shell` (keep in sync)

After edits, restart Neovim or run `:Lazy sync` if you added or removed plugins.

---

## Troubleshooting

| Issue | What to try |
|-------|-------------|
| Plugins not loading | Run `:Lazy sync`; ensure `git` is on `PATH` |
| `ENOENT: 'tree-sitter'` during lazy build / `:TSUpdate` | Install **tree-sitter CLI** (0.26.1+) and a **C compiler** on the host where Neovim runs; restart the terminal; run `:Lazy sync` then `:TSUpdate` (see [Installing tree-sitter and build tools](#installing-tree-sitter-and-build-tools)) |
| Treesitter errors / `ensure_installed` nil | Use nvim-treesitter 1.0 API (`:checkhealth nvim-treesitter`); install `tree-sitter` CLI + build tools; run `:TSUpdate` |
| Telescope grep empty | Install `ripgrep` (`rg`) |
| Broken icons | Use a Nerd Font in your terminal |
| Terminal won’t open | Confirm `zsh` exists, or set `shell` to `bash` / PowerShell |
| Wrong config loaded | Ensure `~/.config/nvim/init.lua` and `lua/` came from the same copy (no mixed old single-file config) |
| Lazy errors on startup | Run `:Lazy sync`; fix syntax in `lua/plugins/*.lua`; check `:messages` |

---

## Related docs in this repo

- [`../zsh/readme.md`](../zsh/readme.md) — shell, `EDITOR`, aliases
- [`../readme.md`](../readme.md) — full dev environment overview

This config is intentionally **lightweight** (UI + navigation + Treesitter). It does not include LSP, completion, or debugging — add those in `init.lua` under new `lazy.setup` entries when you need them.
