local shared = require('plugins.manager.shared')
local state = require('plugins.manager.state').data
local specs = require('plugins.manager.specs')

local M = {}

local api = shared.api
local fn = shared.fn
local set = shared.keymap

local function clear_command_stub(command_name)
  if state.command_stubs[command_name] then
    pcall(api.nvim_del_user_command, command_name)
    state.command_stubs[command_name] = nil
  end
end

local function run_setup(spec)
  if state.configured[spec.name] then
    return
  end

  state.configured[spec.name] = true

  if spec.setup then
    spec.setup()
  end
end

function M.load(name)
  local resolved = specs.resolve_name(name)
  if not resolved then
    error(('未找到插件 %s'):format(name))
  end

  if state.loaded[resolved] then
    return
  end

  local spec = state.specs[resolved]
  for _, dep in ipairs(spec.dependencies) do
    local dep_name = specs.resolve_name(dep)
    if dep_name then
      M.load(dep_name)
    end
  end

  vim.cmd.packadd(spec.name)
  state.loaded[spec.name] = true
  run_setup(spec)
end

local function replay_mapping(rhs)
  local keys = api.nvim_replace_termcodes(rhs, true, false, true)
  vim.schedule(function()
    api.nvim_feedkeys(keys, 'm', false)
  end)
end

local function unpack_keymap(map)
  local mode = map[1] or 'n'
  local lhs = map[2]
  local rhs = map[3]
  local opts = vim.tbl_extend('force', { silent = true }, map[4] or {})
  return mode, lhs, rhs, opts
end

function M.create_key_loader(spec)
  for _, map in ipairs(spec.keys) do
    local mode, lhs, rhs, opts = unpack_keymap(map)

    set(mode, lhs, function()
      M.load(spec.name)
      if type(rhs) == 'function' then
        return rhs()
      end
      replay_mapping(rhs)
    end, opts)
  end
end

local function run_command_stub(command_name, opts, spec)
  clear_command_stub(command_name)
  M.load(spec.name)

  local info = api.nvim_get_commands({})[command_name] or api.nvim_buf_get_commands(0, {})[command_name]
  if not info then
    vim.schedule(function()
      vim.notify(('插件 %s 加载后仍未找到命令 %s'):format(spec.name, command_name), vim.log.levels.ERROR)
    end)
    return
  end

  local executed_command = {
    cmd = command_name,
    bang = opts.bang or nil,
    mods = opts.smods,
    args = opts.fargs,
    count = opts.count >= 0 and opts.range == 0 and opts.count or nil,
  }

  if opts.range == 1 then
    executed_command.range = { opts.line1 }
  elseif opts.range == 2 then
    executed_command.range = { opts.line1, opts.line2 }
  end

  if opts.args and opts.args ~= '' and info.nargs and info.nargs:find('[1?]') then
    executed_command.args = { opts.args }
  end

  vim.schedule(function()
    vim.cmd(executed_command)
  end)
end

function M.create_command_loader(spec)
  for _, command in ipairs(spec.commands) do
    local command_name = command.name
    if fn.exists(':' .. command_name) ~= 2 then
      api.nvim_create_user_command(command_name, function(opts_)
        run_command_stub(command_name, opts_, spec)
      end, {
        bang = true,
        bar = true,
        desc = command.desc or ('加载 %s 后执行 %s'):format(spec.name, command_name),
        nargs = '*',
        range = true,
        complete = function(_, line)
          clear_command_stub(command_name)
          M.load(spec.name)
          return fn.getcompletion(line, 'cmdline')
        end,
      })

      state.command_stubs[command_name] = true
    end
  end
end

function M.create_event_loader(spec)
  for _, event in ipairs(spec.events) do
    api.nvim_create_autocmd(event, {
      group = api.nvim_create_augroup(('PackLoad_%s_%s'):format(spec.name, event), { clear = true }),
      once = true,
      callback = function()
        M.load(spec.name)
      end,
    })
  end
end

function M.register_build_hook(spec)
  if not spec.build then
    return
  end

  api.nvim_create_autocmd('PackChanged', {
    group = api.nvim_create_augroup(('PackBuild_%s'):format(spec.name), { clear = true }),
    callback = function(args)
      if args.data.spec.name ~= spec.name then
        return
      end

      if args.data.kind ~= 'install' and args.data.kind ~= 'update' then
        return
      end

      fn.jobstart(spec.build, {
        cwd = args.data.path,
        on_exit = function(_, code)
          if code == 0 then
            return
          end

          vim.schedule(function()
            vim.notify(('插件 %s 构建失败，退出码 %d'):format(spec.name, code), vim.log.levels.ERROR)
          end)
        end,
        stderr_buffered = true,
        stdout_buffered = true,
      })
    end,
  })
end

function M.install_plugins()
  local pack_specs = {}

  for _, name in ipairs(state.order) do
    local spec = state.specs[name]
    table.insert(pack_specs, {
      name = spec.name,
      src = spec.src,
      version = spec.version,
    })
  end

  vim.pack.add(pack_specs, { confirm = false, load = false })
end

return M
