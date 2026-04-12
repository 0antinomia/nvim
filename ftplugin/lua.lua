-- Lua 文件的局部缩进规则
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2

require('extensions.lsp').activate({
  'extensions.lspconfig.lua_ls',
})
require('extensions.treesitter').enable('lua')
