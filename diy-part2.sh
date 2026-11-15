#!/bin/bash

# =========================================================
# DIY Part 2
# Redmi AX6000 / Official OpenWrt 25.12.6
# First boot customization
# =========================================================

set -euo pipefail

if [ ! -f include/kernel.mk ]; then
    echo "ERROR: Please run this script from OpenWrt source root."
    exit 1
fi

echo "========================================"
echo "DIY Part 2: First boot customization"
echo "========================================"

mkdir -p files/etc/uci-defaults
mkdir -p files/etc/apk/repositories.d

cat > files/etc/uci-defaults/99-custom-settings <<'EOF'
#!/bin/sh

set -eu

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

# Commit settings
uci commit system
uci commit network
uci commit luci

# ---------------------------------------------------------
# 4. Tailscale UDP firewall rule
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
# 5. DAE APK repository
#    DAE is installed and updated independently.
# ---------------------------------------------------------

if [ -s /etc/apk/keys/daeuniverse.pem ] && \
   [ -r /etc/openwrt_release ]; then

    . /etc/openwrt_release

    OPENWRT_SERIES="$(printf '%s' "$DISTRIB_RELEASE" | cut -d. -f1-2)"

    mkdir -p /etc/apk/repositories.d

    cat > /etc/apk/repositories.d/daeuniverse.list <<EOF_DAE
@daeuniverse https://openwrt.daeuniverse.org/${OPENWRT_SERIES}/packages/${DISTRIB_ARCH}/packages.adb
@daeuniverse https://openwrt.daeuniverse.org/${OPENWRT_SERIES}/kmods/${DISTRIB_RELEASE}/${DISTRIB_TARGET}/packages.adb
EOF_DAE

fi

exit 0
EOF

chmod 0755 files/etc/uci-defaults/99-custom-settings

echo "========================================"
echo "DIY Part 2 completed."
echo "========================================"
