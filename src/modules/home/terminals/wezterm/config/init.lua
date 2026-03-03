local wezterm = require("wezterm")
local function local_module(name)
  return dofile(wezterm.config_dir .. "/config/" .. name .. ".lua")
end

local user = local_module("user")
local core = local_module("core")
local fonts = local_module("fonts")
local theme = local_module("theme")
local plugins = local_module("plugins")
local keymaps = local_module("keymaps")
local workspaces = local_module("workspaces")
local status = local_module("status")
local macbook = local_module("macbook")

local M = {}

function M.build()
  local config = wezterm.config_builder()
  local loaded_plugins = plugins.load(user)

  core.apply(config, user)
  fonts.apply(config, user)
  theme.apply(config, user)
  macbook.apply(config, user)

  plugins.apply(config, user, loaded_plugins)
  keymaps.apply(config, user, loaded_plugins, workspaces)

  status.setup(user, loaded_plugins)
  workspaces.setup(user, loaded_plugins)

  return config
end

return M
