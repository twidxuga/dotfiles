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

local autocmds = {
  terminal_job = {
    { "TermOpen", "*", "setlocal listchars= nonumber norelativenumber" },
    { "TermOpen", "*", "if &buftype == 'terminal' | :startinsert | endif" },
    { "BufEnter", "*", "if &buftype == 'terminal' | :startinsert | endif" },
    { "BufLeave", "*", "if &buftype == 'terminal' | :stopinsert | endif" },
    { "BufEnter", "*", "if &filetype == 'markdown' | :startinsert | endif" },
  },
}

nvim_create_augroups(autocmds)
-- autocommands END

