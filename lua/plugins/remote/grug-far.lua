-- grug-far.nvim: 交互式查找替换面板，适合做项目级批量替换
-- 在命令或键位触发时加载
return {
  repo = 'MagicDuck/grug-far.nvim',
  load = {
    commands = {
      { name = 'GrugFar', desc = '打开 GrugFar 替换面板' },
      { name = 'GrugFarWithin', desc = '在选区内打开 GrugFar 替换面板' },
    },
    keys = {
      { { 'n', 'x' }, '<leader>rr', '<Cmd>GrugFar<CR>', { desc = '打开替换面板' } },
      { 'x', '<leader>rR', '<Cmd>GrugFarWithin<CR>', { desc = '在选区内替换' } },
    },
  },
}
