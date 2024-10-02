local config = function()
	local cmp_nvim_lsp = require("cmp_nvim_lsp")
	local lspconfig = require("lspconfig")

	local capabilities = cmp_nvim_lsp.default_capabilities()
	capabilities.offset_encoding = { "utf-8" }

	local on_attach = function(_, buffer)
		-- Enable LSP-based keybindings here
		local bufopts = { noremap = true, silent = true, buffer = buffer }

		-- Go to Definition
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
		-- Go to Declaration
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
		-- Find References
		vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
		-- hrrrrm
		vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, bufopts)
		-- Rename symbol
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
		-- Format document
		vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, bufopts)
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

	local luacheck = require("efmls-configs.linters.luacheck")
	local stylua = require("efmls-configs.formatters.stylua")
	local flake8 = require("efmls-configs.linters.flake8")
	local black = require("efmls-configs.formatters.black")
	local clang_format = require("efmls-configs.formatters.clang_format")
	local latexindent = require("efmls-configs.formatters.latexindent")

	lspconfig.efm.setup({
		capabilities = capabilities,
		filetypes = { "lua", "python", "cpp", "c", "tex" },
		init_options = {
			documentFormatting = true,
			documentRangeFormatting = true,
			hover = false, -- TODO not sure about this...
			documentSymbol = true,
			codeAction = true,
			completion = true,
		},
		settings = {
			languages = {
				lua = { luacheck, stylua },
				python = { flake8, black },
				cpp = { clang_format },
				c = { clang_format },
				tex = { latexindent },
			},
		},
	})

	-- TODO do we want "clear = true"?
	local lsp_fmt_group = vim.api.nvim_create_augroup("LspFormattingGroup", {})
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = lsp_fmt_group,
		callback = function()
			local efm = vim.lsp.get_clients({ name = "efm" })
			if vim.tbl_isempty(efm) then
				return
			end
			vim.lsp.buf.format({ name = "efm" })
		end,
	})
end

return {
	"neovim/nvim-lspconfig",
	lazy = false,
	config = config,
	dependencies = {
		"williamboman/mason.nvim",
		"creativenull/efmls-configs-nvim",
	},
}
