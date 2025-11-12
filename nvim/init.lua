-- File: init.lua (Installation Block)

vim.pack.add({

  -- === Dependencies (Must be installed before dependent plugins) ===
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },

  -- === Main Plugins ===
  { src = 'https://github.com/folke/tokyonight.nvim' },
  { src = 'https://github.com/tpope/vim-fugitive' },
  { src = 'https://github.com/nvim-lualine/lualine.nvim' }, -- (Depends on nvim-web-devicons, which is above)
  { src = 'https://github.com/rmagatti/auto-session' },
  { src = 'https://github.com/vimwiki/vimwiki' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects' }, -- (Treesitter dependency)
  { src = 'https://github.com/ibhagwan/fzf-lua' },                            -- (Depends on nvim-web-devicons, which is above)
  { src = 'https://github.com/nvim-tree/nvim-tree.lua' },                     -- (Depends on nvim-web-devicons, which is above)
  -- Note: If you want to use specific tags/versions, add them here:
  -- { src = 'https://github.com/nvim-tree/nvim-tree.lua', tag = 'v1.0.0' },
  -- === Auto-Completion ===
  { src = 'https://github.com/hrsh7th/nvim-cmp' },     -- The completion engine
  { src = 'https://github.com/hrsh7th/cmp-nvim-lsp' }, -- LSP source for nvim-cmp
  -- You can also add snipmate source for full function completion experience:
  { src = 'https://github.com/saadparwaiz1/cmp_luasnip' },
  { src = 'https://github.com/L3MON4D3/LuaSnip' }, -- Snippet engine

})

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- GLOBALS
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
vim.g.mapleader          = " "
vim.g.maplocalleader     = " "
vim.g.clipboard          = { -- startup improvement https://github.com/neovim/neovim/issues/9570
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
vim.opt.tabstop          = 2 -- how many chars tab takes up
vim.opt.shiftwidth       = 2
vim.opt.softtabstop      = 2
vim.opt.expandtab        = true
vim.opt.smartindent      = true
vim.opt.wrap             = false

-- Search
vim.opt.incsearch        = true
vim.opt.ignorecase       = true -- this is also for autocomplete of commands
vim.opt.smartcase        = true

-- Appearance
vim.opt.number           = true
-- opt.colorcolumn = "96" Don't really like this TBH.
vim.opt.signcolumn       = "yes"
vim.opt.cmdheight        = 1
vim.opt.scrolloff        = 6
vim.opt.completeopt      = "menuone,noinsert,noselect" -- TODO revisit this
vim.opt.wrap             = true
vim.opt.linebreak        = true
vim.opt.breakindent      = true
vim.opt.termguicolors    = true

-- Behavior
vim.opt.hidden           = true -- TODO revisit this
vim.opt.errorbells       = false
vim.opt.swapfile         = false
vim.opt.backup           = false
-- opt.undodir = vim.fn.expand("~/.vim/undodir") -- TODO: Revisit this
-- opt.undofile = true
vim.opt.backspace        = "indent,eol,start"
vim.opt.splitright       = true
vim.opt.splitbelow       = true
vim.opt.clipboard        = "unnamedplus"
vim.opt.modifiable       = true

-- Spelling
vim.opt.spell            = true
vim.opt.spelllang        = { "en_us", }
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
-- Set up LSPs
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

vim.lsp.config['clangd'] = {
  cmd = { 'clangd' },
  filetypes = { 'c', 'cpp' },
  root_dir = vim.fs.root(0, { '.clangd', 'compile_commands.json' }),
}
vim.lsp.enable('clangd')

vim.lsp.config['tinymist'] = {
  cmd = { 'tinymist' },
  filetypes = { 'typ', 'typst' },
  root_dir = vim.fs.root(0, { '.git' }),

  settings = {
    formatterMode = 'typstyle',
    exportPdf = 'onType',
    semanticTokens = 'disable',
  },
}
vim.lsp.enable('tinymist')

-- I just use lua for neovim, so this is just to make life easier with that.
vim.lsp.config['lua_ls'] = {
  -- Command and arguments to start the server.
  cmd = { 'lua-language-server' },
  -- Filetypes to automatically attach to.
  filetypes = { 'lua' },
  root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" }, -- see https://stackoverflow.com/questions/79647620/undefined-global-vim
      },
      -- This let's the LSP know about the vim namespace and symbols and so on.
      workspace = {
        version = 'LuaJIT',
        library = {
          -- Use vim.fn.stdpath to dynamically find the correct directory
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          -- Optionally, add your Neovim config directory for completion of your own functions
          [vim.fn.stdpath('config')] = true,
        }
      },
    }
  },
}
vim.lsp.enable('lua_ls')


vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', { clear = true }), -- Clear old autocommands
  callback = function(args)
    local fzf = require('fzf-lua')
    local map = vim.keymap.set

    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    local bufnr = args.buf
    local opts = { buffer = bufnr, silent = true } -- Options for keymaps

    -- === 2. Formatting on Save (Your Existing Code) ===
    if not client:supports_method('textDocument/willSaveWaitUntil')
        and client:supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('my.lsp.format', { clear = false }),
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr, id = client.id, timeout_ms = 1000 })
        end,
      })
    end

    -- === 3. LSP Navigation Keymaps (Native vs. Fzf-lua) ===

    -- 3a. Native LSP Keymaps (for actions not suited for a fuzzy finder)
    map('n', 'K', vim.lsp.buf.hover, opts)                -- Show Hover documentation
    map('n', '<leader>rn', vim.lsp.buf.rename, opts)      -- Rename symbol
    map('n', '<leader>ca', vim.lsp.buf.code_action, opts) -- Code Actions

    -- 3b. Fzf-lua LSP Integration (for interactive searching/listing)
    if pcall(require, 'fzf-lua') then
      -- Document/Workspace Symbols
      map('n', 'gO', function() fzf.lsp_document_symbols() end, opts)          -- Buffer Symbols
      map('n', '<leader>ws', function() fzf.lsp_workspace_symbols() end, opts) -- Project Symbols

      -- Jumps (Uses fzf-lua for multi-definition results)
      map('n', 'gd', function() fzf.lsp_definitions() end, opts)     -- Go to Definition
      map('n', 'gr', function() fzf.lsp_references() end, opts)      -- Find References
      map('n', 'gi', function() fzf.lsp_implementations() end, opts) -- Go to Implementation
      map('n', 'gt', function() fzf.lsp_typedefs() end, opts)        -- Go to Type Definition

      -- Diagnostics Listing
      map('n', '<leader>ld', function() fzf.diagnostics_document() end, opts)  -- List buffer diagnostics
      map('n', '<leader>lw', function() fzf.diagnostics_workspace() end, opts) -- List workspace diagnostics
    else
      -- Fallback: Use native functions if fzf-lua is not installed/loaded
      map('n', 'gd', vim.lsp.buf.definition, opts)
      map('n', 'gr', vim.lsp.buf.references, opts)
    end

    -- -- 3c. Native Diagnostics Navigation (Quick Jump)
    -- map('n', '[d', vim.diagnostic.goto_prev, opts)
    -- map('n', ']d', vim.diagnostic.goto_next, opts)
  end,
})

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- PLUGINS
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Helper function to require and setup a plugin, reporting errors if they occur.
local function setup_plugin(name, setup_func)
  local ok, plugin = pcall(require, name)

  if not ok then
    -- 'plugin' now holds the error message from the failed 'require' call
    vim.notify(
      string.format("Plugin '%s' failed to load. Error: %s", name, plugin),
      vim.log.levels.ERROR,
      { title = "Plugin Load Error" }
    )
    return
  end

  -- If loading was successful, run the configuration function in protected mode
  -- to catch setup errors.
  local setup_ok, err = pcall(setup_func, plugin)

  if not setup_ok then
    -- 'err' now holds the error message from the failed setup function
    vim.notify(
      string.format("Plugin '%s' setup failed. Error: %s", name, err),
      vim.log.levels.ERROR,
      { title = "Plugin Setup Error" }
    )
  end
end
--------------------------------------------------------------------------------
-- === GLOBAL VARIABLE CONFIGURATION (NO pcall needed) ===

-- vimwiki/vimwiki
vim.g.vimwiki_list = {
  {
    path = "$ONEDRIVE_PATH/Documents/vimwiki",
    syntax = "markdown",
    ext = ".wiki.md",
    links_space_char = "-",
    diary_start_week_day = "sunday",
    diary_rel_path = "",
  },
}

-- rmagatti/auto-session
vim.g.auto_session_config = {
  log_level = 'info',
  suppressed_dirs = { "~/", "~/Downloads", "/", },
}



--------------------------------------------------------------------------------
-- === PLUGIN SETUP USING THE HELPER FUNCTION ===

-- Load this plugin immediately
setup_plugin("auto-session", function(auto_session)
  auto_session.setup()
end)

-- 1. folke/tokyonight.nvim
setup_plugin("tokyonight", function()
  vim.cmd("colorscheme tokyonight-night")
end)

-- 2. nvim-treesitter/nvim-treesitter
setup_plugin("nvim-treesitter.configs", function(ts_configs)
  ts_configs.setup({
    ensure_installed = {
      "c", "cpp", "python", "rust", "toml", "bash", "make", "typst",
      "dot", "lua", "vim", "vimdoc", "query", "bibtex", "beancount", "markdown",
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = { ["af"] = "@function.outer", ["if"] = "@function.inner", },
      },
    },
  })
end)

-- 3. nvim-lualine/lualine.nvim
setup_plugin("lualine", function(lualine)
  lualine.setup()
end)

-- 4. ibhagwan/fzf-lua
setup_plugin("fzf-lua", function(fzf)
  fzf.setup({
    winopts = { preview = { layout = 'vertical', }, },
  })

  vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "fzf find files", })
  vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "fzf live grep", })
  vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "fzf buffers", })
  vim.keymap.set("n", "<leader>fh", fzf.helptags, { desc = "fzf help tags", })
  vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "fzf keymaps", })
end)

-- 5. nvim-tree/nvim-tree.lua
setup_plugin("nvim-tree", function(nvim_tree)
  nvim_tree.setup({
    view = { float = { enable = true, }, },
  })

  local api = require("nvim-tree.api")
  vim.keymap.set("n", "<leader>tt", function()
    api.tree.open({ find_file = true })
  end, { desc = "toggle neovim-tree" })
  vim.keymap.set("n", "<leader>tT", api.tree.toggle, { desc = "toggle neovim-tree global view" })
end)

-- 6. hrsh7th/nvim-cmp (The standard Neovim completion engine)
setup_plugin("cmp", function(cmp)
  local luasnip = require('luasnip')

  cmp.setup({
    -- Configure the different completion sources
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' }, -- For snippets
      { name = 'buffer' },
    }),

    -- Set up keybindings
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept selected item
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    }),
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
  })
end)
