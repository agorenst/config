-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

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
keymap.set("i", "<c-v>", "<esc>pi", { noremap = true })

-- https://www.reddit.com/r/neovim/comments/okbag3/how_can_i_remap_ctrl_backspace_to_delete_a_word/ which cites:
-- https://unix.stackexchange.com/questions/203418/bind-c-i-and-tab-keys-to-different-commands-in-terminal-applications-via-inputr/203521#203521
keymap.set("i", "<c-h>", "<c-w>", { noremap = true })

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- AUTOMATICALLY SAVE SESSIONS
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Run these functions on entering and leaving Neovim
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local cwd = vim.fn.getcwd()
    local session_file = cwd:gsub("[/\\]", "_") .. ".vim" -- Convert the path to a file-safe format
    local session_path = vim.fn.stdpath("data") .. "/sessions/" .. session_file

    if vim.fn.filereadable(session_path) == 1 then
      vim.cmd("silent! source " .. session_path) -- Load the session if it exists
    end
  end
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    local cwd = vim.fn.getcwd()
    local session_file = cwd:gsub("[/\\]", "_") .. ".vim" -- Convert the path to a file-safe format
    local session_path = vim.fn.stdpath("data") .. "/sessions/" .. session_file

    -- Ensure the session directory exists
    vim.fn.mkdir(vim.fn.stdpath("data") .. "/sessions", "p")

    -- Save the current session to the specified path
    vim.cmd("mksession! " .. session_path)
  end
})


--------------------------------------------------------------------------------
-- Bibtex formatting. Format on save. Frustrating this isn't built in, oh well.
--------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.bib",
  callback = function()
    vim.cmd("silent !bibtex-tidy " .. vim.fn.shellescape(vim.fn.expand("%:p")))
  end,
})

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- PLUGINS
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- Setup lazy.nvim
require("lazy").setup({
  spec = {

    {
      "micangl/cmp-vimtex",
      lazy = false,
    },
    {
      "lervag/vimtex",
      config = function()
        vim.g.vimtex_compiler_latexmk = {
          options = {
            "-shell-escape", -- for minted
            "-verbose",
            "-file-line-error",
            "-synctex=1",
            "-interaction=nonstopmode",
          },
        }
      end,
    },
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 999,
      opts = {},
      config = function()
        vim.cmd("colorscheme tokyonight-night")
      end,
    },
    {
      "tpope/vim-fugitive",
      lazy = false,
    },
    -- Programming language support
    { import = "plugins.languages" },
    -- The big one!
    { import = "plugins.telescope" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "tokyonight" } },
  checker = { enabled = false }, -- don't check for updates.
})
