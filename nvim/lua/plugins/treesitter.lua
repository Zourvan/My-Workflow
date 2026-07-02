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

local function tree_sitter_cli_ok()
  if vim.fn.executable("tree-sitter") ~= 1 then
    return false, "tree-sitter CLI not found on PATH (need 0.26.1+; see nvim/readme.md)"
  end

  local probe = vim.system({ "tree-sitter", "build", "--help" }, { text = true })
  if probe.code ~= 0 then
    return false,
      "tree-sitter CLI is too old or not the official CLI (missing `build` subcommand). "
        .. "Install 0.26.1+ and ensure `which tree-sitter` is not an old distro package. "
        .. "See nvim/readme.md"
  end

  return true
end

return {
  "nvim-treesitter/nvim-treesitter",
  -- nvim-treesitter 1.0+ does not support lazy-loading
  lazy = false,
  build = function()
    local ok, err = tree_sitter_cli_ok()
    if not ok then
      vim.notify(err, vim.log.levels.WARN)
      return
    end
    vim.cmd.TSUpdate()
  end,
  config = function()
    require("nvim-treesitter").setup({})

    local ok, err = tree_sitter_cli_ok()
    if ok then
      require("nvim-treesitter").install(parsers)
    else
      vim.notify(err, vim.log.levels.WARN)
    end

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "FileType" }, {
      desc = "Enable treesitter highlighting when a parser exists",
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
