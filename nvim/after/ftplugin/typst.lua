-- This file runs AFTER Neovim's built-in Typst compiler plugin
-- and explicitly resets the makeprg to the system default 'make'.

-- 1. Reset makeprg to the default system 'make'
vim.opt_local.makeprg = 'make'
vim.cmd("TSBufEnable highlight")
