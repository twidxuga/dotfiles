return {
  "kelly-lin/ranger.nvim",
  config = function()
    require("ranger-nvim").setup({
      replace_netrw = false,
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
