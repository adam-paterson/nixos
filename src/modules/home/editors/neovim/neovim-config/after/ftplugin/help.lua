-- Help window settings
vim.opt_local.conceallevel = 0
vim.opt_local.number = false
vim.opt_local.relativenumber = false

-- Better navigation in help
vim.keymap.set("n", "<CR>", "<C-]>", { buffer = true, desc = "Jump to tag" })
vim.keymap.set("n", "<BS>", "<C-T>", { buffer = true, desc = "Go back" })
vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true, desc = "Close help" })
