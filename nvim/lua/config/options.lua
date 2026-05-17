local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

opt.wrap = false
opt.ignorecase = true
opt.smartcase = true

opt.termguicolors = true
opt.signcolumn = "yes"
opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 8
opt.updatetime = 50

-- zsh on Unix; PowerShell on Windows (see readme if you use WSL + zsh)
if vim.fn.has("win32") == 1 then
  opt.shell = "powershell.exe"
else
  opt.shell = "zsh"
end
