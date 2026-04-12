-- 基础快捷键

local set = vim.keymap.set

vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- 文件
set('n', '<leader>wf', '<Cmd>w<CR>', { desc = '保存文件' })
set('n', '<leader>q', '<Cmd>q<CR>', { desc = '退出' })
set('n', '<leader>wq', '<Cmd>wq<CR>', { desc = '保存并退出' })

-- 窗口
set('n', '<leader>sv', '<C-w>v', { desc = '垂直分屏' })
set('n', '<leader>sh', '<C-w>s', { desc = '水平分屏' })
set('n', '<leader>se', '<C-w>=', { desc = '等分窗口' })
set('n', '<leader>sx', '<Cmd>close<CR>', { desc = '关闭窗口' })
set('n', '<C-h>', '<C-w>h', { desc = '跳转到左侧窗口' })
set('n', '<C-j>', '<C-w>j', { desc = '跳转到下方窗口' })
set('n', '<C-k>', '<C-w>k', { desc = '跳转到上方窗口' })
set('n', '<C-l>', '<C-w>l', { desc = '跳转到右侧窗口' })

-- 标签页
set('n', '<leader>to', '<Cmd>tabnew<CR>', { desc = '打开新标签页' })
set('n', '<leader>tx', '<Cmd>tabclose<CR>', { desc = '关闭当前标签页' })
set('n', '<leader>tn', '<Cmd>tabn<CR>', { desc = '下一个标签页' })
set('n', '<leader>tp', '<Cmd>tabp<CR>', { desc = '上一个标签页' })

-- 缓冲区
set('n', '<leader>bd', '<Cmd>bdelete<CR>', { desc = '关闭当前缓冲区' })

-- 编辑
set('n', '<leader>h', '<Cmd>nohlsearch<CR>', { desc = '清除搜索高亮' })
set('x', 'J', ":m '>+1<CR>gv=gv", { desc = '向下移动选中行', silent = true })
set('x', 'K', ":m '<-2<CR>gv=gv", { desc = '向上移动选中行', silent = true })
set('i', 'jk', '<Esc>', { desc = '退出插入模式' })
set('x', 'p', '"_dP', { desc = '粘贴不覆盖寄存器' })
set('n', '<C-a>', 'ggVG', { desc = '全选' })
set({ 'n', 'x' }, 'H', '^', { desc = '行首' })
set({ 'n', 'x' }, 'L', '$', { desc = '行尾' })
set('n', '<leader>lf', function()
  vim.lsp.buf.format({ async = true })
end, { desc = 'LSP 整理当前文件' })
