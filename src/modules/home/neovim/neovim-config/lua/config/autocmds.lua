-- ╭─────────────────────────────────────────────────────────╮
-- │ Autocommands Configuration                                │
-- ╰─────────────────────────────────────────────────────────╯

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- General autocommands group
local general = augroup("General", { clear = true })

-- Highlight on yank
autocmd("TextYankPost", {
  group = general,
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
  desc = "Highlight yanked text",
})

-- Remove trailing whitespace on save
autocmd({ "BufWritePre" }, {
  group = general,
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
  desc = "Remove trailing whitespace",
})

-- Equalize splits when window is resized
autocmd("VimResized", {
  group = general,
  pattern = "*",
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
  desc = "Equalize splits on resize",
})

-- Auto-create directories when saving files
autocmd({ "BufWritePre" }, {
  group = general,
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
  desc = "Auto-create parent directories",
})

-- Set filetype-specific options
autocmd("FileType", {
  group = general,
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
  desc = "Enable wrap and spell for text files",
})

-- Disable auto-comment on new line
autocmd("BufEnter", {
  group = general,
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
  desc = "Disable auto-comment",
})
