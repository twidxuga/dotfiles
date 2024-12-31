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
  },
  markdown = {
    { "BufEnter", "*.md", "silent! lua vim.diagnostic.disable(0)" },
    -- img-paste
    { "BufEnter", "*.md", 'silent! lua vim.keymap.set("n","<leader>P",":EasyTablesImportThisTable<cr>", { buffer = vim.fn.bufnr(), silent = true, desc = "Markdown Edit Table (EasyTables)" })' },
    -- EasyTables mappings for markdown buffers
    { "BufEnter", "*.md", 'silent! lua vim.keymap.set("n","<leader>ti",":EasyTablesImportThisTable<cr>", { buffer = vim.fn.bufnr(), silent = true, desc = "Markdown Edit Table (EasyTables)" })' },
    { "BufEnter", "*.md", 'silent! lua vim.keymap.set("n","<leader>tn",":let b:shape=input(\'<Cols>x<Rows>: \') | execute \'EasyTablesCreateNew \'.b:shape<cr>", { buffer = vim.fn.bufnr(), silent = true, desc = "Markdown New Table (EasyTables)" })' },
    { "BufEnter", "*.md", 'silent! lua require("which-key").add({ "<leader>t", group = "Markdown Table Edit/Create (EasyTables)" })' },
  },
  python = {
    -- Convert python to ipynb
    { "BufEnter", "*.py", 'silent! lua vim.keymap.set("n", "<leader>ci", ":!jupytext --to notebook <c-r>%<cr>", { noremap = true, silent = true, desc = "Convert python to ipynb"})' },
  },
  json = {
    -- convert ipynb to python
    { "BufEnter", "*.ipynb", 'silent! lua vim.keymap.set("n", "<leader>cy", ":!jupyter nbconvert --to python <c-r>%<cr>", { noremap = true, silent = true, desc = "Convert ipynb to python"})' },
  }
}

nvim_create_augroups(autocmds)

-- Venv autocommand to find cached venvs
vim.api.nvim_create_autocmd('VimEnter', {
  desc = 'Auto select virtualenv Nvim open',
  -- pattern = '*',
  pattern = '*.py',
  callback = function()
    local venv = vim.fn.findfile('pyproject.toml', vim.fn.getcwd() .. ';')
    if venv ~= '' then
      require('venv-selector').retrieve_from_cache()
    end
  end,
  once = true,
})

-- autocmd FileType markdown nmap <buffer><silent> <leader>p :call mdip#MarkdownClipboardImage()<CR>

-- autocommands END

