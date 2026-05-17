local shell = vim.fn.has("win32") == 1 and "powershell.exe" or "zsh"

return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<C-\\>", "<cmd>ToggleTerm<cr>", mode = { "n", "t" }, desc = "Toggle terminal" },
  },
  config = function()
    require("toggleterm").setup({
      size = 12,
      open_mapping = [[<c-\>]],
      direction = "horizontal",
      shell = shell,
      start_in_insert = true,
      persist_size = true,
    })
  end,
}
