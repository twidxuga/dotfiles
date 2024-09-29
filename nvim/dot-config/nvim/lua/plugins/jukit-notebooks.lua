return {
  "luk400/vim-jukit",
  init = function()
    -- Specifies the command used to start a shell in the output split. Can also be an absolute path. Can also be any other shell command, e.g. `R`, `julia`, etc. (note that output saving is only possible for ipython)
    vim.g.jukit_shell_cmd = "ipython"
    -- Terminal to use. Can be one of '', 'kitty', 'vimterm', 'nvimterm' or 'tmux'. If '' is given then will try to detect terminal (though this might fail, in which case it simply defaults to 'vimterm' or 'nvimterm' - depending on the output of `has("nvim")`)
    vim.g.jukit_terminal = "tmux"
    -- If set to 1, will create an autocmd with event `CursorHold` to show saved ipython output of current cell in output-history split. Might slow down (n)vim significantly, you can use `set updatetime=<number of milliseconds>` to control the time to wait until CursorHold events are triggered, which might improve performance if set to a higher number (e.g. `set updatetime=1000`).
    vim.g.jukit_auto_output_hist = 0
    -- Whether to use tcomment plugin (https://github.com/tomtom/tcomment_vim) to comment out cell markers. If not, then cell markers will simply be prepended with `g:jukit_comment_mark`
    vim.g.jukit_use_tcomment = 0
    -- See description of `g:jukit_use_tcomment` above
    vim.g.jukit_comment_mark = "#"
    -- If set to 0, none of the default function mappings (as specified further down) will be applied
    vim.g.jukit_mappings = 0 -- Twid prefers his own mappings
    -- String or list of strings specifying extensions for which the mappings will be created. For example, `vim.g.jukit_mappings_ext_enabled=['py', 'ipynb']` will enable the mappings only in `.py` and `.ipynb` files. Use `vim.g.jukit_mappings_ext_enabled='*'` to enable them for all files.
    vim.g.jukit_mappings_ext_enabled = "*"
    -- Command to open .ipynb files, by default jupyter-notebook is used. To use e.g. vs code instead, you could set this to `vim.g.jukit_notebook_viewer = 'code'`
    vim.g.jukit_notebook_viewer = "jupyter-notebook"
    -- Default setting when converting from .ipynb to .py or vice versa and a file of the same name already exists. Can be of [-1, 0, 1], where -1 means no default (i.e. you'll be prompted to specify what to do), 0 means never overwrite, 1 means always overwrite
    vim.g.jukit_convert_overwrite_default = -1
    -- Default setting for whether the notebook should be opened after converting from .py to .ipynb. Can be of [-1, 0, 1], where -1 means no default (i.e. you'll be prompted to specify what to do), 0 means never open, 1 means always open
    vim.g.jukit_convert_open_default = -1
    -- Default encoding for reading and writing to files in the python helper functions
    vim.g.jukit_file_encodings = "utf-8"
    -- Whether to also use the provided terminal command for the output history split when starting the splits using the JukitOUtHist command. If 0, the provided terminal command is only used in the output split, not in the output history split.
    vim.g.jukit_venv_in_output_hist = 1
  end,
}
