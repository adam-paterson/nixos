-- ╭─────────────────────────────────────────────────────────╮
-- │ Utility Module Loader                                     │
-- ╰─────────────────────────────────────────────────────────╯

local M = {}

-- Lazy-load utility submodules
setmetatable(M, {
  __index = function(t, k)
    local ok, mod = pcall(require, "utils." .. k)
    if ok then
      t[k] = mod
      return mod
    end
  end,
})

-- ╭─────────────────────────────────────────────────────────╮
-- │ General Helper Functions                                  │
-- ╰─────────────────────────────────────────────────────────╯

-- Check if a plugin is available
function M.has(plugin)
  return require("lazy.core.config").spec.plugins[plugin] ~= nil
end

-- Safe require with error handling
function M.safe_require(module)
  local ok, mod = pcall(require, module)
  if not ok then
    vim.notify("Failed to load: " .. module, vim.log.levels.WARN)
    return nil
  end
  return mod
end

-- Check if running on macOS
function M.is_mac()
  return vim.loop.os_uname().sysname == "Darwin"
end

-- Check if running on Linux
function M.is_linux()
  return vim.loop.os_uname().sysname == "Linux"
end

-- Check if running on Windows (WSL)
function M.is_wsl()
  local uname = vim.loop.os_uname()
  return uname.release:lower():match("microsoft") ~= nil
end

return M
