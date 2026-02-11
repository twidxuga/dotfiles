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
    end,
  },
  -- {
  --   'NickvanDyke/opencode.nvim',
  --   dependencies = {
  --     -- Recommended for better prompt input, and required to use `opencode.nvim`'s embedded terminal — otherwise optional
  --     { 'folke/snacks.nvim', opts = { input = { enabled = true }, picker = { enabled = true } } },
  --   },
  --   config = function()
  --     vim.g.opencode_opts = {
  --       -- Your configuration, if any — see `lua/opencode/config.lua`
  --     }
  --
  --     -- Required for `opts.auto_reload`
  --     vim.opt.autoread = true
  --
  --   end,
  -- },
  -- New opencode.nvim (sudo-tee/opencode.nvim)
  {
    "sudo-tee/opencode.nvim",
    main = "opencode",
    opts = {
      default_global_keymaps = false, -- Keymaps defined in keymaps.lua
      default_mode = "build",
      ui = {
        position = "right",
        window_width = 0.40,
        icons = {
          preset = "nerdfonts",
        },
      },
      debug = {
        enabled = true,
      },
      keymap = {
        input_window = {
          ["<leader>oS"] = {
            function()
              local state = require("opencode.state")
              local ui = require("opencode.ui.ui")
              local core = require("opencode.core")
              state.api_client:list_sessions():and_then(function(sessions)
                if not sessions or #sessions == 0 then
                  vim.notify("No sessions found", vim.log.levels.INFO)
                  return
                end
                table.sort(sessions, function(a, b) return a.time.updated > b.time.updated end)
                ui.select_session(sessions, function(selected)
                  if selected then core.switch_session(selected.id) end
                end)
              end)
            end,
            mode = "n",
            desc = "All sessions (global)",
          },
          ["<leader>oD"] = { "debug_message", desc = "Debug message" },
          ["<leader>oO"] = { "debug_output", desc = "Debug output" },
        },
        output_window = {
          ["<leader>oS"] = {
            function()
              local state = require("opencode.state")
              local ui = require("opencode.ui.ui")
              local core = require("opencode.core")
              state.api_client:list_sessions():and_then(function(sessions)
                if not sessions or #sessions == 0 then
                  vim.notify("No sessions found", vim.log.levels.INFO)
                  return
                end
                table.sort(sessions, function(a, b) return a.time.updated > b.time.updated end)
                ui.select_session(sessions, function(selected)
                  if selected then core.switch_session(selected.id) end
                end)
              end)
            end,
            mode = "n",
            desc = "All sessions (global)",
          },
          ["<leader>oD"] = { "debug_message", desc = "Debug message" },
          ["<leader>oO"] = { "debug_output", desc = "Debug output" },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          anti_conceal = { enabled = false },
          -- file_types = { "markdown", "opencode_output" },
          file_types = { "opencode_output" },
        },
        -- ft = { "markdown", "Avante", "copilot-chat", "opencode_output" },
        ft = { "opencode_output" },
      },
      -- Optional, for file mentions and commands completion, pick only one
      'saghen/blink.cmp',
      -- 'hrsh7th/nvim-cmp',

      -- Optional, for file mentions picker, pick only one
      'folke/snacks.nvim',
      -- 'nvim-telescope/telescope.nvim',
      -- 'ibhagwan/fzf-lua',
      -- 'nvim_mini/mini.nvim',
    },
  },
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "bundled_build.lua", -- Bundles `mcp-hub` binary along with the neovim plugin
    config = function()
      require("mcphub").setup({
        --- `mcp-hub` binary related options-------------------
        config = vim.fn.expand("~/.config/mcphub/servers.json"), -- Absolute path to MCP Servers config file (will create if not exists)
        port = 37373, -- The port `mcp-hub` server listens to
        shutdown_delay = 60 * 10 * 000, -- Delay in ms before shutting down the server when last instance closes (default: 10 minutes)
        use_bundled_binary = true, -- Use local `mcp-hub` binary (set this to true when using build = "bundled_build.lua")
        mcp_request_timeout = 60000, --Max time allowed for a MCP tool or resource to execute in milliseconds, set longer for long running tasks
        ---Chat-plugin related options-----------------
        auto_approve = true, -- Auto approve mcp tool calls
        auto_toggle_mcp_servers = true, -- Let LLMs start and stop MCP servers automatically
        extensions = {
          avante = {
            make_slash_commands = true, -- make /slash commands from MCP server prompts
          },
        },
        --- Plugin specific options-------------------
        native_servers = {}, -- add your custom lua native servers here
        builtin_tools = {
          edit_file = {
            parser = {
              track_issues = true,
              extract_inline_content = true,
            },
            locator = {
              fuzzy_threshold = 0.8,
              enable_fuzzy_matching = true,
            },
            ui = {
              go_to_origin_on_complete = true,
              keybindings = {
                accept = ".",
                reject = ",",
                next = "n",
                prev = "p",
                accept_all = "ga",
                reject_all = "gr",
              },
            },
          },
        },
        ui = {
          window = {
            width = 0.8, -- 0-1 (ratio); "50%" (percentage); 50 (raw number)
            height = 0.8, -- 0-1 (ratio); "50%" (percentage); 50 (raw number)
            align = "center", -- "center", "top-left", "top-right", "bottom-left", "bottom-right", "top", "bottom", "left", "right"
            relative = "editor",
            zindex = 50,
            border = "rounded", -- "none", "single", "double", "rounded", "solid", "shadow"
          },
          wo = { -- window-scoped options (vim.wo)
            winhl = "Normal:MCPHubNormal,FloatBorder:MCPHubBorder",
          },
        },
        on_ready = function(hub)
          -- Called when hub is ready
        end,
        on_error = function(err)
          -- Called on errors
        end,
        log = {
          level = vim.log.levels.WARN,
          to_file = false,
          file_path = nil,
          prefix = "MCPHub",
        },
      })
    end,
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
  --
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      -- needed to install additional parsers
      { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
      { "nvim-lua/plenary.nvim" },
      { "ravitemer/mcphub.nvim" },
      -- Test with blink.cmp (delete if not required)
      {
        "saghen/blink.cmp",
        lazy = false,
        version = "*",
        opts = {
          keymap = {
            preset = "enter",
            ["<C-p>"] = { "select_prev", "fallback" },
            ["<C-n>"] = { "select_next", "fallback" },
          },
          cmdline = { sources = { "cmdline" } },
          sources = {
            default = { "lsp", "path", "buffer", "codecompanion" },
          },
        },
      },
      -- Test with nvim-cmp
      -- { "hrsh7th/nvim-cmp" },
    },
    opts = {
      --Refer to: https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/config.lua
      strategies = {
        --NOTE: Change the adapter as required
        chat = { 
          adapter = {
            name = "gemini",
            model = "gemini-2.5-pro",
          }
        },
        inline = { adapter = "gemini" },
        cmd = { adapter = "gemini" },
      },
      extensions = {
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            make_vars = true,
            make_slash_commands = true,
            show_result_in_chat = true
          }
        }
      }
      -- opts = {
      --   log_level = "DEBUG",
      -- },
    },
  },
}
