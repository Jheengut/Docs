#!/bin/sh

# standalone linux kernel with attached initramfsg.
# These are perfect for live OS, as they by nature, already don't
# rely on a disk.


git clone git://git.buildroot.net/buildroot

cd buildroot

cat > configs/my_defconfig << EOF
BR2_x86_generic=y
BR2_CCACHE=y
BR2_JLEVEL="$(($(grep -c ^processor /proc/cpuinfo)*2))"
BR2_DL_DIR="/home/$USER/.bldroot"
BR2_TOOLCHAIN_BUILDROOT_LARGEFILE=y
BR2_TOOLCHAIN_BUILDROOT_INET_IPV6=y
BR2_TOOLCHAIN_BUILDROOT_WCHAR=y
BR2_TOOLCHAIN_BUILDROOT_CXX=y
BR2_TOOLCHAIN_BUILDROOT_INET_RPC=y
BR2_TOOLCHAIN_BUILDROOT_LOCALE=y
BR2_TOOLCHAIN_BUILDROOT_USE_SSP=y
BR2_ROOTFS_DEVICE_CREATION_DYNAMIC_UDEV=y
BR2_TARGET_GENERIC_GETTY_PORT="tty1" 
BR2_LINUX_KERNEL=y
BR2_LINUX_KERNEL_DEFCONFIG="i386" 
BR2_TARGET_ROOTFS_INITRAMFS=y 
EOF

make my_defconfig

make



