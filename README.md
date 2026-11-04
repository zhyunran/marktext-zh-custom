# marktext-zh-custom

[中文说明](README.zh.md) · **English**

A **Chinese-localized, convenience-tuned packaging** of [MarkText](https://github.com/marktext/marktext) 0.23.0 for Windows.
Ships as a per-user NSIS installer (no admin rights) **and** a portable ZIP, both bundled with a Chinese
getting-started tutorial.

This repository contains **only the packaging sources and docs**. The ready-to-use binaries are attached to
[Releases](../../releases).

## What you get

| Artifact | Size | Notes |
| --- | --- | --- |
| `MarkText-0.23.0-安装程序.exe` | ~121 MB | NSIS installer, no admin, custom install dir, Start-menu + desktop shortcuts |
| `MarkText-0.23.0-便携版.zip` | ~179 MB | Unzip anywhere (USB stick friendly), config lives in `data\`, no registry writes |

Both install the same Electron app (~489 MB on disk, 116 files) and carry the tutorial in `教程\`.

## Customizations vs. upstream

| Change | Why |
| --- | --- |
| **Enter inserts a new table row** | Upstream: Enter jumps to the next cell, `Ctrl+Enter` inserts a row. Changed to the Word-like habit. |
| **Auto-update removed** (`resources/app-update.yml` deleted) | Otherwise an auto-update would overwrite the patch above. |
| **First launch opens the tutorial** | Handled by `启动 MarkText.exe`, once per install (flag file). |
| **Right-click → New → Markdown Document** | Native ShellNew registration; consistent with Office. |
| **Single `.md` ProgId** | Older builds registered both `MarkText.Document` and `Applications\marktext.exe`, which made the *Open with* menu list three MarkText entries. |
| **Chinese tutorial bundled** | Offline-friendly: tutorial + 4 real screenshots in `教程\`. |

## Build

Requirements: Windows 10/11 x64, PowerShell 5.1, .NET Framework 4.0 `csc.exe`, and a local MarkText
installation (used as the application source) — plus the portable NSIS 3.11 under `tools\nsis-3.11\`
(download it from [nsis.sourceforge.io](https://nsis.sourceforge.io/Download); it is not committed here).

```powershell
# installer only
powershell -ExecutionPolicy Bypass -File build\build.ps1 -AppSrc "C:\Users\<you>\AppData\Local\Programs\marktext"

# installer + portable zip
powershell -ExecutionPolicy Bypass -File build\build.ps1 -AppSrc "..." -Tutorial "path\to\tutorial" -Portable
```

| Parameter | Default | Meaning |
| --- | --- | --- |
| `-AppSrc` | `%LOCALAPPDATA%\Programs\marktext` | Installed MarkText used as file source |
| `-Tutorial` | sibling `教程` folder | Tutorial folder copied into the package |
| `-Portable` | off | Also emit `dist\MarkText-0.23.0-便携版.zip` |
| `-KeepStage` | off | Keep the ~489 MB staging folder for inspection |

Output goes to `dist\`. The staging folder is removed automatically.

## Repository layout

```
build/
  build.ps1                 one-click packaging (installer / portable)
  launcher.cs               启动 MarkText.exe — first run opens the tutorial
  marktext-installer.nsi    NSIS script (per-user, custom dir, single ProgId, ShellNew)
docs/
  安装包说明.md              end-user install notes (Chinese)
tutorial/
  新手教学.md                getting-started tutorial (11 chapters, Chinese)
  使用说明.md                one-page cheat sheet (Chinese)
  images/                   4 real screenshots used by the tutorial
```

## Known limitations

- **Not code-signed** — the first run shows a SmartScreen prompt (*More info → Run anyway*). Normal for
  self-packaged software.
- Icons and UI are upstream MarkText; no rebranding.
- The `.md` default program is whatever Windows' *Open with* setting says; the installer only makes MarkText
  appear in that list (and adds a New-menu item).
- The Enter-in-table patch lives inside the installed `resources/app.asar`; this repo only packages the app.

## License & credits

- Packaging scripts, tutorial and docs: **MIT** (see [LICENSE](LICENSE)).
- MarkText itself is MIT, © Luo Ran and MarkText contributors — <https://github.com/marktext/marktext>.
- Electron / Chromium components keep their own licenses (see `LICENSES.chromium.html` in the installed app).
