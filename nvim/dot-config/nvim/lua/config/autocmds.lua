-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Under SSH, route ALL clipboard-affecting operations (yank AND delete/change/
-- put) through the + register so they emit OSC 52 to the local machine. The
-- only mechanism that captures deletes is clipboard=unnamedplus (there is no
-- TextDeletePost autocmd), combined with the OSC 52 provider set in
-- options.lua whose copy['+'] fires on every + register write.
--
-- The catch: LazyVim sets clipboard="" under SSH_CONNECTION and saves/clears/
-- restores it around VeryLazy, clobbering anything we set in options.lua. So
-- we re-assert it on LazyVimStarted, which fires AFTER that restore. The
-- OptionSet guard re-applies it once if any later plugin clears it again.
if vim.env.SSH_CONNECTION or vim.env.SSH_TTY or vim.env.SSH_CLIENT then
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyVimStarted",
    once = true,
    callback = function()
      vim.opt.clipboard = "unnamedplus"
    end,
  })

  vim.api.nvim_create_autocmd("OptionSet", {
    pattern = "clipboard",
    callback = function()
      if vim.o.clipboard == "" then
        vim.schedule(function()
          vim.opt.clipboard = "unnamedplus"
        end)
      end
    end,
  })
end

-- This function is taken from https://github.com/norcalli/nvim_utils
-- Creates augroups automatially
local function nvim_create_augroups(definitions)
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

-- Avante input navigation keymaps
vim.api.nvim_create_autocmd("FileType", {
  pattern = "AvanteInput",
  callback = function(args)
    -- the following keymaps require tmux.nvim to be installed
    vim.keymap.set("i", "<C-k>", function() require('tmux').move_top() end, {
      buffer = args.buf,
      silent = true,
      noremap = true,
      desc = "Avante: switch to pane above",
    })
    vim.keymap.set("i", "<C-j>", function() require('tmux').move_bottom() end, {
      buffer = args.buf,
      silent = true,
      noremap = true,
      desc = "Avante: switch to pane below",
    })
    vim.keymap.set("i", "<C-h>", function() require('tmux').move_left() end, {
      buffer = args.buf,
      silent = true,
      noremap = true,
      desc = "Avante: switch to pane left",
    })
    vim.keymap.set("i", "<C-l>", function() require('tmux').move_right() end, {
      buffer = args.buf,
      silent = true,
      noremap = true,
      desc = "Avante: switch to pane right",
    })
  end,
  desc = "Custom Avante keymap for input buffer",
})

-- autocommands END

