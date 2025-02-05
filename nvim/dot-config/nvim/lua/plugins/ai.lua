return {
    {
      "Exafunction/codeium.nvim",
      -- enabled = (vim.fn.has('macunix') == 0),
      enabled = false,
      dependencies = {
          "nvim-lua/plenary.nvim",
          "hrsh7th/nvim-cmp",
      },
      opts = {
        enable_chat = true,
      },
      -- config = function()
      --     require("codeium").setup({
      --     })
      -- end
    },
}
