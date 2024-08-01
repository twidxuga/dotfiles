return {
  -- { "shaunsingh/nord.nvim" },
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
}
