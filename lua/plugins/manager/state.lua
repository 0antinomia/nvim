local M = {}

M.data = {
  aliases = {},
  command_stubs = {},
  configured = {},
  loaded = {},
  order = {},
  specs = {},
}

function M.reset()
  M.data.aliases = {}
  M.data.command_stubs = {}
  M.data.configured = {}
  M.data.loaded = {}
  M.data.order = {}
  M.data.specs = {}
end

return M
