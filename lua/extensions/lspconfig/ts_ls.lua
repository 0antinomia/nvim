-- typescript-language-server: JS/TS/React 系列文件的主语言服务
local lsp = require('extensions.lsp')

lsp.setup_server('ts_ls', {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  root_markers = {
    'tsconfig.json',
    'jsconfig.json',
    'package.json',
    'pnpm-workspace.yaml',
    '.git',
  },
  init_options = {
    hostInfo = 'neovim',
  },
})
