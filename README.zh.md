# marktext-zh-custom

**中文** · [English](README.md)

[MarkText](https://github.com/marktext/marktext) 0.23.0 的**中文本地化 + 顺手化**打包版（Windows）。
提供两种形态：**免管理员安装包** 与 **便携版**，都自带一份中文新手教程。

本仓库只放**打包源码与文档**；可直接使用的安装包 / 便携版在 [Releases](../../releases)。

## 拿到什么

| 产物 | 大小 | 说明 |
| --- | --- | --- |
| `MarkText-0.23.0-安装程序.exe` | 约 121 MB | NSIS 安装包，免管理员、可自选目录、桌面+开始菜单快捷方式 |
| `MarkText-0.23.0-便携版.zip` | 约 179 MB | 解压即用（U 盘友好），配置在 `data\` 里，不写注册表 |

两者装完都是同一个 Electron 应用（约 489 MB / 116 个文件），并在 `教程\` 里带教程。

## 相比官方版的改动

| 改动 | 原因 |
| --- | --- |
| **表格内 Enter 直接插新行** | 官方是 Enter 跳格、`Ctrl+Enter` 才插行；改成 Word 习惯 |
| **移除自动更新**（删 `resources/app-update.yml`） | 否则自动升级会把上面的改动覆盖掉 |
| **首次启动自动打开教程** | 由 `启动 MarkText.exe` 负责，每次安装只弹一次（标记文件） |
| **右键 → 新建 → Markdown 文档** | 原生 ShellNew 注册，和 Office 一致 |
| **`.md` 只登记一个 ProgId** | 旧版同时写 `MarkText.Document` 和 `Applications\marktext.exe`，导致「打开方式」里出现 3 个 MarkText |
| **自带中文教程** | 离线友好：教程 + 4 张实拍配图都在 `教程\` |

## 打包

依赖：Windows 10/11 x64、PowerShell 5.1、.NET Framework 4.0 的 `csc.exe`、本机已装 MarkText（作为程序文件来源），
以及 `tools\nsis-3.11\` 下的 NSIS 3.11（从 [nsis.sourceforge.io](https://nsis.sourceforge.io/Download) 下载，本仓库不收录）。

```powershell
# 只打安装包
powershell -ExecutionPolicy Bypass -File build\build.ps1 -AppSrc "C:\Users\<你>\AppData\Local\Programs\marktext"

# 安装包 + 便携版
powershell -ExecutionPolicy Bypass -File build\build.ps1 -AppSrc "..." -Tutorial "教程目录" -Portable
```

| 参数 | 默认 | 作用 |
| --- | --- | --- |
| `-AppSrc` | `%LOCALAPPDATA%\Programs\marktext` | 已装 MarkText，作为程序文件来源 |
| `-Tutorial` | 同级的 `教程` 目录 | 打进包里的教程 |
| `-Portable` | 关 | 额外产出 `dist\MarkText-0.23.0-便携版.zip` |
| `-KeepStage` | 关 | 保留约 489 MB 的暂存目录供检查 |

产物在 `dist\`，暂存目录打完自动清理。

## 仓库结构

```
build/
  build.ps1                 一键打包（安装包 / 便携版）
  launcher.cs               启动 MarkText.exe：首启弹教程
  marktext-installer.nsi    NSIS 脚本（免管理员、可改目录、单 ProgId、右键新建）
docs/
  安装包说明.md              给使用者的安装说明
tutorial/
  新手教学.md                11 章入门教程（新建 / PDF / 图片 / 便携版都覆盖）
  使用说明.md                一页纸速查
  images/                   教程用的 4 张实拍图
```

## 已知限制

- **没有代码签名**：首次运行会有 SmartScreen 提示（更多信息 → 仍要运行），自行打包的软件都这样。
- 图标与界面沿用官方 MarkText，未改品牌。
- `.md` 的默认打开程序由 Windows「打开方式」决定；安装包只保证 MarkText 出现在列表里，并加一个"新建"菜单项。
- 表格 Enter 补丁在已安装程序的 `resources/app.asar` 里，本仓库只负责打包它。

## 许可与致谢

- 打包脚本、教程与文档：**MIT**（见 [LICENSE](LICENSE)）。
- MarkText 本体为 MIT，© Luo Ran 与 MarkText 贡献者 —— <https://github.com/marktext/marktext>。
- Electron / Chromium 组件沿用各自许可（见安装目录里的 `LICENSES.chromium.html`）。
