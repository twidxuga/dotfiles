return {
  -- { "shaunsingh/nord.nvim" },
  -- { 
  --   "zenbones-theme/zenbones.nvim",
  --   -- Optionally install Lush. Allows for more configuration or extending the colorscheme
  --   -- If you don't want to install lush, make sure to set g:zenbones_compat = 1
  --   -- In Vim, compat mode is turned on as Lush only works in Neovim.
  --   dependencies = "rktjmp/lush.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   -- you can set set configuration options here
  --   -- config = function()
  --   --     vim.g.zenbones_darken_comments = 45
  --   --     vim.cmd.colorscheme('zenbones')
  --   -- end
  -- },
  {
    "gbprod/nord.nvim",
    lazy = false,
    priority = 1000,
    -- config = function()
    --   require("nord").setup({})
    --   vim.cmd.colorscheme("nord")
    -- end,
  },
  -- {
  --   "AlexvZyl/nordic.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require("nordic").load()
  --   end,
  -- },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nord",
      -- colorscheme = "nordic",
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        -- component_separators = { left = '', right = ''},
        -- section_separators = { left = '', right = ''},
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        -- lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_x = { "encoding", "fileformat" },
      },
    },
  },
  -- {
  --   'akinsho/bufferline.nvim',
  --   -- version = "*", 
  --   -- dependencies = 'nvim-tree/nvim-web-devicons',
  --   opts = {
  --     options = {
  --       -- diagnostics = "nvim_lsp"
  --       diagnostics = ""
  --     },
  --     highlights = {}
  --   },
  -- }
}
