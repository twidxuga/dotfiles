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
          file_types = { "markdown", "opencode_output" },
        },
        ft = { "markdown", "Avante", "copilot-chat", "opencode_output" },
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
  -- copilot can be enabled in lazy extras
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
    opts = {
      -- temporary fix for error calling tool
      -- mode = 'legacy', -- default is 'agentic'
      provider = "openai",
      -- provider = "gemini",
      -- provider = "ollama",
      auto_suggestions_provider = "gemini",
      cursor_applying_provider = "gemini",
      memory_summary_provider = "gemini",
      -- auto_suggestions_provider = "openai",
      -- cursor_applying_provider = "openai",
      -- memory_summary_provider = "openai",
      providers = {
        openai = {
          -- endpoint = "https://api.openai.com/v1",
          -- model = "gpt-4o", -- your desired model (or use gpt-4o, etc.)
          model = "gpt-5", -- your desired model (or use gpt-4o, etc.)
          -- model = "gpt-4o-2024-08-06",
          -- model = "o3-mini", -- your desired model (or use gpt-4o, etc.)
          timeout = 30000, -- timeout in milliseconds
          extra_request_body = {
            temperature = 1, -- adjust if needed
            -- stream = false,
            -- max_tokens = 4096,
            -- max_tokens = 16384, -- max for 4o
            -- max_completion_tokens = 16384, -- max for o3-mini
            -- reasoning_effort = "high" -- only supported for "o" models
            -- reasoning_effort = "medium", -- only supported for "o" models
          },
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
        ollama = {
          endpoint = "http://127.0.0.1:11434", -- Note that there is no /v1 at the end.
          -- model = "qwq:32b",
          -- model = "deepseek-r1:8b",
          -- model = "huihui_ai/deepseek-r1-abliterated:8b",
          -- model = "gemma3n:latest",
          -- model = "phi4-mini-reasoning:latest",
          model = "codellama:latest",
          temperature = 0,
        },
      },
      web_search_engine = {
        provider = "tavily", -- tavily, serpapi, searchapi, google or kagi
        -- provider = "google", -- tavily, serpapi, searchapi, google or kagi
      },
      -- system_prompt as function ensures LLM always has latest MCP server state
      -- This is evaluated for every message, even in existing chats
      system_prompt = function()
        local hub = require("mcphub").get_hub_instance()
        return hub and hub:get_active_servers_prompt() or ""
      end,
      -- Using function prevents requiring mcphub before it's loaded
      custom_tools = function()
        return {
          require("mcphub.extensions.avante").mcp_tool(),
        }
      end,
      -- tools disabled becuase they are provided by mcphub
      disabled_tools = {
        "list_files", -- Built-in file operations
        "search_files",
        "read_file",
        "create_file",
        "rename_file",
        "delete_file",
        "create_dir",
        "rename_dir",
        "delete_dir",
        "bash", -- Built-in terminal access
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
      windows = {
        ---@alias AvantePosition "right" | "left" | "top" | "bottom" | "smart"
        ---@type AvantePosition
        position = "right",
        fillchars = "eob: ",
        wrap = true, -- similar to vim.o.wrap
        width = 30, -- default % based on available width in vertical layout
        height = 30, -- default % based on available height in horizontal layout
        sidebar_header = {
          enabled = true, -- true, false to enable/disable the header
          align = "center", -- left, center, right for title
          rounded = true,
        },
        input = {
          prefix = "> ",
          -- height = 6
          height = 20, -- Height of the input window in vertical layout
        },
        edit = {
          border = { " ", " ", " ", " ", " ", " ", " ", " " },
          start_insert = true, -- Start insert mode when opening the edit window
        },
        ask = {
          floating = false, -- Open the 'AvanteAsk' prompt in a floating window
          border = { " ", " ", " ", " ", " ", " ", " ", " " },
          start_insert = true, -- Start insert mode when opening the ask window
          ---@alias AvanteInitialDiff "ours" | "theirs"
          ---@type AvanteInitialDiff
          focus_on_apply = "ours", -- which diff to focus after applying
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
