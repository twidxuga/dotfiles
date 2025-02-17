-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.color_scheme = 'nord'
config.font = wezterm.font 'DejaVuSansM Nerd Font Mono'
-- config.font = wezterm.font 'CommitMono Nerd Font Mono'
-- config.font = wezterm.font 'CodeNewRoman Nerd Font Mono'
-- config.font_size = 10.4
config.font_size = 15.0
config.enable_tab_bar = false
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
-- config.window_decorations = "NONE"
config.warn_about_missing_glyphs = false
-- macos normal alt behaviour
config.send_composed_key_when_left_alt_is_pressed = true

-- Aditional maps for mac
config.keys = {
 -- consistency with Karabiner's remaps
 {
   key = '3',
   mods = 'OPT',
   action = wezterm.action { SendString = "#" },
 },
 -- vim moving in insert mode
 {
   key = 'h',
   mods = 'CMD',
   action = wezterm.action.SendKey { key="h", mods='ALT' },
 },
 {
   key = 'j',
   mods = 'CMD',
   action = wezterm.action.SendKey { key="j", mods='ALT' },
 },
 {
   key = 'k',
   mods = 'CMD',
   action = wezterm.action.SendKey { key="k", mods='ALT' },
 },
 {
   key = 'l',
   mods = 'CMD',
   action = wezterm.action.SendKey { key="l", mods='ALT' },
 },
 -- vim new line after/before (NOTE \x1b is the ALT key, equivalent to the above)
 {
   key = 'o',
   mods = 'CMD',
   action = wezterm.action { SendString = "\x1bo" },
 },
 {
   key = 'O',
   mods = 'CMD',
   action = wezterm.action { SendString = "\x1bO" },
 },
 --  vim additional actions
 {
   key = 'a',
   mods = 'CMD',
   action = wezterm.action { SendString = "\x1ba" },
 },
 {
   key = 'A',
   mods = 'CMD',
   action = wezterm.action { SendString = "\x1bA" },
 },
 {
   key = 'e',
   mods = 'CMD',
   action = wezterm.action { SendString = "\x1ba" },
 },
 {
   key = 'w',
   mods = 'CMD',
   action = wezterm.action { SendString = "\x1bw" },
 },
 {
   key = 'I',
   mods = 'CMD',
   action = wezterm.action { SendString = "\x1bI" },
 },
 -- shell forwar/backward/delete workd
 {
   key = 'b',
   mods = 'CMD',
   action = wezterm.action { SendString = "\x1bb" },
 },
 {
   key = 'f',
   mods = 'CMD',
   action = wezterm.action { SendString = "\x1bf" },
 },
 {
   key = 'd',
   mods = 'CMD',
   action = wezterm.action { SendString = "\x1bd" },
 },
}

-- and finally, return the configuration to wezterm
return config
