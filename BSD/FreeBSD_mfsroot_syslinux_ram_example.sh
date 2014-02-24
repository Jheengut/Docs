#!/bin/sh

# 2014 (C) Documentation script, cgraf 
# Using syslinux to boot FreeBSD
# This technique makes use of pre made "mfsbsd" images. 
# If you are on FreeBSD you can fetch and `make -C /path/to/mfsbsd'.
# One caveat is that the "mfsroot" filesystem must be smaller than 100MB.
# The mfsbsd page says not to inflate their root filesystem images above 50MB.
# If you wish to use larger mfsroot's then the FreeBSD kernel must be recompiled.


# Freebsd mfsroot with isolinux on a binary-hybrid iso9660 made with xorriso.
# Binary-hybrid isos are useful in that they can be copied to and booted from a USB.

rsync -a /usr/lib/syslinux ISO_root 
cat > ISO_root/syslinux/isolinux.cfg <<EOF
UI menu.c32
LABEL BSD
KERNEL memdisk raw
INITRD /mfsbsd.img 
EOF
wget http://mfsbsd.vx.sk/files/images/9/i386/mfsbsd-9.2-RELEASE-i386.img -O ISO_root/mfsbsd.img 
xorrisofs -r -J    \
-o output.iso            \
-no-emul-boot            \
-boot-info-table         \
-boot-load-size 4        \
-c syslinux/boot.cat     \
-b syslinux/isolinux.bin \
-partition_offset 16     \
-isohybrid-mbr ISO_root/syslinux/isohdpfx.bin \
ISO_root
kvm -m 500 -cdrom output.iso 


# FreeBSD mfsroot with syslinux on a vfat hard disk image.
# `Mkdiskimage' creates, partitions, and formats to vfat in one step.  
mkdiskimage -z -F -4 -o binary.img 1000 64 32 
mount -o loop,offset=16384 binary.img /mnt 
rsync -a /usr/lib/syslinux /mnt/boot 
cat > /mnt/boot/syslinux/syslinux.cfg <<EOF
UI menu.c32
LABEL BSD
KERNEL memdisk raw
INITRD /boot/mfsbsd.img
EOF
wget http://mfsbsd.vx.sk/files/images/9/i386/mfsbsd-9.2-RELEASE-i386.img -O /mnt/boot/mfsbsd.img 
umount /mnt 
syslinux -d /boot -t 16384 -i binary.img 
kvm -m 500 binary.img


# FreeBSD on a partitionless ext4 binary hard disk image with `extlinux'.  
dd if=/dev/zero of=binary.img bs=1M count=1000 
mkfs.ext4 -F binary.img 
mount binary.img /mnt 
rsync -a /usr/lib/syslinux /mnt/boot 
cat > /mnt/boot/syslinux/extlinux.conf <<EOF
UI menu.c32
LABEL BSD
KERNEL memdisk raw
INITRD /boot/mfsbsd.img
EOF
extlinux --install /mnt/boot/syslinux/ 
wget http://mfsbsd.vx.sk/files/images/9/i386/mfsbsd-9.2-RELEASE-i386.img -O /mnt/boot/mfsbsd.img 
umount  /mnt 
kvm -m 500 binary.img

