return {
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
}

