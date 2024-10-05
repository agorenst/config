return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
  },
  lazy = false,
  config = function()
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local lspconfig = require("lspconfig")

    local capabilities = cmp_nvim_lsp.default_capabilities()
    capabilities.offset_encoding = { "utf-8" }

    local lsp_fmt_group = vim.api.nvim_create_augroup("LspFormattingGroup", {})
    local on_attach = function(client, buffer)
      -- Enable LSP-based keybindings here
      local bufopts = { noremap = true, silent = true, buffer = buffer }

      vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
      vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, bufopts)

      -- Formatting on save
      if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_clear_autocmds({ group = lsp_fmt_group, buffer = buffer })
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = lsp_fmt_group,
          buffer = buffer,
          callback = function()
            vim.lsp.buf.format({ async = false })
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
            globals = { "vim" },
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

    lspconfig.marksman.setup({})

    -- Can't install LSP these days.
    -- lspconfig.fish_lsp.setup({
    --   capabilities = capabilities,
    --   on_attach = on_attach,
    -- })
  end,
}
