; MarkText 0.23.0 中文定制版 · NSIS 安装脚本
; 免管理员 · 可改目录 · 桌面/开始菜单 · 首启弹教程 · .md 只登记一个 ProgId
Unicode true
!include "MUI2.nsh"

!define APP_NAME  "MarkText"
!define APP_VER   "0.23.0"
!define APP_EXE   "marktext.exe"
!define LAUNCHER  "启动 MarkText.exe"
!define SRC       "..\stage\app"
!define ICON      "..\stage\app\resources\md.ico"    ; 仅编译期用；运行时用 $INSTDIR\resources\md.ico
!define PROGID    "Markdown"                          ; 与官方安装同一个 ProgId，避免“打开方式”出现多个 MarkText
!define CFG_KEY   "Software\MarkTextCustom"
!define REG_KEY   "Software\Microsoft\Windows\CurrentVersion\Uninstall\MarkText"

Name "${APP_NAME} ${APP_VER}"
BrandingText "${APP_NAME} ${APP_VER}"
OutFile "..\dist\MarkText-0.23.0-安装程序.exe"
InstallDir "$LOCALAPPDATA\Programs\MarkText"
InstallDirRegKey HKCU "${CFG_KEY}" "InstallDir"
RequestExecutionLevel user
SetCompressor /SOLID lzma
SetCompressorDictSize 64
CRCCheck on
ShowInstDetails show
ShowUninstDetails show

!define MUI_ABORTWARNING
!define MUI_ICON   "${ICON}"
!define MUI_UNICON "${ICON}"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Header\nsis3-metro.bmp"
!define MUI_WELCOMEPAGE_TITLE "安装 MarkText ${APP_VER}"
!define MUI_WELCOMEPAGE_TEXT "开箱即用的 Markdown 编辑器：无需联网、无需管理员、可自选安装位置。$\r$\n$\r$\n装好后桌面有快捷方式，第一次打开会自动显示《新手教学》。"
!define MUI_DIRECTORYPAGE_TEXT_TOP "请选择安装位置。建议保持默认，也可点“浏览”换到别的盘（例如 D:\MarkText）。"
!define MUI_FINISHPAGE_RUN "$INSTDIR\${LAUNCHER}"
!define MUI_FINISHPAGE_RUN_TEXT "立即打开 MarkText（首次会显示新手教程）"
!define MUI_FINISHPAGE_LINK "查看新手教程"
!define MUI_FINISHPAGE_LINK_LOCATION "$INSTDIR\教程\MarkText 新手教学\新手教学.md"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH
!insertmacro MUI_LANGUAGE "SimpChinese"

; ------------------------------ 安装 ------------------------------
Section "MarkText 主程序（必装）"
  SectionIn RO
  SetShellVarContext current
  SetOutPath "$INSTDIR"
  File /r "${SRC}\*.*"
  WriteUninstaller "$INSTDIR\卸载 MarkText.exe"

  CreateShortCut "$DESKTOP\MarkText.lnk" "$INSTDIR\${LAUNCHER}" "" "$INSTDIR\${LAUNCHER}" 0
  CreateDirectory "$SMPROGRAMS\MarkText"
  CreateShortCut "$SMPROGRAMS\MarkText\MarkText.lnk"   "$INSTDIR\${LAUNCHER}" "" "$INSTDIR\${LAUNCHER}" 0
  CreateShortCut "$SMPROGRAMS\MarkText\新手教程.lnk"   "$INSTDIR\${APP_EXE}" '"$INSTDIR\教程\MarkText 新手教学\新手教学.md"' "$INSTDIR\resources\md.ico" 0
  CreateShortCut "$SMPROGRAMS\MarkText\卸载 MarkText.lnk" "$INSTDIR\卸载 MarkText.exe"

  ; 只登记一个 ProgId（不写 Applications\marktext.exe，否则“打开方式”里会重复）
  WriteRegStr HKCU "Software\Classes\${PROGID}" "" "Markdown 文档"
  WriteRegStr HKCU "Software\Classes\${PROGID}\DefaultIcon" "" "$INSTDIR\resources\md.ico,0"
  WriteRegStr HKCU "Software\Classes\${PROGID}\shell\open\command" "" '"$INSTDIR\${APP_EXE}" "%1"'
  WriteRegStr HKCU "Software\Classes\.md\OpenWithProgids"       "${PROGID}" ""
  WriteRegStr HKCU "Software\Classes\.markdown\OpenWithProgids" "${PROGID}" ""
  WriteRegStr HKCU "Software\Classes\.mdown\OpenWithProgids"    "${PROGID}" ""

  ; 右键「新建」菜单里出现「Markdown 文档」
  WriteRegStr HKCU "Software\Classes\.md\ShellNew" "NullFile" ""

  WriteRegStr   HKCU "${CFG_KEY}" "InstallDir"     "$INSTDIR"
  WriteRegStr   HKCU "${REG_KEY}" "DisplayName"     "${APP_NAME} ${APP_VER}"
  WriteRegStr   HKCU "${REG_KEY}" "DisplayIcon"     "$INSTDIR\resources\md.ico"
  WriteRegStr   HKCU "${REG_KEY}" "DisplayVersion"  "${APP_VER}"
  WriteRegStr   HKCU "${REG_KEY}" "Publisher"       "MarkText"
  WriteRegStr   HKCU "${REG_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr   HKCU "${REG_KEY}" "UninstallString" '"$INSTDIR\卸载 MarkText.exe"'
  WriteRegDWORD HKCU "${REG_KEY}" "NoModify" 1
  WriteRegDWORD HKCU "${REG_KEY}" "NoRepair" 1

  Delete "$APPDATA\MarkTextLauncher\tutorial-shown.flag"   ; 重装后重新触发首启教程
SectionEnd

; ------------------------------ 卸载 ------------------------------
Section "Uninstall"
  SetShellVarContext current
  Delete "$DESKTOP\MarkText.lnk"
  Delete "$SMPROGRAMS\MarkText\MarkText.lnk"
  Delete "$SMPROGRAMS\MarkText\新手教程.lnk"
  Delete "$SMPROGRAMS\MarkText\卸载 MarkText.lnk"
  RMDir  "$SMPROGRAMS\MarkText"

  ; ProgId 只有还指向本目录时才删，避免连坐另一个 MarkText 安装
  ReadRegStr $0 HKCU "Software\Classes\${PROGID}\shell\open\command" ""
  StrCmp $0 '"$INSTDIR\${APP_EXE}" "%1"' 0 progid_keep
    DeleteRegKey HKCU "Software\Classes\${PROGID}"
  progid_keep:

  DeleteRegValue HKCU "Software\Classes\.md\OpenWithProgids"       "${PROGID}"
  DeleteRegValue HKCU "Software\Classes\.markdown\OpenWithProgids" "${PROGID}"
  DeleteRegValue HKCU "Software\Classes\.mdown\OpenWithProgids"    "${PROGID}"
  DeleteRegKey HKCU "Software\Classes\.md\ShellNew"
  DeleteRegKey HKCU "${CFG_KEY}"
  DeleteRegKey HKCU "${REG_KEY}"
  RMDir /r "$INSTDIR"
SectionEnd
