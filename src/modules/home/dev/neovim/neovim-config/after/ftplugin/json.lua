-- JSON specific settings
vim.opt_local.conceallevel = 0
vim.opt_local.formatprg = "jq"

-- Keybinding to format JSON
vim.keymap.set("n", "<leader>cf", ":%!jq .<CR>", { buffer = true, desc = "Format JSON" })
