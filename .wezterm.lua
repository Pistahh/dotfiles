-- Pull in the wezterm API
local wezterm = require 'wezterm'

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
config.color_scheme = 'Espresso Libre'
config.font = wezterm.font 'LiterationMono Nerd Font'
config.inactive_pane_hsb = {
  saturation = 1,
  brightness = 1,
}

config.swallow_mouse_click_on_pane_focus = true

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local pane_title = tab.active_pane.title
  local user_title = tab.active_pane.user_vars.panetitle

  -- if user_title ~= nil and #user_title > 0 then
    -- pane_title = user_title
  -- end
  local  pane_title = tab.active_pane.domain_name
  if pane_title then
  return {
    --{Background={Color="blue"}},
    --{Foreground={Color="white"}},
    {Text=" " .. pane_title .. " "},
  }
  end
end)

-- and finally, return the configuration to wezterm
return config
