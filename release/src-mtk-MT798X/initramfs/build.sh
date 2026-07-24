#!/bin/bash
#
# ASUS MT798X Initramfs Builder
# Builds a kernel with embedded initramfs (cpio) that can be booted
# via TFTP from U-Boot without writing to NAND flash.
#
# Usage:
#   ./initramfs/build.sh <BUILD_NAME>
#
# Prerequisites:
#   A completed firmware build: make <BUILD_NAME>
#
# Output:
#   image/initramfs-<BUILD_NAME>.bin  (FIT image, kernel+dtb only)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TOPDIR="$(dirname "$SCRIPT_DIR")"

BUILD_NAME="${1:-}"
if [ -z "$BUILD_NAME" ]; then
	echo "Usage: $0 <BUILD_NAME>"
	echo "  e.g. $0 RT-AX57M"
	exit 1
fi

# Determine architecture and platform
# Strategy: try arm64 first (all MT798X are arm64), fall back to arm32
LINUXDIR="$TOPDIR/linux/linux-5.4.x"
PLATFORM="aarch64-musl"

# Check if MUSL64 is set as env var (exported by target.mak during firmware build)
if [ "${MUSL64}" = "y" ]; then
	ARCH="arm64"
	CROSS_COMPILE="aarch64-linux-gnu-"
	DTB_PATH="arch/arm64/boot/dts/mediatek"
	LOADADDR="48080000"
	PLATFORM="aarch64-musl"
elif [ -d "$LINUXDIR/arch/arm64" ] && [ -f "$LINUXDIR/Makefile" ]; then
	# Kernel source has arm64 support → assume arm64 build
	ARCH="arm64"
	CROSS_COMPILE="aarch64-linux-gnu-"
	DTB_PATH="arch/arm64/boot/dts/mediatek"
	LOADADDR="48080000"
	PLATFORM="aarch64-musl"
else
	ARCH="arm"
	CROSS_COMPILE="arm-linux-gnueabi-"
	DTB_PATH="arch/arm/boot/dts"
	LOADADDR="40008000"
	PLATFORM="arm-linux"
fi

# Detect SOC type by looking at which DTB files exist
MT7981=0; MT7986A=0; MT7986B=0; CHEETAH_1GWAN=0
if [ -f "$LINUXDIR/$DTB_PATH/mt7981-${BUILD_NAME}_1GWAN.dtb" ]; then
	MT7981=1; CHEETAH_1GWAN=1
elif [ -f "$LINUXDIR/$DTB_PATH/mt7981-${BUILD_NAME}.dtb" ]; then
	MT7981=1
elif [ -f "$LINUXDIR/$DTB_PATH/mt7986a-${BUILD_NAME}.dtb" ]; then
	MT7986A=1
elif [ -f "$LINUXDIR/$DTB_PATH/mt7986b-${BUILD_NAME}.dtb" ]; then
	MT7986B=1
fi

ENTRYADDR="$LOADADDR"

TARGETDIR="$TOPDIR/router/$PLATFORM/target"
IMAGEDIR="$TOPDIR/image"

# Check prerequisites
if [ ! -d "$TARGETDIR/bin" ] || [ ! -x "$TARGETDIR/bin/busybox" ]; then
	echo "ERROR: Target filesystem not found at $TARGETDIR"
	echo "       Run 'make $BUILD_NAME' first to build firmware."
	exit 1
fi

if [ ! -f "$LINUXDIR/.config" ]; then
	echo "ERROR: Kernel config not found at $LINUXDIR/.config"
	exit 1
fi

# Determine DTB filename
lowercase_B=$(echo "$BUILD_NAME" | tr 'A-Z' 'a-z')
if [ "$MT7981" -gt 0 ]; then
	DTB_SOC="mt7981"
	if [ "$CHEETAH_1GWAN" -gt 0 ]; then
		DTB_FILE="${DTB_SOC}-${BUILD_NAME}_1GWAN.dtb"
	else
		DTB_FILE="${DTB_SOC}-${BUILD_NAME}.dtb"
	fi
elif [ "$MT7986A" -gt 0 ]; then
	DTB_FILE="mt7986a-${BUILD_NAME}.dtb"
elif [ "$MT7986B" -gt 0 ]; then
	DTB_FILE="mt7986b-${BUILD_NAME}.dtb"
else
	echo "ERROR: Unknown MT798X model (MT7981/MT7986 not detected)"
	exit 1
fi

DTB_FULLPATH="$LINUXDIR/$DTB_PATH/$DTB_FILE"
if [ ! -f "$DTB_FULLPATH" ]; then
	echo "WARNING: DTB not found at $DTB_FULLPATH"
	echo "         Trying to find DTB..."
	DTB_FOUND=$(find "$LINUXDIR/$DTB_PATH" -name "${DTB_SOC}-${BUILD_NAME}*.dtb" 2>/dev/null | head -1)
	if [ -z "$DTB_FOUND" ]; then
		DTB_FOUND=$(find "$LINUXDIR/$DTB_PATH" -name "${DTB_SOC}*${BUILD_NAME}*.dtb" 2>/dev/null | head -1)
	fi
	if [ -z "$DTB_FOUND" ]; then
		echo "ERROR: Cannot find DTB for $BUILD_NAME. Build the firmware first."
		exit 1
	fi
	DTB_FILE="$(basename "$DTB_FOUND")"
	DTB_FULLPATH="$DTB_FOUND"
	echo "         Found: $DTB_FULLPATH"
fi

LOWER_B="$lowercase_B"

echo "============================================"
echo "  ASUS MT798X Initramfs Builder"
echo "============================================"
echo "  BUILD_NAME:   $BUILD_NAME"
echo "  ARCH:         $ARCH"
echo "  CROSS_COMPILE: $CROSS_COMPILE"
echo "  LOADADDR:     0x$LOADADDR"
echo "  TARGETDIR:    $TARGETDIR"
echo "  DTB:          $DTB_FULLPATH"
echo "  Output:       $IMAGEDIR/initramfs-${LOWER_B}.bin"
echo "============================================"
echo ""

INITRAMFS_CPIO="$TOPDIR/image/initramfs.cpio"
INITRAMFS_KERNEL="$TOPDIR/image/initramfs-vmlinux"
INITRAMFS_ZIMAGE="$TOPDIR/image/initramfs-zImage.tmp"
INITRAMFS_ITS="$IMAGEDIR/initramfs-${LOWER_B}.its"
INITRAMFS_BIN="$IMAGEDIR/initramfs-${LOWER_B}.bin"

# Step 1: Create initramfs cpio from TARGETDIR
echo "[1/5] Creating initramfs cpio archive..."
cd "$TARGETDIR"

# Use existing init script from initramfs directory
if [ -f "$SCRIPT_DIR/init" ]; then
	cp "$SCRIPT_DIR/init" ./init
	chmod +x ./init
	chmod 755 ./init
fi

# Create cpio archive (skip kernel modules and runtime mountpoints to reduce size)
# -R 0:0 forces all files to uid=0, gid=0.  Without this, files owned by the
# build user (uid 1000) will cause busybox mount() to fail with EPERM because
# the kernel init process sees a non-root-owned filesystem.
find . -not -path './lib/modules/*' \
       -not -path './proc/*' \
       -not -path './sys/*' \
       -not -path './tmp/*' \
       -not -name '.gitkeep' | \
	cpio -o -H newc -R 0:0 2>/dev/null > "$INITRAMFS_CPIO"
CPIO_SIZE=$(stat -c%s "$INITRAMFS_CPIO" 2>/dev/null || stat -f%z "$INITRAMFS_CPIO")
echo "  Main cpio: $CPIO_SIZE bytes"

# Prepend essential device nodes to the cpio.
# In the initramfs boot path the kernel skips prepare_namespace() (because
# /init exists), so devtmpfs is NOT auto-mounted.  Without /dev/console the
# kernel cannot open init's stdin/stdout/stderr, which makes musl-linked
# busybox segfault on startup.
# We inject /dev/console (c 5:1) and /dev/null (c 1:3) by generating
# raw cpio-newc entries — no root/mknod required.
echo "  Prepending /dev/console and /dev/null device nodes..."
python3 -c '
import struct, sys

HDR_SIZE = 110  # cpio newc header is exactly 110 bytes

def cpio_newc_entry(name, mode, filesize=0, uid=0, gid=0, nlink=1,
                    devmajor=0, devminor=0, rdevmajor=0, rdevminor=0):
    namesize = len(name) + 1
    hdr = struct.pack("=6s" + "8s"*13,
        b"070701",
        b"%08x" % 0,                            # ino
        b"%08x" % mode,
        b"%08x" % uid,
        b"%08x" % gid,
        b"%08x" % nlink,
        b"%08x" % 0,                            # mtime
        b"%08x" % filesize,
        b"%08x" % devmajor,
        b"%08x" % devminor,
        b"%08x" % rdevmajor,
        b"%08x" % rdevminor,
        b"%08x" % namesize,
        b"00000000",                            # checksum
    )
    namebytes = name.encode("ascii") + b"\x00"
    # cpio newc requires the ENTIRE entry (header + name + pad) to be
    # 4-byte aligned.  The header alone is 110 bytes (110%%4==2), so
    # the padding must compensate.
    raw_total = HDR_SIZE + len(namebytes)
    pad = (4 - (raw_total % 4)) % 4
    return hdr + namebytes + b"\x00" * pad

S_IFDIR  = 0o040000
S_IFCHR  = 0o020000
entries = [
    cpio_newc_entry("dev",          S_IFDIR | 0o755),
    cpio_newc_entry("dev/console",  S_IFCHR | 0o600, rdevmajor=5, rdevminor=1),
    cpio_newc_entry("dev/null",     S_IFCHR | 0o666, rdevmajor=1, rdevminor=3),
    cpio_newc_entry("TRAILER!!!",   0),
]
sys.stdout.buffer.write(b"".join(entries))
' > "${INITRAMFS_CPIO}.devnodes"

# Concatenate: devnodes cpio + main cpio (both end with TRAILER!!!, kernel
# processes concatenated cpio archives sequentially).
cat "${INITRAMFS_CPIO}.devnodes" "$INITRAMFS_CPIO" > "${INITRAMFS_CPIO}.tmp"
mv "${INITRAMFS_CPIO}.tmp" "$INITRAMFS_CPIO"
rm -f "${INITRAMFS_CPIO}.devnodes"
CPIO_SIZE=$(stat -c%s "$INITRAMFS_CPIO" 2>/dev/null || stat -f%z "$INITRAMFS_CPIO")
echo "  Final cpio (with devnodes): $CPIO_SIZE bytes"

cd "$TOPDIR"

# Step 2: Configure kernel with initramfs
echo "[2/5] Configuring kernel with embedded initramfs..."
cp "$LINUXDIR/.config" "$LINUXDIR/.config.initramfs"

# Remove any existing CONFIG_INITRAMFS_SOURCE
sed -i '/^CONFIG_INITRAMFS_SOURCE=/d' "$LINUXDIR/.config.initramfs"

# Add initramfs source
echo "CONFIG_INITRAMFS_SOURCE=\"$INITRAMFS_CPIO\"" >> "$LINUXDIR/.config.initramfs"

# Ensure initramfs support is enabled
for cfg in \
	"CONFIG_BLK_DEV_INITRD=y" \
	"CONFIG_INITRAMFS_FORCE=y" \
	"CONFIG_INITRAMFS_ROOT_UID=0" \
	"CONFIG_INITRAMFS_ROOT_GID=0" \
	"CONFIG_RD_GZIP=y" \
; do
	if ! grep -q "^${cfg%%=*}=" "$LINUXDIR/.config.initramfs"; then
		echo "$cfg" >> "$LINUXDIR/.config.initramfs"
	fi
done

# Make olddefconfig to resolve any conflicts
make -C "$LINUXDIR" ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" \
	KCONFIG_CONFIG=.config.initramfs olddefconfig 2>/dev/null

# Verify initramfs config was applied
if ! grep -q 'CONFIG_INITRAMFS_SOURCE="'"$INITRAMFS_CPIO"'"' "$LINUXDIR/.config.initramfs"; then
	echo "ERROR: Failed to set CONFIG_INITRAMFS_SOURCE in kernel config"
	exit 1
fi
echo "  CONFIG_INITRAMFS_SOURCE set successfully"

# Step 3: Build initramfs kernel
echo "[3/5] Building initramfs kernel (vmlinux only, no modules)..."
make -C "$LINUXDIR" ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" \
	KCONFIG_CONFIG=.config.initramfs -j$(nproc) vmlinux
echo "  vmlinux built successfully"

# Step 4: Extract and compress kernel binary
echo "[4/5] Creating compressed kernel image..."
${CROSS_COMPILE}objcopy -O binary -R .note -R .comment -S \
	"$LINUXDIR/vmlinux" "$INITRAMFS_KERNEL"
KERNEL_SIZE=$(stat -c%s "$INITRAMFS_KERNEL" 2>/dev/null || stat -f%z "$INITRAMFS_KERNEL")
echo "  vmlinux binary: $KERNEL_SIZE bytes"

# Compress with lzma
lzma -z -c -9 "$INITRAMFS_KERNEL" > "$INITRAMFS_ZIMAGE"
ZIMAGE_SIZE=$(stat -c%s "$INITRAMFS_ZIMAGE" 2>/dev/null || stat -f%z "$INITRAMFS_ZIMAGE")
echo "  Compressed (lzma): $ZIMAGE_SIZE bytes"

# Step 5: Generate FIT image (kernel+dtb only, no ramdisk)
echo "[5/5] Generating FIT image..."
"$SCRIPT_DIR/mkits-initramfs.sh" \
	-o "$INITRAMFS_ITS" \
	-k "$INITRAMFS_ZIMAGE" \
	-d "$DTB_FULLPATH" \
	-C lzma \
	-a "0x$LOADADDR" \
	-e "0x$ENTRYADDR" \
	-A "$ARCH" \
	-v "initramfs"

# Use mkimage from the build environment
if command -v mkimage &>/dev/null; then
	MKIMAGE="mkimage"
elif [ -f "$TOPDIR/uboot-mtk/tools/mkimage" ]; then
	MKIMAGE="$TOPDIR/uboot-mtk/tools/mkimage"
elif [ -f "$TOPDIR/asustools/mkimage" ]; then
	MKIMAGE="$TOPDIR/asustools/mkimage"
else
	echo "ERROR: mkimage not found. Build uboot-mtk first or install u-boot-tools."
	exit 1
fi

"$MKIMAGE" -f "$INITRAMFS_ITS" "$INITRAMFS_BIN"
ITB_SIZE=$(stat -c%s "$INITRAMFS_BIN" 2>/dev/null || stat -f%z "$INITRAMFS_BIN")

echo ""
echo "============================================"
echo "  INITRAMFS BUILD COMPLETE"
echo "============================================"
echo "  Output:  $INITRAMFS_BIN"
echo "  Size:    $ITB_SIZE bytes ($(( ITB_SIZE / 1024 )) KB)"
echo ""
echo "  To use in U-Boot:"
echo "    MT7981> setenv ipaddr 192.168.1.1"
echo "    MT7981> setenv serverip 192.168.1.100"
echo "    MT7981> tftpboot 0x46000000 initramfs-${LOWER_B}.bin"
echo "    MT7981> bootm 0x46000000"
echo ""
echo "  This boots Linux entirely from RAM - no NAND writes!"
echo "============================================"
