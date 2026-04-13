local M = {}

M.data = {
  aliases = {}, -- name/module/repo/path 等别名到规范插件名的映射
  command_stubs = {}, -- 懒加载期间临时注册的命令桩
  configured = {}, -- 已执行 setup 的插件
  disabled = {}, -- 显式禁用但仍受管理的插件
  loaded = {}, -- 已完成运行时加载的插件
  order = {}, -- 当前活动插件的加载顺序
  shadowed = {}, -- 被同名 dev 插件覆盖的 remote 插件
  specs = {}, -- 当前活动插件规格，按规范名索引
}

function M.reset()
  M.data.aliases = {}
  M.data.command_stubs = {}
  M.data.configured = {}
  M.data.disabled = {}
  M.data.loaded = {}
  M.data.order = {}
  M.data.shadowed = {}
  M.data.specs = {}
end

return M
