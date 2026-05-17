# Neovim setup guide

This folder contains [`init.lua`](./init.lua): a **VS Code–style** Neovim config built on **lazy.nvim** — file tree, buffer tabs, status line, Treesitter, Telescope fuzzy search, integrated terminal, and Tokyo Night theme.

It pairs with the Zsh stack in [`../zsh/.zshrc`](../zsh/.zshrc), which sets `EDITOR=nvim` and aliases like `v` → `nvim`.

---

## Quick start

| Step | What to do |
|------|------------|
| 1 | Install Neovim (0.9+ recommended) and **git** |
| 2 | Install **zsh** if you use the built-in terminal / shell options |
| 3 | Copy or symlink `init.lua` to `~/.config/nvim/init.lua` |
| 4 | Open Neovim once; **lazy.nvim** clones itself on first launch |
| 5 | Run `:Lazy sync` to install all plugins |
| 6 | (Optional) Run `:TSUpdate` after Treesitter installs parsers |

---

## Install this config

Neovim loads config from `~/.config/nvim/` (Linux/macOS) or `%LOCALAPPDATA%\nvim\` (Windows).

**Copy:**

```bash
mkdir -p ~/.config/nvim
cp "/path/to/My Workflow/nvim/init.lua" ~/.config/nvim/init.lua
```

**Symlink** (updates in the repo apply automatically):

```bash
mkdir -p ~/.config/nvim
ln -sf "/path/to/My Workflow/nvim/init.lua" ~/.config/nvim/init.lua
```

**Windows (PowerShell)** — example using this repo path:

```powershell
$nvimDir = "$env:LOCALAPPDATA\nvim"
New-Item -ItemType Directory -Force -Path $nvimDir | Out-Null
Copy-Item "D:\MD\Project\My Workflow\nvim\init.lua" "$nvimDir\init.lua"
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
| **Neovim** 0.9+ | Runtime |
| **git** | lazy.nvim bootstrap and plugin clones |
| **zsh** | `vim.opt.shell`, ToggleTerm default shell |
| **C compiler / build tools** | Treesitter parser builds (platform packages vary) |
| **ripgrep** (`rg`) | Telescope `live_grep` (recommended; install if grep is empty) |
| **Nerd Font** (terminal) | Icons in nvim-tree, lualine, bufferline |

`init.lua` sets the editor shell to **zsh**. On Windows without WSL, change `vim.opt.shell` and ToggleTerm’s `shell` to your preferred shell (e.g. PowerShell) or use Neovim from WSL with this file unchanged.

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
| [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim) | Colorscheme: `tokyonight-night` |
| [nvim-tree/nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | Side file explorer (width 30) |
| [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Status line |
| [akinsho/bufferline.nvim](https://github.com/akinsho/bufferline.nvim) | Buffer tabs |
| [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax + indent |
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

All behavior lives in a single file: [`init.lua`](./init.lua).

Common edits:

- **Colorscheme** — change `vim.cmd.colorscheme("tokyonight-night")` or swap the theme plugin block.
- **File tree width** — `require("nvim-tree").setup({ view = { width = 30 } })`.
- **Treesitter languages** — add names under `ensure_installed`.
- **Terminal** — `require("toggleterm").setup({ size, direction, shell, ... })`.
- **Shell** — `vim.opt.shell` at the top and ToggleTerm `shell` should match.

After edits, restart Neovim or run `:Lazy sync` if you added or removed plugins.

---

## Troubleshooting

| Issue | What to try |
|-------|-------------|
| Plugins not loading | Run `:Lazy sync`; ensure `git` is on `PATH` |
| Treesitter errors | Install a C compiler; run `:TSUpdate` |
| Telescope grep empty | Install `ripgrep` (`rg`) |
| Broken icons | Use a Nerd Font in your terminal |
| Terminal won’t open | Confirm `zsh` exists, or set `shell` to `bash` / PowerShell |
| Wrong config loaded | Check only one `init.lua` under `~/.config/nvim/` (no conflicting `init.vim`) |

---

## Related docs in this repo

- [`../zsh/readme.md`](../zsh/readme.md) — shell, `EDITOR`, aliases
- [`../readme.md`](../readme.md) — full dev environment overview

This config is intentionally **lightweight** (UI + navigation + Treesitter). It does not include LSP, completion, or debugging — add those in `init.lua` under new `lazy.setup` entries when you need them.
