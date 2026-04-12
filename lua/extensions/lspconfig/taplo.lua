-- taplo: TOML 语言服务
local lsp = require('extensions.lsp')

lsp.setup_server('taplo', {
  cmd = { 'taplo', 'lsp', 'stdio' },
  filetypes = { 'toml' },
  root_markers = {
    'taplo.toml',
    '.taplo.toml',
    '.git',
  },
})
