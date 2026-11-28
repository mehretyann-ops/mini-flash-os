#!/usr/bin/env bash
set -e

BASE_DIR="$HOME/mini-flash-os"
STATE_FILE="$BASE_DIR/flashpart/session-state.env"
ADMIN_FILE="$BASE_DIR/flashpart/admin-account.env"
SWAP_STATE="$BASE_DIR/cloud-swap/swap-status.env"

mkdir -p "$(dirname "$STATE_FILE")" "$(dirname "$SWAP_STATE")"
touch "$STATE_FILE" "$ADMIN_FILE" "$SWAP_STATE"

confirm_swap_removal() {
  echo "Configurar memória na nuvem removerá o arquivo swap de 2,5 GB."
  printf "Deseja continuar? [Sim / Cancelar]: "
  read -r ANS
  case "${ANS,,}" in
    sim|s)
      echo "SWAP_ACTIVE=false" > "$SWAP_STATE"
      echo "SWAP_REMOVED_FOR_CLOUD_MEMORY=true" >> "$SWAP_STATE"
      echo "Arquivo swap de 2,5 GB removido."
      return 0
      ;;
    *)
      echo "Operação cancelada. Swap de 2,5 GB mantido."
      return 1
      ;;
  esac
}

login_flow() {
  echo "Escolha o método de login: [1] E-mail | [2] Google (Play Store) | [3] GitHub"
  printf "Opção: "
  read -r OPT
  case "$OPT" in
    1) PROVIDER="email" ;;
    2) PROVIDER="google" ;;
    3) PROVIDER="github" ;;
    *) echo "Opção inválida."; return 1 ;;
  esac
  printf "Digite seu usuário/identificador para %s: " "$PROVIDER"
  read -r IDENT
  echo "LOGGED_IN=true" > "$STATE_FILE"
  echo "LOGIN_PROVIDER=$PROVIDER" >> "$STATE_FILE"
  echo "LOGIN_USER=$IDENT" >> "$STATE_FILE"
  echo "Login realizado via $PROVIDER ($IDENT)."
}

ensure_admin() {
  . "$ADMIN_FILE" 2>/dev/null || true
  if [ -z "${ADMIN_USER:-}" ] || [ -z "${ADMIN_PASS:-}" ]; then
    echo "Nenhuma conta de administrador configurada."
    printf "Criar usuário de administrador: "
    read -r NEW_ADMIN
    printf "Criar senha de administrador: "
    read -rs NEW_PASS
    echo ""
    echo "ADMIN_USER=$NEW_ADMIN" > "$ADMIN_FILE"
    echo "ADMIN_PASS=$NEW_PASS" >> "$ADMIN_FILE"
    echo "Conta de administrador '$NEW_ADMIN' criada."
  fi
}

nuvem_otimizador() {
  . "$STATE_FILE" 2>/dev/null || true
  if [ "${LOGGED_IN:-false}" != "true" ]; then
    login_flow || return 1
  fi
  printf "Tamanho do arquivo em MB (otimização ativa acima de 150 MB): "
  read -r SIZE_MB
  if [ "$SIZE_MB" -gt 150 ] 2>/dev/null; then
    echo "Arquivo de ${SIZE_MB} MB (> 150 MB) enviado ao Nuvem Otimizator."
  else
    echo "Arquivo de ${SIZE_MB} MB não passa do limite de 150 MB para envio automático."
  fi
}

configurador_particao() {
  . "$STATE_FILE" 2>/dev/null || true
  if [ "${LOGGED_IN:-false}" != "true" ]; then
    login_flow || return 1
  fi
  printf "RAM virtual na nuvem (2 a 8 GB): "
  read -r VRAM
  printf "Armazenamento na nuvem (até 8 GB): "
  read -r CSTOR
  if [ "$VRAM" -ge 2 ] && [ "$VRAM" -le 8 ] && [ "$CSTOR" -le 8 ] 2>/dev/null; then
    confirm_swap_removal || return 1
    echo "VIRTUAL_RAM_GB=$VRAM" > "$BASE_DIR/cloud-swap/virtual-mem.conf"
    echo "CLOUD_STORAGE_GB=$CSTOR" >> "$BASE_DIR/cloud-swap/virtual-mem.conf"
    echo "Partição configurada: ${VRAM} GB RAM virtual / ${CSTOR} GB armazenamento na nuvem."
  else
    echo "Valores fora da faixa permitida (RAM virtual: 2–8 GB; armazenamento: até 8 GB)."
  fi
}

creator_mode() {
  ensure_admin
  . "$STATE_FILE" 2>/dev/null || true
  if [ "${LOGGED_IN:-false}" != "true" ]; then
    login_flow || return 1
  fi
  confirm_swap_removal || return 1
  echo "VIRTUAL_RAM_GB=8" > "$BASE_DIR/cloud-swap/virtual-mem.conf"
  echo "CLOUD_STORAGE_GB=16" >> "$BASE_DIR/cloud-swap/virtual-mem.conf"
  echo "Modo Creator ativado: 8 GB RAM virtual / até 16 GB armazenamento na nuvem."
}

root_mode() {
  ensure_admin
  printf "Digite o PIN do Modo Root: "
  read -rs PIN
  echo ""
  if [ "$PIN" != "2410" ]; then
    echo "PIN incorreto."
    return 1
  fi
  echo "AVISO: Acessar o Modo Root revogará a conta de administrador atual e exigirá criar um novo usuário e senha de administrador."
  rm -f "$ADMIN_FILE"
  printf "Digite o NOVO usuário de administrador: "
  read -r NEW_ADMIN
  printf "Digite a NOVA senha de administrador: "
  read -rs NEW_PASS
  echo ""
  echo "ADMIN_USER=$NEW_ADMIN" > "$ADMIN_FILE"
  echo "ADMIN_PASS=$NEW_PASS" >> "$ADMIN_FILE"
  echo "ROOT_UNLOCKED=true" > "$BASE_DIR/flashpart/root-session.conf"
  echo "ROOT_VIRTUAL_RAM_MAX_GB=10" >> "$BASE_DIR/flashpart/root-session.conf"
  echo "ROOT_CLOUD_STORAGE_MAX_GB=18" >> "$BASE_DIR/flashpart/root-session.conf"
  echo "ROOT_AUTO_CACHE_MINUTES=5" >> "$BASE_DIR/flashpart/root-session.conf"
  echo "Modo Root ativo para '$NEW_ADMIN' (até 10 GB RAM virtual, máx. 18 GB nuvem, limpeza de cache a cada 5 min)."
}

echo "=== FlashPart Suite (65 MB) ==="
echo "1) Login (E-mail / Google / GitHub)"
echo "2) Nuvem Otimizator (> 150 MB)"
echo "3) Configurador de Partição (2-8 GB RAM virtual / até 8 GB nuvem)"
echo "4) Creator (8 GB RAM virtual / até 16 GB nuvem / Admin)"
echo "5) Modo Root (PIN 2410)"
printf "Escolha uma opção: "
read -r CHOICE

case "$CHOICE" in
  1) login_flow ;;
  2) nuvem_otimizador ;;
  3) configurador_particao ;;
  4) creator_mode ;;
  5) root_mode ;;
  *) echo "Opção inválida." ;;
esac
