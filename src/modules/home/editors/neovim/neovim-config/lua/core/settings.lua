-- ╭─────────────────────────────────────────────────────────╮
-- │ Vim Settings & Options                                    │
-- ╰─────────────────────────────────────────────────────────╯

local opt = vim.opt
local g = vim.g

-- ╭─────────────────────────────────────────────────────────╮
-- │ General Options                                           │
-- ╰─────────────────────────────────────────────────────────╯
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.colorcolumn = "100"

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2

opt.smartindent = true
opt.wrap = false

opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undodir"

opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

opt.termguicolors = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.updatetime = 50
opt.timeoutlen = 300

opt.splitbelow = true
opt.splitright = true

opt.clipboard = "unnamedplus"

opt.list = true
opt.listchars = { tab = "  ", trail = "·", nbsp = "␣" }

-- ╭─────────────────────────────────────────────────────────╮
-- │ Global Variables                                          │
-- ╰─────────────────────────────────────────────────────────╯
g.mapleader = " "
g.maplocalleader = " "

-- Disable unused providers
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0

-- Disable netrw (using neo-tree instead)
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
