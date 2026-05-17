local parsers = {
  "lua",
  "javascript",
  "typescript",
  "python",
  "json",
  "bash",
  "html",
  "css",
}

return {
  "nvim-treesitter/nvim-treesitter",
  -- nvim-treesitter 1.0+ does not support lazy-loading
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({})
    require("nvim-treesitter").install(parsers)

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "FileType" }, {
      desc = "Enable treesitter highlighting when a parser exists",
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
