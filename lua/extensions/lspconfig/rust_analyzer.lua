-- rust_analyzer: Rust 语言服务，负责补全、跳转、诊断和语义信息
local lsp = require('extensions.lsp')

lsp.setup_server('rust_analyzer', {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = {
    'Cargo.toml',
    'rust-project.json',
    '.git',
  },
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        buildScripts = {
          enable = true,
        },
      },
      procMacro = {
        enable = true,
      },
    },
  },
})
