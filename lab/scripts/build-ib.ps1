# Пересоздаёт файловую ИБ из исходников: src\ (+ расширение tests\, если есть).
. "$PSScriptRoot\env.ps1"
$ErrorActionPreference = "Stop"

Write-Host ">> Пересоздаю ИБ $IbPath"
if (Test-Path $IbPath) { Remove-Item -Recurse -Force $IbPath }
New-Item -ItemType Directory -Force -Path $IbPath | Out-Null
Start-Process -FilePath $V8Bin -ArgumentList @("CREATEINFOBASE", "File=`"$IbPath`"", "/Out", "`"$OutDir\create.log`"") -Wait -NoNewWindow

Write-Host ">> Загружаю конфигурацию из $SrcDir"
if (-not (Invoke-Designer "load.log" @("/LoadConfigFromFiles", "`"$SrcDir`"", "/UpdateDBCfg"))) { throw "Ошибка загрузки конфигурации" }

if (Test-Path $TestsDir) {
    Write-Host ">> Загружаю расширение Tests"
    if (-not (Invoke-Designer "load-tests.log" @("/LoadConfigFromFiles", "`"$TestsDir`"", "-Extension", "Tests", "/UpdateDBCfg", "-Extension", "Tests"))) { throw "Ошибка загрузки расширения" }
}
Write-Host ">> Готово"
