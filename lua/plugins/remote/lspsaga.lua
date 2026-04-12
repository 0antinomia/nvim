-- lspsaga.nvim: LSP 交互界面层，负责 hover、rename、outline、诊断跳转等
-- 通过 keys 加载
return {
  repo = 'nvimdev/lspsaga.nvim',
  load = {
    keys = {
      { 'n', '<leader>la', '<Cmd>Lspsaga code_action<CR>', { desc = '代码操作' } },
      { 'n', '<leader>lr', '<Cmd>Lspsaga rename<CR>', { desc = '重命名' } },
      { 'n', '<leader>lo', '<Cmd>Lspsaga outline<CR>', { desc = '符号大纲' } },
      { 'n', 'gd', '<Cmd>Lspsaga goto_definition<CR>', { desc = '跳转到定义' } },
      { 'n', 'gr', '<Cmd>Lspsaga finder ref<CR>', { desc = '查找引用' } },
      { 'n', 'gi', '<Cmd>Lspsaga finder imp<CR>', { desc = '查找实现' } },
      { 'n', 'gt', '<Cmd>Lspsaga peek_type_definition<CR>', { desc = '预览类型定义' } },
      { 'n', '[d', '<Cmd>Lspsaga diagnostic_jump_prev<CR>', { desc = '上一个诊断' } },
      { 'n', ']d', '<Cmd>Lspsaga diagnostic_jump_next<CR>', { desc = '下一个诊断' } },
      { 'n', 'K', '<Cmd>Lspsaga hover_doc<CR>', { desc = '悬停文档' } },
    },
  },
  setup = function()
    require('lspsaga').setup({
      symbol_in_winbar = {
        enable = false,
      },
    })
  end,
}
