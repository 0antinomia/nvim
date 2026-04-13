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

local function register_aliases(module_name, source, name)
  add_alias(name, name)
  add_alias(module_name, name)
  add_alias(infer_name(source), name)
end

local function insert_spec(spec)
  state.specs[spec.name] = spec
  table.insert(state.order, spec.name)
end

local function normalize_dev_spec(module_name, raw)
  if raw.enabled == false then
    return
  end

  local source = raw.dir
  if type(source) ~= 'string' or source:sub(1, 1) ~= '/' then
    error(('开发插件 %s 缺少本地 dir 字段'):format(module_name))
  end
  if fn.isdirectory(source) ~= 1 then
    error(('开发插件 %s 的目录不存在: %s'):format(module_name, source))
  end

  local name = raw.name or infer_name(source)
  local load = raw.load or {}
  local spec = {
    commands = listify(load.commands),
    dependencies = listify(raw.dependencies),
    events = listify(load.events),
    eager = load.eager == true,
    keys = listify(load.keys),
    kind = 'dev',
    module = module_name,
    name = name,
    priority = raw.priority or 0,
    setup = raw.setup,
    src = source,
  }

  insert_spec(spec)
  register_aliases(module_name, source, name)
end

local function normalize_remote_spec(module_name, raw)
  local repo = raw.repo or raw[1]
  if type(repo) ~= 'string' then
    error(('插件 %s 缺少 repo 字段'):format(module_name))
  end

  local name = raw.name or infer_name(repo)
  if state.specs[name] and state.specs[name].kind == 'dev' then
    -- 本地开发插件优先于同名远端插件，避免重复安装与加载。
    state.shadowed[name] = true
    register_aliases(module_name, repo, name)
    return
  end

  if raw.enabled == false then
    state.disabled[name] = true
    register_aliases(module_name, repo, name)
    add_alias(repo, name)
    return
  end

  local load = raw.load or {}
  local spec = {
    build = raw.build,
    commands = listify(load.commands),
    dependencies = listify(raw.dependencies),
    events = listify(load.events),
    eager = load.eager == true,
    keys = listify(load.keys),
    kind = 'remote',
    module = module_name,
    name = name,
    priority = raw.priority or 0,
    repo = repo,
    setup = raw.setup,
    src = github_url(repo),
    version = raw.version or raw.branch or raw.tag or raw.commit,
  }

  insert_spec(spec)
  register_aliases(module_name, repo, name)
  add_alias(repo, name)
end

local function collect_specs(glob_pattern, module_prefix, normalize)
  local files = fn.glob(glob_pattern, false, true)
  table.sort(files)

  for _, file in ipairs(files) do
    local module_name = ('%s.%s'):format(module_prefix, fn.fnamemodify(file, ':t:r'))
    local ok, raw = pcall(require, module_name)
    if not ok then
      error(('加载插件模块 %s 失败: %s'):format(module_name, raw))
    end
    normalize(module_name, raw)
  end
end

function M.collect()
  local config_dir = fn.stdpath('config')

  collect_specs(config_dir .. '/lua/plugins/dev/*.lua', 'plugins.dev', normalize_dev_spec)
  collect_specs(config_dir .. '/lua/plugins/remote/*.lua', 'plugins.remote', normalize_remote_spec)
end

function M.resolve_name(name)
  return state.aliases[name] or state.aliases[infer_name(name)]
end

function M.has(name)
  return M.resolve_name(name) ~= nil
end

function M.get(name)
  local resolved = M.resolve_name(name)
  if not resolved then
    return nil
  end

  return state.specs[resolved]
end

function M.has_kind(name, kind)
  local spec = M.get(name)
  return spec ~= nil and spec.kind == kind
end

function M.by_kind(kind)
  local names = {}

  for _, name in ipairs(state.order) do
    if state.specs[name].kind == kind then
      table.insert(names, name)
    end
  end

  return names
end

function M.sort()
  table.sort(state.order, function(left, right)
    local a = state.specs[left]
    local b = state.specs[right]
    if a.priority == b.priority then
      return a.name < b.name
    end
    return a.priority > b.priority
  end)
end

return M
