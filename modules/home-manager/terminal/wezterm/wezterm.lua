-- Pull in the wezterm API
local wezterm = require("wezterm")

-- Other Wezterm plugins
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
local toggle_terminal = wezterm.plugin.require("https://github.com/zsh-sage/toggle_terminal.wez")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
local color_scheme_light = "Solarized Light (Gogh)"
local color_scheme_dark = "Batman"

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

config.use_fancy_tab_bar = true
config.window_decorations = "RESIZE"
config.enable_tab_bar = false
config.window_frame = {
	font_size = 10,
}
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.adjust_window_size_when_changing_font_size = false

config.front_end = "WebGpu"
config.max_fps = 120

config.enable_kitty_keyboard = true
config.keys = {
	{
		key = "p",
		mods = "SUPER",
		action = wezterm.action.ShowTabNavigator,
	},
	{
		key = "o",
		mods = "SUPER",
		action = wezterm.action.ActivateLastTab,
	},

	-- Resurrect
	{
		key = "w",
		mods = "ALT",
		action = wezterm.action_callback(function(win, pane)
			-- Resurrect state is stored in resurrect plugin directory
			resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
			resurrect.window_state.save_window_action()
		end),
	},
	{
		key = "r",
		mods = "ALT",
		action = wezterm.action_callback(function(win, pane)
			resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
				local type = string.match(id, "^([^/]+)") -- match before '/'
				id = string.match(id, "([^/]+)$") -- match after '/'
				id = string.match(id, "(.+)%..+$") -- remove file extention

				local opts = {
					window = win:mux_window(),
					relative = true,
					restore_text = true,
					on_pane_restore = resurrect.tab_state.default_on_pane_restore,
					close_open_tabs = true,
				}

				if type == "workspace" then
					local state = resurrect.state_manager.load_state(id, "workspace")
					resurrect.workspace_state.restore_workspace(state, opts)
				elseif type == "window" then
					local state = resurrect.state_manager.load_state(id, "window")
					resurrect.window_state.restore_window(pane:window(), state, opts)
				elseif type == "tab" then
					local state = resurrect.state_manager.load_state(id, "tab")
					resurrect.tab_state.restore_tab(pane:tab(), state, opts)
				end
			end, {
				ignore_tabs = true,
				ignore_windows = true,
				show_state_with_date = true,
			})
		end),
	},
	{
		key = "r",
		mods = "ALT|SHIFT",
		action = wezterm.action_callback(function(win, pane)
			resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id)
				resurrect.delete_state(id)
			end, {
				title = "Delete State",
				description = "Select session to delete and press Enter = accept, Esc = cancel, / = filter",
				fuzzy_description = "Search session to delete: ",
				is_fuzzy = true,
				ignore_tabs = true,
				ignore_windows = true,
			})
		end),
	},
}

resurrect.state_manager.periodic_save({
	interval_seconds = 300,
	save_workspaces = true,
	save_windows = true,
	save_tabs = true,
})
resurrect.state_manager.set_max_nlines(50000)

resurrect.state_manager.set_encryption({
	enable = true,
	method = "age",
	private_key = wezterm.home_dir .. ".config/wezterm/resurrect_secret.txt",
	public_key = "age1yzgt8vkltmfuf3cfj0ywt6t27clj80c4k5kktg437x0vuxryvp5qnkrq08",
})

wezterm.on("gui-startup", resurrect.state_manager.resurrect_on_gui_startup)

wezterm.on("augment-command-palette", function(window, pane)
	local workspace_state = resurrect.workspace_state
	return {
		{
			brief = "Window | Workspace: Switch Workspace",
			icon = "md_briefcase_arrow_up_down",
			action = workspace_switcher.switch_workspace(),
		},
		{
			brief = "Window | Workspace: Rename Workspace",
			icon = "md_briefcase_edit",
			action = wezterm.action.PromptInputLine({
				description = "Enter new name for workspace",
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
						resurrect.state_manager.save_state(workspace_state.get_workspace_state())
					end
				end),
			}),
		},
	}
end)

toggle_terminal.apply_to_config(config, {
	key = ";",
	mods = "CTRL",
	direction = "Down", -- Direction to split the pane
	size = { Percent = 20 }, -- Size of the split pane
	change_invoker_id_everytime = false, -- Change invoker pane on every toggle
	zoom = {
		auto_zoom_toggle_terminal = false, -- Automatically zoom toggle terminal pane
		auto_zoom_invoker_pane = true, -- Automatically zoom invoker pane
		remember_zoomed = true, -- Automatically re-zoom the toggle pane if it was zoomed before switching away
	},
})

-- To update the plugins, run
-- wezterm.plugin.update_all()

-- To check plugins, run
-- wezterm.plugin.list()

-- and finally, return the configuration to wezterm
return config
