
#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================"
echo "DIY Part 1: Third-party packages"
echo "========================================"

if [[ ! -f "include/toplevel.mk" ]]; then
    echo "ERROR: OpenWrt source root not found."
    exit 1
fi

# 1. Lucky
echo "[1/3] Cloning Lucky..."

LUCKY_DIR="package/lucky"

rm -rf "${LUCKY_DIR}"

git clone --depth 1 \
    https://github.com/gdy666/luci-app-lucky.git \
    "${LUCKY_DIR}"

echo "===== Lucky repository information ====="
git -C "${LUCKY_DIR}" log -1 --oneline
find "${LUCKY_DIR}" -maxdepth 3 -name Makefile -print

LUCKY_CORE="${LUCKY_DIR}/lucky/Makefile"
LUCKY_LUCI="${LUCKY_DIR}/luci-app-lucky/Makefile"

if [[ ! -f "${LUCKY_CORE}" || ! -f "${LUCKY_LUCI}" ]]; then
    echo "ERROR: Lucky repository structure is unexpected."
    echo "Expected files:"
    echo "  ${LUCKY_CORE}"
    echo "  ${LUCKY_LUCI}"
    echo "Actual Makefiles:"
    find "${LUCKY_DIR}" -maxdepth 4 -name Makefile -print
    exit 1
fi

echo "Lucky core and LuCI Makefiles verified."

# 2. Argon
echo "[2/3] Cloning Argon Theme..."

ARGON_DIR="package/luci-theme-argon"

rm -rf "${ARGON_DIR}"

git clone --depth 1 \
    https://github.com/jerrykuku/luci-theme-argon.git \
    "${ARGON_DIR}"

if [[ ! -f "${ARGON_DIR}/Makefile" ]]; then
    echo "ERROR: Argon Theme Makefile not found."
    find "${ARGON_DIR}" -maxdepth 3 -name Makefile -print
    exit 1
fi

echo "Argon Theme verified."

# 3. DAE APK public key
echo "[3/3] Downloading DAE APK public key..."

DAE_KEY_DIR="files/etc/apk/keys"
DAE_KEY_FILE="${DAE_KEY_DIR}/daeuniverse.pem"

mkdir -p "${DAE_KEY_DIR}"

curl -fL \
    --retry 3 \
    --retry-delay 2 \
    --connect-timeout 20 \
    https://openwrt.daeuniverse.org/public-key.pem \
    -o "${DAE_KEY_FILE}.tmp"

test -s "${DAE_KEY_FILE}.tmp"

mv "${DAE_KEY_FILE}.tmp" "${DAE_KEY_FILE}"

echo "DAE public key installed successfully."

# Final verification
echo "========================================"
echo "DIY Part 1 completed successfully."
echo "========================================"

echo "Lucky:"
ls -l "${LUCKY_CORE}" "${LUCKY_LUCI}"

echo "Argon:"
ls -l "${ARGON_DIR}/Makefile"

echo "DAE key:"
ls -lh "${DAE_KEY_FILE}"
