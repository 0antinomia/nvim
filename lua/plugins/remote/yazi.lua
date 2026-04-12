-- yazi.nvim: 在 Neovim 内调用 yazi 作为文件管理器
-- 在命令或键位触发时加载
return {
  repo = 'mikavilpas/yazi.nvim',
  dependencies = { 'plenary.nvim' },
  load = {
    commands = {
      { name = 'Yazi', desc = '打开 Yazi 文件管理器' },
    },
    keys = {
      { 'n', '<leader>e', '<Cmd>Yazi<CR>', { desc = '打开 Yazi' } },
      { 'n', '<leader>E', '<Cmd>Yazi cwd<CR>', { desc = '以工作目录打开 Yazi' } },
    },
  },
  setup = function()
    require('yazi').setup()
  end,
}
