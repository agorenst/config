return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				-- my typical hobby languages
				"c",
				"cpp",
				"python",
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
			auto_install = true, -- install for any new file

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
}
