local state = require('plugins.manager.state')
local specs = require('plugins.manager.specs')
local clean = require('plugins.manager.clean')
local runtime = require('plugins.manager.runtime')
local commands = require('plugins.manager.commands')

local M = {}
M.clean = clean.clean
M.status = clean.status
M.load = runtime.load
M.has = specs.has
M.dev = {}
M.remote = {}

function M.setup()
  state.reset()
  specs.collect()
  M.clean()

  for _, name in ipairs(state.data.order) do
    runtime.register_build_hook(specs.get(name))
  end

  runtime.install_plugins()

  for _, name in ipairs(state.data.order) do
    local spec = specs.get(name)
    runtime.create_command_loader(spec)
    runtime.create_key_loader(spec)
    if not spec.eager then
      runtime.create_event_loader(spec)
    end
  end

  specs.sort()

  for _, name in ipairs(state.data.order) do
    if specs.get(name).eager then
      M.load(name)
    end
  end

  commands.create_pack_commands(M)
end

function M.dev.has(name)
  return specs.has_kind(name, 'dev')
end

function M.dev.load(name)
  if not M.dev.has(name) then
    error(('未找到开发插件 %s'):format(name))
  end

  return runtime.load(name)
end

function M.dev.names()
  return specs.by_kind('dev')
end

function M.remote.has(name)
  return specs.has_kind(name, 'remote')
end

function M.remote.load(name)
  if not M.remote.has(name) then
    error(('未找到远端插件 %s'):format(name))
  end

  return runtime.load(name)
end

function M.remote.names()
  return specs.by_kind('remote')
end

return M
