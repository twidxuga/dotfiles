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
      },
    },
  },
  -- formatters, etc
  -- {
  --   "williamboman/mason.nvim",
  --   opts = {
  --     ensure_installed = {
  --       -- "xmlformatter",
  --       "eslint_d"
  --     },
  --   },
  -- },
  -- -- Language servers
  -- {
  --   "williamboman/mason-lspconfig.nvim",
  --   opts = {
  --     -- required by venv-selector
  --     ensure_installed = {},
  --   }
  -- },
  -- {
  --   "mfussenegger/nvim-lint",
  --   event = {
  --     "BufReadPre",
  --     "BufNewFile",
  --   },
  --   config = function()
  --     local lint = require("lint")
  --
  --     lint.linters_by_ft = {
  --       javascript = { "eslint_d" },
  --       typescript = { "eslint_d" },
  --       javascriptreact = { "eslint_d" },
  --       typescriptreact = { "eslint_d" },
  --       -- svelte = { "eslint_d" },
  --       -- kotlin = { "ktlint" },
  --       -- terraform = { "tflint" },
  --     }
  --
  --     local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
  --
  --     vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  --       group = lint_augroup,
  --       callback = function()
  --         lint.try_lint()
  --       end,
  --     })
  --
  --     -- vim.keymap.set("n", "<leader>ll", function()
  --     --   lint.try_lint()
  --     -- end, { desc = "Trigger linting for current file" })
  --   end,
  -- },
  -- -- lsp virtualenv select
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap-python" },
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
}
