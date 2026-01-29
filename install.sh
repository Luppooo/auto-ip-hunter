#!/bin/sh
# Auto IP Hunter Installer / Uninstaller (Interactive)
# For OpenWRT
# Author: ais sia

set -e

BIN_DIR="/usr/bin"
INITD_DIR="/etc/init.d"

AUTO_BIN="$BIN_DIR/auto-ip-hunter"
HILINK_BIN="$BIN_DIR/hilink"
MENU_BIN="$BIN_DIR/m"
BALONG_BIN="$BIN_DIR/balong-nvtool"
INITD_BIN="$INITD_DIR/auto-ip-hunter"

REPO_DIR="$(pwd)"

# ================== UTIL ==================
banner() {
  clear
  echo "======================================"
  echo "        AUTO IP HUNTER INSTALLER       "
  echo "======================================"
}

require_root() {
  if [ "$(id -u)" != "0" ]; then
    echo "[ERROR] Jalankan sebagai root"
    exit 1
  fi
}

confirm() {
  while true; do
    printf "%s [y/n]: " "$1"
    read yn
    case "$yn" in
      y|Y) return 0 ;;
      n|N) return 1 ;;
      *) echo "Masukkan y atau n" ;;
    esac
  done
}

pause() {
  echo ""
  read -p "Tekan ENTER untuk kembali ke menu..."
}

# ================== UNINSTALL ==================
do_uninstall() {
  banner
  echo "[*] Uninstall Auto IP Hunter"
  echo ""

  if ! confirm "Yakin ingin UNINSTALL?"; then
    echo "Uninstall dibatalkan."
    sleep 1
    return
  fi

  echo ""
  echo " - Stopping service"
  [ -f "$INITD_BIN" ] && "$INITD_BIN" stop || true
  [ -f "$INITD_BIN" ] && "$INITD_BIN" disable || true

  echo " - Removing files"
  rm -f "$AUTO_BIN" "$HILINK_BIN" "$MENU_BIN" "$BALONG_BIN"
  rm -f "$INITD_BIN"

  echo " - Cleaning temp files"
  rm -rf /tmp/clash-iphunter /tmp/clash-iphunter.log

  echo ""
  echo "✅ Uninstall selesai"
  pause
}

# ================== INSTALL ==================
do_install() {
  banner
  echo "[*] Install Auto IP Hunter"
  echo ""

  if ! confirm "Lanjutkan INSTALL?"; then
    echo "Install dibatalkan."
    sleep 1
    return
  fi

  echo ""
  echo " - Installing binaries"
  cp src/auto-ip-hunter "$AUTO_BIN"
  cp src/hilink "$HILINK_BIN"
  cp src/menu "$MENU_BIN"
  chmod +x "$AUTO_BIN" "$HILINK_BIN" "$MENU_BIN"

  if [ -f "$REPO_DIR/bin/balong-nvtool" ]; then
    cp "$REPO_DIR/bin/balong-nvtool" "$BALONG_BIN"
    chmod +x "$BALONG_BIN"
  else
    echo " [WARN] balong-nvtool tidak ditemukan"
  fi

  if [ -f "$REPO_DIR/init.d/auto-ip-hunter" ]; then
    cp "$REPO_DIR/init.d/auto-ip-hunter" "$INITD_BIN"
    chmod +x "$INITD_BIN"
  fi

  echo " - Checking dependencies"
  opkg update

  for pkg in curl jq adb screen; do
    if ! opkg list-installed | grep -q "^$pkg "; then
      echo "   Installing $pkg"
      opkg install "$pkg"
    fi
  done

  if [ -f "$INITD_BIN" ]; then
    echo " - Enabling service"
    "$INITD_BIN" enable
    "$INITD_BIN" restart
  fi

  echo ""
  echo "✅ Install selesai"
  echo " Menu : ketik 'm'"
  pause
}

# ================== MENU ==================
main_menu() {
  while true; do
    banner
    echo " 1) Install"
    echo " 2) Uninstall"
    echo " 3) Exit"
    echo ""
    read -p "Pilih menu [1-3]: " opt

    case "$opt" in
      1) do_install ;;
      2) do_uninstall ;;
      3) clear; exit 0 ;;
      *) echo "Pilihan tidak valid"; sleep 1 ;;
    esac
  done
}

# ================== ENTRY ==================
require_root

case "$1" in
  uninstall)
    do_uninstall
  ;;
  *)
    main_menu
  ;;
esac
