#!/usr/bin/env bash
set -e

LAYOUT_DIR="$HOME/mini-flash-os/layout-manager"
STATE_FILE="$LAYOUT_DIR/active-layout.conf"
mkdir -p "$LAYOUT_DIR"

apply_layout() {
  local mode="$1"
  cat <<EOF > "$STATE_FILE"
LAYOUT_MODE="$mode"
COMPOSITOR_EFFECTS="off"
ANIMATIONS="disabled"
PANEL_DOCK="bottom-compact"
TILE_POLICY="auto-fit"
EOF
  echo "Disposição '$mode' aplicada: animações desativadas e painel compacto para poupar RAM."
}

echo "=== Mini Flash OS — Layout Manager ==="
echo "1) Janelas lado a lado / mosaico leve (tile)"
echo "2) Janela única focada / ecrã inteiro (focus)"
echo "3) Modo jogos / máxima memória livre (game-focus)"
printf "Escolha a disposição: "
read -r OPT

case "$OPT" in
  1) apply_layout "tile" ;;
  2) apply_layout "focus" ;;
  3) apply_layout "game-focus" ;;
  *) echo "Opção inválida." ;;
esac
