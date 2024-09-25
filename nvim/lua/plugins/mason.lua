local config = function()
  require('mason').setup {
  }
end
return {
  "williamboman/mason.nvim",
  config = config,
  lazy = false
}
