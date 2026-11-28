#!/usr/bin/env bash
set -e

BASE_DIR="$HOME/mini-flash-os"

while true; do
  echo ""
  echo "=== Mini Flash OS ==="
  echo "1) Ligar ao Wi-Fi"
  echo "2) Limpar lixeira (mais de 2h)"
  echo "3) Iniciar jogo"
  echo "4) Mudar disposição de janelas"
  echo "5) Verificar instalação de pacote"
  echo "0) Sair"
  printf "Escolha uma opção: "
  read -r OPCAO

  case "$OPCAO" in
    1) bash "$BASE_DIR/network/wifi-connect.sh" ;;
    2) bash "$BASE_DIR/trash/session-cleaner.sh" ;;
    3) bash "$BASE_DIR/games/game-launcher.sh" ;;
    4) bash "$BASE_DIR/layout-manager/layout-manager.sh" ;;
    5) bash "$BASE_DIR/install-guard/install-guard.sh" ;;
    0) echo "A sair..."; break ;;
    *) echo "Opção inválida." ;;
  esac
done
