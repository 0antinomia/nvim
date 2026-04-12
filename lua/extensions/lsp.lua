-- LSP 扩展入口
-- 按需加载当前 filetype 对应的 LSP 配置模块
-- 提供少量 server 注册与 hook 拼接辅助
local M = {}

-- 同一个 LSP 配置模块只加载一次，避免多个相关 filetype 反复 require
local loaded_modules = {}

function M.activate(modules)
  for _, module_name in ipairs(modules or {}) do
    if not loaded_modules[module_name] then
      loaded_modules[module_name] = true

      local ok, module = pcall(require, module_name)
      if not ok then
        vim.notify(('加载 LSP 扩展失败: %s'):format(module), vim.log.levels.ERROR)
      end
    end
  end
end

function M.setup_server(server_name, config)
  -- 走 Neovim 原生接口
  vim.lsp.config(server_name, config)
  vim.lsp.enable(server_name)
end

local function merge_hooks(base, extra)
  if not base then
    return extra
  end
  if not extra then
    return base
  end

  return function(...)
    -- 保留原有 hook，再追加当前模块的补充逻辑
    -- 这样带少量特例的 server，就不需要自己手写完整 on_attach/on_init
    base(...)
    extra(...)
  end
end

function M.extend_on_attach(config, callback)
  -- 给已有 on_attach 追加逻辑，而不是直接覆盖
  config.on_attach = merge_hooks(config.on_attach, callback)
  return config
end

function M.extend_on_init(config, callback)
  -- on_init 同理，主要给少量需要初始化修正的 server 使用
  config.on_init = merge_hooks(config.on_init, callback)
  return config
end

return M
