# marktext-zh-custom

**中文** · [<kbd>English</kbd>](README.en.md)

[MarkText](https://github.com/marktext/marktext) 0.23.0 的**中文本地化发行版**（Windows）——
提供**免管理员安装包** 与 **自解压便携版**，都自带一份中文新手教程。

本仓库只放**打包源码与文档**；可直接使用的安装包 / 便携版在 [Releases](../../releases)。

> ### 这个项目是什么、不是什么
>
> **编辑器本体不是我们写的。** MarkText 是上游 MIT 项目（© Luo Ran 与贡献者），Electron/Chromium 也是他们的。
> 这里没有重新实现一个 Markdown 编辑器。
>
> 我们贡献的是「发行版/打包」这一层（本仓库全部内容，约 15 KB 脚本 + 文档教程）：
>
> | 我们的 | 上游的 |
> | --- | --- |
> | `marktext-installer.nsi` / `portable.nsi`（NSIS 打包） | MarkText 编辑器本体、`resources/app.asar` |
> | `launcher.cs`（`启动 MarkText.exe`，首启弹教程） | Electron 运行时、Chromium |
> | `build.ps1`（暂存、语言包裁剪、打包） | 界面、Markdown 引擎、主题 |
> | 系统集成（单一 ProgId、右键新建 Markdown 文档） | |
> | 中文教程 + 4 张实拍图 + 使用说明 | |
> | `app.asar` 里一个行为补丁（表格内 Enter 插行） | |
>
> 非官方构建，**与上游项目无从属关系、未获其背书**。
> 和官方安装包的体积差异只是打包策略不同（裁语言包、LZMA），不是功能对比。


## 拿到什么

| 产物 | 大小 | 说明 |
| --- | --- | --- |
| `MarkText-0.23.0-installer.exe` | 约 120 MB | NSIS 安装包，免管理员、可自选目录、桌面+开始菜单快捷方式 |
| `MarkText-0.23.0-portable.exe` | 约 120 MB | 自解压便携版：选个文件夹解压即用（U 盘也行），不写注册表，配置在 `data\` |

两者解出来都是同一个 Electron 应用（**106 个文件 / 约 482 MB**，已精简语言包与文档），并在 `教程\` 里带教程。

## 相比官方版的改动

| 改动 | 原因 |
| --- | --- |
| **表格内 Enter 直接插新行** | 官方是 Enter 跳格、`Ctrl+Enter` 才插行；改成 Word 习惯 |
| **移除自动更新**（删 `resources/app-update.yml`） | 否则自动升级会把上面的改动覆盖掉 |
| **首次启动自动打开教程** | 由 `启动 MarkText.exe` 负责，每次安装只弹一次（标记文件） |
| **右键 → 新建 → Markdown 文档** | 原生 ShellNew 注册，和 Office 一致 |
| **`.md` 只登记一个 ProgId** | 旧版同时写 `MarkText.Document` 和 `Applications\marktext.exe`，导致「打开方式」里出现 3 个 MarkText |
| **精简体积** | 只保留 `zh-CN` / `en-US` 语言包（省 7.7 MB）；工具链去掉 NSIS 文档/示例/帮助 |
| **自带中文教程** | 离线友好：教程 + 4 张实拍配图都在 `教程\` |

## 打包

依赖：Windows 10/11 x64、PowerShell 5.1、.NET Framework 4.0 的 `csc.exe`、本机已装 MarkText（作为程序文件来源），
以及 `tools\nsis-3.11\` 下的 NSIS 3.11（从 [nsis.sourceforge.io](https://nsis.sourceforge.io/Download) 下载，本仓库不收录）。

```powershell
# 只打安装包
powershell -ExecutionPolicy Bypass -File build\build.ps1 -AppSrc "C:\Users\<你>\AppData\Local\Programs\marktext"

# 安装包 + 便携版自解压
powershell -ExecutionPolicy Bypass -File build\build.ps1 -AppSrc "..." -Tutorial "教程目录" -Portable
```

| 参数 | 默认 | 作用 |
| --- | --- | --- |
| `-AppSrc` | `%LOCALAPPDATA%\Programs\marktext` | 已装 MarkText，作为程序文件来源 |
| `-Tutorial` | 同级的 `教程` 目录 | 打进包里的教程 |
| `-Portable` | 关 | 额外产出 `dist\MarkText-0.23.0-便携版.exe`（自解压，LZMA） |
| `-KeepAllLocales` | 关 | 保留全部 Electron 语言包（会多约 7.7 MB） |
| `-KeepStage` | 关 | 保留约 480 MB 的暂存目录供检查 |

产物在 `dist\`，暂存目录打完自动清理。

## 仓库结构

```
build/
  build.ps1                 一键打包（安装包 / 便携版）
  launcher.cs               启动 MarkText.exe：首启弹教程
  marktext-installer.nsi    NSIS 安装脚本（免管理员、单 ProgId、右键新建）
  portable.nsi              NSIS 自解压脚本（便携版）
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

---

[<kbd>English version</kbd>](README.en.md)
