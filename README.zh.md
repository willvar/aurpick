# aurpick

中文 | [English](README.md)

---

轻松安装 AUR 包的特定版本——当前版本、历史版本或更新版本。

**aurpick** 让你浏览完整的 Git 历史、预览 PKGBUILD，并选择你需要的确切版本。

## 特性

- **完整历史浏览** - 查看包的所有 Git 提交历史
- **交互式选择** - 使用 fzf 提供强大的搜索和过滤功能
- **安全版本信息显示** - 从每个提交的 `.SRCINFO` 解析已求值的版本号，不执行历史 PKGBUILD
- **实时预览** - 查看提交信息和 PKGBUILD 内容
- **官方包重定向** - 自动检测官方仓库包并调用 `downgrade` 工具
- **GitHub 镜像支持** - 可选使用 GitHub AUR 镜像，减轻主站压力并避开服务故障
- **Wayback 兜底** - 当上游源文件消失时尝试从归档恢复，同时仍然遵守 `makepkg` 完整性校验
- **无需 AUR 助手** - 仅依赖 git 和 makepkg，独立工作
- **开发模式** - 保留临时文件，方便调试

## 依赖

- `git` - 克隆 AUR 仓库
- `curl` - 探测源文件地址并查询 Wayback Machine
- `fzf` - 交互式选择界面
- `base-devel` - 编译 AUR 包（包含 `makepkg`）
- `downgrade` (可选) - 处理官方仓库包

安装依赖：
```bash
sudo pacman -S git curl fzf base-devel
```

## 使用方法

**基本用法**：
```bash
aurpick <package-name>
```

**示例**：
```bash
# 更新出问题后回退 yay 版本
aurpick yay

# 使用 GitHub AUR 镜像（只读实验性镜像）
aurpick --github yay

# 开发模式（保留临时文件以便调试）
aurpick --dev yay

# 禁用归档兜底，只使用上游在线源地址
aurpick --no-wayback yay
```

## ⚠️ 重要限制

**至少有以下类型的包使用 aurpick 没有意义或一定会失败：**

1. **VCS 包**（`-git`、`-svn`、`-hg` 等）
   - 这些包使用 `pkgver()` 函数在构建时动态拉取上游最新源码
   - 即使选择历史 PKGBUILD，最终仍会构建当前上游版本

2. **下载链接不含版本号的包**
   - 源文件链接如 `https://example.com/latest.tar.xz` 永远指向最新文件
   - 选择历史 PKGBUILD 无法获取对应的历史源文件

3. **上游源文件已被删除的包**
   - 当在线 HTTP(S) 源消失时，aurpick 会尝试通过 Wayback Machine 恢复文件
   - 默认情况下，如果没有归档副本，或归档文件无法通过 `makepkg` 校验，构建仍然会失败

## 工作原理

1. 克隆指定包的 AUR Git 仓库（从 AUR 官方源或 GitHub 镜像）
2. 遍历所有提交历史，从 `.SRCINFO` 提取已求值的版本信息
3. 使用 fzf 提供交互式选择界面
4. 切换到选定的历史提交
5. 先用 `makepkg` 校验源文件，必要时尝试从 Wayback 恢复缺失的 HTTP(S) 文件
6. 使用 `makepkg` 编译并安装

## 参数说明

- `--dev` - 开发模式，保留临时文件在 `/tmp/aurpick-<package>`
- `--github` - 使用 GitHub AUR 镜像而非 AUR 官方源
- `--no-wayback` - 禁用 Wayback 兜底，仅依赖在线上游源地址
- `--version` / `-v` - 显示版本信息

## 使用提示

- 本工具专注于 **AUR 包**，官方仓库包会在 `downgrade` 可用时重定向到该工具
- 旧版本可能出现校验和不匹配，可以根据需要跳过验证
- 历史版本号来自提交中的 `.SRCINFO`；如果元数据未及时更新，显示值可能与 PKGBUILD 或最终构建结果不同
- Wayback 兜底只作用于不可访问的 `http://` 和 `https://` 源；`git+...` 这类 VCS 源不受影响
- 归档文件会先经过 `makepkg` 的正常完整性校验，除非你在校验失败后明确选择 `--skipchecksums`

## 开发

### 开发依赖

用于测试和开发：
```bash
sudo pacman -S shellcheck python-cram
```

- `shellcheck` - Shell 脚本静态分析工具
- `python-cram` - 命令行测试框架

### 运行测试

运行完整测试套件：
```bash
bash test.sh
```

测试流程包括：
1. 运行 `shellcheck` 进行静态代码分析
2. 运行所有 `cram` 功能测试

请确保所有测试通过后再提交代码。

### 项目结构

```
aurpick/
├── aurpick          # 主程序脚本
├── test.sh          # 测试运行器 (shellcheck + cram)
├── test/            # 测试用例 (cram 格式)
│   ├── basic.t
│   ├── version.t
│   ├── dev-mode.t
│   └── ...
├── README.md        # 文档（英文）
└── README.zh.md     # 文档（中文）
```

## 许可证

MIT License - 详见 [LICENSE](LICENSE)
