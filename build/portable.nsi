; MarkText 0.23.0 便携版 · 自解压包（LZMA）
; 只解压，不写注册表、不建快捷方式、不要管理员权限
Unicode true
!include "MUI2.nsh"

Name "MarkText 0.23.0 便携版"
BrandingText "MarkText 0.23.0 便携版"
OutFile "..\dist\MarkText-0.23.0-便携版.exe"
InstallDir "$DESKTOP\MarkText-0.23.0-便携版"
RequestExecutionLevel user
SetCompressor /SOLID lzma
SetCompressorDictSize 64
CRCCheck on
ShowInstDetails nevershow
ShowUninstDetails nevershow

!define MUI_ABORTWARNING
!define MUI_ICON "..\stage\app\resources\md.ico"
!define MUI_WELCOMEPAGE_TITLE "MarkText 0.23.0 便携版"
!define MUI_WELCOMEPAGE_TEXT "选一个文件夹解压就能用：$\r$\n$\r$\n · 不安装、不写注册表、不需要管理员权限$\r$\n · 配置和缓存都在该文件夹的 data\ 里，整个文件夹可以拷走$\r$\n · 第一次打开会自动显示《新手教学》$\r$\n$\r$\n点“下一步”选择解压位置（可以直接放到 U 盘）。"
!define MUI_DIRECTORYPAGE_TEXT_TOP "选择解压位置。建议新建一个空文件夹，例如 D:\MarkText 便携版 或 U 盘上的目录。"
!define MUI_FINISHPAGE_RUN "$INSTDIR\启动 MarkText 便携版.exe"
!define MUI_FINISHPAGE_RUN_TEXT "立即运行 MarkText 便携版"
!define MUI_FINISHPAGE_LINK "查看新手教程"
!define MUI_FINISHPAGE_LINK_LOCATION "$INSTDIR\教程\MarkText 新手教学\新手教学.md"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "SimpChinese"

Section "解压"
  SetShellVarContext current
  SetOutPath "$INSTDIR"
  File /r "..\stage\app\*.*"
SectionEnd
