local map = vim.keymap.set

map("n", "<C-s>", ":w<CR>")
map("n", "<leader>q", ":q<CR>")
map("n", "<C-q>", ":qa!<CR>")

map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

map("n", "<Esc>", ":nohlsearch<CR>")
