-- Post config - Custom config after lazy and plugins are initialized

-- Create a custom highlight for Flash, overriding the default
vim.api.nvim_set_hl(0, 'FlashLabel',  { foreground = '#ffffff', background = '#565d6c' })

-- Sesssion commands
vim.api.nvim_create_user_command('Monadd',":source ~/Monadd/Session.vim",{})
vim.api.nvim_create_user_command('Twid',":source ~/Documents/QuickAccess/Session.vim",{})
