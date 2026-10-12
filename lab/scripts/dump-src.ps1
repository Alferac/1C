# Выгружает конфигурацию (и расширение Tests) из ИБ в исходники для коммита в git.
param([switch]$NoTests)
. "$PSScriptRoot\env.ps1"

if (-not (Invoke-Designer "dump.log" @("/DumpConfigToFiles", "`"$SrcDir`"", "-Format", "Hierarchical"))) { throw "Ошибка выгрузки" }
if (-not $NoTests) {
    if (-not (Invoke-Designer "dump-tests.log" @("/DumpConfigToFiles", "`"$TestsDir`"", "-Extension", "Tests", "-Format", "Hierarchical"))) {
        Write-Warning "Расширение Tests не выгружено (его ещё нет?)"
    }
}
git -C $RepoRoot status --short
