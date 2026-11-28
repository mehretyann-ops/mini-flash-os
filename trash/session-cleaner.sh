#!/usr/bin/env bash
set -e

TRASH_DIR="$HOME/mini-flash-os/trash/lixeira"
mkdir -p "$TRASH_DIR"

# Esvazia automaticamente itens enviados para a lixeira há mais de 2 horas (120 min)
find "$TRASH_DIR" -mindepth 1 -mmin +120 -exec rm -rf {} +
echo "Esvaziamento automático da lixeira concluído (itens com mais de 2 horas removidos)."
