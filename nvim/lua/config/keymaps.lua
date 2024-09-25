local keymap = vim.keymap
keymap.set("i", "jk", "<esc>", { noremap = true })
keymap.set("n", ";", ":", { noremap = true })

-- Enable the live editing (and re-sourcing) of this file
-- local thisfile = vim.fn.stdpath("config") .. "/lua/config/keymaps.lua"
-- keymap.set("n", "<leader>evs", function()
-- 	vim.cmd("edit " .. thisfile)
-- end, { noremap = true }) --, silent = true })
-- local augroup = vim.api.nvim_create_augroup("MyKeymaps", { clear = true })
-- vim.api.nvim_create_autocmd("BufWritePost", {
-- 	group = augroup,
-- 	pattern = thisfile,
-- 	callback = function()
-- 		vim.cmd("source " .. thisfile)
-- 	end,
-- })
