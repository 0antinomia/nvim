-- nvim-surround: 提供 ys/cs/ds 等 surround 文本操作
-- 通过 keys 加载
return {
  repo = 'kylechui/nvim-surround',
  load = {
    keys = {
      { 'n', 'ys', 'ys', { desc = '添加 surround' } },
      { 'n', 'yss', 'yss', { desc = '为整行添加 surround' } },
      { 'n', 'yS', 'yS', { desc = '添加 surround 并换行' } },
      { 'n', 'ySS', 'ySS', { desc = '为整行添加 surround 并换行' } },
      { 'n', 'ds', 'ds', { desc = '删除 surround' } },
      { 'n', 'cs', 'cs', { desc = '替换 surround' } },
      { 'n', 'cS', 'cS', { desc = '替换 surround 并换行' } },
      { 'x', 'S', 'S', { desc = '为选区添加 surround' } },
      { 'x', 'gS', 'gS', { desc = '为选区添加 surround 并换行' } },
    },
  },
  setup = function()
    require('nvim-surround').setup({
      keymaps = {
        insert = false,
      },
    })
  end,
}
