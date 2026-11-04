# Changelog

All notable changes to this packaging project.
Version scheme: `<upstream version>-cn.<build>`.

## v0.23.0-cn.3 — 2026-11-04

### Changed

- **Payload slimmed**: only `zh-CN` and `en-US` Electron locale packs are shipped (−7.7 MB; 11 other
  languages removed). `build.ps1 -KeepAllLocales` restores them.
- **Portable build is now a self-extracting EXE** (`portable.nsi`, solid LZMA) instead of a ZIP:
  `MarkText-0.23.0-便携版.exe` ≈ 119.5 MB, down from the 179.4 MB deflate ZIP. Pick a folder, extract, run —
  still no registry writes, config stays in `data\`.
- Release assets total **≈ 239 MB** (was ≈ 300 MB): installer 119.6 MB + portable 119.5 MB.
- Installed footprint: 106 files / 481.6 MB (was 116 / 489.4 MB).

### Verified

- Silent install → 106 files, `locales` contains exactly `en-US.pak` + `zh-CN.pak`;
  first launch still passes `教程\MarkText 新手教学\新手教学.md` to the app; Chinese UI intact.

## v0.23.0-cn.2 — 2026-11-04

### Added

- **Right-click → New → Markdown Document** (`ShellNew` under `HKCU\Software\Classes\.md`), removed on uninstall.
- **Portable build**: `build.ps1 -Portable` emits `MarkText-0.23.0-便携版.zip`; the launcher runs MarkText with
  `--user-data-dir=<dir>\data` so config and cache travel with the folder.
- Tutorial chapters 8–11: new-document menu, PDF export, image insertion (Word-like), portable version.
- The whole `教程` folder is packaged now (previously `使用说明.md` was left out).

### Fixed

- Launcher and Start-menu shortcut pointed at the old tutorial path after the tutorial folder was nested one
  level deeper (`教程\MarkText 新手教学\新手教学.md`).
- Uninstall could leave `ShellNew` behind.

### Changed

- Slimmer build sources: launcher 2.5 → 1.9 KB, build script 3.1 → 2.7 KB (plus portable support).
- Bundled NSIS 3.11 distribution trimmed 6.8 → 4.4 MB (docs/examples/help/`makensisw` removed; required
  `Plugins\nsDialogs` kept).

## v0.23.0-cn.1 — 2026-11-03

### Added

- First packaging of MarkText 0.23.0 for Windows: per-user NSIS installer, custom install directory,
  desktop/Start-menu shortcuts, bundled Chinese tutorial with 4 screenshots.
- Enter inserts a new table row (patch applied to the installed `resources/app.asar`).
- Auto-update disabled, first launch opens the tutorial, `.md` Open-with registration.

### Fixed

- `.md` was registered under three different ProgIds, so the *Open with* menu showed MarkText three times.
  Now a single `Markdown` ProgId is used; uninstall only removes it when it still points at this install.
