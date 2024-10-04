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
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "===BINARY===" })
        end)
      end
    end,
  }):sync()
end

local builtin = require("telescope.builtin")
return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  lazy = false,
  keys = {
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" }),
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" }),
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" }),
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" }),
    vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Telescope keymaps" }),
    vim.keymap.set("n", "<leader>f/", builtin.current_buffer_fuzzy_find, { desc = "Telescope search" }),
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
