-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.color_scheme = 'nord'
config.font = wezterm.font 'DejaVuSansM Nerd Font Mono'
-- config.font = wezterm.font 'CommitMono Nerd Font Mono'
-- config.font = wezterm.font 'CodeNewRoman Nerd Font Mono'
-- config.font_size = 10.4
config.font_size = 11.0
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

-- Open URLs forwarded from a remote SSH session in Chrome on THIS machine.
-- A remote helper emits OSC 1337 SetUserVar=open-url=<base64(url)>; the escape
-- rides the terminal stream (tmux/ssh) to here. We open only http(s) URLs and
-- pass the url as a single argv (never a shell string) so a hostile URL can't
-- inject. localhost:8090 is rewritten to :8091 because the Mac's 8090 dev
-- server is reached on this laptop via the sshgrok `-L 8091:localhost:8090`
-- forward. The time-based dedupe drops a repeat of the same url within 2s so
-- that multiple GUI windows attached to one mux don't each open it, without
-- dropping legitimate opens emitted from a background pane.
local last_open_url, last_open_at = nil, 0
wezterm.on("user-var-changed", function(window, pane, name, value)
  if name ~= "open-url" then
    return
  end
  local url = value
  if not url:match("^https?://") then
    return
  end
  local now = os.time()
  if url == last_open_url and (now - last_open_at) < 2 then
    return
  end
  last_open_url, last_open_at = url, now
  url = url:gsub("localhost:8090", "localhost:8091")
  url = url:gsub("127%.0%.0%.1:8090", "127.0.0.1:8091")
  wezterm.background_child_process({ "/usr/bin/google-chrome-stable", "--new-window", url })
end)

-- and finally, return the configuration to wezterm
return config
