local wezterm = require("wezterm")

local M = {}

local function safe_require(path, name)
  local ok, plugin = pcall(wezterm.plugin.require, path)
  if not ok then
    wezterm.log_warn("failed to load plugin " .. name .. " (" .. path .. "): " .. tostring(plugin))
    return nil
  end
  return plugin
end

local function require_with_pin(spec, name)
  local attempts = {}
  if spec.url and spec.rev and spec.rev ~= "" then
    table.insert(attempts, spec.url .. "?rev=" .. spec.rev)
  end
  if spec.url then
    table.insert(attempts, spec.url)
  end

  for _, candidate in ipairs(attempts) do
    local plugin = safe_require(candidate, name)
    if plugin ~= nil then
      return plugin
    end
  end

  return nil
end

local function call_if_present(target, method, ...)
  if target and type(target[method]) == "function" then
    local fn = target[method]
    local ok, err = pcall(fn, ...)
    if not ok then
      ok, err = pcall(fn, target, ...)
    end
    if not ok then
      wezterm.log_warn("plugin call failed (" .. method .. "): " .. tostring(err))
      return false
    end
    return true
  end
  return false
end

function M.load(user)
  if not user.plugins.enable then
    return {}
  end

  local remote = user.plugins.remote or {}
  local loaded = {
    workspace_switcher = require_with_pin(remote.workspace_switcher or {}, "workspace_switcher"),
    agent_deck = nil,
    bar = nil,
    _state = {
      bar_owns_status = false,
    },
  }

  if user.agent and user.agent.enable then
    loaded.agent_deck = require_with_pin(remote.agent_deck or {}, "agent_deck")
  end

  if user.bar and user.bar.enable then
    loaded.bar = require_with_pin(remote.bar or {}, "bar")
  end

  return loaded
end

function M.apply(config, user, loaded)
  if not loaded then
    return
  end

  if loaded.agent_deck ~= nil then
    local agent_opts = {
      notifications = user.agent.notifications,
      show_tab_title = user.agent.tab_title,
      right_status = user.agent.right_status,
    }

    call_if_present(loaded.agent_deck, "setup", agent_opts)
    call_if_present(loaded.agent_deck, "apply_to_config", config, agent_opts)
    call_if_present(loaded.agent_deck, "apply", config, agent_opts)
  end

  if loaded.bar ~= nil then
    local bar_opts = {}
    if user.bar.safe_mode then
      bar_opts = {
        separator = "  ",
        modules = {
          workspace = true,
          clock = true,
          hostname = false,
          leader = true,
        },
      }
    end

    local applied = false
    applied = call_if_present(loaded.bar, "setup", bar_opts) or applied
    applied = call_if_present(loaded.bar, "apply_to_config", config, bar_opts) or applied
    applied = call_if_present(loaded.bar, "apply", config, bar_opts) or applied
    loaded._state.bar_owns_status = applied
  end
end

return M
