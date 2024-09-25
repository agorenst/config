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
