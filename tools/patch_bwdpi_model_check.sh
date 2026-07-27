#!/bin/bash
# Patch libbwdpi.so to bypass model check in dump_dpi_support()
# Replaces function entry at the correct offset for each platform.
#
# After patch, dump_dpi_support() always returns 1 regardless of productid/model.
#
# Usage:
#   ./tools/patch_bwdpi_model_check.sh

set -euo pipefail

BWDIPI_DIR="$(dirname "$0")/../release/src/router/bwdpi_source/asus"

declare -A OFFSETS=(
    ["prebuild-mt7981-ax3000"]="0xf080"
    ["prebuild-mt7986-ax6000"]="0xef90"
)

patch_one() {
    local dir="$1"
    local offset="$2"
    local so="${BWDIPI_DIR}/${dir}/libbwdpi.so"

    if [ ! -f "$so" ]; then
        echo "[SKIP] $so not found"
        return
    fi

    # Check current bytes
    local cur
    cur=$(xxd -s "$offset" -l 8 -p "$so" 2>/dev/null)
    if [ "$cur" = "20008052c0035fd6" ]; then
        echo "[OK]   $dir already patched"
        return
    fi

    # Backup if not exists
    if [ ! -f "${so}.bak" ]; then
        cp "$so" "${so}.bak"
        echo "[BAK]  $dir -> libbwdpi.so.bak"
    fi

    # Apply patch: mov w0, #1; ret
    printf '\x20\x00\x80\x52\xc0\x03\x5f\xd6' | dd of="$so" bs=1 seek="$((offset))" conv=notrunc 2>/dev/null

    echo "[PATCH] $dir -> dump_dpi_support() now always returns 1"
}

for dir in "${!OFFSETS[@]}"; do
    patch_one "$dir" "${OFFSETS[$dir]}"
done

echo ""
echo "Done. All libbwdpi.so prebuilds patched."
