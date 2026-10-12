#!/usr/bin/env bash
# Пересоздаёт файловую ИБ из исходников: src/ (+ расширение tests/, если есть).
set -euo pipefail
source "$(dirname "$0")/env.sh"

echo ">> Пересоздаю ИБ $IB_PATH"
rm -rf "$IB_PATH"; mkdir -p "$IB_PATH"
"$V8_BIN" CREATEINFOBASE File="$IB_PATH" /Out "$OUT_DIR/create.log"

echo ">> Загружаю конфигурацию из $SRC_DIR"
designer load.log /LoadConfigFromFiles "$SRC_DIR" /UpdateDBCfg

if [ -d "$TESTS_DIR" ]; then
  echo ">> Загружаю расширение Tests из $TESTS_DIR"
  designer load-tests.log /LoadConfigFromFiles "$TESTS_DIR" -Extension Tests /UpdateDBCfg -Extension Tests
fi
echo ">> Готово"
