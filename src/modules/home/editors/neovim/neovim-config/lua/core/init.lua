-- ╭─────────────────────────────────────────────────────────╮
-- │ Core Module Loader                                        │
-- ╰─────────────────────────────────────────────────────────╯

local M = {}

-- Lazy-load modules using metatable
setmetatable(M, {
  __index = function(t, k)
    local ok, mod = pcall(require, "core." .. k)
    if ok then
      t[k] = mod
      return mod
    end
  end,
})

-- Core configuration values
M.config = {
  ui = {
    theme = "catppuccin",
  },
}

return M
