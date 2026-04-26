-- hardtime.nvim: 限制低效按键重复，帮助养成更高效的编辑习惯
-- 在常规编辑开始前就加载，避免一开始的按键绕过限制
return {
  repo = 'm4xshen/hardtime.nvim',
  dependencies = { 'nui.nvim' },
  load = {
    events = { 'BufReadPre', 'BufNewFile' },
  },
  setup = function()
    require('hardtime').setup()
  end,
}
