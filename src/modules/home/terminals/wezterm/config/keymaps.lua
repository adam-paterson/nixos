local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

local function leader_keys(workspaces, plugins)
  return {
    { key = "s", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "v", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

    { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

    { key = "H", mods = "LEADER", action = act.AdjustPaneSize({ "Left", 5 }) },
    { key = "J", mods = "LEADER", action = act.AdjustPaneSize({ "Down", 5 }) },
    { key = "K", mods = "LEADER", action = act.AdjustPaneSize({ "Up", 5 }) },
    { key = "L", mods = "LEADER", action = act.AdjustPaneSize({ "Right", 5 }) },

    { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
    { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },

    { key = "w", mods = "LEADER", action = workspaces.switch_workspace_action(plugins) },
    { key = "S", mods = "LEADER", action = workspaces.save_workspace_action(plugins) },
    { key = "R", mods = "LEADER", action = workspaces.restore_workspace_action(plugins) },
  }
end

local function direct_keys(workspaces, plugins)
  return {
    { key = "d", mods = "CMD", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "D", mods = "CMD|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

    { key = "LeftArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection("Left") },
    { key = "DownArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection("Down") },
    { key = "UpArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection("Up") },
    { key = "RightArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection("Right") },

    { key = "w", mods = "CMD|SHIFT", action = workspaces.switch_workspace_action(plugins) },
    { key = "s", mods = "CMD|SHIFT", action = workspaces.save_workspace_action(plugins) },
    { key = "r", mods = "CMD|SHIFT", action = workspaces.restore_workspace_action(plugins) },
  }
end

function M.apply(config, user, plugins, workspaces)
  if user.keys.mode == "leader" or user.keys.mode == "hybrid" then
    config.leader = {
      key = "b",
      mods = "CMD",
      timeout_milliseconds = 1200,
    }
  end

  local keys = {
    { key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "n", mods = "CMD", action = act.SpawnWindow },
    { key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = true }) },
    { key = "}", mods = "CMD|SHIFT", action = act.ActivateTabRelative(1) },
    { key = "{", mods = "CMD|SHIFT", action = act.ActivateTabRelative(-1) },
    { key = "f", mods = "CMD|SHIFT", action = act.Search({ CaseSensitiveString = "" }) },
    { key = "p", mods = "CMD|SHIFT", action = act.ActivateCommandPalette },
  }

  if user.keys.mode == "leader" then
    for _, key in ipairs(leader_keys(workspaces, plugins)) do
      table.insert(keys, key)
    end
  elseif user.keys.mode == "direct" then
    for _, key in ipairs(direct_keys(workspaces, plugins)) do
      table.insert(keys, key)
    end
  else
    for _, key in ipairs(leader_keys(workspaces, plugins)) do
      table.insert(keys, key)
    end
    for _, key in ipairs(direct_keys(workspaces, plugins)) do
      table.insert(keys, key)
    end
  end

  config.keys = keys
end

return M
