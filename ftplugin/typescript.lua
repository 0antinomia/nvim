require('extensions.lsp').activate({
  'extensions.lspconfig.ts_ls',
  'extensions.lspconfig.eslint',
  'extensions.lspconfig.emmet_language_server',
})
require('extensions.treesitter').enable('typescript')
