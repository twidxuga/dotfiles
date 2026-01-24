return {
  {
    -- -- TODO this is a dirty workaround plugin and should not exist
    -- -- Update soon
    -- "nvim-treesitter/nvim-treesitter",
    -- opts = function(_, opts)
    --   -- Remove markdown from ensure_installed to prevent auto-install
    --   if opts.ensure_installed then
    --     opts.ensure_installed = vim.tbl_filter(function(lang)
    --       return lang ~= "markdown" and lang ~= "markdown_inline"
    --     end, opts.ensure_installed)
    --   end
    --
    --   -- Disable treesitter for markdown to prevent crash
    --   if not opts.highlight then opts.highlight = {} end
    --   if not opts.highlight.disable then opts.highlight.disable = {} end
    --   table.insert(opts.highlight.disable, "markdown")
    --   table.insert(opts.highlight.disable, "markdown_inline")
    --
    --   if not opts.indent then opts.indent = {} end
    --   if not opts.indent.disable then opts.indent.disable = {} end
    --   table.insert(opts.indent.disable, "markdown")
    --   table.insert(opts.indent.disable, "markdown_inline")
    -- end,
  },
}
