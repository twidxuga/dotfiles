local js_based_languages = {
  "typescript",
  "javascript",
  "typescriptreact",
  "javascriptreact",
  "vue",
}

--- Gets a path to a package in the Mason registry.
--- Prefer this to `get_package`, since the package might not always be
--- available yet and trigger errors.
---@param pkg string
---@param path? string
local function get_pkg_path(pkg, path)
  pcall(require, 'mason')
  local root = vim.env.MASON or (vim.fn.stdpath('data') .. '/mason')
  path = path or ''
  local ret = root .. '/packages/' .. pkg .. '/' .. path
  return ret
end

return {
  { "nvim-neotest/nvim-nio" },
  {
    "mfussenegger/nvim-dap",
  dependencies = {
  -- Install the vscode-js-debug adapter
  -- {
  --   "microsoft/vscode-js-debug",
  --   -- After install, build it and rename the dist directory to out
  --   build = "npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out",
  --   version = "1.*",
  -- },
   },
    config = function()
      local dap = require("dap")

      dap.set_log_level(vim.log.levels.DEBUG)

      local Config = require("lazyvim.config")
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      for name, sign in pairs(Config.icons.dap) do
        sign = type(sign) == "table" and sign or { sign }
        vim.fn.sign_define(
          "Dap" .. name,
          { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
        )
      end

      dap.adapters['pwa-node'] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          command = 'node',
          args = {
            get_pkg_path('js-debug-adapter', '/js-debug/src/dapDebugServer.js'),
            '${port}',
          },
        },
      }

      for _, language in ipairs(js_based_languages) do
        dap.configurations[language] = {
          -- -- Debug single nodejs files
          -- {
          --   type = "pwa-node",
          --   request = "launch",
          --   name = "Launch file",
          --   program = "${file}",
          --   cwd = vim.fn.getcwd(),
          --   sourceMaps = true,
          -- },
          -- Start node js process in cwd WIP
          -- {
          --   type = "pwa-node",
          --   request = "launch",
          --   name = "Launch CWD ./src/server.ts",
          --   cwd = vim.fn.getcwd(),
          --   runtimeArgs = {
          --     -- "--loader",
          --     -- "ts-node/esm"
          --     "-r ts-node/register",
          --   },
          --   runtimeExecutable = "node",
          --   args = {
          --       -- "${file}"
          --       vim.fn.getcwd() .. "/src/server.ts"
          --   },
          --   sourceMaps = true,
          --   protocol = "inspector",
          --   skipFiles = {
          --       -- "<node_internals>/**",
          --       "node_modules/**"
          --   },
          --   resolveSourceMapLocations = {
          --       vim.fn.getcwd() .. "/**",
          --       "!**/node_modules/**"
          --   }
          -- },
          -- -- Debug nodejs processes (make sure to add --inspect when you run the process)
          -- {
          --   type = "pwa-node",
          --   request = "attach",
          --   name = "Attach to process",
          --   processId = require("dap.utils").pick_process,
          --   cwd = vim.fn.getcwd(),
          --   sourceMaps = true,
          -- },
          -- Debug nodejs processes WIP (make sure to add --inspect when you run the process)
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach to Websocket on 9223",
            cwd = vim.fn.getcwd(),
            sourceMaps = true,
            -- host = "127.0.0.1",
            -- port = "9223",
            protocol = "inspector",
            skipFiles = {
                -- "<node_internals>/**",
                "node_modules/**"
            },
            resolveSourceMapLocations = {
                vim.fn.getcwd() .. "/**",
                "!**/node_modules/**"
            },
            port = function()
              return vim.fn.input("Select port: ", 9223)
            end,
          },
          -- Debug web applications (client side)
          -- {
          --   type = "pwa-chrome",
          --   request = "launch",
          --   name = "Launch & Debug Chrome",
          --   url = function()
          --     local co = coroutine.running()
          --     return coroutine.create(function()
          --       vim.ui.input({
          --         prompt = "Enter URL: ",
          --         default = "http://localhost:13000",
          --       }, function(url)
          --         if url == nil or url == "" then
          --           return
          --         else
          --           coroutine.resume(co, url)
          --         end
          --       end)
          --     end)
          --   end,
          --   webRoot = vim.fn.getcwd(),
          --   protocol = "inspector",
          --   sourceMaps = true,
          --   userDataDir = false,
          -- },
          -- --- Attach to chrome with port selection
          -- {
          --   type = "pwa-chrome",
          --   request = "attach",
          --   name = "Attach Program (pwa-chrome, select port)",
          --   program = "${file}",
          --   cwd = vim.fn.getcwd(),
          --   sourceMaps = true,
          --   port = function()
          --     return vim.fn.input("Select port: ", 9222)
          --   end,
          --   webRoot = "${workspaceFolder}",
          -- },
        }
      end
    end,
  },
	{ -- debug configuration for python
		'mfussenegger/nvim-dap-python',
		build = ':TSInstall python',
    -- keys = { -- default keys from lazy
    --   { "<leader>dPt", function() require('dap-python').test_method() end, desc = "Debug Method", ft = "python" },
    --   { "<leader>dPc", function() require('dap-python').test_class() end, desc = "Debug Class", ft = "python" },
    -- },
    keys = {},
		config = function ()
      -- Requires `pip install debugpy` in any of the target environments
      -- Note that target environments are controlled by venv-selector.nvim
			require('dap-python').setup('python')
      require('dap').configurations.python = {
        {
            type = 'python',
            request = 'launch',
            name = "Launch file",
            program = "${file}",
            console = "integratedTerminal",
            pythonArgs = {"-Xfrozen_modules=off"},
            -- pythonPath = pythonPath()
        },
        {
            type = 'python',
            request = 'launch',
            name = 'Launch file with arguments',
            program = '${file}',
            args = function()
                local args_string = vim.fn.input('Arguments: ')
                return vim.split(args_string, " +")
            end,
            console = "integratedTerminal",
            pythonArgs = {"-Xfrozen_modules=off"},
            -- pythonPath = pythonPath()
        },
        {
            type = 'python',
            request = 'attach',
            name = 'Attach 127.0.0.1:8989',
            connect = function()
                return {
                    host = '127.0.0.1',
                    port = 8989
                }
            end,
        },
        {
            type = 'python',
            request = 'launch',
            name = 'Django runner',
            program = function()
              -- Must be a function, otherwise getcwd() assumes nvim started in the right directory
              return vim.fn.getcwd() .. '/manage.py'
            end,
            args = {'runserver', '--noreload'},
            justMyCode = true,
            django = true,
            console = "integratedTerminal",
            pythonArgs = {"-Xfrozen_modules=off"},
        },
        {
            type = 'python',
            request = 'attach',
            name = 'Djanto Attach 127.0.0.1:8989',
            django = true,
            connect = function()
                return {
                    host = '127.0.0.1',
                    port = 8989
                }
            end,
        },
      }
		end
	},
  { 
    "rcarriga/nvim-dap-ui",
    dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
    opts = { -- default options
      {
        controls = {
          element = "repl",
          enabled = true,
          icons = {
            disconnect = "",
            pause = "",
            play = "",
            run_last = "",
            step_back = "",
            step_into = "",
            step_out = "",
            step_over = "",
            terminate = ""
          }
        },
        element_mappings = {},
        expand_lines = true,
        floating = {
          border = "single",
          mappings = {
            close = { "q", "<Esc>" }
          }
        },
        force_buffers = true,
        icons = {
          collapsed = "",
          current_frame = "",
          expanded = ""
        },
        layouts = { {
            elements = { {
                id = "scopes",
                size = 0.25
              }, {
                id = "breakpoints",
                size = 0.25
              }, {
                id = "stacks",
                size = 0.25
              }, {
                id = "watches",
                size = 0.25
              } },
            position = "left",
            size = 40
          }, {
            elements = { {
                id = "repl",
                size = 0.5
              }, {
                id = "console",
                size = 0.5
              } },
            position = "bottom",
            size = 10
          } },
        mappings = {
          edit = "e",
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          repl = "r",
          toggle = "t"
        },
        render = {
          indent = 1,
          max_value_lines = 100
        },
      },
    },
  },
}
