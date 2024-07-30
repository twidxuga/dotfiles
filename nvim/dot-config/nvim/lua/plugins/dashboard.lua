return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  -- dependencies = { {'nvim-tree/nvim-web-devicons'} },
  -- config = function()
  --   require('dashboard').setup {
  --     -- config
  --   }
  -- end,
  opts = {
    config = { 
      header = vim.split([[

A long time ago in a galaxy far, far away...


.________________.____    __    ____  __   _______  ____    ____  __  .___  ___.         
|                |\   \  /  \  /   / |  | |       \ \   \  /   / |  | |   \/   |         
`--------|  |----` \   \/    \/   /  |  | |  .--.  | \   \/   /  |  | |  \  /  |         
         |  |       \            /   |  | |  |  |  |  \      /   |  | |  |\/|  |         
         |  |        \    /\    /    |  | |  '--'  |   \    /    |  | |  |  |  |________.
         |__|         \__/  \__/     |__| |_______/     \__/     |__| |__|  |___________|
                                                                                         


        ]]
        ,
        "\n"
      ), 
    },
  },
}
