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
    })
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    -- Not sure if this captures the dependencies correctly,
    -- will this autocommand unconditionally wait until telescope is loaded?
    local builtin = require("telescope.builtin")
    if client.supports_method("textDocument/documentSymbol") then
      vim.keymap.set("n", "<leader>lds", builtin.lsp_document_symbols, {})
    end
    if client.supports_method("workspace/symbol") then
      vim.keymap.set("n", "<leader>lws", builtin.lsp_workspace_symbols, {})
    end
    if client.supports_method("textDocument/references") then
      vim.keymap.set("n", "<leader>lr", builtin.lsp_references, {})
    end
    -- Can't this be subsumed by some tags keymap?
    if client.supports_method("textDocument/definition") then
      vim.keymap.set("n", "<leader>gd", builtin.lsp_definitions, {})
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
      "williamboman/mason.nvim",
      config = function()
        require("mason").setup({})
      end,
      lazy = false,
    },
    {
      -- Autocompletion engine
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
        "hrsh7th/cmp-buffer",   -- Buffer source for nvim-cmp
        "hrsh7th/cmp-path",     -- Filesystem paths
        "hrsh7th/cmp-cmdline",  -- Cmdline completion
        "L3MON4D3/LuaSnip",     -- Snippet engine
      },
      config = function()
        local cmp = require("cmp")
        cmp.setup({
          snippet = {
            expand = function(args)
              require("luasnip").lsp_expand(args.body) -- For `luasnip` users
            end,
          },
          mapping = {
            ["<c-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert, }),
            ["<tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert, }),
            ["<c-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert, }),
            ["<cr>"] = cmp.mapping.confirm({ select = true, }),
          },
          sources = cmp.config.sources({
            { name = "nvim_lsp", }, -- LSP-based completion
            { name = "luasnip", },
            -- { name = "buffer" }, -- Buffer-based completion
            { name = "path", },   -- Path-based completion
            { name = "vimtex", }, -- https://github.com/micangl/cmp-vimtex
          }),
        })
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
      "nvim-telescope/telescope.nvim",
      dependencies = { "nvim-lua/plenary.nvim", },
      lazy = false,
      config = function()
        local actions = require("telescope.actions")
        require("telescope").setup({
          defaults = {
            -- From wiki: disable preview on binary files.
            buffer_previewer_maker = function(filepath, bufnr, opts)
              local Job = require("plenary.job")
              local previewers = require("telescope.previewers")
              filepath = vim.fn.expand(filepath)
              Job:new({
                command = "file",
                args = { "--mime-type", "-b", filepath, },
                on_exit = function(j)
                  local mime_type = vim.split(j:result()[1], "/")[1]
                  if mime_type == "text" then
                    previewers.buffer_previewer_maker(filepath, bufnr, opts)
                  else
                    -- maybe we want to write something to the buffer here
                    vim.schedule(function()
                      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "===BINARY===", })
                    end)
                  end
                end,
              }):sync()
            end,


            file_sorter = require("telescope.sorters").get_fuzzy_file, -- allow for fuzzy matching
            mappings = {
              i = {
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
              },
              n = {
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
              },
            },
            layout_strategy = "vertical",
          },
        })
        -- Set the keymapping:
        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files", })
        vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep", })
        vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers", })
        vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags", })
        vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Telescope keymaps", })
        -- vim.keymap.set("n", "<leader>f/",
        --   require("telescope.builtin").current_buffer_fuzzy_find { desc = "Telescope search", })
      end,
    },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "tokyonight", }, },
  checker = { enabled = false, }, -- don't check for updates.
})
