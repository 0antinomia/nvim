-- hop.nvim: 轻量级屏内跳转插件，用于快速跳到目标单词
-- 通过 keys 加载
return {
  repo = 'smoka7/hop.nvim',
  load = {
    keys = {
      { 'n', '<leader>jw', '<Cmd>HopWord<CR>', { desc = '跳转到单词' } },
    },
  },
  setup = function()
    require('hop').setup({
      hint_position = 3,
    })
  end,
}
