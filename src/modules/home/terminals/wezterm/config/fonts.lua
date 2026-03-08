local wezterm = require("wezterm")

local M = {}

function M.apply(config, user)
  config.font = wezterm.font_with_fallback({
    user.font.family,
    "Monaspace Neon",
    "Monaspace Krypton",
    "Symbols Nerd Font Mono",
    "Apple Color Emoji",
  })
  config.font_size = user.font.size

  config.harfbuzz_features = {
    "calt=1",
    "clig=1",
    "liga=1",
    "ss01=1",
    "ss02=1",
    "ss03=1",
    "ss04=1",
  }
end

return M
