-- nvim-web-devicons: 提供文件图标
return {
  repo = 'nvim-tree/nvim-web-devicons',
  priority = 990,
  load = {
    eager = true,
  },
  setup = function()
    require('nvim-web-devicons').setup()
  end,
}
