#!/usr/bin/env bash
set -e

ISO_PENDRIVE_MAX_MB=325
LOG_DIR="$HOME/mini-flash-os/flashpart"
LOG_FILE="$LOG_DIR/flashpart.log"

mkdir -p "$LOG_DIR"

echo "=== Mini Flash OS - Flashpart (Gerenciador de Memória) ==="
echo "Regra de pendrive/ISO: até ${ISO_PENDRIVE_MAX_MB} MB"

if [ -r /proc/meminfo ]; then
  MEM_TOTAL_KB=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
  MEM_AVAIL_KB=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)
  [ -z "$MEM_AVAIL_KB" ] && MEM_AVAIL_KB="$MEM_TOTAL_KB"

  MEM_TOTAL_MB=$((MEM_TOTAL_KB / 1024))
  MEM_AVAIL_MB=$((MEM_AVAIL_KB / 1024))
  MEM_USED_MB=$((MEM_TOTAL_MB - MEM_AVAIL_MB))

  echo "RAM Total: ${MEM_TOTAL_MB} MB"
  echo "RAM Em uso: ${MEM_USED_MB} MB | Disponível: ${MEM_AVAIL_MB} MB"

  if [ "$MEM_AVAIL_MB" -lt 512 ]; then
    echo "Alerta: memória livre baixa (< 512 MB). Feche abas ou apps pesados."
  fi
fi

echo ""
echo "--- Espaço em disco / montagens ---"
df -h 2>/dev/null | head -n 8

echo "Verificado em $(date)" >> "$LOG_FILE"
