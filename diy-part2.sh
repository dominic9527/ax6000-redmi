
#!/bin/bash
# DIY part 2: OpenWrt 25.12.6
set -euo pipefail

[ -f include/kernel.mk ] || {
    echo "ERROR: run from OpenWrt source root."
    exit 1
}

mkdir -p files/etc/uci-defaults files/etc/apk/repositories.d

cat > files/etc/uci-defaults/99-custom-settings <<'EOF'
#!/bin/sh
set -eu

# 1. 系统基本设置
uci set system.@system[0].hostname='Redmi-AX6000'
uci set system.@system[0].zonename='Asia/Shanghai'
uci set system.@system[0].timezone='CST-8'

# 2. LAN 地址
uci set network.lan.ipaddr='192.168.8.1'

# 3. LuCI 中文界面及 Argon 主题
uci set luci.main.lang='zh_cn'
uci set luci.main.mediaurlbase='/luci-static/argon'

uci commit system
uci commit network
uci commit luci

# 4. Tailscale UDP 端口
uci -q get firewall.tailscale_udp >/dev/null 2>&1 || \
    uci set firewall.tailscale_udp='rule'

uci set firewall.tailscale_udp.name='Allow-Tailscale-UDP'
uci set firewall.tailscale_udp.src='wan'
uci set firewall.tailscale_udp.proto='udp'
uci set firewall.tailscale_udp.dest_port='41641'
uci set firewall.tailscale_udp.target='ACCEPT'
uci commit firewall

# 5. DAE 官方 APK 软件源
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

echo "DIY part 2 complete."
