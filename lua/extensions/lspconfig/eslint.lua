-- eslint-language-server: JS/TS 项目的 lint、诊断与代码动作来源
local lsp = require('extensions.lsp')

lsp.setup_server('eslint', {
  cmd = { 'vscode-eslint-language-server', '--stdio' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  root_markers = {
    'eslint.config.js',
    'eslint.config.cjs',
    'eslint.config.mjs',
    'eslint.config.ts',
    '.eslintrc',
    '.eslintrc.js',
    '.eslintrc.cjs',
    '.eslintrc.json',
    'package.json',
    '.git',
  },
})
