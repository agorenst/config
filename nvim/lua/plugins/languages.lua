return {
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
          "fish", -- not able to install the LSP for now...
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
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
    },
    lazy = false,
    config = function()
      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      local lspconfig = require("lspconfig")

      local capabilities = cmp_nvim_lsp.default_capabilities()
      capabilities.offset_encoding = { "utf-8", }

      local lsp_fmt_group = vim.api.nvim_create_augroup("LspFormattingGroup", {})
      local on_attach = function(client, buffer)
        -- Per https://neovim.io/doc/user/lsp.html#_quickstart we have the default mappings:
        -- "grn" is mapped in Normal mode to vim.lsp.buf.rename()
        -- "gra" is mapped in Normal and Visual mode to vim.lsp.buf.code_action()
        -- "grr" is mapped in Normal mode to vim.lsp.buf.references()
        -- CTRL-S is mapped in Insert mode to vim.lsp.buf.signature_help()

        -- vim.keymap.set("n", "gd", vim.lsp.buf.definition)
        -- vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
        -- vim.keymap.set("n", "gr", vim.lsp.buf.references)
        -- vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
        -- vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

        vim.keymap.set("n", "grn", vim.lsp.buf.rename)
        vim.keymap.set("n", "gra", vim.lsp.buf.code_action)
        vim.keymap.set("n", "grr", vim.lsp.buf.references)
        vim.keymap.set("n", "gri", vim.lsp.buf.incoming_calls)

        vim.keymap.set("n", "grd", vim.lsp.buf.definition)
        vim.keymap.set("n", "grD", vim.lsp.buf.declaration)
        vim.keymap.set("n", "grs", vim.lsp.buf.signature_help)
        vim.keymap.set("n", "ged", vim.diagnostic.open_float)

        -- Formatting on save
        if client.server_capabilities.documentFormattingProvider then
          vim.api.nvim_clear_autocmds({ group = lsp_fmt_group, buffer = buffer, })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = lsp_fmt_group,
            buffer = buffer,
            callback = function()
              vim.lsp.buf.format({ async = false, })
            end,
          })
        end
      end

      -- lua
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim", },
            },
            format = {
              -- This is basically what we'd apply.
              defaultConfig = {
                quote_style = "double",
                trailing_table_separator = "always",
              },
            },
            workspace = {
              library = {
                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                [vim.fn.stdpath("config") .. "/lua"] = true,
              },
            },
          },
        },
      })

      -- python
      lspconfig.pyright.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- c, cpp, cuda
      lspconfig.clangd.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      lspconfig.rust_analyzer.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      lspconfig.marksman.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Can't install LSP with node gunk.
      -- lspconfig.fish_lsp.setup({
      --   capabilities = capabilities,
      --   on_attach = on_attach,
      -- })
    end,
  },
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({})
    end,
    lazy = false,
  },
}
