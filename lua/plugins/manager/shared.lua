local fn = vim.fn
local api = vim.api
local keymap = vim.keymap.set

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

return {
  api = api,
  fn = fn,
  github_url = github_url,
  infer_name = infer_name,
  keymap = keymap,
  listify = listify,
  LOCKFILE = fn.stdpath('config') .. '/nvim-pack-lock.json',
  PACK_OPT_DIR = fn.stdpath('data') .. '/site/pack/core/opt',
}
