# nvim

这是我的个人 Neovim 配置。

## 特点

- 结构尽量简单，在返璞归真的思路下保留必要的扩展性。
- 基于 Neovim 0.12 原生 `vim.pack` 的轻量插件管理。
- LSP 和 tree-sitter 等扩展能力尽量通过原生方式配置。

## 依赖

这套配置面向较新的 Neovim 环境，至少需要：

- Neovim `0.12+`
- `git`
- `cargo`

其中：

- `cargo` 主要用于构建 `blink.cmp` 的 Rust fuzzy 匹配库。
- LSP server 需要你自己在系统里安装。
- tree-sitter parser 也需要你自己安装和管理。

这里的整体思路是尽量贴近 Neovim 原生能力，把编辑器配置和外部工具管理分开。

## 目录结构

主要目录如下：

```text
.
├── ftplugin/            # 按 filetype 激活相应拓展
├── lua/
│   ├── core/            # 基础选项、快捷键、自动命令
│   ├── extensions/      # LSP / tree-sitter 这类原生能力扩展
│   └── plugins/
│       ├── manager/     # 基于 vim.pack 的轻量管理层
│       ├── remote/      # 远程插件
│       └── dev/         # 本地开发插件
└── .hlcraft/            # 高亮组配置
```

## 插件管理

插件管理完全建立在 Neovim 0.12 原生 `vim.pack` 之上。

当前 manager 支持的加载方式不多，但对个人配置来说已经足够：

- `eager = true`：立即加载
- `events = { ... }`：事件触发加载
- `keys = { ... }`：按键触发加载
- `commands = { ... }`：命令触发加载

另外保留了几个最基本的管理命令：

- `:PackStatus`
- `:PackClean`
- `:PackUpdate`
- `:PackSync`
- `:PackRestore`

## LSP 与 tree-sitter

这套配置在这两部分的策略比较明确。

### LSP

- 配置位于 `lua/extensions/lsp.lua` 与 `lua/extensions/lspconfig/`
- 各语言在 `ftplugin/` 里按需激活
- 只保留真正需要的 server 配置，不额外包过多中间层

目前主要覆盖这些语言：

- Lua
- Python
- Rust
- C / C++
- HTML / CSS / SCSS / Less
- JavaScript / TypeScript / React
- JSON / JSONC
- TOML

### tree-sitter

- 只负责在 `ftplugin/` 里按 filetype 原生启用
- 如果 parser 缺失，会给出提示
- 但不会在配置内部自动下载 parser

这是一个刻意的选择：配置本身只负责编辑器行为，不顺手承担环境安装器的职责。

## 主题与高亮

我现在通过 [`hlcraft.nvim`](https://github.com/0antinomia/hlcraft.nvim) 统一管理高亮组，包括：

- 自定义主题风格
- 通用界面配色
- 插件高亮

如果你也在意高亮体系的一致性，可以看看这个插件。

## 使用方式

如果你只是想直接试用这套配置，最直接的方式就是把它放到：

```sh
~/.config/nvim
```

如果你准备基于它来做自己的配置，我建议：

- 先理解目录结构和设计取向
- 再决定保留哪些插件、删掉哪些层，或者补上你真正需要的东西
