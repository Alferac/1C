#!/usr/bin/env bash
# Настройки стенда. Отредактируйте под себя один раз.
export V8_VERSION="${V8_VERSION:-8.3.25.1000}"          # ваша версия платформы
export V8_BIN="${V8_BIN:-/opt/1cv8/x86_64/$V8_VERSION/1cv8}"
export REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export IB_PATH="${IB_PATH:-$HOME/1c/ib/trade}"           # каталог файловой ИБ
export SRC_DIR="${SRC_DIR:-$REPO_ROOT/src}"              # выгрузка конфигурации
export TESTS_DIR="${TESTS_DIR:-$REPO_ROOT/tests}"        # выгрузка расширения Tests (YAxUnit)
export OUT_DIR="${OUT_DIR:-$REPO_ROOT/out}"
export IB_USER="${IB_USER:-}"                            # пусто, пока в ИБ нет пользователей
export IB_PWD="${IB_PWD:-}"
mkdir -p "$OUT_DIR"

v8_auth() { [ -n "$IB_USER" ] && printf '%s\n' /N "$IB_USER" /P "$IB_PWD"; }

# designer <лог> <параметры...> — пакетный запуск Конфигуратора с проверкой кода возврата
designer() {
  local log="$OUT_DIR/$1"; shift
  "$V8_BIN" DESIGNER /F "$IB_PATH" $(v8_auth) /DisableStartupDialogs /DisableStartupMessages /Out "$log" "$@"
  local rc=$?
  cat "$log" 2>/dev/null
  return $rc
}
