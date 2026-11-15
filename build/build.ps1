<#
  MarkText 0.23.0 中文定制版 · 一键打包
  依赖：.NET Framework 的 csc.exe、tools\nsis-3.11（makensis）
  用法：
    powershell -ExecutionPolicy Bypass -File build.ps1                  # 只打安装包
    powershell -ExecutionPolicy Bypass -File build.ps1 -Portable        # 安装包 + 便携版自解压 exe
  可选：-AppSrc <已装 MarkText> -Tutorial <教程目录> -KeepAllLocales -KeepStage
#>
param(
    [string]$AppSrc   = "$env:LOCALAPPDATA\Programs\marktext",
    [string]$Tutorial = "$env:USERPROFILE\Desktop\藴然\DSH工作\MarkText中文定制版\教程",
    [switch]$Portable,
    [switch]$KeepAllLocales,
    [switch]$KeepStage
)
$ErrorActionPreference = 'Stop'

$here  = $PSScriptRoot
$root  = Split-Path -Parent $here
$stage = Join-Path $root 'stage\app'
$dist  = Join-Path $root 'dist'
$out   = Join-Path $dist 'MarkText-0.23.0-安装程序.exe'
$pout  = Join-Path $dist 'MarkText-0.23.0-便携版.exe'
$csc   = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
$nsis  = Join-Path $root 'tools\nsis-3.11\Bin\makensis.exe'
$src   = Join-Path $here 'launcher.cs'

function Say([string]$m) { Write-Host "[build] $m" -ForegroundColor Cyan }
function Must([string]$p, [string]$what) { if (-not (Test-Path -LiteralPath $p)) { throw "$what 不存在: $p" } }
function Note([string]$path) {
    $f = Get-Item -LiteralPath $path
    Write-Host ("  {0,-36} {1,6:N1} MB  {2}" -f $f.Name, ($f.Length / 1MB), (Get-FileHash $f -Algorithm SHA256).Hash.ToLower())
}

Must $AppSrc '已安装的 MarkText 目录'
Must $csc    'csc.exe'
Must $nsis   'makensis.exe'
Must (Join-Path $here 'marktext-installer.nsi') '安装脚本'
Must (Join-Path $here 'portable.nsi') '便携版脚本'
Must $src '启动器源码'

if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Force -Path $stage, $dist | Out-Null

Say '1/5 收集程序文件'
robocopy $AppSrc $stage /E /XF app.asar.bak 'Uninstall marktext.exe' /NFL /NDL /NJH /NJS /NP | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy 失败: $LASTEXITCODE" }
Remove-Item (Join-Path $stage 'resources\app-update.yml') -Force -ErrorAction SilentlyContinue   # 保住表格 Enter 补丁

Say '2/5 精简语言包（只留 zh-CN / en-US）'
if (-not $KeepAllLocales) {
    $locales = Join-Path $stage 'locales'
    if (Test-Path $locales) {
        $before = (Get-ChildItem $locales -File | Measure-Object Length -Sum).Sum
        Get-ChildItem $locales -File | Where-Object { $_.Name -notmatch '^(zh-CN|en-US)\.pak$' } | Remove-Item -Force
        $after = (Get-ChildItem $locales -File | Measure-Object Length -Sum).Sum
        Write-Host ("  语言包 {0:N1} MB -> {1:N1} MB（省 {2:N1} MB）" -f ($before/1MB), ($after/1MB), (($before-$after)/1MB))
    }
} else { Write-Host "  （-KeepAllLocales：保留全部语言包）" }

Say '3/5 放入教程'
if (Test-Path $Tutorial) {
    robocopy $Tutorial (Join-Path $stage '教程') /E /NFL /NDL /NJH /NJS /NP | Out-Null
} else {
    Write-Warning "教程目录不存在，跳过: $Tutorial"
}

Say '4/5 编译启动器 + NSIS 打包安装程序（几分钟）'
& $csc /nologo /target:winexe /optimize+ /win32icon:"$stage\resources\md.ico" /out:"$stage\启动 MarkText.exe" $src
if ($LASTEXITCODE) { throw "csc 失败: $LASTEXITCODE" }
Push-Location $here
try { & $nsis /V2 'marktext-installer.nsi' } finally { Pop-Location }
if ($LASTEXITCODE) { throw "makensis(安装包) 失败: $LASTEXITCODE" }

if ($Portable) {
    Say '5/5 便携版自解压包（LZMA，几分钟）'
    # 换成便携版启动器：配置存 data\、不碰 %APPDATA%
    Remove-Item (Join-Path $stage '启动 MarkText.exe') -Force -ErrorAction SilentlyContinue
    & $csc /nologo /target:winexe /optimize+ /define:PORTABLE /win32icon:"$stage\resources\md.ico" `
        /out:"$stage\启动 MarkText 便携版.exe" $src
    if ($LASTEXITCODE) { throw "csc(PORTABLE) 失败: $LASTEXITCODE" }

    $txt = @"
MarkText 0.23.0 便携版
======================

把本包解压到任意文件夹（U 盘也行），双击「启动 MarkText 便携版.exe」。

· 不需要安装、不需要管理员权限、不写注册表、不建快捷方式
· 配置和缓存都在本文件夹的 data\ 里，换电脑整体拷走即可
· 第一次打开会自动显示《新手教学》
· 想清空所有设置：删掉 data\ 文件夹即可

注意：便携版不会接管 .md 的默认打开方式。要在别的电脑上双击打开 .md，
请右键 → 打开方式 → 选择本文件夹的 marktext.exe → 勾「始终使用」。
"@
    Set-Content -Path (Join-Path $stage '便携版使用说明.txt') -Value $txt -Encoding UTF8

    $old = $env:NSISDIR
    Push-Location $here
    try {
        $env:NSISDIR = Join-Path $root 'tools\nsis-3.11'
        & $nsis /V2 'portable.nsi'
    } finally { Pop-Location; $env:NSISDIR = $old }
    if ($LASTEXITCODE) { throw "makensis(便携版) 失败: $LASTEXITCODE" }
}

$installer = Get-Item $out
if (-not $KeepStage) { Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue }   # 清掉几百 MB 暂存区

Say '完成'
Note $installer.FullName
if ($Portable -and (Test-Path $pout)) { Note $pout }
if ($KeepStage) { Write-Host "  （已保留 stage\ 供检查）" }
