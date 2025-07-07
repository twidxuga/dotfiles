return {
  {
    "Exafunction/windsurf.nvim",
    -- enabled = (vim.fn.has('macunix') == 0),
    enabled = true,
    dependencies = {
        "nvim-lua/plenary.nvim",
        -- "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/nvim-cmp",
    },
    -- opts = {
    --   enable_chat = true,
    --   -- enable_cmp_source = false -- virtual text only
    -- },
    config = function()
        -- Dynamically check if nvim-cmp is available.
        -- This is to prevent errors when using a completion manager other than nvim-cmp, like blink.cmp.
        local has_cmp, _ = pcall(require, "cmp")

        require("codeium").setup({
          enable_chat = true,
          -- Only enable the cmp source if nvim-cmp is loaded.
          enable_cmp_source = has_cmp,
          -- If nvim-cmp is not available, use virtual text for suggestions.
          virtual_text = {
            enabled = not has_cmp,
            -- key_bindings = {
            --   accept = false, -- handled by nvim-cmp / blink.cmp
            --   next = "<M-]>",
            --   prev = "<M-[>",
            -- },
          },
        })
      end
    },
  -- copilot can be enabled in lazy extras
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
    opts = {
      -- temporary fix for error calling tool
      -- mode = 'legacy', -- default is 'agentic' 
      -- provider = "openai",
      provider = "gemini",
      -- auto_suggestions_provider = "openai",
      auto_suggestions_provider = "gemini",
      cursor_applying_provider = "gemini",
			memory_summary_provider = "gemini",
      providers = {
        openai = {
          endpoint = "https://api.openai.com/v1",
          model = "gpt-4o", -- your desired model (or use gpt-4o, etc.)
          -- model = "gpt-4o-2024-08-06",
          -- model = "o3-mini", -- your desired model (or use gpt-4o, etc.)
          timeout = 30000, -- timeout in milliseconds
          extra_request_body = {
            temperature = 0, -- adjust if needed
            -- max_tokens = 4096,
            -- max_tokens = 16384, -- max for 4o
            max_completion_tokens = 16384, -- max for o3-mini
            -- reasoning_effort = "high" -- only supported for "o" models
            reasoning_effort = "medium" -- only supported for "o" models
          }
        },
        gemini = {
          -- @see https://ai.google.dev/gemini-api/docs/models/gemini
          -- model = "gemini-2.5-pro-exp-03-25",
          -- model = "gemini-2.5-pro-preview-05-06",
          model = "gemini-2.5-pro",
          -- model = "gemini-1.5-flash",
          temperature = 0,
          -- max_tokens = 4096,
          max_tokens = 16384,
        },
      },
      web_search_engine = {
       provider = "tavily", -- tavily, serpapi, searchapi, google or kagi
       -- provider = "google", -- tavily, serpapi, searchapi, google or kagi
      },
      mappings = {
        --- @class AvanteConflictMappings
        diff = {
          ours = "co",
          theirs = "ct",
          all_theirs = "ca",
          both = "cb",
          cursor = "cc",
          next = "]x",
          prev = "[x",
        },
        suggestion = {
          accept = "<M-a>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
        jump = {
          next = "]]",
          prev = "[[",
        },
        submit = {
          normal = "<CR>",
          insert = "<C-s>",
        },
        sidebar = {
          apply_all = "A",
          apply_cursor = "a",
          switch_windows = "<Tab>",
          reverse_switch_windows = "<S-Tab>",
        },
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      -- "echasnovski/mini.pick", -- for file_selector provider mini.pick
      -- "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      -- "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions -- replaced by blink.cmp
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      -- "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      --   -- Make sure to set this up properly if you have lazy=true
      -- {
      --   'MeanderingProgrammer/render-markdown.nvim',
      --   opts = {
      --     -- file_types = { "markdown", "Avante" },
      --     file_types = { "Avante" },
      --   },
      --   -- ft = { "markdown", "Avante" },
      --   ft = { "Avante" },
      -- },
    },
  },
  -- {
  --   -- Enabled via lazy extras 
  --   "zbirenbaum/copilot.lua",
  --   opts = {
  --     suggestion = {
  --       enabled = true,
  --       auto_trigger = false,
  --       hide_during_completion = true,
  --       debounce = 75,
  --       keymap = {
  --         accept = "<M-l>",
  --         accept_word = false,
  --         accept_line = false,
  --         next = "<M-]>",
  --         prev = "<M-[>",
  --         dismiss = "<C-]>",
  --       }
  --     }
  --   }
  -- }
}
