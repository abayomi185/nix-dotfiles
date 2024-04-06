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

-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
local color_scheme_light = "Solarized Light (Gogh)"
-- local color_scheme_light = "Batman"
local color_scheme_dark = "Batman"
-- local color_scheme = "Builtin Solarized Dark"
-- local color_scheme = "AdventureTime"
-- local color_scheme = "Andromeda"

local function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end
local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return color_scheme_dark
	else
		return color_scheme_light
	end
end

config.color_scheme = scheme_for_appearance(get_appearance())

-- config.font = wezterm.font('JetBrains Mono', { bold = false, italic = false })

config.use_fancy_tab_bar = false

config.adjust_window_size_when_changing_font_size = false

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

wezterm.on("update-right-status", function(window, pane)
	-- "Wed Mar 3 08:14"
	local date = wezterm.strftime("%a %b %-d %H:%M ")

	local bat = ""
	for _, b in ipairs(wezterm.battery_info()) do
		bat = "🔋 " .. string.format("%.0f%%", b.state_of_charge * 100)
	end

	window:set_right_status(wezterm.format({
		{ Text = bat .. "   " .. date },
	}))
end)

-- and finally, return the configuration to wezterm
return config
