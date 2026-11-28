#!/usr/bin/env bash
set -e

GUARD_DIR="$HOME/mini-flash-os/install-guard"
LOG_FILE="$GUARD_DIR/blocked-installs.log"
MAX_PKG_MB=250
MIN_FREE_RAM_MB=600

mkdir -p "$GUARD_DIR"
touch "$LOG_FILE"

printf "Nome do programa ou pacote a instalar: "
read -r PKG_NAME
printf "Tamanho estimado da instalação em MB: "
read -r PKG_SIZE_MB

FREE_RAM_MB="$(free -m 2>/dev/null | awk '/^Mem:/ {print $7}' || echo 1024)"

if [ -z "$PKG_NAME" ]; then
  echo "Nome de pacote inválido."
  exit 1
fi

if [ "$PKG_SIZE_MB" -gt "$MAX_PKG_MB" ] 2>/dev/null; then
  echo "[BLOQUEADO] '$PKG_NAME' (${PKG_SIZE_MB} MB) ultrapassa o limite máximo de ${MAX_PKG_MB} MB do Mini Flash OS."
  echo "$(date '+%Y-%m-%d %H:%M:%S') | BLOQUEADO POR TAMANHO | $PKG_NAME (${PKG_SIZE_MB} MB)" >> "$LOG_FILE"
  exit 1
fi

if [ "$FREE_RAM_MB" -lt "$MIN_FREE_RAM_MB" ] 2>/dev/null; then
  echo "[BLOQUEADO] Memória RAM livre insuficiente (${FREE_RAM_MB} MB livres; mínimo exigido: ${MIN_FREE_RAM_MB} MB)."
  echo "$(date '+%Y-%m-%d %H:%M:%S') | BLOQUEADO POR RAM | $PKG_NAME (${FREE_RAM_MB} MB livres)" >> "$LOG_FILE"
  exit 1
fi

echo "[APROVADO] '$PKG_NAME' (${PKG_SIZE_MB} MB) dentro dos limites leves do Mini Flash OS (RAM livre: ${FREE_RAM_MB} MB)."
