local wezterm = require("wezterm")

local M = {}

function M.setup(_, plugins)
  local bar_owns_status = false
  if plugins and plugins._state then
    bar_owns_status = plugins._state.bar_owns_status == true
  end
  if bar_owns_status then
    return
  end

  wezterm.on("update-right-status", function(window, pane)
    local workspace = window:active_workspace()
    local cells = {
      { Foreground = { Color = "#89b4fa" } },
      { Text = " " .. workspace .. " " },
      { Foreground = { Color = "#a6adc8" } },
      { Text = wezterm.strftime("%a %H:%M ") },
    }

    local process = pane:get_foreground_process_name() or ""
    if process ~= "" then
      local short = process:gsub(".*/", "")
      table.insert(cells, 1, { Foreground = { Color = "#f9e2af" } })
      table.insert(cells, 2, { Text = " " .. short .. " " })
    end

    window:set_right_status(wezterm.format(cells))
  end)
end

return M
