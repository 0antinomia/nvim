-- 基础选项

local opt = vim.opt
local statusline = require('core.statusline')

-- 显示
opt.number = true
opt.relativenumber = true
opt.cursorline = false
opt.wrap = false
opt.showmode = false

-- 缩进
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4

-- 搜索
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- 界面
opt.termguicolors = true
opt.signcolumn = 'yes'
opt.pumheight = 10
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.fillchars = { eob = ' ' }

-- 文件
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = false
opt.updatetime = 300

-- 窗口
opt.splitright = true
opt.splitbelow = true

-- 输入
opt.mouse = 'a'
opt.clipboard = 'unnamedplus'

-- 诊断
vim.lsp.log.set_level('error')
vim.diagnostic.config({
  virtual_text = true,
  update_in_insert = true,
})

statusline.setup_options()
