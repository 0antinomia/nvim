local shared = require('plugins.manager.shared')
local state = require('plugins.manager.state').data

local M = {}

local fn = shared.fn

local function read_file(path)
  local file = io.open(path, 'r')
  if not file then
    return nil
  end

  local content = file:read('*a')
  file:close()
  return content
end

local function write_file(path, content)
  local file = io.open(path, 'w')
  if not file then
    return false
  end

  file:write(content)
  file:close()
  return true
end

local function active_plugin_names()
  -- disabled 与 shadowed 仍属于受管理插件，避免 clean 误删锁文件或安装目录。
  local active = {}
  for name, _ in pairs(state.specs) do
    active[name] = true
  end
  for name, _ in pairs(state.disabled or {}) do
    active[name] = true
  end
  for name, _ in pairs(state.shadowed or {}) do
    active[name] = true
  end
  return active
end

local function read_lockfile_plugins()
  if fn.filereadable(shared.LOCKFILE) ~= 1 then
    return {}
  end

  local raw = read_file(shared.LOCKFILE)
  if not raw or vim.trim(raw) == '' then
    return {}
  end

  local ok, decoded = pcall(vim.json.decode, raw)
  if not ok or type(decoded) ~= 'table' or type(decoded.plugins) ~= 'table' then
    vim.schedule(function()
      vim.notify('插件锁文件解析失败，已跳过陈旧条目分析', vim.log.levels.WARN)
    end)
    return {}
  end

  return decoded.plugins, decoded
end

local function installed_plugin_names()
  local installed = {}
  if fn.isdirectory(shared.PACK_OPT_DIR) ~= 1 then
    return installed
  end

  for _, path in ipairs(fn.glob(shared.PACK_OPT_DIR .. '/*', false, true)) do
    local name = fn.fnamemodify(path, ':t')
    if fn.isdirectory(path) == 1 then
      installed[name] = path
    end
  end

  return installed
end

function M.to_clean()
  local active = active_plugin_names()
  local installed = installed_plugin_names()
  local lock_plugins, decoded = read_lockfile_plugins()
  local stale = {
    lock = {},
    pack_dirs = {},
    lockfile = decoded,
  }

  for name, _ in pairs(lock_plugins or {}) do
    if not active[name] then
      table.insert(stale.lock, name)
    end
  end
  table.sort(stale.lock)

  for name, path in pairs(installed) do
    if not active[name] then
      table.insert(stale.pack_dirs, {
        name = name,
        path = path,
      })
    end
  end
  table.sort(stale.pack_dirs, function(a, b)
    return a.name < b.name
  end)

  return stale
end

function M.clean()
  local stale = M.to_clean()
  local removed = {}

  if stale.lockfile and type(stale.lockfile.plugins) == 'table' and #stale.lock > 0 then
    for _, name in ipairs(stale.lock) do
      stale.lockfile.plugins[name] = nil
    end

    local encoded = vim.json.encode(stale.lockfile)
    if encoded then
      write_file(shared.LOCKFILE, encoded)
    end
  end

  for _, item in ipairs(stale.pack_dirs) do
    fn.delete(item.path, 'rf')
    table.insert(removed, item.name)
  end

  return {
    lock = stale.lock,
    removed = removed,
  }
end

function M.status()
  local declared_map = active_plugin_names()
  local installed_map = installed_plugin_names()
  local lock_plugins = read_lockfile_plugins()
  local stale = M.to_clean()
  local declared = vim.tbl_keys(declared_map)
  local installed = vim.tbl_keys(installed_map)
  local locked = vim.tbl_keys(lock_plugins or {})

  table.sort(declared)
  table.sort(installed)
  table.sort(locked)

  return {
    declared = declared,
    installed = installed,
    locked = locked,
    stale = stale,
  }
end

return M
