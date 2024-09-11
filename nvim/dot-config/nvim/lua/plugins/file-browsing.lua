return { 
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = 'Neotree',
    init = function()
      vim.api.nvim_create_autocmd('BufEnter', {
        -- make a group to be able to delete it later
        group = vim.api.nvim_create_augroup('NeoTreeInit', {clear = true}),
        callback = function()
          local f = vim.fn.expand('%:p')
          if vim.fn.isdirectory(f) ~= 0 then
            vim.cmd('Neotree current dir=' .. f)
            -- neo-tree is loaded now, delete the init autocmd
            vim.api.nvim_clear_autocmds{group = 'NeoTreeInit'}
          end
        end
      })
      -- keymaps
    end,
    opts = {
      filesystem = {
        -- hijack_netrw_behavior = "open_default"
        hijack_netrw_behavior = "open_current"
        -- hijack_netrw_behavior = "disabled"
      },
    },
  },
  {
    "kelly-lin/ranger.nvim",
    config = function()
      require("ranger-nvim").setup({
        replace_netrw = false,
        enable_cmds = true,
        ui = {
          -- border = "none",
          -- • "none": No border (default).
          -- • "single": A single line box.
          -- • "double": A double line box.
          -- • "rounded": Like "single", but with rounded corners
          border = "rounded",
          height = 0.85,
          width = 0.85,
          x = 0.5,
          y = 0.5,
        },
      })
      vim.api.nvim_set_keymap("n", "-", "", {
        noremap = true,
        callback = function()
          require("ranger-nvim").open(true)
        end,
      })
    end,
  }
}
