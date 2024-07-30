-- All markdonw related plugins
return {
  {
    "twidxuga/vim-instant-markdown",
    init = function()
      -- vim.g.instant_markdown_send_interval_secs = 1
      vim.g.instant_markdown_port = 8090
      -- vim.g.instant_markdown_autostart = 0
      -- vim.g.instant_markdown_open_to_the_world = 0
      vim.g.instant_markdown_allow_unsafe_content = 1
      vim.g.instant_markdown_allow_external_content = 1
      vim.g.instant_markdown_serve_folder_tree = 1
      vim.g.instant_markdown_serve_home_folder = 1
      -- vim.g.instant_markdown_slow = 0
    end,
  },
  {
    -- "iamcco/markdown-preview.nvim",
    "Knyffen/markdown-preview.nvim", -- includes file serving
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    -- config = function() let g:mkdp_theme = 'dark' end,
    config = function()
      vim.g.mkdp_theme = 'light'
      vim.g.mkdp_image_path = '/home/twidxuga/Documents/QuickAccess/kb/images'
    end,
  },
  { 
    -- Vivify also alows preview markdown notebooks
    -- requires vivify installed separately (AUR vivify)
    "jannis-baum/vivify.vim", 
    init = function()
      -- Refresh page contents on CursorHold and CursorHoldI
      vim.g.vivify_instant_refresh = 1
      -- Refresh page contents on CursorHold and CursorHoldI
      vim.g.vivify_instant_refresh = 0
      -- additional filetypes to recognize as markdown
      vim.g.vivify_filetypes = { 'vimwiki', }
    end,
  },
}
