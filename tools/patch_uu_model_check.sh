#!/bin/bash
# Patch uu_utils.o to bypass model check in uu_model_check()
# Replaces function entry at offset 0x40 (start of .text section).
#
# After patch, uu_model_check() always returns 1 regardless of productid/model.
#
# Usage:
#   ./tools/patch_uu_model_check.sh

set -euo pipefail

UU_DIR="$(dirname "$0")/../release/src/router/shared"
OFFSET="0x40"

PLATFORMS=(
    "prebuild-mt7981-ax3000"
    "prebuild-mt7986-ax6000"
)

patch_one() {
    local dir="$1"
    local obj="${UU_DIR}/${dir}/uu_utils.o"

    if [ ! -f "$obj" ]; then
        echo "[SKIP] $obj not found"
        return
    fi

    local cur
    cur=$(xxd -s "$OFFSET" -l 8 -p "$obj" 2>/dev/null)
    if [ "$cur" = "20008052c0035fd6" ]; then
        echo "[OK]   $dir already patched"
        return
    fi

    if [ ! -f "${obj}.bak" ]; then
        cp "$obj" "${obj}.bak"
        echo "[BAK]  $dir -> uu_utils.o.bak"
    fi

    printf '\x20\x00\x80\x52\xc0\x03\x5f\xd6' | dd of="$obj" bs=1 seek="$((OFFSET))" conv=notrunc 2>/dev/null

    echo "[PATCH] $dir -> uu_model_check() now always returns 1"
}

for dir in "${PLATFORMS[@]}"; do
    patch_one "$dir"
done

echo ""
echo "Done. All uu_utils.o prebuilds patched."
