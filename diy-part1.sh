#!/bin/bash

# =========================================================
# DIY Part 1
# Redmi AX6000 / OpenWrt 25.12.6
#
# Third-party packages and DAE APK signing key
# =========================================================

set -Eeuo pipefail

# ---------------------------------------------------------
# 0. Check OpenWrt source directory
# ---------------------------------------------------------

if [ ! -f include/kernel.mk ]; then
    echo "ERROR: Please run this script from OpenWrt source root."
    exit 1
fi

echo "========================================"
echo "DIY Part 1: Third-party packages"
echo "========================================"

mkdir -p package
mkdir -p files/etc/apk/keys

# ---------------------------------------------------------
# 1. Lucky
# ---------------------------------------------------------

if [ ! -d package/lucky ]; then

    echo "[1/3] Cloning Lucky..."

    git clone --depth 1 \
        https://github.com/gdy666/luci-app-lucky.git \
        package/lucky

else

    echo "[1/3] Lucky already exists, skipping."

fi

# ---------------------------------------------------------
# 2. Argon Theme
# ---------------------------------------------------------

if [ ! -d package/luci-theme-argon ]; then

    echo "[2/3] Cloning Argon Theme..."

    git clone --depth 1 \
        https://github.com/jerrykuku/luci-theme-argon.git \
        package/luci-theme-argon

else

    echo "[2/3] Argon already exists, skipping."

fi

# ---------------------------------------------------------
# 3. DAE APK public signing key
#
# DAE remains independently installed.
# ---------------------------------------------------------

echo "[3/3] Downloading DAE APK public key..."

DAE_KEY="files/etc/apk/keys/daeuniverse.pem"
DAE_TMP="${DAE_KEY}.tmp"

rm -f "$DAE_TMP"

if ! wget -q \
    --tries=3 \
    --timeout=30 \
    -O "$DAE_TMP" \
    https://openwrt.daeuniverse.org/public-key.pem; then

    rm -f "$DAE_TMP"

    echo "ERROR: Failed to download DAE public key."
    exit 1
fi

if [ ! -s "$DAE_TMP" ]; then

    rm -f "$DAE_TMP"

    echo "ERROR: DAE public key is empty."
    exit 1
fi

mv "$DAE_TMP" "$DAE_KEY"

echo "DAE public key installed successfully."

# ---------------------------------------------------------
# 4. Verify package directories
# ---------------------------------------------------------

if [ ! -f package/lucky/Makefile ]; then
    echo "ERROR: Lucky package Makefile not found."
    exit 1
fi

if [ ! -f package/luci-theme-argon/Makefile ]; then
    echo "ERROR: Argon package Makefile not found."
    exit 1
fi

echo "========================================"
echo "DIY Part 1 completed successfully."
echo "========================================"
