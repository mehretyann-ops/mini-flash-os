#!/usr/bin/env bash
set -e

NET_DIR="$HOME/mini-flash-os/network"
STATE_FILE="$NET_DIR/wifi-status.env"
mkdir -p "$NET_DIR"

if command -v nmcli >/dev/null 2>&1; then
  nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi list | head -n 10
  printf "Digite o nome da rede Wi-Fi (SSID): "
  read -r SSID

  if [ -z "$SSID" ]; then
    echo "Nome da rede inválido."
    exit 1
  fi

  printf "Digite a senha do Wi-Fi (ou pressione Enter se for rede aberta): "
  read -rs PASS
  echo ""

  if [ -n "$PASS" ]; then
    nmcli dev wifi connect "$SSID" password "$PASS"
  else
    nmcli dev wifi connect "$SSID"
  fi

  echo "WIFI_CONNECTED=true" > "$STATE_FILE"
  echo "WIFI_SSID=$SSID" >> "$STATE_FILE"
  echo "Conectado com sucesso à rede '$SSID'."
else
  echo "Ferramenta 'nmcli' não encontrada. Configure a rede pelo gestor do sistema."
fi
