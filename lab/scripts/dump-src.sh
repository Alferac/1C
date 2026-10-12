#!/usr/bin/env bash
# Выгружает конфигурацию (и расширение Tests) из ИБ в исходники для коммита в git.
set -euo pipefail
source "$(dirname "$0")/env.sh"

designer dump.log /DumpConfigToFiles "$SRC_DIR" -Format Hierarchical
if [ "${WITH_TESTS:-1}" = "1" ]; then
  designer dump-tests.log /DumpConfigToFiles "$TESTS_DIR" -Extension Tests -Format Hierarchical || \
    echo "!! Расширение Tests не выгружено (его ещё нет?)"
fi
git -C "$REPO_ROOT" status --short
