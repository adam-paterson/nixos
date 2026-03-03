local wezterm = require("wezterm")
local init = dofile(wezterm.config_dir .. "/config/init.lua")

return init.build()
