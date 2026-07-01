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

-- SSH-only OSC 52 clipboard provider. This file is shared across the local
-- Linux laptop and the remote Mac; the SSH guard is what distinguishes them.
-- Outside SSH the guard is false so nvim's native provider (xclip/pbcopy)
-- stays in effect. osc52.paste() is intentionally unused: an OSC 52 read
-- query blocks until the terminal replies and hangs ~10s when it never does.
-- cached_paste returns the register contents instead, which is hang-free.
if vim.env.SSH_CONNECTION or vim.env.SSH_TTY then
  local osc52 = require("vim.ui.clipboard.osc52")

  local function cached_paste(reg)
    return function()
      return {
        vim.split(vim.fn.getreg(reg), "\n", { plain = true }),
        vim.fn.getregtype(reg),
      }
    end
  end

  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      ["+"] = cached_paste("+"),
      ["*"] = cached_paste("*"),
    },
  }
end
