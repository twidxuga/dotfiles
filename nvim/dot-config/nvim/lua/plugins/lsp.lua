return {
  {
    "nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false,
        -- signs = false,
      },
      servers = {
        bashls = {
          filetypes = { "sh", "zsh" },
        },
        eslint = {
          settings = {
        --     -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
            -- workingDirectories = { mode = "auto" },
            workingDirectories = { mode = "local" },
        --     experimental = {
        --       -- allows to use flat config format
        --       useFlatConfig = true,
        --     },
          },
          -- root_dir = require('lspconfig.util').find_git_ancestor
          root_dir = (function() return vim.fs.dirname(vim.fs.find('.git', { path = vim.api.nvim_buf_get_name(0), upward = true })[1])end)
        },
      },
    },
  },
  -- Mason workaround
  --
  -- { "mason-org/mason.nvim", version = "^1.0.0" },
  -- { "mason-org/mason-lspconfig.nvim", version = "^1.0.0" },
  -- https://github.com/LazyVim/LazyVim/issues/6039
  {
    -- "williamboman/mason.nvim",
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "js-debug-adapter",
        "prettier",
      },
      registries = {
          "github:mason-org/mason-registry", -- main mason
          "github:Crashdummyy/mason-registry", -- required for rosly
      },
    }
  },
  {
    -- "williamboman/mason-lspconfig.nvim",
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "eslint", -- "eslint-lsp",
        "ts_ls" -- "typescript-language-server"
      },
    }
  },
  { -- lsp virtualenv select
    "linux-cultist/venv-selector.nvim",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap-python" },
    -- branch = "main",
    opts = {
      -- Your options go here
      -- name = "venv",
      -- auto_refresh = false
      dap_enabled = true, -- requires debugpy
    },
    event = "VeryLazy", -- Optional: needed only if you want to type `:VenvSelect` without a keymapping
    -- keys = {
    --   -- Keymap to open VenvSelector to pick a venv.
    --   { '<leader>vs', '<cmd>VenvSelect<cr>' },
    --   -- Keymap to retrieve the venv from a cache (the one previously used for the same project directory).
    --   { '<leader>vc', '<cmd>VenvSelectCached<cr>' },
    -- },
  },
  { -- explicitly add blink even if also added via extras
    "saghen/blink.cmp",
    dependencies = {
      "Kaiser-Yang/blink-cmp-avante",
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      sources = {
        default = { "lsp", "avante", "path", "snippets", "buffer" },
        providers = {
          avante = {
            module = "blink-cmp-avante",
            name = "Avante",
            opts = {
              -- options for blink-cmp-avante
            },
          },
        },
      },
    }
  },
  {
    "seblyng/roslyn.nvim",
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {
      broad_search = true -- default is false
        -- your configuration comes here; leave empty for default settings
    },
  }
}
