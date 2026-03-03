local M = {}

function M.apply(config, user)
  if user.profile ~= "macbook" then
    return
  end

  config.initial_cols = 132
  config.initial_rows = 38

  config.window_padding = {
    left = 12,
    right = 12,
    top = 10,
    bottom = 10,
  }

  local style = user.style and user.style.macos or {}
  config.macos_window_background_blur = style.blur or 10
  config.window_background_opacity = style.opacity or 1.0

  if style.compact_tabs then
    config.tab_max_width = 22
  end
end

return M
