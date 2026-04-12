-- 自动命令

local general = vim.api.nvim_create_augroup('General', { clear = true })
local statusline = require('core.statusline')

vim.api.nvim_create_autocmd('BufWritePre', {
  group = general,
  pattern = '*',
  callback = function(args)
    local view = vim.fn.winsaveview()
    vim.api.nvim_buf_call(args.buf, function()
      vim.cmd([[silent keepjumps keeppatterns %s/\s\+$//e]])
    end)
    vim.fn.winrestview(view)
  end,
  desc = '保存前清理尾随空白',
})

vim.api.nvim_create_autocmd('TextYankPost', {
  group = general,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
  end,
  desc = '高亮复制的文本',
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'FocusGained' }, {
  group = general,
  callback = function(args)
    statusline.refresh_git(args.buf or vim.api.nvim_get_current_buf())
    vim.cmd.redrawstatus()
  end,
  desc = '刷新状态栏 git 缓存',
})
