-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath, })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg", },
      { out,                            "WarningMsg", },
      { "\nPress any key to exit...", },
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

-- Disable netrw per neovim-tree documentation
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- OPTIONS
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Most of this is all from https://www.youtube.com/watch?v=ZjMzBd1Dqz8, around the 35 minute mark.
-- Tabs
vim.opt.tabstop = 2 -- how many chars tab takes up
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false

-- Search
vim.opt.incsearch = true
vim.opt.ignorecase = true -- this is also for autocomplete of commands
vim.opt.smartcase = true

-- Appearance
vim.opt.number = true
-- opt.colorcolumn = "96" Don't really like this TBH.
vim.opt.signcolumn = "yes"
vim.opt.cmdheight = 1
vim.opt.scrolloff = 6
vim.opt.completeopt = "menuone,noinsert,noselect" -- TODO revisit this
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.termguicolors = true

-- Behavior
vim.opt.hidden = true -- TODO revisit this
vim.opt.errorbells = false
vim.opt.swapfile = false
vim.opt.backup = false
-- opt.undodir = vim.fn.expand("~/.vim/undodir") -- TODO: Revisit this
-- opt.undofile = true
vim.opt.backspace = "indent,eol,start"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.clipboard = "unnamedplus"
vim.opt.modifiable = true

-- Spelling
vim.opt.spell = true
vim.opt.spelllang = { "en_us", }
vim.cmd("syntax spell toplevel")

vim.opt.virtualedit = "block"

-- opt.autochdir = true -- this doesn't play well with telescope...
-- opt.shada = "'100" -- Ensure shada stores last cursor positions -- this isn't working?

-- %f is relative filename, ;vspli
-- y F   Type of file in the buffer, e.g., "[vim]".  See 'filetype'.
-- l N   Line number.
-- c N   Column number (byte index).
-- m F   Modified flag, text is "[+]"; "[-]" if 'modifiable' is off.
-- vim.o.statusline = "%f %y %m (%l:%c) %= %{FugitiveStatusline()}"
-- Recommended via checkhealth?
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- KEYMAPS
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
vim.keymap.set("i", "jk", "<esc>", { noremap = true, })
vim.keymap.set("n", ";", ":", { noremap = true, })
vim.keymap.set("i", "<c-v>", "<esc>pi", { noremap = true, })

-- https://www.reddit.com/r/neovim/comments/okbag3/how_can_i_remap_ctrl_backspace_to_delete_a_word/ which cites:
-- https://unix.stackexchange.com/questions/203418/bind-c-i-and-tab-keys-to-different-commands-in-terminal-applications-via-inputr/203521#203521
-- This let's me do ctrl-backspace to do delete-word.
vim.keymap.set("i", "<c-h>", "<c-w>", { noremap = true, })


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- AUTOMATICALLY SAVE SESSIONS
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Run these functions on entering and leaving Neovim
-- Turning these off: they had trouble with opening new buffers, etc.
-- vim.api.nvim_create_autocmd("VimEnter", {
--   callback = function()
--     local cwd = vim.fn.getcwd()
--     local session_file = cwd:gsub("[/\\]", "_") .. ".vim" -- Convert the path to a file-safe format
--     local session_path = vim.fn.stdpath("data") .. "/sessions/" .. session_file
--
--     if vim.fn.filereadable(session_path) == 1 then
--       vim.cmd("silent! source " .. session_path) -- Load the session if it exists
--     end
--   end,
-- })
--
-- vim.api.nvim_create_autocmd("VimLeavePre", {
--   callback = function()
--     local cwd = vim.fn.getcwd()
--     local session_file = cwd:gsub("[/\\]", "_") .. ".vim" -- Convert the path to a file-safe format
--     local session_path = vim.fn.stdpath("data") .. "/sessions/" .. session_file
--
--     -- Ensure the session directory exists
--     vim.fn.mkdir(vim.fn.stdpath("data") .. "/sessions", "p")
--
--     -- Save the current session to the specified path
--     vim.cmd("mksession! " .. session_path)
--   end,
-- })


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
-- Set up LSP
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", },
  callback = function(ev)
    vim.lsp.start({
      name = "clangd",
      cmd = { "clangd", },
      root_dir = vim.fs.root(ev.buf, {
        "compile_commands.json",
        ".clangd",
      }),
      capabilities = require("blink.cmp").get_lsp_capabilities(),
    })
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    -- Not sure if this captures the dependencies correctly,
    -- will this autocommand unconditionally wait until telescope is loaded?
    local fzf = require("fzf-lua")
    if client.supports_method("textDocument/documentSymbol") then
      vim.keymap.set("n", "<leader>lds", fzf.lsp_document_symbols, {})
    end
    if client.supports_method("workspace/symbol") then
      vim.keymap.set("n", "<leader>lws", fzf.lsp_workspace_symbols, {})
    end
    if client.supports_method("textDocument/references") then
      vim.keymap.set("n", "<leader>lr", fzf.lsp_references, {})
    end
    -- Can't this be subsumed by some tags keymap?
    if client.supports_method("textDocument/definition") then
      vim.keymap.set("n", "<leader>gd", fzf.lsp_definitions, {})
    end
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
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons", },
      lazy = false,
      config = function()
        require("lualine").setup()
      end,
    },
    {
      "rmagatti/auto-session",
      lazy = false,
      ---@module "auto-session"
      ---@type AutoSession.Config
      opts = {
        suppressed_dirs = { "~/", "~/Downloads", "/", },
        -- log_level = 'debug',
      },
    },
    {
      "vimwiki/vimwiki",
      init = function()
        vim.g.vimwiki_list = {
          {
            path = "~/vimwiki",
            syntax = "markdown",
            ext = ".wiki.md",
            links_space_char = "-",
            diary_frequency = "weekly",
            diary_start_week_day = "sunday",
            diary_rel_path = "",
          },
        }
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      lazy = false,
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = {
            -- my typical hobby languages
            "c",
            "cpp",
            "python",
            "rust", "toml",
            -- scripting etc.
            "bash",
            "make",
            "dot",
            "lua",
            "vim",
            "vimdoc",
            "query", -- ?
            -- writing
            "bibtex",
            "beancount",
            "markdown",
          },
          -- auto_install = true, -- install for any new file

          -- Use the treesitter grammar to enable text objects.
          -- Requires "nvim-treesitter/nvim-treesitter-textobjects"
          textobjects = {
            select = {
              enable = true,
              lookahead = true,
              keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
              },
            },
          },
        })
      end,
      dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
      },
    },
    {
      'saghen/blink.cmp',
      -- optional: provides snippets for the snippet source
      -- dependencies = 'rafamadriz/friendly-snippets',

      -- use a release tag to download pre-built binaries
      version = 'v0.*',
      -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
      -- build = 'cargo build --release',
      -- If you use nix, you can build from source using latest nightly rust with:
      -- build = 'nix run .#build-plugin',

      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      opts = {
        -- https://cmp.saghen.dev/configuration/keymap.html
        keymap = {
          preset = 'none',
          ['<Tab>'] = { 'select_next', 'fallback' },
          ['<C-j>'] = { 'select_next', 'fallback' },
          ['<C-n>'] = { 'select_next', 'fallback' },
          ['<C-k>'] = { 'select_prev', 'fallback' },
          ['<C-p>'] = { 'select_prev', 'fallback' },
          ['<CR>'] = { 'accept', 'fallback' },
          ['<Esc>'] = { 'hide', 'fallback'},
        },
        completion = {
          list = {
            selection = 'manual',
          },
        },

        appearance = {
          -- Sets the fallback highlight groups to nvim-cmp's highlight groups
          -- Useful for when your theme doesn't support blink.cmp
          -- will be removed in a future release
          use_nvim_cmp_as_default = true,
          -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
          -- Adjusts spacing to ensure icons are aligned
          nerd_font_variant = 'mono'
        },

        -- default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, via `opts_extend`
        sources = {
          default = {
            'lsp', 
            'path',
            -- 'snippets',
            'buffer',
          },
          -- optionally disable cmdline completions
          -- cmdline = {},
        },

        -- experimental signature help support
        -- signature = { enabled = true }
      },
      -- allows extending the providers array elsewhere in your config
      -- without having to redefine it
      opts_extend = { "sources.default" }
    },
    {
      "ibhagwan/fzf-lua",
      lazy=false,
      -- optional for icon support
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        -- -- calling `setup` is optional for customization
        local fzf = require("fzf-lua")
        fzf.setup({
          winopts = {
            preview = {
              layout='vertical',
            },
          },
          files = {
            formatter="path.filename_first",
            path_shorten = 3,
          },
        })

        vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "fzf find files", })
        vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "fzf live grep", })
        vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "fzf buffers", })
        vim.keymap.set("n", "<leader>fh", fzf.helptags, { desc = "fzf help tags", })
        vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "fzf keymaps", })
      end,
    },
    {
      "nvim-tree/nvim-tree.lua",
      version = "*",
      lazy = false,
      dependencies = {
        "nvim-tree/nvim-web-devicons",
      },
      config = function()
        -- Things to change:
        -- Have it reset the directory state on closing, or whatever.
        -- Decrease scroll delay -- or maybe that's my own keyboard?!
        require("nvim-tree").setup({
          view = {
            float = {
              enable=true,
            },
          },
        })

        local api = require("nvim-tree.api")
        vim.keymap.set("n", "<leader>tt", function()
          api.tree.open({find_file=true})
        end, { desc = "toggle neovim-tree" })
        vim.keymap.set("n", "<leader>tT", api.tree.toggle, { desc = "toggle neovim-tree global view" })
      end,
    },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "tokyonight", }, },
  checker = { enabled = false, }, -- don't check for updates.
})

