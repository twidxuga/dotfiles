-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.color_scheme = 'nord'
config.font = wezterm.font 'DejaVuSansM Nerd Font Mono'
-- config.font = wezterm.font 'CommitMono Nerd Font Mono'
-- config.font = wezterm.font 'CodeNewRoman Nerd Font Mono'
config.font_size = 10.4
config.enable_tab_bar = false
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
config.warn_about_missing_glyphs = false

-- and finally, return the configuration to wezterm
return config
