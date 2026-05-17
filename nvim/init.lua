-- =====================================================
-- Neovim Professional VSCode-like Setup
-- =====================================================

----------------------------------------------------------
-- LEADER
----------------------------------------------------------
vim.g.mapleader = " "

----------------------------------------------------------
-- BASIC SETTINGS
----------------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.scrolloff = 8

vim.opt.updatetime = 50

----------------------------------------------------------
-- POWERSHELL
----------------------------------------------------------
vim.opt.shell = "zsh"

----------------------------------------------------------
-- LAZY.NVIM INSTALL
----------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

----------------------------------------------------------
-- PLUGINS
----------------------------------------------------------
require("lazy").setup({

  --------------------------------------------------------
  -- THEME
  --------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },

  --------------------------------------------------------
  -- FILE EXPLORER
  --------------------------------------------------------
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 30,
        },
      })

      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
    end,
  },

  --------------------------------------------------------
  -- STATUS LINE
  --------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("lualine").setup()
    end,
  },

  --------------------------------------------------------
  -- BUFFER TABS
  --------------------------------------------------------
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("bufferline").setup({})
    end,
  },

  --------------------------------------------------------
  -- TREESITTER
  --------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.config").setup({
        ensure_installed = {
          "lua",
          "javascript",
          "typescript",
          "python",
          "json",
          "bash",
          "html",
          "css",
        },

        highlight = {
          enable = true,
        },

        indent = {
          enable = true,
        },
      })
    end,
  },

  --------------------------------------------------------
  -- TELESCOPE
  --------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },

    config = function()
      local builtin = require("telescope.builtin")

      vim.keymap.set("n", "<leader>ff", builtin.find_files)
      vim.keymap.set("n", "<leader>fg", builtin.live_grep)
      vim.keymap.set("n", "<leader>fb", builtin.buffers)
      vim.keymap.set("n", "<leader>fh", builtin.help_tags)
    end,
  },

  --------------------------------------------------------
  -- TERMINAL
  --------------------------------------------------------
  {
    "akinsho/toggleterm.nvim",
    version = "*",

    config = function()
      require("toggleterm").setup({

        size = 12,

        open_mapping = [[<c-\>]],

        direction = "horizontal",

        shell = "zsh",

        start_in_insert = true,

        persist_size = true,
      })
    end,
  },

  --------------------------------------------------------
  -- AUTOPAIRS
  --------------------------------------------------------
  {
    "windwp/nvim-autopairs",

    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

})

----------------------------------------------------------
-- KEYMAPS
----------------------------------------------------------

-- save
vim.keymap.set("n", "<C-s>", ":w<CR>")

-- quit
vim.keymap.set("n", "<leader>q", ":q<CR>")

-- better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-q>", ":qa!<CR>")
----------------------------------------------------------
-- REMOVE SEARCH HIGHLIGHT
----------------------------------------------------------
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>")

----------------------------------------------------------
-- STARTUP
----------------------------------------------------------
vim.cmd([[
highlight Normal guibg=NONE
highlight NonText guibg=NONE
highlight Normal ctermbg=NONE
]])