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

-- Hybrid clipboard: OSC 52 for COPY, the native tool for PASTE. Shared across
-- the local Linux laptop and the remote Mac (terminal is wezterm on both).
--
-- COPY is unconditional OSC 52 - correct everywhere because wezterm honours it
-- whether nvim is local or over ssh:
--   * physically at a machine: local wezterm writes that machine's clipboard;
--   * over ssh: the escape rides tmux -> ssh -> tmux -> wezterm to the LOCAL
--     (client) machine's clipboard.
-- We deliberately do NOT gate copy on SSH_CONNECTION/SSH_TTY: those describe
-- how the process started, not which terminal receives output, and tmux leaks
-- a stale SSH_CONNECTION into panes (which would break a physical-at-Mac yank).
--
-- PASTE reads the REAL system clipboard of the machine RUNNING nvim, via the
-- native tool (pbpaste on macOS, xclip/xsel under X11). We can't use OSC 52
-- READ: wezterm ignores clipboard query escapes, so nvim's osc52.paste() would
-- hang ~10s then return nothing. Consequence over ssh: `p`/`"+p` read the
-- MAC's clipboard (the nvim host), while copy still lands on the LINUX client.
-- To paste the Linux clipboard into remote nvim, use wezterm paste
-- (Cmd+V / Ctrl+Shift+V); `"0p` puts the latest nvim yank specifically.
-- Plain tty (no DISPLAY, no pbpaste) falls back to an in-process cache so
-- paste never errors; that cache is why copy still mirrors into `cache`.
local osc52 = require("vim.ui.clipboard.osc52")

local cache = {
  ["+"] = { {}, "v" },
  ["*"] = { {}, "v" },
}

local function copy(reg)
  local osc52_copy = osc52.copy(reg)
  return function(lines, regtype)
    cache[reg] = { vim.deepcopy(lines), regtype }
    osc52_copy(lines, regtype)
  end
end

local function cached_paste(reg)
  return function()
    return cache[reg]
  end
end

local paste = {}

if vim.fn.has("mac") == 1 and vim.fn.executable("pbpaste") == 1 then
  paste["+"] = { "pbpaste" }
  paste["*"] = { "pbpaste" }
else
  local has_display = vim.env.DISPLAY ~= nil and vim.env.DISPLAY ~= ""

  if has_display and vim.fn.executable("xclip") == 1 then
    paste["+"] = { "xclip", "-selection", "clipboard", "-o" }
    paste["*"] = { "xclip", "-selection", "primary", "-o" }
  elseif has_display and vim.fn.executable("xsel") == 1 then
    paste["+"] = { "xsel", "--clipboard", "--output" }
    paste["*"] = { "xsel", "--primary", "--output" }
  end
end

vim.g.clipboard = {
  name = "OSC52 copy / native paste",
  copy = {
    ["+"] = copy("+"),
    ["*"] = copy("*"),
  },
  paste = {
    ["+"] = paste["+"] or cached_paste("+"),
    ["*"] = paste["*"] or cached_paste("*"),
  },
  cache_enabled = 0,
}

vim.opt.clipboard = "unnamedplus"
