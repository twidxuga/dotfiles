return {
  {
    "aserowy/tmux.nvim",
    opts = {
      copy_sync = {
        -- enables copy sync. by default, all registers are synchronized.
        -- to control which registers are synced, see the `sync_*` options.
        enable = false,

        -- ignore specific tmux buffers e.g. buffer0 = true to ignore the
        -- first buffer or named_buffer_name = true to ignore a named tmux
        -- buffer with name named_buffer_name :)
        ignore_buffers = { empty = false },

        -- TMUX >= 3.2: all yanks (and deletes) will get redirected to system
        -- clipboard by tmux
        redirect_to_clipboard = false,

        -- offset controls where register sync starts
        -- e.g. offset 2 lets registers 0 and 1 untouched
        register_offset = 0,

        -- overwrites vim.g.clipboard to redirect * and + to the system
        -- clipboard using tmux. If you sync your system clipboard without tmux,
        -- disable this option!
        sync_clipboard = false,

        -- synchronizes registers *, +, unnamed, and 0 till 9 with tmux buffers.
        sync_registers = false,

        -- syncs deletes with tmux clipboard as well, it is adviced to
        -- do so. Nvim does not allow syncing registers 0 and 1 without
        -- overwriting the unnamed register. Thus, ddp would not be possible.
        sync_deletes = false,

        -- syncs the unnamed register with the first buffer entry from tmux.
        sync_unnamed = false,
      },
      navigation = {
        -- cycles to opposite pane while navigating into the border
        cycle_navigation = true,

        -- enables default keybindings (C-hjkl) for normal mode
        enable_default_keybindings = false,

        -- prevents unzoom tmux when navigating beyond vim border
        persist_zoom = false,
      },
      resize = {
        -- enables default keybindings (A-hjkl) for normal mode
        enable_default_keybindings = false,

        -- sets resize steps for x axis
        resize_step_x = 1,

        -- sets resize steps for y axis
        resize_step_y = 1,
      },
    },
  },
  -- {
  --   "EvWilson/slimux.nvim",
  --   config = function()
  --     local slimux = require("slimux")
  --     slimux.setup({
  --       target_socket = slimux.get_tmux_socket(),
  --       target_pane = string.format("%s.2", slimux.get_tmux_window()),
  --     })
  --     vim.keymap.set(
  --       "v",
  --       "<leader>r",
  --       slimux.send_highlighted_text,
  --       { desc = "Send currently highlighted text to configured tmux pane" }
  --     )
  --     vim.keymap.set(
  --       "n",
  --       "<leader>r",
  --       slimux.send_paragraph_text,
  --       { desc = "Send paragraph under cursor to configured tmux pane" }
  --     )
  --     -- vim.keymap.set(
  --     --   "v",
  --     --   "<leader>r",
  --     --   ":lua require'slimux'.send_highlighted_text()<cr>",
  --     --   { desc = "Send currently highlighted text to configured tmux pane" }
  --     -- )
  --   end,
  -- },
  -- {
  --    "twidxuga/slimux",
  -- }
  {
    "jpalardy/vim-slime",
    init = function()
      vim.g.slime_target = "tmux"
      vim.g.slime_no_mappings = 1
      vim.g.slime_default_config = {socket_name = "default", target_pane = "2"}
      vim.g.slime_bracketed_paste = 1
    end,
  }
}
