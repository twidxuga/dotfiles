return {
  {
    "mfussenegger/nvim-dap",
    config = function() end,
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
