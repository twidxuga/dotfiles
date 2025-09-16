-- Post config - Custom config after lazy and plugins are initialized

-- Create a custom highlight for Flash, overriding the default
vim.api.nvim_set_hl(0, "FlashLabel", { foreground = "#ffffff", background = "#565d6c" })

-- Vertical help
vim.api.nvim_create_user_command("H", "vertical bo help <args>", { nargs = "?", desc = "Vertical help" })
vim.api.nvim_create_user_command("Help", "vertical bo help <args>", { nargs = "?", desc = "Vertical help" })

-- Sesssion commands
vim.api.nvim_create_user_command(
  "Twid",
  ":source ~/Documents/QuickAccess/Session.vim",
  { desc = "Start Twid's session" }
)
vim.api.nvim_create_user_command(
  "CV",
  ":source ~/Documents/CV/Session.vim",
  { desc = "Start CV editing session" }
)
vim.api.nvim_create_user_command(
  "Monadd",
  ":source ~/Projects/Monadd/Session.vim",
  { desc = "Start Monadd's session" }
)
-- vim.api.nvim_create_user_command(
--   "HXCFAFilter", 
--   ":execute 'r !grep -ip \"cfa-\\d\\d\\d\" ~/Documents/QuickAccess/HX.md' | %s/\\(^.*\\(cfa-\\d\\d\\d\\).*$\\)/\\U\\2\\E - \\1/gi | %sort u",
--   { desc = "Filter CFAs from HX.md and compile a sorted list of all cases reference in there. Finally merge them into the current buffer" }
-- )
vim.api.nvim_create_user_command(
  "Bunch",
  ":source ~/Bunch/Session.vim",
  { desc = "Start Bunch's session" }
)
