-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- prevent lazy vim from formating on save
vim.g.autoformat = false

-- characters for set list
vim.opt.showbreak = "↪ "
vim.opt.listchars = { eol = "↵", space = "_", nbsp = "␣", tab = "» ", trail = "-", precedes = "←", extends = "→" }
-- set list listchars=tab:>\ ,trail:-,eol:$
-- print(vim.inspect(vim.opt.listchars:get()))

-- Disable listchars by default
vim.opt.list = false

-- enable wrap by defaul
vim.opt.wrap = true

-- Create a custom highlight for Flash 
vim.api.nvim_set_hl(0, 'FlashAlternative',  { foreground = '#ffffff', background = '#0000ff' })
