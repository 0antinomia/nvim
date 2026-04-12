-- pyright: Python 类型检查与补全来源
-- 当前把 import 整理和大部分 lint 职责交给 Ruff
local lsp = require('extensions.lsp')

lsp.setup_server('pyright', {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    'pyrightconfig.json',
    '.git',
  },
  settings = {
    pyright = {
      -- import organize 交给 Ruff，避免两个 server 重复给动作
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        -- 保留类型诊断，但把范围压到当前打开文件，避免和 Ruff 诊断层过度重叠
        diagnosticMode = 'openFilesOnly',
        typeCheckingMode = 'standard',
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
})
