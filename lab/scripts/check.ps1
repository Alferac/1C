# Проверка решения: синтаксический контроль + тесты YAxUnit.
# Пример: .\scripts\check.ps1 -Module ОМ_М06_КонтрольОстатков
param([string]$Module = "")
. "$PSScriptRoot\env.ps1"

Write-Host ">> 1/2 Синтаксический контроль"
if (-not (Invoke-Designer "check-modules.log" @("/CheckModules", "-ThinClient", "-Server"))) {
    Write-Host "❌ Ошибки компиляции, см. $OutDir\check-modules.log"; exit 1
}

Write-Host ">> 2/2 Тесты YAxUnit"
$filter = @{ extensions = @("Tests") }
if ($Module) { $filter.modules = @($Module) }
$cfg = @{
    filter = $filter; reportFormat = "jUnit"; reportPath = "$OutDir\junit.xml"
    exitCode = "$OutDir\exitcode.txt"; closeAfterTests = $true; showReport = $false
    logging = @{ file = "$OutDir\yaxunit.log"; console = $false }
}
$cfgPath = Join-Path $OutDir "yaxunit.json"
$cfg | ConvertTo-Json -Depth 5 | Set-Content -Path $cfgPath -Encoding UTF8
Remove-Item -ErrorAction SilentlyContinue "$OutDir\exitcode.txt", "$OutDir\junit.xml"

$argList = @("ENTERPRISE", "/F", "`"$IbPath`"") + (Get-V8Auth) +
           @("/DisableStartupDialogs", "/DisableStartupMessages", "/C", "`"RunUnitTests=$cfgPath`"")
Start-Process -FilePath $V8Bin -ArgumentList $argList -Wait -NoNewWindow

if (-not (Test-Path "$OutDir\exitcode.txt")) { Write-Host "⚠ Тесты не запустились — установлено ли расширение YAxUnit?"; exit 2 }
if ((Get-Content "$OutDir\exitcode.txt").Trim() -ne "0") { Write-Host "❌ Есть упавшие тесты, см. $OutDir\junit.xml"; exit 1 }
Write-Host "✅ Все проверки пройдены"
