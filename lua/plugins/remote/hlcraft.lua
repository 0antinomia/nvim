-- hlcraft.nvim: 高亮组统一管理入口
return {
  repo = '0antinomia/hlcraft.nvim',
  priority = 1000,
  load = {
    eager = true,
  },
  setup = function()
    require('hlcraft').setup({
      from_none = {
        enabled = true,
        scope = 'extended',
      },
      reapply_events = {
        enabled = false,
        events = {
          'ColorScheme',
        },
      },
    })
  end,
}
