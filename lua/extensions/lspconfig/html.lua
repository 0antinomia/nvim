-- vscode-html-language-server: HTML 语言服务
local lsp = require('extensions.lsp')

lsp.setup_server('html', {
  cmd = { 'vscode-html-language-server', '--stdio' },
  filetypes = { 'html' },
  root_markers = {
    'package.json',
    '.git',
  },
})
