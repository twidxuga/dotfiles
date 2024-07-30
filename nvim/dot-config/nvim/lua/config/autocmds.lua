-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- This function is taken from https://github.com/norcalli/nvim_utils
-- Creates augroups automatially
function nvim_create_augroups(definitions)
  for group_name, definition in pairs(definitions) do
    vim.api.nvim_command("augroup " .. group_name)
    vim.api.nvim_command("autocmd!")
    for _, def in ipairs(definition) do
      local command = table.concat(vim.iter({ "autocmd", def }):flatten():totable(), " ")
      vim.api.nvim_command(command)
    end
    vim.api.nvim_command("augroup END")
  end
end

-- Always enter terminal in insert mode
-- :au TermOpen,BufEnter * if &buftype == 'terminal' | :startinsert | endif
-- vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
--   pattern = { "*" },
--   callback = function()
--     if vim.opt.buftype:get() == "terminal" then
--       vim.cmd(":startinsert")
--     end
--   end,
-- })
-- Always leave terminal in normal mode
-- :autocmd BufLeave term://* stopinsert
-- vim.api.nvim_create_autocmd({ "BufLeave" }, {
--   pattern = { "*" },
--   callback = function()
--     if vim.opt.buftype:get() == "terminal" then
--       vim.cmd(":stopinsert")
--     end
--   end,
-- })
--
-- local function terminal_start_insert()
--   if vim.opt.buftype:get() == "terminal" then
--     vim.cmd(":startinsert")
--   end
-- end
--
-- local function terminal_stop_insert()
--   if vim.opt.buftype:get() == "terminal" then
--     vim.cmd(":stopinsert")
--   end
-- end

local autocmds = {
  -- reload_vimrc = {
  --     -- Reload vim config automatically
  --     {"BufWritePost",[[$VIM_PATH/{*.vim,*.yaml,vimrc} nested source $MYVIMRC | redraw]]};
  -- };
  -- packer = {
  --     { "BufWritePost", "plugins.lua", "PackerCompile" };
  -- };
  -- restore_cursor = {
  --     { 'BufRead', '*', [[call setpos(".", getpos("'\""))]] };
  -- };
  -- save_shada = {
  --     {"VimLeave", "*", "wshada!"};
  -- };
  -- resize_windows_proportionally = {
  --     { "VimResized", "*", ":wincmd =" };
  -- };
  -- toggle_search_highlighting = {
  --     { "InsertEnter", "*", "setlocal nohlsearch" };
  -- };
  -- lua_highlight = {
  --     { "TextYankPost", "*", [[silent! lua vim.highlight.on_yank() {higroup="IncSearch", timeout=400}]] };
  -- };
  -- ansi_esc_log = {
  --     { "BufEnter", "*.log", ":AnsiEsc" };
  -- };
  terminal_job = {
    { "TermOpen", "*", "setlocal listchars= nonumber norelativenumber" },
    { "TermOpen", "*", "if &buftype == 'terminal' | :startinsert | endif" },
    { "BufEnter", "*", "if &buftype == 'terminal' | :startinsert | endif" },
    { "BufLeave", "*", "if &buftype == 'terminal' | :stopinsert | endif" },
  },
}

nvim_create_augroups(autocmds)
-- autocommands END
