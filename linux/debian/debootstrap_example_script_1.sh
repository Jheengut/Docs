#!/bin/sh

# `debootstrap' a debian system onto a superfloppy binary hard drive image 
# and make it bootable with the `extlinux' bootloader.  

# Make a chroot, using debootstrap. The only package we really MUST include
# is a linux kernel. Or of course there will be nothing to boot.
debootstrap \
--include="linux-image-amd64" \
wheezy primarychroot          \
http://ftp.us.debian.org/debian/

# Make a superfloppy binary hard disk image.
# This is just simpler than using partitions.
dd if=/dev/zero of=binary.img bs=1M count=1000 
mkfs.ext4 -F -j binary.img 
mkdir mnt 
mount binary.img mnt

# Copy the contents of the chroot onto the disk image.
cp -r primarychroot/* mnt

# Set a password or you will not be able to log in.
echo "root:live" | chroot mnt chpasswd --md5

# Some symlinks really simplify the bootloader configuration.
cd mnt/boot 
ln -s vmlinuz* vmlinuz 
ln -s initrd.img* initrd.img 
cd ../..


# For ext2|3|4 use the `extlinux' boootloader from the package `syslinux'
extlinux --install mnt/boot

# Create the configuration file "extlinux.conf"
cat > mnt/boot/extlinux.conf << EOF
default linux
timeout 0
prompt 0
label linux
kernel /boot/vmlinuz
append initrd=/boot/initrd.img root=/dev/sda 
EOF

# Unmount everything and test with a virtual machine.
umount mnt 
kvm binary.img

# "debootstrap_example_script.sh"
# (C) Documentation Script, Statix  cgraf 
