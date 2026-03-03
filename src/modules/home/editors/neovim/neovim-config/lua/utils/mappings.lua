-- ╭─────────────────────────────────────────────────────────╮
-- │ Key Mapping Utilities                                     │
-- ╰─────────────────────────────────────────────────────────╯

local M = {}

-- Standard keymap function
function M.map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  opts.noremap = opts.noremap ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Create lazy.nvim compatible keymap specs
function M.lazy_map(mode, lhs, rhs, opts)
  opts = opts or {}
  return vim.tbl_extend("force", {
    mode = mode,
    lhs,
    rhs,
  }, opts)
end

-- Quick mapping for common modes
function M.nmap(lhs, rhs, opts)
  M.map("n", lhs, rhs, opts)
end

function M.imap(lhs, rhs, opts)
  M.map("i", lhs, rhs, opts)
end

function M.vmap(lhs, rhs, opts)
  M.map("v", lhs, rhs, opts)
end

function M.tmap(lhs, rhs, opts)
  M.map("t", lhs, rhs, opts)
end

return M
