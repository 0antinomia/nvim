local M = {}

local fn = vim.fn
local api = vim.api
local set = vim.keymap.set

local DEV_DIR = fn.stdpath('config') .. '/lua/plugins/dev'

local state = {
  aliases = {},
  command_stubs = {},
  configured = {},
  loaded = {},
  order = {},
  specs = {},
}

local function listify(value)
  if value == nil then
    return {}
  end
  if type(value) == 'table' then
    return value
  end
  return { value }
end

local function infer_name(repo)
  local tail = repo:match('/([^/]+)$') or repo
  return tail:gsub('%.git$', '')
end

local function github_url(repo)
  if repo:match('^https?://') or repo:match('^git@') then
    return repo
  end
  return ('https://github.com/%s.git'):format(repo)
end

local function reset_state()
  state.aliases = {}
  state.command_stubs = {}
  state.configured = {}
  state.loaded = {}
  state.order = {}
  state.specs = {}
end

local function add_alias(alias, name)
  if alias and alias ~= '' then
    state.aliases[alias] = name
  end
end

local function normalize_spec(module_name, raw)
  if raw.enabled == false then
    return
  end

  local source = raw.path or raw.dir or raw.repo or raw[1]
  if type(source) ~= 'string' then
    error(('开发插件 %s 缺少 path/dir/repo 字段'):format(module_name))
  end

  local is_local = raw.path ~= nil or raw.dir ~= nil or (type(source) == 'string' and source:sub(1, 1) == '/')
  local name = raw.name or infer_name(source)
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
    setup = raw.setup,
    src = is_local and source or github_url(source),
    version = is_local and nil or (raw.version or raw.branch or raw.tag or raw.commit),
  }

  state.specs[name] = spec
  table.insert(state.order, name)

  add_alias(name, name)
  add_alias(module_name, name)
  add_alias(infer_name(source), name)
  if raw.repo then
    add_alias(raw.repo, name)
  end

  return spec
end

local function resolve_name(name)
  return state.aliases[name] or state.aliases[infer_name(name)]
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

local function clear_command_stub(command_name)
  if state.command_stubs[command_name] then
    pcall(api.nvim_del_user_command, command_name)
    state.command_stubs[command_name] = nil
  end
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

function M.load(name)
  local resolved = resolve_name(name)
  if not resolved then
    local ok, manager = pcall(require, 'plugins.manager')
    if ok then
      return manager.load(name)
    end
    error(('未找到开发插件 %s'):format(name))
  end

  if state.loaded[resolved] then
    return
  end

  local spec = state.specs[resolved]
  for _, dep in ipairs(spec.dependencies) do
    local dep_name = resolve_name(dep)
    if dep_name then
      M.load(dep_name)
    else
      local ok, manager = pcall(require, 'plugins.manager')
      if ok then
        manager.load(dep)
      end
    end
  end

  vim.cmd.packadd(spec.name)
  state.loaded[spec.name] = true
  run_setup(spec)
end

local function create_key_loader(spec)
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
      vim.notify(
        ('开发插件 %s 加载后仍未找到命令 %s'):format(spec.name, command_name),
        vim.log.levels.ERROR
      )
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

local function create_command_loader(spec)
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

local function create_event_loader(spec)
  for _, event in ipairs(spec.events) do
    api.nvim_create_autocmd(event, {
      group = api.nvim_create_augroup(('PackDevLoad_%s_%s'):format(spec.name, event), { clear = true }),
      once = true,
      callback = function()
        M.load(spec.name)
      end,
    })
  end
end

local function register_build_hook(spec)
  if not spec.build then
    return
  end

  api.nvim_create_autocmd('PackChanged', {
    group = api.nvim_create_augroup(('PackDevBuild_%s'):format(spec.name), { clear = true }),
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
            vim.notify(('开发插件 %s 构建失败，退出码 %d'):format(spec.name, code), vim.log.levels.ERROR)
          end)
        end,
        stderr_buffered = true,
        stdout_buffered = true,
      })
    end,
  })
end

local function install_plugins()
  local pack_specs = {}

  for _, name in ipairs(state.order) do
    local spec = state.specs[name]
    table.insert(pack_specs, {
      name = spec.name,
      src = spec.src,
      version = spec.version,
    })
  end

  if #pack_specs > 0 then
    vim.pack.add(pack_specs, { confirm = false, load = false })
  end
end

function M.setup()
  if fn.isdirectory(DEV_DIR) ~= 1 then
    return
  end

  reset_state()

  local files = fn.glob(DEV_DIR .. '/*.lua', false, true)
  table.sort(files)

  for _, file in ipairs(files) do
    local module_name = ('plugins.dev.%s'):format(fn.fnamemodify(file, ':t:r'))
    local ok, raw = pcall(require, module_name)
    if not ok then
      error(('加载开发插件模块 %s 失败: %s'):format(module_name, raw))
    end
    normalize_spec(module_name, raw)
  end

  if #state.order == 0 then
    return
  end

  for _, name in ipairs(state.order) do
    register_build_hook(state.specs[name])
  end

  install_plugins()

  for _, name in ipairs(state.order) do
    local spec = state.specs[name]
    create_command_loader(spec)
    create_key_loader(spec)
    if not spec.eager then
      create_event_loader(spec)
    end
  end

  table.sort(state.order, function(left, right)
    local a = state.specs[left]
    local b = state.specs[right]
    if a.priority == b.priority then
      return a.name < b.name
    end
    return a.priority > b.priority
  end)

  for _, name in ipairs(state.order) do
    if state.specs[name].eager then
      M.load(name)
    end
  end
end

return M
