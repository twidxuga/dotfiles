return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      pickers = {
        buffers = {
          ignore_current_buffer = true,
          sort_lastused = false,
          sort_mru = true,
        },
      },
      extensions = {
        frecency = {
          auto_validate = true, -- prune entries automatically if true
          db_safe_mode = false, -- avoid prompts to delete stale entries
          matcher = "fuzzy",
          path_display = { "filename_first" },
        },
      },
    },
  },
  {
    "nvim-telescope/telescope-frecency.nvim",
    config = function()
      require("telescope").load_extension("frecency")
    end,
  },
}
