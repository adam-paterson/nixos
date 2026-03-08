local wezterm = require("wezterm")

local M = {}

function M.apply(config, user)
  config.automatically_reload_config = true
  config.check_for_updates = false

  config.enable_scroll_bar = false
  config.scrollback_lines = 12000
  config.use_fancy_tab_bar = false
  config.hide_tab_bar_if_only_one_tab = false
  config.show_new_tab_button_in_tab_bar = false
  config.tab_max_width = 28

  config.window_decorations = "RESIZE"
  config.window_close_confirmation = "AlwaysPrompt"
  config.adjust_window_size_when_changing_font_size = false
  config.send_composed_key_when_left_alt_is_pressed = true

  config.window_padding = {
    left = 8,
    right = 8,
    top = 8,
    bottom = 8,
  }

  config.default_prog = { user.shell.program }
  for _, arg in ipairs(user.shell.args or {}) do
    table.insert(config.default_prog, arg)
  end

  if user.profile == "macbook" then
    config.native_macos_fullscreen_mode = true
    config.quit_when_all_windows_are_closed = false
  end
end

return M
