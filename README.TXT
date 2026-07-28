The GPL source is created for ASUS wireless router related products. Please visit the
ASUS support site (http://support.asus.com) to get the latest GPL tarball.


Mediatek Filogic MT79xx SoC Models
===================================

    Supported models:

        MT7981 (Filogic 820):  CHEETAH, RT-AX57M, RT-AX52
        MT7986 (Filogic 830):  PANTHERA, PANTHERB,TUF-AX4200, TUF-AX6000, RT-AX59U, 


1. Prepare Environment (Ubuntu 20.04+)

    Install required packages:

        sudo apt install libncurses5 libncurses5-dev m4 bison gawk flex \
          gengetopt git zlib1g-dev autoconf autopoint libtool-bin shtool autogen \
          mtd-utils intltool sharutils texinfo dos2unix xsltproc \
          u-boot-tools device-tree-compiler qemu gperf liblzo2-dev uuid-dev \
          build-essential lzma-dev liblzma-dev lzma binutils-dev patch cmake \
          libglib2.0-dev gtk-doc-tools libssl-dev libyaml-dev python3


2. Install Toolchain

    Extract the toolchain to /opt:

        sudo tar xvf tools/openwrt-sdk2102-gcc840_musl-1.1.24.aarch64.tar.bz2 -C /opt/

    If your PC is 32-bit or Ubuntu 16, use tools/openwrt-gcc840_musl-1.1.24.aarch64-U16-32bit.tar.bz2 instead.

    Create a symlink for ASUS internal build path (required by some components):

        sudo mkdir -p /opt/ASUS/toolchains
        sudo ln -sf /opt/openwrt-gcc840_musl.aarch64 /opt/ASUS/toolchains/openwrt-gcc840_musl.aarch64

    Set STAGING_DIR if you want to build small utilities outside the asuswrt box:

        export STAGING_DIR=/opt/openwrt-gcc840_musl.aarch64


3. Build Firmware

    cd release/src-mtk-MT798X
    make RT-AX57M

    Other models:
        make CHEETAH                 # MT7981 reference board
        make PANTHERA                # MT7986A reference board
        make PANTHERB                # MT7986B reference board
        make RT-AX52                 # MT7981
        make RT-AX57M                # MT7981
        make TUF-AX4200              # MT7986
        make TUF-AX6000              # MT7986
        make RT-AX59U                # MT7986

    Build a specific package (e.g. httpd):
        make mk-httpd
