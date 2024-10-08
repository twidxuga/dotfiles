-- DBUI
return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod', lazy = true },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true }, -- Optional
  },
  -- keys = {
  --   {"v", "<leader>dd", "<Plug>(DBUI_ExecuteQuery)", { silent = true, desc = "Execute visual selection query" }},
  --   {"n", "<leader>dd", "vip<Plug>(DBUI_ExecuteQuery)", { silent = true, desc = "Execute query in paragraph" }},
  -- },
  -- cmd = {
  --   'DBUI',
  --   'DBUIToggle',
  --   'DBUIAddConnection',
  --   'DBUIFindBuffer',
  -- },
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_disable_progress_bar = 1
    vim.g.db_ui_execute_on_save = 0
    vim.g.db_ui_disable_mappings = 0
    vim.g.db_ui_disable_mappings = 0
    vim.g.db_ui_save_location = '~/Projects/DadbodDBQueries'
  end,
}
