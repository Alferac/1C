# Настройки стенда (Windows). Отредактируйте один раз. Подключение: . .\scripts\env.ps1
$V8Version = if ($env:V8_VERSION) { $env:V8_VERSION } else { "8.3.25.1000" }
$Global:V8Bin    = "C:\Program Files\1cv8\$V8Version\bin\1cv8.exe"
$Global:RepoRoot = Split-Path -Parent $PSScriptRoot
$Global:IbPath   = "C:\1c\ib\trade"
$Global:SrcDir   = Join-Path $RepoRoot "src"
$Global:TestsDir = Join-Path $RepoRoot "tests"
$Global:OutDir   = Join-Path $RepoRoot "out"
$Global:IbUser   = ""    # пусто, пока в ИБ нет пользователей
$Global:IbPwd    = ""
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

function Get-V8Auth { if ($IbUser) { @("/N", $IbUser, "/P", $IbPwd) } else { @() } }

# Пакетный запуск Конфигуратора. Возвращает $true при успехе.
function Invoke-Designer([string]$Log, [string[]]$Params) {
    $logPath = Join-Path $OutDir $Log
    $argList = @("DESIGNER", "/F", "`"$IbPath`"") + (Get-V8Auth) +
               @("/DisableStartupDialogs", "/DisableStartupMessages", "/Out", "`"$logPath`"") + $Params
    $p = Start-Process -FilePath $V8Bin -ArgumentList $argList -Wait -PassThru -NoNewWindow
    if (Test-Path $logPath) { Get-Content $logPath -Encoding UTF8 }
    return ($p.ExitCode -eq 0)
}
