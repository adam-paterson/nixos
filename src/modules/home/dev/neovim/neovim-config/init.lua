-- ╭─────────────────────────────────────────────────────────╮
-- │ Neovim Configuration Entry Point                        │
-- ╰─────────────────────────────────────────────────────────╯

-- ╭─────────────────────────────────────────────────────────╮
-- │ Global Utilities                                          │
-- ╰─────────────────────────────────────────────────────────╯
_G.utils = require("utils")
_G.core = require("core")

-- Make mapping functions globally accessible
_G.map = utils.mappings.map
_G.lazy_map = utils.mappings.lazy_map

-- ╭─────────────────────────────────────────────────────────╮
-- │ Load Core Configuration                                   │
-- ╰─────────────────────────────────────────────────────────╯
-- Load settings
require("core.settings")

-- Load filetype associations
vim.filetype.add(core.filetypes)

-- ╭─────────────────────────────────────────────────────────╮
-- │ Setup Lazy.nvim                                           │
-- ╰─────────────────────────────────────────────────────────╯
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- LazyVim base distribution
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      opts = {
        colorscheme = "catppuccin",
      },
    },
    -- Language configurations
    { import = "languages" },
    -- Custom plugin configurations
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = {
    colorscheme = { "catppuccin", "habamax" },
  },
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- ╭─────────────────────────────────────────────────────────╮
-- │ Load Keymaps & Autocommands                               │
-- ╰─────────────────────────────────────────────────────────╯
require("config.keymaps")
require("config.autocmds")
