#!/usr/bin/env bash
# Проверка решения: синтаксический контроль модулей + модульные тесты YAxUnit.
# Использование: scripts/check.sh [фильтр_модулей_тестов, напр. ОМ_М06]
set -uo pipefail
source "$(dirname "$0")/env.sh"
FILTER="${1:-}"

echo ">> 1/2 Синтаксический контроль"
if ! designer check-modules.log /CheckModules -ThinClient -Server; then
  echo "❌ Ошибки компиляции, см. $OUT_DIR/check-modules.log"; exit 1
fi

echo ">> 2/2 Тесты YAxUnit"
CFG="$OUT_DIR/yaxunit.json"
if [ -n "$FILTER" ]; then MODULES="\"modules\": [\"$FILTER\"],"; else MODULES=""; fi
cat > "$CFG" <<JSON
{
  "filter": { $MODULES "extensions": ["Tests"] },
  "reportFormat": "jUnit",
  "reportPath": "$OUT_DIR/junit.xml",
  "exitCode": "$OUT_DIR/exitcode.txt",
  "closeAfterTests": true,
  "showReport": false,
  "logging": { "file": "$OUT_DIR/yaxunit.log", "console": true }
}
JSON
rm -f "$OUT_DIR/exitcode.txt" "$OUT_DIR/junit.xml"
"$V8_BIN" ENTERPRISE /F "$IB_PATH" $(v8_auth) /DisableStartupDialogs /DisableStartupMessages \
  /C "RunUnitTests=$CFG" /Out "$OUT_DIR/enterprise.log"

if [ ! -s "$OUT_DIR/exitcode.txt" ]; then
  echo "⚠ Тесты не запустились — проверьте, что установлено расширение YAxUnit (см. $OUT_DIR/yaxunit.log)"; exit 2
elif [ "$(tr -d '[:space:]' < "$OUT_DIR/exitcode.txt")" != "0" ]; then
  echo "❌ Есть упавшие тесты, см. $OUT_DIR/junit.xml"; exit 1
fi
echo "✅ Все проверки пройдены"
