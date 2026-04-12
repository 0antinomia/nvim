-- vscode-css-language-server: CSS / SCSS / Less 语言服务
local lsp = require('extensions.lsp')

lsp.setup_server('cssls', {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  root_markers = {
    'package.json',
    '.git',
  },
})
