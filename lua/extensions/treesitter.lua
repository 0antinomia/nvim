-- treesitter 拓展入口
-- 启用当前 filetype 对应的 parser

local M = {}

-- 缺失 parser 的提示按名字去重，避免每次进入同类 buffer 都重复通知
local notified = {}

function M.enable(parser, bufnr)
  bufnr = bufnr or 0
  if not parser then
    return
  end

  -- inspect 失败基本就意味着 parser 尚未安装，这里直接给一次性提示
  if not pcall(vim.treesitter.language.inspect, parser) then
    if not notified[parser] then
      notified[parser] = true
      vim.schedule(function()
        vim.notify(
          ('Treesitter parser "%s" 未安装，请手动安装后再重试'):format(parser),
          vim.log.levels.WARN,
          { title = 'Treesitter' }
        )
      end)
    end
    return
  end

  pcall(vim.treesitter.start, bufnr, parser)
end

return M
