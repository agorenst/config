local config = function()
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
      -- writing
      "bibtex",
      "beancount",
      "markdown"
    },
    auto_install = true
  })
end
return {
  "nvim-treesitter/nvim-treesitter",
  lazy=false,
  config = config,
}
