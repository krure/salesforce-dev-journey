#!/usr/bin/env bash
# Despliega solo lo que cambió (sfdx-git-delta) a una org ya autenticada.
# Uso: ./scripts/ci/deploy-delta.sh <alias-org> <test-level> [sha-base]
#   test-level: NoTestRun | RunLocalTests | RunAllTestsInOrg
#   sha-base:   commit desde el cual calcular el delta. Si se omite (o es el SHA nulo
#               de un primer push), se hace un despliegue completo de force-app.
set -euo pipefail

TARGET_ORG="${1:?Falta el alias de la org}"
TEST_LEVEL="${2:?Falta el nivel de pruebas}"
FROM="${3:-}"

if [[ -z "$FROM" || "$FROM" =~ ^0+$ ]]; then
  echo "==> Sin commit base: despliegue completo de force-app"
  sf project deploy start \
    --source-dir force-app \
    --target-org "$TARGET_ORG" \
    --test-level "$TEST_LEVEL" \
    --wait 60
  exit 0
fi

echo "==> Instalando sfdx-git-delta"
echo y | sf plugins install sfdx-git-delta

echo "==> Calculando delta ${FROM}..HEAD"
rm -rf changed-sources
mkdir -p changed-sources
sf sgd source delta --from "$FROM" --to HEAD --output-dir changed-sources --generate-delta --source-dir force-app

PACKAGE_XML="changed-sources/package/package.xml"
DESTRUCTIVE_XML="changed-sources/destructiveChanges/destructiveChanges.xml"

HAS_CHANGES=false
HAS_DESTRUCTIVE=false
if [[ -f "$PACKAGE_XML" ]] && grep -q "<members>" "$PACKAGE_XML"; then HAS_CHANGES=true; fi
if [[ -f "$DESTRUCTIVE_XML" ]] && grep -q "<members>" "$DESTRUCTIVE_XML"; then HAS_DESTRUCTIVE=true; fi

if [[ "$HAS_CHANGES" = false && "$HAS_DESTRUCTIVE" = false ]]; then
  echo "==> No hay cambios de metadata que desplegar."
  exit 0
fi

echo "--- package.xml ---"
cat "$PACKAGE_XML"

ARGS=(--target-org "$TARGET_ORG" --test-level "$TEST_LEVEL" --wait 60)
if [[ "$HAS_CHANGES" = true ]]; then
  ARGS+=(--manifest "$PACKAGE_XML")
fi
if [[ "$HAS_DESTRUCTIVE" = true ]]; then
  ARGS+=(--post-destructive-changes "$DESTRUCTIVE_XML")
  # Con solo cambios destructivos se necesita un manifiesto (puede estar vacío)
  if [[ "$HAS_CHANGES" = false ]]; then
    ARGS+=(--manifest "$PACKAGE_XML")
  fi
fi

sf project deploy start "${ARGS[@]}"
