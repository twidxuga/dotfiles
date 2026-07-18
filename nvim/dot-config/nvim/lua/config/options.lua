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

-- Unconditional OSC 52 clipboard provider. This file is shared across the
-- local Linux laptop and the remote Mac, and the terminal on BOTH is wezterm,
-- which honours OSC 52 whether nvim is local or reached over ssh. So a single
-- OSC 52 path is correct everywhere:
--   * physically at a machine: the local wezterm receives the escape and
--     writes that machine's system clipboard;
--   * over ssh: the escape rides the tmux -> ssh -> tmux -> wezterm chain and
--     lands in the LOCAL (client) machine's clipboard.
-- We deliberately do NOT gate this on SSH_CONNECTION/SSH_TTY: those describe
-- how the process was started, not which terminal is receiving output, and
-- tmux leaks a stale SSH_CONNECTION into panes (breaking a physical-at-Mac
-- yank when the pane once had an ssh client attached).
--
-- paste is served from an in-process cache populated by the copy wrapper, not
-- from an OSC 52 read query (which blocks until the terminal replies and hangs
-- when it never does). Note: `p`/`"+p` return the last value copied THROUGH
-- this provider, not arbitrary external clipboard content; terminal paste
-- (Cmd+V / Ctrl+Shift+V) is unaffected. This asymmetry is inherent to a
-- write-only OSC 52 path and is the price of one robust code path.
local osc52 = require("vim.ui.clipboard.osc52")

local clipboard_cache = {
  ["+"] = { {}, "v" },
  ["*"] = { {}, "v" },
}

local function osc52_copy(reg)
  local inner = osc52.copy(reg)
  return function(lines, regtype)
    clipboard_cache[reg] = { vim.deepcopy(lines), regtype }
    inner(lines, regtype)
  end
end

local function cached_paste(reg)
  return function()
    return clipboard_cache[reg]
  end
end

vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = osc52_copy("+"),
    ["*"] = osc52_copy("*"),
  },
  paste = {
    ["+"] = cached_paste("+"),
    ["*"] = cached_paste("*"),
  },
}

vim.opt.clipboard = "unnamedplus"
