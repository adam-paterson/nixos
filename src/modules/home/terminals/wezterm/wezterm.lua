local wezterm = require("wezterm")
local init = dofile(wezterm.config_dir .. "/config/init.lua")
local base_config = type(config) == "table" and config or nil

return init.build(base_config)
