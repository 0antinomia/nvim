-- emmet-language-server: HTML/CSS/React 场景下的 Emmet 展开补全
local lsp = require('extensions.lsp')

lsp.setup_server('emmet_language_server', {
  cmd = { 'emmet-language-server', '--stdio' },
  filetypes = {
    'html',
    'css',
    'scss',
    'less',
    'javascriptreact',
    'typescriptreact',
  },
})
