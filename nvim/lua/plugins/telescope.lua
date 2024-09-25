local actions = require("telescope.actions")

-- From wiki: disable preview on binary files.
local previewers = require("telescope.previewers")
local Job = require("plenary.job")
local new_maker = function(filepath, bufnr, opts)
  filepath = vim.fn.expand(filepath)
  Job:new({
    command = "file",
    args = { "--mime-type", "-b", filepath },
    on_exit = function(j)
      local mime_type = vim.split(j:result()[1], "/")[1]
      if mime_type == "text" then
        previewers.buffer_previewer_maker(filepath, bufnr, opts)
      else
        -- maybe we want to write something to the buffer here
        vim.schedule(function()
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
        end)
      end
    end
  }):sync()
end

require("telescope").setup {
  defaults = {
    buffer_previewer_maker = new_maker,
  }
}
return {
	"nvim-telescope/telescope.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	lazy = false,
	keys = {
		vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Telescope find files" }),
		vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Telescope live grep" }),
		vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "Telescope buffers" }),
		vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>", { desc = "Telescope help tags" }),
		vim.keymap.set("n", "<leader>fk", ":Telescope keymaps<CR>", { desc = "Telescope keymaps" }),
		vim.keymap.set("n", "<leader>f/", ":Telescope current_buffer_fuzzy_find<CR>", { desc = "Telescope search" }),
	},
	config = function()
		require("telescope").setup({
			defaults = {
        buffer_previewer_maker = new_maker,
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
			},
		})
	end,
}
