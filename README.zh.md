# aurpick

中文 | [English](README.md)

---

轻松安装 AUR 包的任意版本——当前版本、历史版本或更新版本。

**aurpick** 让你浏览完整的 Git 历史、预览 PKGBUILD，并选择你需要的确切版本。

## 特性

- **完整历史浏览** - 查看包的所有 Git 提交历史
- **交互式选择** - 使用 fzf 提供强大的搜索和过滤功能
- **版本信息显示** - 自动解析每个提交的 PKGBUILD 版本号
- **实时预览** - 查看提交信息和 PKGBUILD 内容
- **官方包重定向** - 自动检测官方仓库包并调用 `downgrade` 工具
- **GitHub 镜像支持** - 可选使用 GitHub AUR 镜像获取包
- **开发模式** - 保留临时文件，方便调试

## 依赖

- `git` - 克隆 AUR 仓库
- `fzf` - 交互式选择界面
- `base-devel` - 编译 AUR 包（包含 `makepkg`）
- `downgrade` (可选) - 处理官方仓库包

安装依赖：
```bash
sudo pacman -S git fzf base-devel
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
```

## 工作原理

1. 克隆指定包的 AUR Git 仓库（从 AUR 官方源或 GitHub 镜像）
2. 遍历所有提交历史，提取 PKGBUILD 版本信息
3. 使用 fzf 提供交互式选择界面
4. 切换到选定的历史提交
5. 使用 `makepkg` 编译并安装

## 参数说明

- `--dev` - 开发模式，保留临时文件在 `/tmp/aurpick-<package>`
- `--github` - 使用 GitHub AUR 镜像而非 AUR 官方源
- `--version` / `-v` - 显示版本信息

## 使用提示

- 本工具专注于 **AUR 包**，官方仓库包会自动重定向到 `downgrade` 工具
- 由于上游源文件变化，旧版本可能出现校验和不匹配，可以根据需要跳过验证

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
