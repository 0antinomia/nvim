-- 原生状态栏
-- 只显示文件路径、git 状态、文件标记、类型、编码和行列信息

local api = vim.api
local fn = vim.fn

local M = {}
local git_cache = {}

local function escape(text)
  return tostring(text):gsub('%%', '%%%%')
end

local function current_window()
  local winid = vim.g.statusline_winid
  if type(winid) ~= 'number' or winid == 0 then
    return api.nvim_get_current_win()
  end
  return winid
end

local function file_path(buf)
  local name = api.nvim_buf_get_name(buf)
  if name == '' then
    return '[No Name]'
  end

  local path = fn.fnamemodify(name, ':.')
  local parts = vim.split(path, '/', { plain = true, trimempty = true })

  if #parts <= 2 then
    return path
  end

  return ('…/%s/%s'):format(parts[#parts - 1], parts[#parts])
end

local function file_flags(buf)
  local flags = {}

  if vim.bo[buf].modified then
    table.insert(flags, '[+]')
  end
  if vim.bo[buf].readonly then
    table.insert(flags, '[RO]')
  end
  if vim.bo[buf].modifiable == false then
    table.insert(flags, '[-]')
  end

  return table.concat(flags, '')
end

local function trim(text)
  return (text or ''):gsub('%s+$', '')
end

local function git_root(buf)
  local name = api.nvim_buf_get_name(buf)
  if name == '' then
    return nil
  end

  local dir = fn.fnamemodify(name, ':p:h')
  local result = vim.system({ 'git', '-C', dir, 'rev-parse', '--show-toplevel' }, { text = true }):wait()
  if result.code ~= 0 then
    return nil
  end

  return trim(result.stdout)
end

local function git_info(root)
  if not root or root == '' then
    return nil
  end

  if git_cache[root] ~= nil then
    return git_cache[root] or nil
  end

  local branch = vim.system({ 'git', '-C', root, 'symbolic-ref', '--short', 'HEAD' }, { text = true }):wait()
  local name = trim(branch.stdout)

  if branch.code ~= 0 or name == '' then
    local detached = vim.system({ 'git', '-C', root, 'rev-parse', '--short', 'HEAD' }, { text = true }):wait()
    if detached.code ~= 0 then
      git_cache[root] = false
      return nil
    end
    name = trim(detached.stdout)
  end

  local upstream = vim
    .system({ 'git', '-C', root, 'rev-parse', '--abbrev-ref', '--symbolic-full-name', '@{upstream}' }, { text = true })
    :wait()
  local branch_status = '≢'

  if upstream.code == 0 then
    local diverged = vim
      .system({ 'git', '-C', root, 'rev-list', '--left-right', '--count', '@{upstream}...HEAD' }, { text = true })
      :wait()
    local behind, ahead = diverged.stdout:match('(%d+)%s+(%d+)')
    behind = tonumber(behind) or 0
    ahead = tonumber(ahead) or 0

    if ahead == 0 and behind == 0 then
      branch_status = '≡'
    else
      local parts = {}
      if ahead > 0 then
        table.insert(parts, '↑' .. ahead)
      end
      if behind > 0 then
        table.insert(parts, '↓' .. behind)
      end
      branch_status = table.concat(parts, ' ')
    end
  end

  local dirty = vim.system({ 'git', '-C', root, 'status', '--porcelain' }, { text = true }):wait()
  local working = {
    added = 0,
    deleted = 0,
    modified = 0,
    untracked = 0,
  }
  local staging = {
    added = 0,
    deleted = 0,
    modified = 0,
    untracked = 0,
  }

  local function count_status(target, code)
    if code == 'A' then
      target.added = target.added + 1
      return
    end
    if code == 'D' then
      target.deleted = target.deleted + 1
      return
    end
    if code ~= ' ' and code ~= '?' then
      target.modified = target.modified + 1
    end
  end

  for line in vim.gsplit(dirty.stdout or '', '\n', { plain = true, trimempty = true }) do
    local x = line:sub(1, 1)
    local y = line:sub(2, 2)

    if x == '?' and y == '?' then
      working.untracked = working.untracked + 1
    else
      count_status(staging, x)
      count_status(working, y)
    end
  end

  local info = {
    repo = fn.fnamemodify(root, ':t'),
    branch = name,
    branch_status = branch_status,
    staging = staging,
    working = working,
  }

  git_cache[root] = info
  return info
end

local function git_section(buf)
  local info = git_info(git_root(buf))
  if not info then
    return ''
  end

  local function status_string(status)
    local parts = {}
    if status.untracked > 0 then
      table.insert(parts, '?' .. status.untracked)
    end
    if status.added > 0 then
      table.insert(parts, '+' .. status.added)
    end
    if status.modified > 0 then
      table.insert(parts, '~' .. status.modified)
    end
    if status.deleted > 0 then
      table.insert(parts, '-' .. status.deleted)
    end
    return table.concat(parts, ' ')
  end

  local working = status_string(info.working)
  local staging = status_string(info.staging)
  local parts = {
    ' ' .. info.repo,
    ' ' .. info.branch,
    info.branch_status,
  }

  if working ~= '' then
    table.insert(parts, ' ' .. working)
  end
  if staging ~= '' then
    if working ~= '' then
      table.insert(parts, '|')
    end
    table.insert(parts, ' ' .. staging)
  end

  return table.concat(parts, '  ')
end

local function file_path_section(buf)
  local parts = { file_path(buf) }
  local flags = file_flags(buf)

  if flags ~= '' then
    table.insert(parts, flags)
  end

  return table.concat(parts, '  ')
end

local function file_type(buf)
  local filetype = vim.bo[buf].filetype
  if filetype == '' then
    return 'text'
  end
  return filetype
end

local function file_format(buf)
  return vim.bo[buf].fileformat
end

local function file_encoding(buf)
  local encoding = vim.bo[buf].fileencoding
  if encoding == '' then
    encoding = vim.o.encoding
  end
  return string.upper(encoding)
end

local function progress(line, total)
  if total <= 1 or line <= 1 then
    return 'Top'
  end
  if line >= total then
    return 'Bot'
  end
  return ('%d%%%%'):format(math.floor(line / total * 100))
end

function M.refresh_git(buf)
  local root = git_root(buf)
  if root then
    git_cache[root] = nil
  end
end

function M.setup_options()
  vim.o.laststatus = 3
  vim.o.statusline = "%!v:lua.require'core.statusline'.render()"
end

function M.render()
  local win = current_window()
  local buf = api.nvim_win_get_buf(win)
  local cursor = api.nvim_win_get_cursor(win)
  local line = cursor[1]
  local col = cursor[2] + 1
  local total = api.nvim_buf_line_count(buf)
  local git = git_section(buf)

  return table.concat({
    ' ',
    '%<',
    escape(git),
    git ~= '' and '  ' or '',
    escape(file_path_section(buf)),
    '%=  ',
    escape(file_type(buf)),
    '  ',
    escape(file_format(buf)),
    '  ',
    escape(file_encoding(buf)),
    '  ',
    line,
    ':',
    col,
    '/',
    total,
    '  ',
    progress(line, total),
    ' ',
  })
end

return M
