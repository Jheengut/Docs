#!/bin/bash

# (C) 2014 Documentation script, Static, cgraf 

# Make a zip drive geometry based hard disk image using
# `mkdiskimage' and mounting the offsets
# offset is calculated by multiplying 32 * 512

mkdiskimage -z -F -4 -o binary.img 1000 64 32
mount -o loop,offset=16384 binary.img /mnt
mkdir /mnt/boot
cp /usr/lib/syslinux/vesamenu.c32 /mnt/boot
cat > /mnt/boot/syslinux.cfg <<EOF
UI vesamenu.c32
DEFAULT linux
LABEL linux
EOF
umount /mnt
syslinux -d /boot -t 16384 -i binary.img
kvm binary.img
