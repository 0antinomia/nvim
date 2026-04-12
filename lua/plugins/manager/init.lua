local state = require('plugins.manager.state')
local specs = require('plugins.manager.specs')
local clean = require('plugins.manager.clean')
local runtime = require('plugins.manager.runtime')
local commands = require('plugins.manager.commands')

local M = {}
M.clean = clean.clean
M.status = clean.status
M.load = runtime.load

function M.setup()
  state.reset()
  specs.collect()
  M.clean()

  for _, name in ipairs(state.data.order) do
    runtime.register_build_hook(state.data.specs[name])
  end

  runtime.install_plugins()

  for _, name in ipairs(state.data.order) do
    local spec = state.data.specs[name]
    runtime.create_command_loader(spec)
    runtime.create_key_loader(spec)
    if not spec.eager then
      runtime.create_event_loader(spec)
    end
  end

  table.sort(state.data.order, function(left, right)
    local a = state.data.specs[left]
    local b = state.data.specs[right]
    if a.priority == b.priority then
      return a.name < b.name
    end
    return a.priority > b.priority
  end)

  for _, name in ipairs(state.data.order) do
    if state.data.specs[name].eager then
      M.load(name)
    end
  end

  commands.create_pack_commands(M)
end

return M
