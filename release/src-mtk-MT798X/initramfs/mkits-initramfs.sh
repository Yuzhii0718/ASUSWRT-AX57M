#!/bin/bash
#
# Generate FIT ITS file for initramfs kernel (no ramdisk)
#
# Usage:
#   mkits-initramfs.sh -o output.its -k kernel_image -d dtb_file
#                      [-a load_addr] [-e entry_addr] [-C compression]
#                      [-A arch] [-v version]
#

set -e

usage() {
	echo "Usage: $0 -o output.its -k kernel_image -d dtb_file"
	echo "  -o output.its   Output ITS file"
	echo "  -k kernel.img   Kernel image (already compressed)"
	echo "  -d dtb_file     Device tree blob"
	echo "  -a load_addr    Kernel load address (default: 0x48080000)"
	echo "  -e entry_addr   Kernel entry address (default: same as -a)"
	echo "  -C compression  Compression type (default: none, kernel is pre-compressed)"
	echo "  -A arch          Architecture (default: arm64)"
	echo "  -v version      Version string"
	exit 1
}

OUTPUT=""
KERNEL=""
DTB=""
LOADADDR="0x48080000"
ENTRYADDR=""
COMPRESSION="none"
ARCH="arm64"
VERSION="initramfs"

while [ $# -gt 0 ]; do
	case "$1" in
		-o) OUTPUT="$2"; shift 2 ;;
		-k) KERNEL="$2"; shift 2 ;;
		-d) DTB="$2"; shift 2 ;;
		-a) LOADADDR="$2"; shift 2 ;;
		-e) ENTRYADDR="$2"; shift 2 ;;
		-C) COMPRESSION="$2"; shift 2 ;;
		-A) ARCH="$2"; shift 2 ;;
		-v) VERSION="$2"; shift 2 ;;
		*) usage ;;
	esac
done

[ -z "$OUTPUT" ] && usage
[ -z "$KERNEL" ] && usage
[ -z "$DTB" ] && usage
[ -z "$ENTRYADDR" ] && ENTRYADDR="$LOADADDR"

KERNEL_SIZE=$(stat -c%s "$KERNEL" 2>/dev/null || stat -f%z "$KERNEL")
DTB_SIZE=$(stat -c%s "$DTB" 2>/dev/null || stat -f%z "$DTB")

cat > "$OUTPUT" << EOF
/dts-v1/;

/ {
	description = "${ARCH} initramfs kernel image with DTB";
	#address-cells = <1>;

	images {
		kernel {
			description = "Linux kernel with embedded initramfs";
			data = /incbin/("${KERNEL}");
			type = "kernel";
			arch = "${ARCH}";
			os = "linux";
			compression = "${COMPRESSION}";
			load = <${LOADADDR}>;
			entry = <${ENTRYADDR}>;
			hash {
				algo = "crc32";
			};
		};
		fdt {
			description = "Flattened Device Tree blob";
			data = /incbin/("${DTB}");
			type = "flat_dt";
			arch = "${ARCH}";
			compression = "none";
			hash {
				algo = "crc32";
			};
		};
	};

	configurations {
		default = "config-1";
		config-1 {
			description = "Boot initramfs kernel";
			kernel = "kernel";
			fdt = "fdt";
		};
	};
};
EOF

echo "Generated ITS: $OUTPUT"
echo "  Kernel: $KERNEL ($KERNEL_SIZE bytes)"
echo "  DTB:    $DTB ($DTB_SIZE bytes)"
echo "  Load:   $LOADADDR, Entry: $ENTRYADDR"
