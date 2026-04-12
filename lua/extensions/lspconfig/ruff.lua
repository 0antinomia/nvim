-- ruff: Python lint/诊断服务，同时接管 hover 之外的静态检查职责
local lsp = require('extensions.lsp')

local config = {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = {
    'ruff.toml',
    '.ruff.toml',
    'pyproject.toml',
    '.git',
  },
}

-- hover 交给 pyright，避免两个 Python server 提供重复文档窗口
lsp.extend_on_attach(config, function(client)
  client.server_capabilities.hoverProvider = false
end)

lsp.setup_server('ruff', config)
