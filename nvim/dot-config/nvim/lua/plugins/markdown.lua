-- All markdonw related plugins
return {
  {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {},
      -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
      dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
      -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  },
  {
    "Kicamon/markdown-table-mode.nvim",
    opts = {
      filetype = {
        '*.md',
      },
      options = {
        insert = true, -- when typeing "|"
        insert_leave = true, -- when leaving insert
      },
    },
  },
  {
    "Myzel394/easytables.nvim",
    opts = {
      table = {
          -- Whether to enable the header by default
          header_enabled_by_default = true,
          window = {
              preview_title = "Table Preview",
              prompt_title = "Cell content",
              -- Either "auto" to automatically size the window, or a string
              -- in the format of "<width>x<height>" (e.g. "20x10")
              size = "auto"
          },
          cell = {
              -- Min width of a cell (excluding padding)
              min_width = 3,
              -- Filler character for empty cells
              filler = " ",
              align = "left",
          },
          -- Characters used to draw the table
          -- Do not worry about multibyte characters, they are handled correctly
          border = {
              top_left = "┌",
              top_right = "┐",
              bottom_left = "└",
              bottom_right = "┘",
              horizontal = "─",
              vertical = "│",
              left_t = "├",
              right_t = "┤",
              top_t = "┬",
              bottom_t = "┴",
              cross = "┼",
              header_left_t = "╞",
              header_right_t = "╡",
              header_bottom_t = "╧",
              header_cross = "╪",
              header_horizontal = "═",
          }
      },
      export = {
          markdown = {
              -- Padding around the cell content, applied BOTH left AND right
              -- E.g: padding = 1, content = "foo" -> " foo "
              padding = 1,
              -- What markdown characters are used for the export, you probably
              -- don't want to change these
              characters = {
                  horizontal = "-",
                  vertical = "|",
                  -- Filler for padding
                  filler = " "
              }
          }
      },
      set_mappings = function(buf)
          vim.keymap.set(
              {"n","i"},
              "<C-e>",
              "<esc>:ExportTable<CR>",
              { buffer = buf }
          )
          vim.keymap.set(
              {"n","i"},
              "<Left>",
              "<esc>:JumpLeft<CR>",
              { buffer = buf }
          )
          vim.keymap.set(
              {"n","i"},
              "<S-Left>",
              "<esc>:SwapWithLeftCell<CR>",
              { buffer = buf }
          )
          vim.keymap.set(
              {"n","i"},
              "<Right>",
              "<esc>:JumpRight<CR>",
              { buffer = buf }
          )
          vim.keymap.set(
              {"n","i"},
              "<S-Right>",
              "<esc>:SwapWithRightCell<CR>",
              { buffer = buf }
          )
          vim.keymap.set(
              {"n","i"},
              "<Up>",
              "<esc>:JumpUp<CR>",
              { buffer = buf }
          )
          vim.keymap.set(
              {"n","i"},
              "<S-Up>",
              "<esc>:SwapWithUpperCell<CR>",
              { buffer = buf }
          )
          vim.keymap.set(
              {"n","i"},
              "<Down>",
              "<esc>:JumpDown<CR>",
              { buffer = buf }
          )
          vim.keymap.set(
              {"n","i"},
              "<S-Down>",
              "<esc>:SwapWithLowerCell<CR>",
              { buffer = buf }
          )
          vim.keymap.set(
              {"n","i"},
              "<CR>",
              "<esc>:JumpToNextCell<CR>i",
              { buffer = buf }
          )
          vim.keymap.set(
              {"n","i"},
              "<Tab>",
              "<esc>:JumpToNextCell<CR>i",
              { buffer = buf }
          )
          vim.keymap.set(
              {"n","i"},
              "<S-Tab>",
              "<esc>:JumpToPreviousCell<CR>i",
              { buffer = buf }
          )
          vim.keymap.set(
              {"n","i"},
              "<C-Left>",
              "<esc>:SwapWithLeftColumn<CR>",
              { buffer = buf }
          )
          vim.keymap.set(
              {"n","i"},
              "<C-Right>",
              "<esc>:SwapWithRightColumn<CR>",
              { buffer = buf }
          )
          vim.keymap.set(
              {"n","i"},
              "<C-Up>",
              "<esc>:SwapWithUpperRow<CR>",
              { buffer = buf }
          )
          vim.keymap.set(
              {"n","i"},
              "<C-Down>",
              "<esc>:SwapWithLowerRow<CR>",
              { buffer = buf }
          )
      end
    },
  },
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
  -- {
  --   -- "iamcco/markdown-preview.nvim",
  --   "Knyffen/markdown-preview.nvim", -- includes file serving
  --   cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  --   ft = { "markdown" },
  --   build = function() vim.fn["mkdp#util#install"]() end,
  --   -- config = function() let g:mkdp_theme = 'dark' end,
  --   config = function()
  --     vim.g.mkdp_theme = 'light'
  --     vim.g.mkdp_image_path = vim.fn.expand('$HOME') + '/Documents/QuickAccess/kb/images'
  --   end,
  -- },
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
  {
    "img-paste-devs/img-paste.vim",
    init = function()
      -- keymap autocommand added to the autocomands file
      vim.g.mdip_imgdir = 'img'
      vim.g.mdip_imgname = 'image'
    end,
  }
}
