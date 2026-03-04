-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Maximize window on startup
local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

-- Set appearance
config.font_size = 23
config.color_scheme = "Everforest Dark Soft (Gogh)"
config.use_resize_increments = false
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "NONE"

-- If windows (amd64 is the only one I have)
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
	-- Set default domain to wsl archlinux
	config.default_domain = "WSL:archlinux"
end

-- Finally, return the configuration to wezterm:
return config
