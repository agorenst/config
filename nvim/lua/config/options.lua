--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- GLOBALS
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.clipboard = { -- startup improvement https://github.com/neovim/neovim/issues/9570
  name = "xclip",
  copy = {
    ["+"] = "xclip -selection clipboard",
    ["*"] = "xclip -selection clipboard",
  },
  paste = {
    ["+"] = "xclip -selection clipboard -o",
    ["*"] = "xclip -selection clipboard -o",
  },
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- OPTIONS
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Most of this is all from https://www.youtube.com/watch?v=ZjMzBd1Dqz8, around the 35 minute mark.
local opt = vim.opt

-- Tabs
opt.tabstop = 2 -- how many chars tab takes up
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.wrap = false

-- Search
opt.incsearch = true
opt.ignorecase = true -- this is also for autocomplete of commands
opt.smartcase = true

-- Appearance
opt.number = true
-- opt.colorcolumn = "96" Don't really like this TBH.
opt.signcolumn = "yes"
opt.cmdheight = 1
opt.scrolloff = 6
opt.completeopt = "menuone,noinsert,noselect" -- TODO revisit this
opt.wrap = true
opt.linebreak = true
opt.breakindent = true
opt.termguicolors = true

-- Behavior
opt.hidden = true -- TODO revisit this
opt.errorbells = false
opt.swapfile = false
opt.backup = false
-- opt.undodir = vim.fn.expand("~/.vim/undodir") -- TODO: Revisit this
-- opt.undofile = true
opt.backspace = "indent,eol,start"
opt.splitright = true
opt.splitbelow = true
opt.clipboard = "unnamedplus"
opt.modifiable = true

-- Spelling
opt.spell = true
opt.spelllang = { "en_us" }
vim.cmd("syntax spell toplevel")

opt.virtualedit = "block"

-- opt.autochdir = true -- this doesn't play well with telescope...
-- opt.shada = "'100" -- Ensure shada stores last cursor positions -- this isn't working?

-- %f is relative filename, ;vspli
-- y F   Type of file in the buffer, e.g., "[vim]".  See 'filetype'.
-- l N   Line number.
-- c N   Column number (byte index).
-- m F   Modified flag, text is "[+]"; "[-]" if 'modifiable' is off.
vim.o.statusline = "%f %y %m (%l:%c) %= %{FugitiveStatusline()}"
-- Recommended via checkhealth?
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- KEYMAPS
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local keymap = vim.keymap
keymap.set("i", "jk", "<esc>", { noremap = true })
keymap.set("n", ";", ":", { noremap = true })
