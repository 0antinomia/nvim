-- clangd: C/C++/Objective-C 语言服务配置
local lsp = require('extensions.lsp')

local config = {
  cmd = { 'clangd' },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
  root_markers = {
    '.clangd',
    '.clang-tidy',
    '.clang-format',
    'compile_commands.json',
    'compile_flags.txt',
    'configure.ac',
    '.git',
  },
  capabilities = {
    textDocument = {
      completion = {
        -- 让 clangd 的补全编辑尽量贴近光标位置，减少大范围替换
        editsNearCursor = true,
      },
    },
    offsetEncoding = { 'utf-8', 'utf-16' },
  },
}

-- clangd 会在初始化结果里回传 offsetEncoding，这里显式接住避免编码不一致
lsp.extend_on_init(config, function(client, init_result)
  if init_result.offsetEncoding then
    client.offset_encoding = init_result.offsetEncoding
  end
end)

lsp.setup_server('clangd', config)
