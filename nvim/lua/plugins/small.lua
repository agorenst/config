return {
  {
    "micangl/cmp-vimtex",
    lazy = false,
  },
  {
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
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 999,
    opts = {},
    config = function()
      vim.cmd("colorscheme tokyonight-night")
    end,
  },
  {
    "rmagatti/auto-session",
    lazy = false,

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      suppressed_dirs = { "~/", "~/Downloads", "/" },
      -- log_level = 'debug',
    },
  },
  {
    "tpope/vim-fugitive",
    lazy = false,
  },
}
