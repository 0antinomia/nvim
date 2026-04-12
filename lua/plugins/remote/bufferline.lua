-- bufferline.nvim: 顶部缓冲区标签栏，用来管理多 buffer 切换与选择
return {
  repo = 'akinsho/bufferline.nvim',
  dependencies = {
    'nvim-web-devicons',
  },
  priority = 980,
  load = {
    eager = true,
    keys = {
      { 'n', '<leader>bh', '<Cmd>BufferLineCyclePrev<CR>', { desc = '上一个缓冲区' } },
      { 'n', '<leader>bl', '<Cmd>BufferLineCycleNext<CR>', { desc = '下一个缓冲区' } },
      { 'n', '<leader>bo', '<Cmd>BufferLineCloseOthers<CR>', { desc = '关闭其他缓冲区' } },
      { 'n', '<leader>bp', '<Cmd>BufferLinePick<CR>', { desc = '选择缓冲区' } },
      { 'n', '<leader>bc', '<Cmd>BufferLinePickClose<CR>', { desc = '选择关闭缓冲区' } },
    },
  },
  setup = function()
    require('bufferline').setup({
      options = {
        -- 尽量保持低装饰度，减少与状态栏、主题争夺视觉注意力
        style_preset = require('bufferline').style_preset.minimal,
        mode = 'buffers',
        numbers = 'none',
        indicator = 'none',
        buffer_close_icon = '◈',
        modified_icon = '◈',
        separator_style = { '', '' },
        color_icons = true,
        show_buffer_icons = true,
        max_name_length = 15,
        truncate_names = true,
        tab_size = 18,
        min_padding = 2,
        always_show_bufferline = true,
      },
    })
  end,
}
