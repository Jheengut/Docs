#!/bin/sh

# 2014 (C) Documentation script, Statix, cgraf 
# Create a simple Freebsd installation on a binary hard disk image
# formatted to UFS.

# Make an arbitrarily sized disk image.
dd if=/dev/zero of=binary.img bs=1M count=1000

# Attach a memory disk to the image created above.
mdconfig -a -t vnode -f binary.img -u 0

# Install the bootloader.
bsdlabel -w -B md0 auto

# Format the hard disk image to UFS.
newfs -m 0 md0a

# Create a mount point.
mkdir mnt

# Mount the abstracted bainry hard disk image.
mount /dev/md0a mnt

# Get a FreeBSD kernel.
fetch ftp://ftp.freebsd.org/pub/FreeBSD/snapshots/i386/i386/9.2-STABLE/kernel.txz

# Get the FreeBSD base, which contains all of the programs, etc.
fetch ftp://ftp.freebsd.org/pub/FreeBSD/snapshots/i386/i386/9.2-STABLE/base.txz

# Un-archive the base onto the binary hard disk image.
tar -xf base.txz -C mnt

# Un-archive the kernel onto the binary hard disk image.
tar -xf kernel.txz -C mnt

# Create an "fstab" configuration file.
cat > mnt/etc/fstab <<EOF
/dev/ada0a   /   ufs   rw   0   0
EOF

# Chroot into the hard disk image base install and set a password. (optional)
chroot mnt passwd

# Unmount the hard disk image.
umount mnt

# Unattach the `mdconfig' memory disk
mdconfig -d -u 0

# Test boot the final image.
kvm -m 1000 binary.img
