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
opt.ignorecase = true
opt.smartcase = true

-- Appearance
opt.number = true
opt.colorcolumn = "96"
opt.signcolumn = "yes"
opt.cmdheight = 1
opt.scrolloff = 10
opt.completeopt = "menuone,noinsert,noselect" -- TODO revisit this
opt.wrap = true
opt.linebreak = true
opt.breakindent = true

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
-- Saves time to load this after globals
opt.clipboard:append("unnamedplus")
opt.modifiable = true
opt.spell = true
opt.spelllang = { "en_us" }
vim.cmd("syntax spell toplevel")

-- opt.autochdir = true -- this doesn't play well with telescope...
-- opt.shada = "'100" -- Ensure shada stores last cursor positions -- this isn't working?

-- %f is relative filename, ;vspli
-- y F   Type of file in the buffer, e.g., "[vim]".  See 'filetype'.
-- l N   Line number.
-- c N   Column number (byte index).
-- m F   Modified flag, text is "[+]"; "[-]" if 'modifiable' is off.
vim.o.statusline = "%f %y %m (%l:%c)"
