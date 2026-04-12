-- jsonls: JSON / JSONC 语言服务
local lsp = require('extensions.lsp')

lsp.setup_server('jsonls', {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  root_markers = {
    'package.json',
    '.git',
  },
  settings = {
    json = {
      format = {
        enable = true,
      },
      validate = {
        enable = true,
      },
      schemaDownload = {
        enable = true,
      },
      schemas = {
        {
          description = 'package.json',
          fileMatch = { 'package.json' },
          url = 'https://json.schemastore.org/package.json',
        },
        {
          description = 'tsconfig.json',
          fileMatch = { 'tsconfig.json', 'tsconfig.*.json' },
          url = 'https://json.schemastore.org/tsconfig.json',
        },
        {
          description = 'pyrightconfig.json',
          fileMatch = { 'pyrightconfig.json' },
          url = 'https://raw.githubusercontent.com/microsoft/pyright/main/packages/vscode-pyright/schemas/pyrightconfig.schema.json',
        },
      },
    },
  },
})
