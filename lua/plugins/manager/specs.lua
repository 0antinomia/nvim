local shared = require('plugins.manager.shared')
local state = require('plugins.manager.state').data

local M = {}

local fn = shared.fn
local github_url = shared.github_url
local infer_name = shared.infer_name
local listify = shared.listify

local function add_alias(alias, name)
  if alias and alias ~= '' then
    state.aliases[alias] = name
  end
end

local function normalize_spec(module_name, raw)
  if raw.enabled == false then
    return
  end

  local repo = raw.repo or raw[1]
  if type(repo) ~= 'string' then
    error(('插件 %s 缺少 repo 字段'):format(module_name))
  end

  local name = raw.name or infer_name(repo)
  local load = raw.load or {}
  local spec = {
    build = raw.build,
    commands = listify(load.commands),
    dependencies = listify(raw.dependencies),
    events = listify(load.events),
    eager = load.eager == true,
    keys = listify(load.keys),
    module = module_name,
    name = name,
    priority = raw.priority or 0,
    repo = repo,
    setup = raw.setup,
    src = github_url(repo),
    version = raw.version or raw.branch or raw.tag or raw.commit,
  }

  state.specs[name] = spec
  table.insert(state.order, name)

  add_alias(name, name)
  add_alias(repo, name)
  add_alias(module_name, name)
  add_alias(infer_name(repo), name)

  return spec
end

function M.collect()
  local files = fn.glob(fn.stdpath('config') .. '/lua/plugins/remote/*.lua', false, true)
  table.sort(files)

  for _, file in ipairs(files) do
    local module_name = ('plugins.remote.%s'):format(fn.fnamemodify(file, ':t:r'))
    local ok, raw = pcall(require, module_name)
    if not ok then
      error(('加载插件模块 %s 失败: %s'):format(module_name, raw))
    end
    normalize_spec(module_name, raw)
  end
end

function M.resolve_name(name)
  return state.aliases[name] or state.aliases[infer_name(name)]
end

return M
