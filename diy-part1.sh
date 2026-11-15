#!/bin/bash

# =========================================================
# DIY Part 1
# Redmi AX6000 / Official OpenWrt 25.12.6
# =========================================================

set -euo pipefail

if [ ! -f include/kernel.mk ]; then
    echo "ERROR: Please run this script from OpenWrt source root."
    exit 1
fi

echo "========================================"
echo "DIY Part 1: Adding third-party packages"
echo "========================================"

mkdir -p package

# ---------------------------------------------------------
# 1. Lucky
# ---------------------------------------------------------

if [ ! -d package/lucky ]; then
    git clone --depth 1 \
        https://github.com/gdy666/luci-app-lucky.git \
        package/lucky
fi

# ---------------------------------------------------------
# 2. Argon Theme
# ---------------------------------------------------------

if [ ! -d package/luci-theme-argon ]; then
    git clone --depth 1 \
        https://github.com/jerrykuku/luci-theme-argon.git \
        package/luci-theme-argon
fi

# ---------------------------------------------------------
# 3. DAE official APK signing key
#    DAE itself remains independently installed.
# ---------------------------------------------------------

mkdir -p files/etc/apk/keys

wget -O files/etc/apk/keys/daeuniverse.pem \
    https://openwrt.daeuniverse.org/public-key.pem

if [ ! -s files/etc/apk/keys/daeuniverse.pem ]; then
    echo "ERROR: Failed to download DAE APK public key."
    exit 1
fi

echo "DAE public key installed."

echo "========================================"
echo "DIY Part 1 completed."
echo "========================================"
