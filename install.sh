#!/bin/sh
# Auto IP Hunter Installer
# For OpenWRT
# Author: ais sia

set -e

echo "======================================"
echo " Auto IP Hunter - Installer"
echo "======================================"

# ================== CHECK ROOT ==================
if [ "$(id -u)" != "0" ]; then
  echo "[ERROR] Jalankan installer sebagai root"
  exit 1
fi

# ================== PATH ==================
BIN_DIR="/usr/bin"
INITD_DIR="/etc/init.d"
REPO_DIR="$(pwd)"

# ================== INSTALL BINARIES ==================
echo "[*] Installing binaries..."

cp "$REPO_DIR/auto-ip-hunter" "$BIN_DIR/auto-ip-hunter"
cp "$REPO_DIR/hilink" "$BIN_DIR/hilink"
cp "$REPO_DIR/menu-hilink" "$BIN_DIR/m"

chmod +x \
  "$BIN_DIR/auto-ip-hunter" \
  "$BIN_DIR/hilink" \
  "$BIN_DIR/m"

# ================== INSTALL BALONG NVTOOL ==================
if [ -f "$REPO_DIR/bin/balong-nvtool" ]; then
  echo "[*] Installing balong-nvtool..."
  cp "$REPO_DIR/bin/balong-nvtool" "$BIN_DIR/balong-nvtool"
  chmod +x "$BIN_DIR/balong-nvtool"
else
  echo "[WARN] bin/balong-nvtool tidak ditemukan (lock/unlock tidak akan berfungsi)"
fi

# ================== INSTALL INIT.D SERVICE ==================
if [ -f "$REPO_DIR/init.d/auto-ip-hunter" ]; then
  echo "[*] Installing init.d service..."
  cp "$REPO_DIR/init.d/auto-ip-hunter" "$INITD_DIR/auto-ip-hunter"
  chmod +x "$INITD_DIR/auto-ip-hunter"
else
  echo "[WARN] init.d/auto-ip-hunter tidak ditemukan"
fi

# ================== DEPENDENCIES ==================
echo "[*] Checking dependencies..."

opkg update

for pkg in curl jq adb screen; do
  if ! opkg list-installed | grep -q "^$pkg "; then
    echo "  - Installing $pkg"
    opkg install "$pkg"
  else
    echo "  - $pkg already installed"
  fi
done

# ================== ENABLE SERVICE ==================
if [ -f "$INITD_DIR/auto-ip-hunter" ]; then
  echo "[*] Enabling auto-ip-hunter service..."
  "$INITD_DIR/auto-ip-hunter" enable
  "$INITD_DIR/auto-ip-hunter" restart
fi

echo "======================================"
echo " ✅ Installation complete"
echo "======================================"
echo ""
echo " Menu  : ketik 'm'"
echo " Service status :"
echo "   ps | grep auto-ip-hunter"
echo "   logread | tail"
echo ""
