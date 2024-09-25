return {
	-- Autocompletion engine
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
		"hrsh7th/cmp-buffer", -- Buffer source for nvim-cmp
		"hrsh7th/cmp-path", -- Filesystem paths
		"hrsh7th/cmp-cmdline", -- Cmdline completion
		"L3MON4D3/LuaSnip", -- Snippet engine
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
				["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
				["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
				["<CR>"] = cmp.mapping.confirm({ select = true }),
			},
			sources = cmp.config.sources({
				{ name = "nvim_lsp" }, -- LSP-based completion
				-- { name = "buffer" }, -- Buffer-based completion
				{ name = "path" }, -- Path-based completion
				{ name = "vimtex" }, -- https://github.com/micangl/cmp-vimtex
			}),
		})
	end,
}
