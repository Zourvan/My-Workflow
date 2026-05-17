-- Apply after colorscheme loads (lazy installs theme on startup).
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.cmd.highlight("Normal guibg=NONE")
    vim.cmd.highlight("NonText guibg=NONE")
    vim.cmd.highlight("Normal ctermbg=NONE")
  end,
})
