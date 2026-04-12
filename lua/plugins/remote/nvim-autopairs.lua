-- nvim-autopairs: 自动补全括号、引号等成对符号
-- 放在 InsertEnter 后加载
return {
  repo = 'windwp/nvim-autopairs',
  load = {
    events = { 'InsertEnter' },
  },
  setup = function()
    require('nvim-autopairs').setup()
  end,
}
