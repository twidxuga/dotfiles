-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- --- Cell text objects
function select_cell(regex, ia)
    local prev_matchl = vim.fn.search(regex, 'bcW')
    local last_line = vim.fn.line('$')
    if prev_matchl > 0 then
      if ia == 'i' and (vim.fn.line('.') + 1) <= last_line then
        vim.cmd('+')
      end
      vim.cmd('normal! 0V')
      local pre_searchl = vim.fn.line('.')
      local next_matchl = vim.fn.search(regex, 'W')
      if ia == 'i' then
        vim.cmd('-')
      end
      if next_matchl <= pre_searchl then
        vim.cmd('normal! 0V')
      end
    end
end

vim.api.nvim_set_keymap('o', "ix", ":<c-u>lua select_cell('^###', 'i')<cr>", { noremap = true, silent = false, desc = "inner cell text object" })
vim.api.nvim_set_keymap('x', "ix", ":<c-u>lua select_cell('^###', 'i')<cr>", { noremap = true, silent = false, desc = "inner cell text object" })
vim.api.nvim_set_keymap('o', "ax", ":<c-u>lua select_cell('^###', 'a')<cr>", { noremap = true, silent = false, desc = "inner cell text object" })
vim.api.nvim_set_keymap('x', "ax", ":<c-u>lua select_cell('^###', 'a')<cr>", { noremap = true, silent = false, desc = "inner cell text object" })
-- vim.api.nvim_set_keymap('x', "ix", '?^###<cr>:<c-u>normal! j<esc>Vnk', { noremap = false, silent = false, desc = "Inner cell text object" })

-- Telescope keymaps
vim.keymap.set("n", "<C-p>", ":FzfLua buffers<cr>", { silent = true, desc = "Show buffers" })
-- telescope frecency (deprecated, use <leader>fr instead)
-- vim.keymap.set("n", "<leader>sf", ":Telescope frecency<cr>", { silent = true, desc = "Show buffers" })

-- Remap lsp hover
vim.keymap.set("n", "gh", ":lua vim.lsp.buf.hover()<cr>", { silent = true, desc = "Show hover info" })

-- Remap J K
local keys = require("lazyvim.plugins.lsp.keymaps").get()
keys[#keys + 1] = { "K", false }
-- vim.keymap.set({ "n", "x" }, "J", "15jzz", { silent = true, desc = "Scroll down" })
vim.keymap.set({ "n", "x" }, "J", "<c-d>", { silent = true, desc = "Scroll down" })
-- vim.keymap.set({ "n", "x" }, "K", "15kzz", { silent = true, desc = "Scroll up" })
vim.keymap.set({ "n", "x" }, "K", "<c-u>", { silent = true, desc = "Scroll up" })

-- remap enter to noh
vim.keymap.set("n", "<cr>", "<esc>:noh<cr>", { noremap = true, silent = true, desc = "which_key_ignore" })
vim.keymap.set("v", "<cr>", "<esc>:noh<cr>", { noremap = true, silent = true, desc = "which_key_ignore" })

-- remap direction exit insert to save
vim.keymap.set({ "i", "n" }, "<M-h>", "<esc>:w<cr>", { noremap = true, silent = true, desc = "which_key_ignore" })
vim.keymap.set({ "i", "n" }, "<M-j>", "<esc>:w<cr>j", { noremap = true, silent = true, desc = "which_key_ignore" })
vim.keymap.set({ "i", "n" }, "<M-k>", "<esc>:w<cr>k", { noremap = true, silent = true, desc = "which_key_ignore" })
vim.keymap.set({ "i", "n" }, "<M-l>", "<esc>:w<cr>l", { noremap = true, silent = true, desc = "which_key_ignore" })
-- same but on mac with option key
vim.keymap.set({ "i", "n" }, "˙", "<esc>:w<cr>", { noremap = true, silent = true, desc = "which_key_ignore" })
vim.keymap.set({ "i", "n" }, "∆", "<esc>:w<cr>j", { noremap = true, silent = true, desc = "which_key_ignore" })
vim.keymap.set({ "i", "n" }, "˚", "<esc>:w<cr>k", { noremap = true, silent = true, desc = "which_key_ignore" })
vim.keymap.set({ "i", "n" }, "¬", "<esc>:w<cr>l", { noremap = true, silent = true, desc = "which_key_ignore" })

-- Remap trouble vim errors inline and hide inline hints
vim.keymap.set(
  "n",
  "<leader>xd",
  ":lua vim.diagnostic.open_float()<CR>",
  { silent = true, desc = "Expand inline diagnostic" }
)

-- Toggle diagnostics
vim.g["diagnostics_active"] = true
function Toggle_diagnostics()
    if vim.g.diagnostics_active then
        vim.g.diagnostics_active = false
        vim.diagnostic.disable()
    else
        vim.g.diagnostics_active = true
        vim.diagnostic.enable()
    end
end
vim.keymap.set('n', '<leader>xe', Toggle_diagnostics, { noremap = true, silent = true, desc = "Toggle vim diagnostics" })


-- tab mappings
vim.keymap.set("n", "<leader>1", "1gt:pwd<cr>", { silent = true, desc = "which_key_ignore" })
vim.keymap.set("n", "<leader>2", "2gt:pwd<cr>", { silent = true, desc = "which_key_ignore" })
vim.keymap.set("n", "<leader>3", "3gt:pwd<cr>", { silent = true, desc = "which_key_ignore" })
vim.keymap.set("n", "<leader>4", "4gt:pwd<cr>", { silent = true, desc = "which_key_ignore" })
vim.keymap.set("n", "<leader>5", "5gt:pwd<cr>", { silent = true, desc = "which_key_ignore" })
vim.keymap.set("n", "<leader>6", "6gt:pwd<cr>", { silent = true, desc = "which_key_ignore" })
vim.keymap.set("n", "<leader>7", "7gt:pwd<cr>", { silent = true, desc = "which_key_ignore" })
vim.keymap.set("n", "<leader>8", "8gt:pwd<cr>", { silent = true, desc = "which_key_ignore" })
vim.keymap.set("n", "<leader>9", "9gt:pwd<cr>", { silent = true, desc = "which_key_ignore" })
-- new tab workspace
vim.keymap.set("n", "<leader><tab>n", ":tabnew<cr>:tcd ", { desc = "New tab workspace" })

-- Tmux navigation keymaps
vim.keymap.set(
  { "n", "x", "t" },
  "<C-h>",
  "<cmd>lua require('tmux').move_left()<cr>",
  { silent = true, desc = "which_key_ignore" }
)
vim.keymap.set(
  { "n", "x", "t" },
  "<C-j>",
  "<cmd>lua require('tmux').move_bottom()<cr>",
  { silent = true, desc = "which_key_ignore" }
)
vim.keymap.set(
  { "n", "x", "t" },
  "<C-k>",
  "<cmd>lua require('tmux').move_top()<cr>",
  { silent = true, desc = "which_key_ignore" }
)
vim.keymap.set(
  { "n", "x", "t" },
  "<C-l>",
  "<cmd>lua require('tmux').move_right()<cr>",
  { silent = true, desc = "which_key_ignore" }
)
-- Tmux resize keymaps
vim.keymap.set(
  { "n", "x", "t" },
  "<C-M-h>",
  "<cmd>lua require('tmux').resize_left()<cr>",
  { silent = true, desc = "which_key_ignore" }
)
vim.keymap.set(
  { "n", "x", "t" },
  "<C-M-j>",
  "<cmd>lua require('tmux').resize_bottom()<cr>",
  { silent = true, desc = "which_key_ignore" }
)
vim.keymap.set(
  { "n", "x", "t" },
  "<C-M-k>",
  "<cmd>lua require('tmux').resize_top()<cr>",
  { silent = true, desc = "which_key_ignore" }
)
vim.keymap.set(
  { "n", "x", "t" },
  "<C-M-l>",
  "<cmd>lua require('tmux').resize_right()<cr>",
  { silent = true, desc = "which_key_ignore" }
)

-- Maps
vim.keymap.set(
  "n",
  "<leader>sn",
  ":redir @a | silent map | redir END | new | put a<cr>",
  { silent = true, desc = "Full normal mode maps" }
)
vim.keymap.set(
  "n",
  "<leader>si",
  ":redir @a | silent map! | redir END | new | put a<cr>",
  { silent = true, desc = "Full insert mode maps" }
)

vim.keymap.set("v", "<down>", "<Plug>FreeDragDown", { silent = true, desc = "which_key_ignore" })
vim.keymap.set("v", "<up>", "<Plug>FreeDragUp", { silent = true, desc = "which_key_ignore" })
vim.keymap.set("v", "<right>", "<Plug>FreeDragRight", { silent = true, desc = "which_key_ignore" })

-- DBUI
vim.keymap.del("n", "<leader>D") -- Remove mapping automatically added by DBUI
vim.keymap.set("n", "<leader>ds", ":DBUIToggle<cr>", { silent = true, desc = "Toggle DBUI" })
vim.keymap.set(
  "v",
  "<leader>dd",
  "<Plug>(DBUI_ExecuteQuery)",
  { silent = true, desc = "Execute visual selection query" }
)
vim.keymap.set(
  "n",
  "<leader>dd",
  "vip<Plug>(DBUI_ExecuteQuery)",
  { silent = true, desc = "Execute query in paragraph" }
)
require("which-key").add({ "<leader>d", group = "DBUI" })

-- Suda (write/read as sudo)
vim.keymap.set("n", "<leader>bW", ":SudaWrite<cr>", { silent = true, desc = "Write file as sudo" })
vim.api.nvim_create_user_command("Test", 'echo "It works!"', {})
vim.keymap.set("n", "<leader>bR", ":SudaRead ", { desc = "Read file as sudo" })

-- Twidxuga's Slimux
-- vim.keymap.set("n", "<leader>rl", ":SlimuxREPLSendLine<CR>", { silent = true, desc = "Send line to REPL" })
-- vim.keymap.set(
--   "v",
--   "<leader>rr",
--   ":SlimuxREPLSendSelection<CR>",
--   { silent = true, desc = "Send visual selection to REPL" }
-- )
-- vim.keymap.set("n", "<leader>rr", "vip:SlimuxREPLSendSelection<CR>", { silent = true, desc = "Send paragraph to REPL" })
-- vim.keymap.set("n", "<leader>rb", ":SlimuxREPLSendBuffer<CR>", { silent = true, desc = "Send paragraph to REPL" })
-- vim.keymap.set("n", "<leader>rc", ":SlimuxREPLConfigure<CR>", { silent = true, desc = "Configure REPL" })
-- require("which-key").add({ "<leader>r", group = "REPLs in tmux (Slimux)" })

-- Vim-slime
-- xmap <c-c><c-c> <Plug>SlimeRegionSend
-- nmap <c-c><c-c> <Plug>SlimeParagraphSend
-- nmap <c-c>v     <Plug>SlimeConfig
vim.keymap.set("n", "<leader>rr", "<Plug>SlimeParagraphSend", { silent = true, desc = "Send paragraph to REPL" })
vim.keymap.set("x", "<leader>rr", "<Plug>SlimeRegionSend", { silent = true, desc = "Send visual selection to REPL" })
vim.keymap.set("n", "<leader>rl", "V<Plug>SlimeRegionSend", { silent = true, desc = "Send line to REPL" })
-- vim.keymap.set("n", "<leader>rx", "vix<Plug>SlimeRegionSend", { silent = true, desc = "Send ### delimited cell to REPL" })
vim.cmd('nmap <silent> <leader>rx i<esc>vix<Plug>SlimeRegionSend`^')
require("which-key").add({ "<leader>rx", desc = "Send ### delimited cell to REPL" })
vim.keymap.set("n", "<leader>rc", "<Plug>SlimeConfig", { silent = true, desc = "Configure REPL" })
require("which-key").add({ "<leader>r", group = "Send ### delimited cell to REPL" })

-- C-a in command mode
vim.keymap.set("c", "<c-a>", "<Home>", { desc = "which_key_ignore" })
vim.keymap.set("c", "<c-l>", "<Right>", { desc = "which_key_ignore" })
vim.keymap.set("c", "<c-h>", "<Left>", { desc = "which_key_ignore" })
vim.keymap.set("c", "<c-L>", "<S-Right>", { desc = "which_key_ignore" })
vim.keymap.set("c", "<c-H>", "<S-Left>", { desc = "which_key_ignore" })

-- Show filename and root folder
vim.keymap.set("n", "<leader>#", ':echo "<c-r>%"<cr>', { silent = true, desc = "Show current file name" })
vim.keymap.set("n", "<leader>~", ":pwd<cr>", { silent = true, desc = "Show root dir" })
-- Show filename 
vim.keymap.set("n", "<leader>'", ':echo "<c-r>%"<cr>', { silent = true, desc = "Show current file name" })
vim.keymap.set("n", '<leader>"', ":pwd<cr>", { silent = true, desc = "Show root dir" })

-- Yarepl
vim.keymap.set("n", "<leader>ys", "<Plug>(REPLStart)", { silent = true, desc = "Yarepl start" })
vim.keymap.set("n", "<leader>yt", "<Plug>(REPLHideOrFocus)", { silent = true, desc = "Yarepl toggle focus" })
vim.keymap.set("n", "<leader>yz", ":REPLStart zsh<cr>", { silent = true, desc = "Yarepl start zsh" })
vim.keymap.set("n", "<leader>yl", "<Plug>(REPLSendLine)", { silent = true, desc = "Yarepl send line" })
vim.keymap.set("v", "<leader>yy", "<Plug>(REPLSendVisual)", { silent = true, desc = "Yarepl send visual selection" })
vim.keymap.set("n", "<leader>yy", "vip<Plug>(REPLSendVisual)<esc>", { silent = true, desc = "Yarepl send paragraph" })
-- vim.keymap.set("n", "<leader>yx", "vix<Plug>(REPLSendVisual)<esc>", { silent = true, desc = "Yarepl send ### delimited cell" })
vim.cmd('nmap <silent> <leader>yx vix<Plug>(REPLSendVisual)<esc>')
require("which-key").add({ "<leader>yx", desc = "Yarepl send ### delimited cell" })
vim.keymap.set("n", "<leader>yc", "<Plug>(REPLClose)", { silent = true, desc = "Yarepl close" })
require("which-key").add({ "<leader>y", group = "REPLs in vim (Yarepl)" })

-- Lua repls
vim.keymap.set("n", "<leader>ip", ":Luapad<cr>", { silent = true, desc = "Luapad start" })
vim.keymap.set("n", "<leader>ir", ":LuaRun<cr>", { silent = true, desc = "Luapad run current file" })
require("which-key").add({ "<leader>i", group = "Embedded lua REPL" })

-- toggle color column
-- vim.cmd([[ let &colorcolumn=join(range(81,999),",") ]])
vim.keymap.set("n", "<leader>ut", 
  function()
    if vim.wo.colorcolumn == "" then
      vim.wo.colorcolumn = vim.fn.join(vim.fn.range(81,999),",")
    else
      vim.wo.colorcolumn = ""
    end
  end,
  { desc = "Toggle color column" }
)

-- Copy current file name
vim.keymap.set("n", "<leader>cp", ":let @+=expand('%')<cr>", { silent = true, desc = "Copy relative file path" })
vim.keymap.set("n", "<leader>ct", ":let @+=expand('%:t')<cr>", { silent = true, desc = "Copy only file name" })
vim.keymap.set("n", "<leader>cP", ":let @+=expand('%:p')<cr>", { silent = true, desc = "Copy full file path" })

-- venv-selector keymaps
vim.keymap.set("n", "<leader>vs", "<cmd>VenvSelect<cr>", { silent = true, desc = "Select Python Venv for LSP" })
vim.keymap.set("n", "<leader>vc", "<cmd>VenvSelectCached<cr>", { silent = true, desc = "Use Cached Python Venv for LSP" })
require("which-key").add({ "<leader>v", group = "Venv Selector for Python" })

-- nvim-dap keymaps
vim.keymap.set('n', '<leader>nc', function()
  local dap, dapui = require("dap"), require("dapui")
  dap.listeners.before.attach.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.launch.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
  end
  dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
  end
  dap.continue()
end, { silent = true, desc = "Debug Start/Continue" })
vim.keymap.set('n', '<leader>ns', function() require('dap').step_over() end, { silent = true, desc = "Step Over" })
vim.keymap.set('n', '<leader>ni', function() require('dap').step_into() end, { silent = true, desc = "Step Into" })
vim.keymap.set('n', '<leader>no', function() require('dap').step_out() end, { silent = true, desc = "Step Out" })
vim.keymap.set('n', '<leader>nb', function() require('dap').toggle_breakpoint() end, { silent = true, desc = "Toggle Breakpoint" })
vim.keymap.set('n', '<leader>nB', function() require('dap').set_breakpoint() end, { silent = true, desc = "Set Breakpoint" })
vim.keymap.set('n', '<Leader>nP', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, { silent = true, desc = "Set Breakpoint with Message" })
vim.keymap.set('n', '<Leader>nr', function() require('dap').repl.open() end, { silent = true, desc = "Open REPL" })
vim.keymap.set('n', '<Leader>nl', function() require('dap').run_last() end, { silent = true, desc = "Run Last" })
vim.keymap.set({'n', 'v'}, '<Leader>nh', function()
  require('dap.ui.widgets').hover()
end, { silent = true, desc = "Hover (:q to dismiss)" })
vim.keymap.set({'n', 'v'}, '<Leader>np', function()
  require('dap.ui.widgets').preview()
end, { silent = true, desc = "Preview (:q to dismiss)" })
vim.keymap.set('n', '<Leader>nf', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.frames)
end, { silent = true, desc = "Frames (:q to dismiss)" })
vim.keymap.set('n', '<Leader>nS', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.scopes)
end, { silent = true, desc = "Scopes (:q to dismiss)" })
vim.keymap.set('n', '<leader>nu', function() require('dapui').toggle() end, { silent = true, desc = "Toggle Debug UI (dapui e o d r t)"})
-- Test methods
vim.keymap.set('n', '<leader>ntm', function() require('dap-python').test_method() end, { silent = true, desc = "Debug Method" })
vim.keymap.set('n', '<leader>ntc', function() require('dap-python').test_class() end, { silent = true, desc = "Debug Class" })
require("which-key").add({ "<leader>nt", group = "Debug test method/class" })
require("which-key").add({ "<leader>n", group = "Debug (nvim-dap)" })

-- rename.vim shortcut
vim.keymap.set('n', '<F2>', ":let @r=expand('%:t')<cr>:Rename <c-r>r", { silent = false, desc = "which_key_ignore"})

-- Run copied line in command prompt
vim.keymap.set('n', '<leader>cv', 'yy:<c-r>"<cr>', { noremap = true, silent = false, desc = "Run line in command prompt" })
-- send selection to command prompt (e.g. multiline functions, but not good for a sequence of commands) 
vim.keymap.set('v', '<leader>cv', 'y:<c-r>"<cr>', { noremap = true, silent = false, desc = "Send selection to command prompt" })


-- -- Convert python to ipynb (moved to autocommands)
-- vim.keymap.set('n', '<leader>ci', ':!jupytext --to notebook <c-r>%<cr>', { noremap = true, silent = true, desc = "Convert python to ipynb"})
-- -- convert ipynb to python
-- vim.keymap.set('n', '<leader>cy', ':!jupyter nbconvert --to python <c-r>%<cr>', { noremap = true, silent = true, desc = "Convert ipynb to python"})

-- Keybindings to snack notifications
--lua Snacks.notifier.show_history()
vim.keymap.set('n', '<leader>m', ":lua Snacks.notifier.show_history()<cr>", { silent = true, desc = "Show all notifications (snack)" })

