#!/bin/sh

# The best way to accomplish this is to build against the netbsd
# "INSTALL" kernel, or "TINY_INSTALL". Hoewever this is very time
# consuming. So, instead I fetch "netbsd-INSTALL.gz" kernel from the
# netbsd installer image, as this already has a root filesystem 


# Get a multiboot compliant netbsd kernel that will run in ram:
wget http://ftp.netbsd.org/pub/NetBSD/NetBSD-6.0/i386/binary/kernel/netbsd-INSTALL.gz

# Make a disk image:
mkdiskimage -z -F -o binary.img 1000 64 32 

# Mount the disk image:
mount -o loop,offset=16384 binary.img /mnt

# Copy in the syslinux bootloader libraries:
rsync -a /usr/lib/syslinux /mnt/

# Create the syslinux configuration file "syslinux.cfg":
cat > /mnt/syslinux/syslinux.cfg <<EOF
UI vesamenu.c32
LABEL NetBsdExperiments
KERNEL mboot.c32
APPEND /netbsd-INSTALL.gz
EOF

# Copy in the kernel:
cp netbsd-INSTALL.gz /mnt

# Unmount the disk image:
umount /mnt

# Install syslinux bootloader:
syslinux -d /syslinux  -t 16384 -i binary.img

# Test boot the disk image. (optional)
kvm -m 1000 binary.img


# (C) 2014 Documentation script by cgraf
