-- blink.cmp: 主补全引擎，统一处理插入模式和命令行补全
-- 这里固定使用本地构建的 Rust fuzzy 实现
return {
  repo = 'saghen/blink.cmp',
  dependencies = { 'friendly-snippets' },
  build = 'cargo build --release',
  load = {
    eager = true,
  },
  setup = function()
    require('blink.cmp').setup({
      fuzzy = {
        implementation = 'prefer_rust',
      },
      completion = {
        documentation = {
          auto_show = true,
        },
      },
      keymap = {
        preset = 'super-tab',
      },
      sources = {
        default = { 'path', 'snippets', 'buffer', 'lsp' },
      },
      cmdline = {
        -- / ? 走 buffer 搜索补全，: 走命令行补全
        sources = function()
          local cmd_type = vim.fn.getcmdtype()
          if cmd_type == '/' or cmd_type == '?' then
            return { 'buffer' }
          end
          if cmd_type == ':' then
            return { 'cmdline' }
          end
          return {}
        end,
        keymap = {
          preset = 'super-tab',
        },
        completion = {
          menu = {
            auto_show = true,
          },
        },
      },
    })
  end,
}
