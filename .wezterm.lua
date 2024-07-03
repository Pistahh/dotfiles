-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
--config.color_scheme = 'Digerati (terminal.sexy)'
config.color_scheme = "Espresso Libre"
config.font = wezterm.font("LiterationMono Nerd Font")
config.inactive_pane_hsb = {
	saturation = 1,
	brightness = 1,
}

config.swallow_mouse_click_on_pane_focus = true
config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_function = "EaseIn",
	fade_in_duration_ms = 30,
	fade_out_function = "EaseOut",
	fade_out_duration_ms = 30,
}
config.colors = {
	visual_bell = "#802020",
	split = "#aaa",
}

config.mouse_bindings = {
	-- Disable the default click behavior
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = wezterm.action.DisableDefaultAssignment,
	},
	-- Ctrl-click will open the link under the mouse cursor
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
	-- Disable the Ctrl-click down event to stop programs from seeing it when a URL is clicked
	{
		event = { Down = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = wezterm.action.Nop,
	},
}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local domain_name = tab.active_pane.domain_name
	if domain_name then
		return {
			{ Text = " " .. domain_name .. " " },
		}
	end
end)

-- and finally, return the configuration to wezterm
return config
