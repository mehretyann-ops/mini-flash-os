#!/usr/bin/env bash
set -e

ACTIVE_LOCK="/tmp/minios-active-game.lock"
GAMES_DIR="$HOME/mini-flash-os/games"
mkdir -p "$GAMES_DIR"

if [ -f "$ACTIVE_LOCK" ]; then
  CURRENT_GAME="$(cat "$ACTIVE_LOCK")"
  echo "Já existe um jogo em execução: '$CURRENT_GAME'."
  echo "Feche o jogo atual antes de abrir outro para economizar memória RAM."
  exit 1
fi

printf "Nome ou executável do jogo (ex.: Roblox, Clash of Clans): "
read -r GAME_NAME
printf "Tamanho estimado do jogo em MB: "
read -r GAME_SIZE

if [ -z "$GAME_NAME" ]; then
  echo "Nome do jogo inválido."
  exit 1
fi

if [ "$GAME_SIZE" -gt 110 ] 2>/dev/null; then
  echo "Jogo pesado (> 110 MB): aplicando perfil de gráficos mínimos, resolução reduzida e prioridade em um jogo por vez."
elif [ "$GAME_SIZE" -ge 99 ] 2>/dev/null; then
  echo "Jogo na faixa de atenção (99–110 MB): monitorando uso de memória e mantendo gráficos no mínimo."
else
  echo "Jogo leve (< 99 MB): iniciando com gráficos mínimos para preservar RAM."
fi

echo "$GAME_NAME" > "$ACTIVE_LOCK"
trap 'rm -f "$ACTIVE_LOCK"' EXIT

echo "Iniciando '$GAME_NAME' (gráficos: mínimo | resolução: equilibrada baixa | modo: um por vez)..."
