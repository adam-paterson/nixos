local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

local function zoxide_path()
  local candidates = {
    "/run/current-system/sw/bin/zoxide",
    "/opt/homebrew/bin/zoxide",
    "/usr/local/bin/zoxide",
  }

  for _, path in ipairs(candidates) do
    local handle = io.open(path, "r")
    if handle then
      handle:close()
      return path
    end
  end

  return nil
end

function M.switch_workspace_action(plugins)
  if
    plugins.workspace_switcher
    and plugins.workspace_switcher.switch_workspace
  then
    local opts = {
      extra_args = " | head -100",
    }

    local zoxide = zoxide_path()
    if zoxide ~= nil then
      opts.fuzzy = true
      opts.zoxide_path = zoxide
    end

    return plugins.workspace_switcher.switch_workspace(opts)
  end

  return act.ShowLauncherArgs({ flags = "WORKSPACES" })
end

function M.save_workspace_action(plugins)
  local _ = plugins
  return act.ShowLauncherArgs({ flags = "WORKSPACES" })
end

function M.restore_workspace_action(plugins)
  if
    plugins.workspace_switcher
    and plugins.workspace_switcher.switch_to_prev_workspace
  then
    return plugins.workspace_switcher.switch_to_prev_workspace()
  end

  return act.ShowLauncherArgs({ flags = "WORKSPACES" })
end

function M.setup(_, plugins)
  -- Kept as a hook for future workspace event wiring.
  local _ = plugins
end

return M
