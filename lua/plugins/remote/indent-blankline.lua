-- indent-blankline.nvim: 显示缩进参考线，帮助阅读层级结构
-- 打开文件后加载
return {
  repo = 'lukas-reineke/indent-blankline.nvim',
  load = {
    events = { 'BufReadPost', 'BufNewFile' },
  },
  setup = function()
    require('ibl').setup({
      indent = {
        char = '▏',
        highlight = {
          'IblIndent',
          'IblIndent',
          'IblIndent',
          'IblIndent',
          'IblIndent',
          'IblIndent',
          'IblIndent',
        },
      },
      scope = {
        enabled = false,
      },
    })
  end,
}
