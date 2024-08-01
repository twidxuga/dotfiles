-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Toggle maximize with leader>m
LazyVim.toggle.map("<leader>m", LazyVim.toggle.maximize)

-- Telescope keymaps
vim.keymap.set("n", "<C-p>", ":Telescope buffers<cr>", { silent = true, desc = "Show buffers" })
-- telescope frecency
vim.keymap.set("n", "<leader>sf", ":Telescope frecency<cr>", { silent = true, desc = "Show buffers" })

-- Remap lsp hover
vim.keymap.set("n", "gh", ":lua vim.lsp.buf.hover()<cr>", { silent = true, desc = "Show hover info" })

-- Remap J K
local keys = require("lazyvim.plugins.lsp.keymaps").get()
keys[#keys + 1] = { "K", false }
vim.keymap.set({ "n", "x" }, "J", "10jzz", { silent = true, desc = "Scroll down" })
vim.keymap.set({ "n", "x" }, "K", "10kzz", { silent = true, desc = "Scroll up" })

-- remap enter to noh
vim.keymap.set("n", "<cr>", "<esc>:noh<cr>", { noremap = true, silent = true, desc = "which_key_ignore" })
vim.keymap.set("v", "<cr>", "<esc>:noh<cr>", { noremap = true, silent = true, desc = "which_key_ignore" })

-- remap direction exit insert to save
vim.keymap.set({ "i", "n" }, "<M-h>", "<esc>:w<cr>", { noremap = true, silent = true, desc = "which_key_ignore" })
vim.keymap.set({ "i", "n" }, "<M-j>", "<esc>:w<cr>j", { noremap = true, silent = true, desc = "which_key_ignore" })
vim.keymap.set({ "i", "n" }, "<M-k>", "<esc>:w<cr>k", { noremap = true, silent = true, desc = "which_key_ignore" })
vim.keymap.set({ "i", "n" }, "<M-l>", "<esc>:w<cr>l", { noremap = true, silent = true, desc = "which_key_ignore" })

-- Remap trouble vim errors inline and hide inline hints
vim.keymap.set(
  "n",
  "<leader>xd",
  ":lua vim.diagnostic.open_float()<CR>",
  { silent = true, desc = "Expand inline diagnostic" }
)

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
vim.keymap.set("n", "<leader>rl", ":SlimuxREPLSendLine<CR>", { silent = true, desc = "Send line to REPL" })
vim.keymap.set(
  "v",
  "<leader>rr",
  ":SlimuxREPLSendSelection<CR>",
  { silent = true, desc = "Send visual selection to REPL" }
)
vim.keymap.set("n", "<leader>rr", "vip:SlimuxREPLSendSelection<CR>", { silent = true, desc = "Send paragraph to REPL" })
vim.keymap.set("n", "<leader>rb", ":SlimuxREPLSendBuffer<CR>", { silent = true, desc = "Send paragraph to REPL" })
vim.keymap.set("n", "<leader>rc", ":SlimuxREPLConfigure<CR>", { silent = true, desc = "Configure REPL" })
require("which-key").add({ "<leader>r", group = "REPLs in tmux (Slimux)" })

-- C-a in command mode
vim.keymap.set("c", "<c-a>", "<Home>", { desc = "which_key_ignore" })
vim.keymap.set("c", "<c-l>", "<Right>", { desc = "which_key_ignore" })
vim.keymap.set("c", "<c-h>", "<Left>", { desc = "which_key_ignore" })
vim.keymap.set("c", "<c-L>", "<S-Right>", { desc = "which_key_ignore" })
vim.keymap.set("c", "<c-H>", "<S-Left>", { desc = "which_key_ignore" })

-- Show filename and root folder
vim.keymap.set("n", "<leader>#", ':echo "<c-r>%"<cr>', { silent = true, desc = "Show current file name" })
vim.keymap.set("n", "<leader>~", ":pwd<cr>", { silent = true, desc = "Show root dir" })

-- Yarepl
vim.keymap.set("n", "<leader>ys", "<Plug>(REPLStart)", { silent = true, desc = "Yarepl start" })
vim.keymap.set("n", "<leader>yt", "<Plug>(REPLHideOrFocus)", { silent = true, desc = "Yarepl toggle focus" })
vim.keymap.set("n", "<leader>yz", ":REPLStart zsh_tmux<cr>", { silent = true, desc = "Yarepl start zsh (tmux)" })
vim.keymap.set("n", "<leader>yl", "<Plug>(REPLSendLine)", { silent = true, desc = "Yarepl send line" })
vim.keymap.set("v", "<leader>yy", "<Plug>(REPLSendVisual)", { silent = true, desc = "Yarepl send visual selection" })
vim.keymap.set("n", "<leader>yy", "vip<Plug>(REPLSendVisual)<esc>", { silent = true, desc = "Yarepl send paragraph" })
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

