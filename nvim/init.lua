-- Bootstrap lazy.nvim, then load options, keymaps, and plugins.
vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local fs_stat = (vim.uv or vim.loop).fs_stat

if not fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.loader.enable()

require("config.options")
require("config.keymaps")
require("config.autocmds")

require("lazy").setup("plugins", {
  install = { colorscheme = { "tokyonight-night" } },
  checker = { enabled = true },
  change_detection = { notify = false },
})
