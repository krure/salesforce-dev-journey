#!/usr/bin/env bash
# Crea una scratch org para desarrollo local, despliega el proyecto y la deja lista.
# Uso: ./scripts/scratch/create-scratch-org.sh [alias] [dias]
# Requisitos: Salesforce CLI (sf) y una Dev Hub autenticada (sf org login web --set-default-dev-hub).
set -euo pipefail

ALIAS="${1:-muc-dev}"
DURATION="${2:-7}"

echo "==> Creando scratch org '${ALIAS}' (${DURATION} días)"
sf org create scratch \
  --definition-file config/project-scratch-def.json \
  --alias "${ALIAS}" \
  --duration-days "${DURATION}" \
  --set-default \
  --wait 15

echo "==> Desplegando código fuente"
sf project deploy start --source-dir force-app --target-org "${ALIAS}" --wait 20

echo "==> Asignando permission set al usuario por defecto"
sf org assign permset --name MassUserCreator_Admin --target-org "${ALIAS}"

echo "==> Cargando datos semilla"
sf apex run --file scripts/apex/seed-data.apex --target-org "${ALIAS}"

echo "==> Listo. Abriendo la org..."
sf org open --target-org "${ALIAS}"
