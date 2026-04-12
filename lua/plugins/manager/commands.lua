local M = {}

local api = vim.api

function M.create_pack_commands(manager)
  api.nvim_create_user_command('PackClean', function()
    local result = manager.clean()
    local names = {}

    for _, name in ipairs(result.lock or {}) do
      names[name] = true
    end
    for _, name in ipairs(result.removed or {}) do
      names[name] = true
    end

    local summary = vim.tbl_keys(names)
    table.sort(summary)

    if #summary == 0 then
      vim.notify('PackClean: 没有需要清理的陈旧插件', vim.log.levels.INFO)
    else
      vim.notify(('PackClean: 已清理 %s'):format(table.concat(summary, ', ')), vim.log.levels.INFO)
    end
  end, { desc = '清理已删除插件的锁文件条目和本地安装目录' })

  api.nvim_create_user_command('PackStatus', function()
    local status = manager.status()
    local stale_names = {}

    for _, name in ipairs(status.stale.lock or {}) do
      stale_names[name] = true
    end
    for _, item in ipairs(status.stale.pack_dirs or {}) do
      stale_names[item.name] = true
    end

    local stale = vim.tbl_keys(stale_names)
    table.sort(stale)

    vim.notify(
      table.concat({
        ('declared: %d'):format(#status.declared),
        ('installed: %d'):format(#status.installed),
        ('locked: %d'):format(#status.locked),
        ('stale: %d'):format(#stale),
        (#stale > 0) and ('stale plugins: ' .. table.concat(stale, ', ')) or 'stale plugins: none',
      }, '\n'),
      vim.log.levels.INFO,
      { title = 'PackStatus' }
    )
  end, { desc = '显示当前插件声明、安装和待清理状态' })

  api.nvim_create_user_command('PackUpdate', function()
    manager.clean()
    vim.pack.update()
  end, { desc = '更新 vim.pack 管理的插件' })

  api.nvim_create_user_command('PackSync', function()
    manager.clean()
    vim.pack.update(nil, { force = true })
  end, { desc = '无确认更新 vim.pack 管理的插件' })

  api.nvim_create_user_command('PackRestore', function()
    manager.clean()
    vim.pack.update(nil, { force = true, offline = true, target = 'lockfile' })
  end, { desc = '按锁文件恢复 vim.pack 管理的插件' })
end

return M
