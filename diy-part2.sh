#!/bin/bash

# =========================================================
# DIY Part 2
# Redmi AX6000 / OpenWrt 25.12.6
#
# First boot customization
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
echo "DIY Part 2: First boot customization"
echo "========================================"

mkdir -p files/etc/uci-defaults
mkdir -p files/etc/apk/repositories.d

# ---------------------------------------------------------
# 1. First boot configuration
# ---------------------------------------------------------

cat > files/etc/uci-defaults/99-custom-settings <<'EOF'
#!/bin/sh

set -eu

echo "========================================"
echo "Redmi AX6000 First Boot Configuration"
echo "========================================"

# ---------------------------------------------------------
# 1. System settings
# ---------------------------------------------------------

uci set system.@system[0].hostname='Redmi-AX6000'
uci set system.@system[0].zonename='Asia/Shanghai'
uci set system.@system[0].timezone='CST-8'

# ---------------------------------------------------------
# 2. LAN address
# ---------------------------------------------------------

uci set network.lan.ipaddr='192.168.8.1'

# ---------------------------------------------------------
# 3. LuCI language and theme
# ---------------------------------------------------------

uci set luci.main.lang='zh_cn'
uci set luci.main.mediaurlbase='/luci-static/argon'

# ---------------------------------------------------------
# 4. Commit UCI settings
# ---------------------------------------------------------

uci commit system
uci commit network
uci commit luci

# ---------------------------------------------------------
# 5. Tailscale UDP firewall
# ---------------------------------------------------------

if ! uci -q get firewall.tailscale_udp >/dev/null 2>&1; then
    uci set firewall.tailscale_udp='rule'
fi

uci set firewall.tailscale_udp.name='Allow-Tailscale-UDP'
uci set firewall.tailscale_udp.src='wan'
uci set firewall.tailscale_udp.proto='udp'
uci set firewall.tailscale_udp.dest_port='41641'
uci set firewall.tailscale_udp.target='ACCEPT'

uci commit firewall

# ---------------------------------------------------------
# 6. DAE APK repository
#
# Official DAE repository for OpenWrt 25.12
# DAE is independently installed and updated.
# ---------------------------------------------------------

DAE_KEY='/etc/apk/keys/daeuniverse.pem'

if [ ! -s "$DAE_KEY" ]; then
    echo "ERROR: DAE signing key not found."
    exit 1
fi

if [ ! -r /etc/openwrt_release ]; then
    echo "ERROR: OpenWrt release information unavailable."
    exit 1
fi

. /etc/openwrt_release

OPENWRT_SERIES="$(printf '%s' "$DISTRIB_RELEASE" | cut -d. -f1-2)"

if [ "$OPENWRT_SERIES" != "25.12" ]; then
    echo "WARNING: Unexpected OpenWrt series: $OPENWRT_SERIES"
    exit 1
fi

if [ -z "${DISTRIB_ARCH:-}" ] || [ -z "${DISTRIB_TARGET:-}" ]; then
    echo "ERROR: OpenWrt architecture information unavailable."
    exit 1
fi

mkdir -p /etc/apk/repositories.d

cat > /etc/apk/repositories.d/daeuniverse.list <<EOF_DAE
@daeuniverse https://openwrt.daeuniverse.org/${OPENWRT_SERIES}/packages/${DISTRIB_ARCH}/packages.adb
@daeuniverse https://openwrt.daeuniverse.org/${OPENWRT_SERIES}/kmods/${DISTRIB_RELEASE}/${DISTRIB_TARGET}/packages.adb
EOF_DAE

echo "DAE APK repository configured."

# ---------------------------------------------------------
# 7. Finish
# ---------------------------------------------------------

echo "========================================"
echo "First boot configuration completed."
echo "========================================"

exit 0

EOF

chmod 0755 files/etc/uci-defaults/99-custom-settings

echo "========================================"
echo "DIY Part 2 completed successfully."
echo "========================================"
